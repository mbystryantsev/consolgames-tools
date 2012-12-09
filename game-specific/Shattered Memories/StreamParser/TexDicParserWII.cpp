#include "TexDicParserWII.h"
#include "Streams/Stream.h"
#include <string.h>
#include <algorithm>

namespace shsm
{

int TexDicParserWII::readString(char *str)
{
    uint32_t size;
    stream->read(&size, 4);
    size = endian32(size);
    stream->read(str, size);
    return size + 4;
}

bool TexDicParserWII::open(cg::Stream *stream)
{

    opened = false;
    image_occurred = false;

    bool ret = TexDicParser::open(stream);
    if(!ret)
    {
        return ret;
    }

    __int64 offset = stream->tell();
    int id = stream->readInt();
    stream->seek(offset, CG_SEEK_SET);
    if(id != 0x0016 && id != 0x0716)
    {
        return false;
    }

    state = STATE_WII_NONE;
    opened = true;
    in_stream = false;
    return true;
}

bool TexDicParserWII::parse()
{
    if(!opened) return false;
    while(stream->tell() + 12 < stream->size())
    {
        //printf("%p\n", stream->tell());
        switch(state)
        {
        case STATE_WII_NONE:
            uint32_t tag, size, flags;
            stream->read(&tag, 4);
            stream->read(&size, 4);
            stream->read(&flags, 4);
            switch(tag)
            {
            case 0x0016:
                state = STATE_WII_TEX_DIC;
                in_stream = false;
                dic_size = size;
                dic_flags = flags;
                stream->read(&dic_unk, 4);
                dic_first_tex = true;
                continue;
                //goto texdic;
            case 0x0716:
                state = STATE_WII_DATA_STREAM;
                in_stream = true;
                stream_size = size;
                stream_flags = flags;
                //goto datastream;
                continue;
            default:
                //printf("tag: %8.8X\n", tag);
                stream->seek(size, CG_SEEK_CUR);
                continue;
            case 0:
                return false;
            }
            break;
        case STATE_WII_DATA_STREAM:
//datastream:
            uint32_t header_size, footer_unk;
            unsigned char unk[16];

            while(stream_size > 0)
            {
                stream->read(&header_size, 4);
                header_size = endian32(header_size);
                stream_size -= header_size + 8;

                header_size -= readString(res_unk1);
                header_size -= stream->read(unk, 16);
                header_size -= readString(res_type);
                header_size -= readString(res_path);
                header_size -= readString(res_unk2);
                header_size -= stream->read(&footer_unk, 4);

                uint32_t data_size;
                stream->read(&data_size, 4);
                data_size = (endian32(data_size) + 3) & -4U;

                stream_size -= data_size;

                if(header_size > 0)
                    stream->seek(header_size, CG_SEEK_CUR);

                if(strcmp(res_type, "rwID_TEXDICTIONARY") != 0)
                    stream->seek(data_size, CG_SEEK_CUR);
                else
                {
                    state = STATE_WII_TEX_DIC;
                    stream->read(&tag, 4);
                    stream->read(&dic_size, 4);
                    stream->read(&dic_flags, 4);
                    stream->read(&dic_unk, 4);
                    dic_first_tex = true;
                    goto texdic;
                    //continue;
                }
            }

            state = STATE_WII_NONE;
            continue;
        case STATE_WII_TEX_DIC:
texdic:
            if(!dic_first_tex)
            {
                stream->seek(image_size, CG_SEEK_CUR);
            }
            else
            {
                dic_size -= 4;
                dic_first_tex = false;
            }

            if(dic_size <= sizeof(tex_header))
            {
dicexit:
                stream->seek(dic_size, CG_SEEK_CUR);
                if(in_stream)
                {
                    in_stream = false;
                    state = STATE_WII_DATA_STREAM;
                }
                else
                    state = STATE_WII_NONE;
                continue;
            }
            dic_size -= stream->read(&tex_header, sizeof(tex_header));
            if(tex_header.header_data.magic == 0 || tex_header.header_data.magic > 256)
            {
                //system("PAUSE");
                goto dicexit;
            }
            image_occurred = true;

            switch(tex_header.clut_type)
            {
            case CLUT_16_COLORS:
                dic_size -= stream->read(clut, 32);
                break;
            case CLUT_256_COLORS:
                dic_size -= stream->read(clut, sizeof(clut));
                break;
            }
            dic_size -= stream->read(&image_size, 4);
            image_size = endian32(image_size);

            dic_size -= image_size;
            return true;
            break;
        }
    }
    return false;
}

int TexDicParserWII::getImageName(char* str)
{
    if(!image_occurred) return -1;
    strcpy(str, tex_header.name);
    return strlen(str);
}

int TexDicParserWII::getImageData(void *buf, size_t size)
{
    if(!image_occurred) return -1;
    __int64 pos = stream->tell();
    int readed = stream->read(buf, std::min(size, image_size));
    stream->seek(pos, CG_SEEK_SET);
    return readed;
}

int TexDicParserWII::setImageData(void *buf, size_t size)
{
    if(!image_occurred) return -1;
    __int64 pos = stream->tell();
    int writed = stream->write(buf, std::min(size, image_size));
    stream->seek(pos, CG_SEEK_SET);
    return writed;
}

int  TexDicParserWII::getImageWidth()
{
    if(!image_occurred) return -1;
    return endian16(tex_header.width);
}

int  TexDicParserWII::getImageHeight()
{
    if(!image_occurred) return -1;
    return endian16(tex_header.height);
}

int  TexDicParserWII::getImageSize()
{
    if(!image_occurred) return -1;
    return image_size;
}

int  TexDicParserWII::getImageFormat()
{
    if(!image_occurred) return -1;
    return tex_header.format_id;
}

int TexDicParserWII::getMipmapCount()
{
    if(!image_occurred) return -1;
    return tex_header.mipmap_count;
}

}
