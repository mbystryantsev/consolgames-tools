#pragma once
#include "TextureDictionaryParser.h"
#include <FileStream.h>
#include <core.h>
#include <memory>

namespace Consolgames
{
class Stream;
class FileStream;
}

namespace ShatteredMemories
{

class TextureDictionaryParserWii: public TextureDictionaryParser
{
//     enum TextureType
//     {
//         ClutNone = -1,
//         ClutUnknown = 0,
//         Clut256 = 1,
//         Clut16 = 2
//     };

    struct TextureHeader
    {
        struct
        {
            u32 magic; // ???
            u32 flags;
            u16 unk1;
            u16 unk2;
        } header_data;
        u32 unk1;
        u32 size;
        u32 flags;
        u32 unk_arr[9];
        char name[0x40];
        u32 unk2;
        u16 width;
        u16 height;
        char bits_per_pixel;
        char mipmap_count;
        char format_id; // format_id???
        char clut_type;
        int compression; //?
        // [clut]
        //uint32_t image_size; // before image data, but not in header
    };
// 	struct TextureMetaInfo
// 	{
// 		short width;
// 		short height;
// 		char mipmapCount;
// 		char formatId; // format_id???
// 		char clutType;
// 		int compression; //?
// 	};

//     unsigned short clut[256];
//     int state;
//     bool in_stream;
// 	bool dic_first_tex;
//     uint32 stream_size, stream_flags, dic_size, dic_flags, dic_unk, image_size;
//     char res_type[256], res_path[256], res_unk1[256], res_unk2[256];
//     int readString(char *str);
public:
    TextureDictionaryParserWii();

	bool open(const std::wstring& filename);
	bool open(Consolgames::Stream* stream);

	bool initSegment();

	virtual bool fetch() override;
	virtual bool atEnd() const override;
	const TextureMetaInfo& metaInfo() const;
private:
	bool readHeader();
//     int getImageName(char* str);
//     int getImageWidth();
//     int getImageHeight();
//     int getImageSize();
//     int getImageFormat();
//     int getImageData(void *buf, size_t size);
//     int setImageData(void *buf, size_t size);
//     int getMipmapCount();
// 
//     int getUnk1()
//     {
//         return tex_header.bits_per_pixel;
//     }
//     int getUnk2()
//     {
//         return tex_header.mipmap_count;
//     }
//     int getUnk3()
//     {
//         return tex_header.format_id;
//     }
//     int getUnk4()
//     {
//         return tex_header.clut_type;
//     }
//     int getUnk5()
//     {
//         return endian32(tex_header.compression);
//     }
//     int getDC()
//     {
//         return dic_size;
//     }
//     int getImageBitCount()
//     {
//         return (int)(char)tex_header.bits_per_pixel;
//     }
//     int getImageMipmapCount()
//     {
//         return (int)(char)tex_header.mipmap_count;
//     }

protected:	
	TextureMetaInfo m_currentMetaInfo;
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::Stream> m_streamHolder;
	int m_streamSize;
	int m_position;
	int m_currentItemSize;
};

}
