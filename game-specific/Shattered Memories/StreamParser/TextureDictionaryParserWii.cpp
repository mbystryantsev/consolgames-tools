#include "TextureDictionaryParserWii.h"
#include <Streams/FileStream.h>
#ifdef _DEBUG
#include <iostream>
#include <iomanip>
#endif

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

bool TextureDictionaryParserWii::fetch()
{
	m_stream->setByteOrder(Stream::orderLittleEndian);

	const uint32 pos = m_stream->position(); 

	const uint32 unk1 = m_stream->readUInt32();
	const uint32 unk2 = m_stream->readUInt32();
	const uint32 unk5 = m_stream->readUInt32();
	const uint32 unk6 = m_stream->readUInt32();
	const uint32 unk7 = m_stream->readUInt32();
	const uint32 unk8 = m_stream->readUInt32();

	if (unk7 == 0)
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
	m_currentMetaInfo.format = static_cast<TextureFormat>(m_stream->readUInt8());
	/*m_currentMetaInfo.clutType = */m_stream->readUInt8();
	const uint32 unk18 = m_stream->readUInt32();
	
	// skip clut
	const uint32 rasterSize = m_stream->readUInt32();
	m_currentMetaInfo.rasterPosition = m_stream->position();
	m_currentMetaInfo.rasterSize = unk7 - 0x84;//rasterSize;

#if 0
	if (m_currentMetaInfo.name == "PR_ME_UI_BoxSides_paintings")
	{
		m_currentMetaInfo.rasterSize *= 2;
		m_currentMetaInfo.rasterSize += 0x90;
	}

	// 45E9D563
	if (m_currentMetaInfo.name == "EN_IT_PL_game_PSY2of2" && m_stream->position() == 0x13758)
	{
		m_currentMetaInfo.rasterSize = 0x2D570;
	}
	if (m_currentMetaInfo.name == "EN_IT_PL_game_PSY1of2" && m_stream->position() == 0x2521D8)
	{
		m_currentMetaInfo.rasterSize = 0x2FE40;
	}

	// CB3596FE
	if (m_currentMetaInfo.name == "EN_SC_CL_small_PSY_4of4" && m_stream->position() == 0x1A8)
	{
		m_currentMetaInfo.rasterSize = 0x2AD80;
	}
	if (m_currentMetaInfo.name == "EN_SC_CL_DeskBook_PSY1of4" && m_stream->position() == 0xD52F8)
	{
		m_currentMetaInfo.rasterSize = 0x3A8D0;
	}
#endif


	m_stream->seek(m_currentMetaInfo.rasterSize, Stream::seekCur);

#if 0 && defined(_DEBUG)
	std::cout << "Texture: " << m_currentMetaInfo.name << std::endl;
	std::cout << std::hex << std::setfill('0') << std::setw(8)
		<< "05-08: " << unk5  << ' ' << unk6  << ' ' << unk7  << ' ' << unk8 << std::endl		
		<< "09-12: " << unk9  << ' ' << unk10 << ' ' << unk11 << ' ' << unk12 << std::endl
		<< "13-16: " << unk13 << ' ' << unk14 << ' ' << unk15 << ' ' << unk16 << std::endl
		<< "17-18: " << unk17 << ' ' << unk18 << std::endl;
#endif

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
// 	const u32 unk3 = m_stream->read32();
// 	const u32 unk4 = m_stream->read32();

// 	std::cout << std::hex << std::setfill('0') << std::setw(8)
// 		<< "01-04: " << unk1  << ' ' << unk2  << ' ' << unk3  << ' ' << unk4 << std::endl;

	return true;
}

// TextureDictionaryParserWii::TextureMetaInfo TextureDictionaryParserWii::readMetaInfo()
// {
// 	m_stream->setByteOrder(Stream::orderBigEndian);
// 
// 
// 	return TextureMetaInfo();
// }

}


/*

#include "TextureDictionaryParserWii.h"
#include <string>
#include <algorithm>

namespace ShatteredMemories
{

using namespace Consolgames;

static const u32 s_signature = 0x0016;

TextureDictionaryParserWii::TextureDictionaryParserWii()
	: TextureDictionaryParser()
	, m_stream(NULL)
{
}


static std::string readString(Stream* stream)
{
    int length = stream->read32();
	std::string result(length, '\0');
	VERIFY(stream->read(&result[0], length) == length);

    return result;
}

bool TextureDictionaryParserWii::open(Stream *stream)
{
	ASSERT(stream->byteOrder() == Stream::orderBigEndian);

    m_position = stream->tell();
//     int id = m_stream->read32();
//     stream->seek(offset, CG_SEEK_SET);
//     if(id != 0x0016 && id != 0x0716)
//     {
//         return false;
//     }
// 
//     state = STATE_WII_NONE;
//     opened = true;
//     in_stream = false;
    return true;
}


bool TextureDictionaryParserWii::open(const std::wstring& filename)
{
	m_fileStream.reset(new FileStream(filename, Stream::modeRead));
	m_fileStream->setByteOrder(Stream::orderBigEndian);
	return open(m_fileStream.get());
}



bool TextureDictionaryParserWii::parse()
{
    if (m_stream == NULL)
	{
		return false;
	}

	const u32 signature = m_stream->read32();
	if (signature != s_signature)
	{
		return false;
	}
	
	const u32 size = m_stream->read32();
	const u32 flags = m_stream->read32();
	const u32 unknown = m_stream->read32();

	if (m_stream->eof())
	{
		return false;
	}
	
	readHeader();
          
	if (m_header.clutType == Clut16)
	{
		//dic_size -= stream->read(clut, 32);
	}
	else if (m_header.clutType == Clut256)
	{
		//dic_size -= stream->read(clut, sizeof(clut));
	}
//     dic_size -= stream->read(&image_size, 4);
//     image_size = endian32(image_size);
// 	dic_size -= image_size;

	return true;
}

bool TextureDictionaryParserWii::readHeader()
{

}
// 
// int TextureDictionaryParserWii::getImageName(char* str)
// {
//     if(!image_occurred) return -1;
//     strcpy(str, tex_header.name);
//     return strlen(str);
// }
// 
// int TextureDictionaryParserWii::getImageData(void *buf, size_t size)
// {
//     if(!image_occurred) return -1;
//     __int64 pos = stream->tell();
//     int readed = stream->read(buf, std::min(size, image_size));
//     stream->seek(pos, CG_SEEK_SET);
//     return readed;
// }
// 
// int TextureDictionaryParserWii::setImageData(void *buf, size_t size)
// {
//     if(!image_occurred) return -1;
//     __int64 pos = stream->tell();
//     int writed = stream->write(buf, std::min(size, image_size));
//     stream->seek(pos, CG_SEEK_SET);
//     return writed;
// }
// 
// int  TextureDictionaryParserWii::getImageWidth()
// {
//     if(!image_occurred) return -1;
//     return endian16(tex_header.width);
// }
// 
// int  TextureDictionaryParserWii::getImageHeight()
// {
//     if(!image_occurred) return -1;
//     return endian16(tex_header.height);
// }
// 
// int  TextureDictionaryParserWii::getImageSize()
// {
//     if(!image_occurred) return -1;
//     return image_size;
// }
// 
// int  TextureDictionaryParserWii::getImageFormat()
// {
//     if(!image_occurred) return -1;
//     return tex_header.format_id;
// }
// 
// int TextureDictionaryParserWii::getMipmapCount()
// {
//     if(!image_occurred) return -1;
//     return tex_header.mipmap_count;
// }

}
*/