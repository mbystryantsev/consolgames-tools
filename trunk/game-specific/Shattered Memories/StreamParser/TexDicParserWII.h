#ifndef __TEXDICPARSERWII_H
#define __TEXDICPARSERWII_H

#include "TexDicParser.h"

namespace shsm
{

class TexDicParserWII: public TexDicParser
{
    enum
    {
        STATE_WII_NONE,
        STATE_WII_DATA_STREAM,
        STATE_WII_TEX_DIC
    };
#pragma pack(push, 1)

    enum
    {
        CLUT_NONE = -1,
        CLUT_HZ = 0,
        CLUT_256_COLORS = 1,
        CLUT_16_COLORS = 2
    };
    struct TexHeaderWII
    {
        struct
        {
            uint32_t magic; // ???
            uint32_t flags;
            uint16_t unk1;
            uint16_t unk2;
        } header_data;
        uint32_t unk1;
        uint32_t size;
        uint32_t flags;
        uint32_t unk_arr[9];
        char name[0x40];
        uint32_t unk2;
        uint16_t width;
        uint16_t height;
        char bits_per_pixel;
        char mipmap_count;
        char format_id; // format_id???
        char clut_type;
        int compression; //?
        // [clut]
        //uint32_t image_size; // before image data, but not in header
    } tex_header;
#pragma pack(pop)
    unsigned short clut[256];
    int state;
    bool in_stream, dic_first_tex;
    uint32_t stream_size, stream_flags, dic_size, dic_flags, dic_unk, image_size;
    char res_type[256], res_path[256], res_unk1[256], res_unk2[256];
    int readString(char *str);
public:
    TexDicParserWII():TexDicParser()
    {
    }
    bool open(cg::Stream *stream);
    bool parse();
    int getImageName(char* str);
    int getImageWidth();
    int getImageHeight();
    int getImageSize();
    int getImageFormat();
    int getImageData(void *buf, size_t size);
    int setImageData(void *buf, size_t size);
    int getMipmapCount();

    int getUnk1()
    {
        return tex_header.bits_per_pixel;
    }
    int getUnk2()
    {
        return tex_header.mipmap_count;
    }
    int getUnk3()
    {
        return tex_header.format_id;
    }
    int getUnk4()
    {
        return tex_header.clut_type;
    }
    int getUnk5()
    {
        return endian32(tex_header.compression);
    }
    int getDC()
    {
        return dic_size;
    }
    int getImageBitCount()
    {
        return (int)(char)tex_header.bits_per_pixel;
    }
    int getImageMipmapCount()
    {
        return (int)(char)tex_header.mipmap_count;
    }
};

}

#endif /* __TEXDICPARSERWII_H */
