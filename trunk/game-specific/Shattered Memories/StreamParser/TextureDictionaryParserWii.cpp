#include "TextureDictionaryParserWii.h"
#include <WiiFormats.h>

namespace ShatteredMemories
{

using namespace Consolgames;

TextureDictionaryParserWii::TextureDictionaryParserWii()
	: TextureDictionaryParser()
	, m_stream(NULL)
	, m_streamSize(0) 
	, m_position(0) 
	, m_currentItemSize(0)
{
}

// http://code.google.com/p/ctoolswii/source/browse/trunk/ImageTool/ImageDataFormat.cs

bool TextureDictionaryParserWii::fetch()
{
	m_stream->setByteOrder(Stream::orderLittleEndian);

	const uint32 pos = m_stream->position(); 

	const uint32 unk1 = m_stream->readUInt32();
	const uint32 unk2 = m_stream->readUInt32();
	const uint32 unk5 = m_stream->readUInt32();
	const uint32 unk6 = m_stream->readUInt32();
	const uint32 dataSize = m_stream->readUInt32();
	const uint32 unk8 = m_stream->readUInt32();

	if (dataSize == 0)
	{
		return false;
	}

	const uint32 unk9 = m_stream->readUInt32();
	const uint32 unk10 = m_stream->readUInt32();
	const uint32 unk11 = m_stream->readUInt32();
	const uint32 unk12 = m_stream->readUInt32();
	const uint32 unk13 = m_stream->readUInt32();
	const uint32 unk14 = m_stream->readUInt32();
	const uint32 unk15 = m_stream->readUInt32();
	const uint32 unk16 = m_stream->readUInt32();
	const uint32 unk17 = m_stream->readUInt32();

	m_stream->setByteOrder(Stream::orderBigEndian);

	char name[0x41] = {};
	m_stream->read(name, 0x40);
	m_currentMetaInfo.name = name;

	//DLOG << HEX << "Texture, position: " << m_stream->position() << ", name: " << name; 

	const uint32 imageSize = m_stream->readUInt32();

	m_currentMetaInfo.width = m_stream->readUInt16();
	m_currentMetaInfo.height = m_stream->readUInt16();
	m_currentMetaInfo.bitsPerPixel = m_stream->readUInt8();
	m_currentMetaInfo.mipmapCount = m_stream->readUInt8();
	m_currentMetaInfo.textureFormat = m_stream->readUInt8();
	m_currentMetaInfo.paletteFormat = static_cast<char>(m_stream->readUInt8());

	const uint32 unk18 = m_stream->readUInt32();

	m_currentMetaInfo.palettePosition = 0;
	m_currentMetaInfo.paletteSize = 0;

	if (m_currentMetaInfo.paletteFormat != WiiFormats::paletteFormatNone)
	{
		m_currentMetaInfo.palettePosition = m_stream->position();
		m_currentMetaInfo.paletteSize = (1 << m_currentMetaInfo.bitsPerPixel) * 2;
		m_stream->skip(m_currentMetaInfo.paletteSize);
	}

	const int metaInfoSize = 0x84;
	const int dataSizeLeft = dataSize - metaInfoSize - m_currentMetaInfo.paletteSize;

	if (m_currentMetaInfo.width == 1 && m_currentMetaInfo.height == 1)
	{
		// Fake texture
		m_stream->readUInt32();
		m_currentMetaInfo.rasterSize = 0;
		m_currentMetaInfo.rasterPosition = 0;
	}
	else
	{
		m_currentMetaInfo.rasterSize = m_stream->readUInt32();
		m_currentMetaInfo.rasterPosition = m_stream->position();

		if (m_currentMetaInfo.rasterSize != dataSizeLeft)
		{
			DLOG << "WARNING: Unexpected raster size!";
		}
	}

	m_stream->skip(dataSizeLeft);

	return true;
}

bool TextureDictionaryParserWii::atEnd() const 
{
	return m_stream->atEnd();
}

const TextureDictionaryParserWii::TextureMetaInfo& TextureDictionaryParserWii::metaInfo() const 
{
	return m_currentMetaInfo;
}

bool TextureDictionaryParserWii::open(Stream* stream)
{
	m_stream = stream;
	return true;
}

bool TextureDictionaryParserWii::initSegment()
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

const char* TextureDictionaryParserWii::textureFormatToString(int format) const 
{
	return WiiFormats::imageFormatToString(static_cast<WiiFormats::ImageFormat>(format));
}

const char* TextureDictionaryParserWii::paletteFormatToString(int format) const 
{
	return WiiFormats::paletteFormatToString(static_cast<WiiFormats::PaletteFormat>(format));
}

}
