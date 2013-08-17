#include "TextureDictionaryParserPS2.h"
#include <PS2Formats.h>

namespace ShatteredMemories
{

using namespace Consolgames;

TextureDictionaryParserPS2::TextureDictionaryParserPS2()
	: TextureDictionaryParser()
	, m_stream(NULL)
	, m_streamSize(0) 
	, m_position(0) 
	, m_currentItemSize(0)
{
}

bool TextureDictionaryParserPS2::fetch()
{
	m_stream->setByteOrder(Stream::orderLittleEndian);

	const uint32 pos = m_stream->position(); 

	const uint32 unk1 = m_stream->readUInt32();
	const uint32 unk2 = m_stream->readUInt32();
	const uint32 unk5 = m_stream->readUInt32();
	const uint32 unk6 = m_stream->readUInt32();
	const uint32 size = m_stream->readUInt32();
	const uint32 unk8 = m_stream->readUInt32();

	if (size == 0)
	{
		return false;
	}

	const uint32 unk9 = m_stream->readUInt32();
	const uint32 unk10 = m_stream->readUInt32();
	const uint32 unk11 = m_stream->readUInt32();
	const uint32 ps2Signature = m_stream->readUInt32();

	if (ps2Signature != 0x325350)
	{
		DLOG << "Not a PS2";
		return false;
	}

	const uint32 unk13 = m_stream->readUInt32();
	const uint32 unk14 = m_stream->readUInt32();
	const uint32 stringLen = m_stream->readUInt32();
	const uint32 unk16 = m_stream->readUInt32();

	char name[0x41] = {};
	m_stream->read(name, stringLen);
	m_currentMetaInfo.name = name;

	//DLOG << HEX << "Texture, position: " << m_stream->position() << ", name: " << name; 

	m_stream->skip(0x28);

	m_currentMetaInfo.width = m_stream->readUInt32();
	m_currentMetaInfo.height = m_stream->readUInt32();
	m_currentMetaInfo.bitsPerPixel = m_stream->readUInt32();
	m_currentMetaInfo.mipmapCount = 1;
	const uint32 unk17 = m_stream->readUInt32();

	int paletteTotalSize = 0;
	if (m_currentMetaInfo.bitsPerPixel == 4)
	{
		m_currentMetaInfo.textureFormat = PS2Formats::imageFormatIndexed4;
		m_currentMetaInfo.paletteFormat = PS2Formats::paletteFormatRGBA;
		paletteTotalSize = 0x60 + 0x50;
	}
	else if (m_currentMetaInfo.bitsPerPixel == 8)
	{
		m_currentMetaInfo.textureFormat = PS2Formats::imageFormatIndexed8;
		m_currentMetaInfo.paletteFormat = PS2Formats::paletteFormatRGBA;
		paletteTotalSize = 0x400 + 0x50;
	}
	else
	{
		m_currentMetaInfo.textureFormat = PS2Formats::imageFormatRGBA;
		m_currentMetaInfo.paletteFormat = PS2Formats::paletteFormatNone;
		paletteTotalSize = 0;
	}

	m_currentMetaInfo.rasterPosition = m_stream->position() + ((unk17 & 0xFF0000) == 0 ? 0x40 - 4 : 0x90 - 4);
	m_currentMetaInfo.rasterSize = PS2Formats::encodedRasterSize(static_cast<PS2Formats::ImageFormat>(m_currentMetaInfo.textureFormat), m_currentMetaInfo.width, m_currentMetaInfo.height);

	if (m_currentMetaInfo.bitsPerPixel <= 8)
	{
		m_currentMetaInfo.palettePosition = m_currentMetaInfo.rasterPosition + m_currentMetaInfo.rasterSize + 0x50;
		m_currentMetaInfo.paletteSize = (1 << m_currentMetaInfo.bitsPerPixel) * 4;
	}
	else
	{
		m_currentMetaInfo.palettePosition = 0;
		m_currentMetaInfo.paletteSize = 0;
	}

	if (m_currentMetaInfo.width == 1 && m_currentMetaInfo.height == 1)
	{
		// Fake texture
		m_currentMetaInfo.rasterSize = 0;
		m_currentMetaInfo.rasterPosition = 0;
		m_currentMetaInfo.paletteSize = 0;
		m_currentMetaInfo.palettePosition = 0;
	}
	else
	{
		const uint32 expectedRasterSize = size - paletteTotalSize - stringLen - ((unk17 & 0xFF0000) == 0 ? 0xB0 : 0x100);
		if (m_currentMetaInfo.rasterSize != expectedRasterSize)
		{
			DLOG << "WARNING: Unexpected raster size!";
		}
	}

	m_stream->seek(pos + size + 0x0C, Stream::seekSet);

	return true;
}

bool TextureDictionaryParserPS2::atEnd() const 
{
	return m_stream->atEnd();
}

const TextureDictionaryParserPS2::TextureMetaInfo& TextureDictionaryParserPS2::metaInfo() const 
{
	return m_currentMetaInfo;
}

bool TextureDictionaryParserPS2::open(Stream* stream)
{
	m_stream = stream;
	return true;
}

bool TextureDictionaryParserPS2::initSegment()
{
	m_stream->setByteOrder(Stream::orderLittleEndian);
	
	const int signature = m_stream->readUInt32();
	if (signature != 0x16)
	{
		return false;
	}
	m_streamSize = m_stream->readUInt32();

	const uint32 unk1 = m_stream->readUInt32();
	const uint32 unk2 = m_stream->readUInt32();

	return true;
}

const char* TextureDictionaryParserPS2::textureFormatToString(int format) const
{
	return PS2Formats::imageFormatToString(static_cast<PS2Formats::ImageFormat>(format));
}

const char* TextureDictionaryParserPS2::paletteFormatToString(int format) const
{
	return PS2Formats::paletteFormatToString(static_cast<PS2Formats::PaletteFormat>(format));
}

}
