#include "TextureDictionaryParserPSP.h"
#include <PS2Formats.h>

namespace ShatteredMemories
{

using namespace Consolgames;

TextureDictionaryParserPSP::TextureDictionaryParserPSP()
	: TextureDictionaryParser()
	, m_stream(NULL)
	, m_streamSize(0) 
	, m_position(0) 
	, m_currentItemSize(0)
{
}

bool TextureDictionaryParserPSP::fetch()
{
	m_stream->setByteOrder(Stream::orderLittleEndian);

	const uint32 pos = m_stream->position(); 

	m_stream->skip(0x10);

	const uint32 size = m_stream->readUInt32();

	if (size == 0)
	{
		return false;
	}

	m_stream->skip(0x14);

	m_currentMetaInfo.width = m_stream->readUInt16();
	m_currentMetaInfo.height = m_stream->readUInt16();
	m_currentMetaInfo.bitsPerPixel = m_stream->readUInt8();
	m_currentMetaInfo.mipmapCount = m_stream->readUInt8();
	const uint8 textureFormat = m_stream->readUInt8();
	const uint8 paletteFormat = m_stream->readUInt8();

	if (m_currentMetaInfo.mipmapCount != 1)
	{
		DLOG << "WARNING: Unexpected mipmap count!";
	}

	m_stream->skip(0x60);

	char name[0x41] = {};
	m_stream->read(name, 0x40);
	m_currentMetaInfo.name = name;


	int paletteSize = 0;
	if (m_currentMetaInfo.bitsPerPixel == 4)
	{
		m_currentMetaInfo.textureFormat = PS2Formats::imageFormatIndexed4;
		m_currentMetaInfo.paletteFormat = PS2Formats::paletteFormatRGBA;
		paletteSize = 0x40;
	}
	else if (m_currentMetaInfo.bitsPerPixel == 8)
	{
		m_currentMetaInfo.textureFormat = PS2Formats::imageFormatIndexed8;
		m_currentMetaInfo.paletteFormat = PS2Formats::paletteFormatRGBA;
		paletteSize = 0x400;
	}
	else if (m_currentMetaInfo.bitsPerPixel == 16)
	{
		m_currentMetaInfo.textureFormat = PS2Formats::imageFormatRGBA16;
		m_currentMetaInfo.paletteFormat = PS2Formats::paletteFormatNone;
		paletteSize = 0;
	}
	else
	{
		m_currentMetaInfo.textureFormat = PS2Formats::imageFormatRGBA;
		m_currentMetaInfo.paletteFormat = PS2Formats::paletteFormatNone;
		paletteSize = 0;
	}

	m_currentMetaInfo.rasterPosition = m_stream->position() + paletteSize;
	m_currentMetaInfo.rasterSize = PS2Formats::encodedRasterSize(static_cast<PS2Formats::ImageFormat>(m_currentMetaInfo.textureFormat), m_currentMetaInfo.width, m_currentMetaInfo.height);

	if (m_currentMetaInfo.bitsPerPixel <= 8)
	{
		m_currentMetaInfo.palettePosition = m_stream->position();
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
		const uint32 expectedRasterSize = size - paletteSize - 0xC4;
		if (m_currentMetaInfo.rasterSize != expectedRasterSize)
		{
			DLOG << "WARNING: Unexpected raster size!";
		}
	}

	m_stream->seek(pos + size + 0x0C, Stream::seekSet);

	return true;
}

bool TextureDictionaryParserPSP::atEnd() const 
{
	return m_stream->atEnd();
}

const TextureDictionaryParser::TextureMetaInfo& TextureDictionaryParserPSP::metaInfo() const 
{
	return m_currentMetaInfo;
}

bool TextureDictionaryParserPSP::open(Stream* stream)
{
	m_stream = stream;
	return true;
}

bool TextureDictionaryParserPSP::initSegment()
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

const char* TextureDictionaryParserPSP::textureFormatToString(int format) const
{
	return PS2Formats::imageFormatToString(static_cast<PS2Formats::ImageFormat>(format));
}

const char* TextureDictionaryParserPSP::paletteFormatToString(int format) const
{
	return PS2Formats::paletteFormatToString(static_cast<PS2Formats::PaletteFormat>(format));
}

}
