#ifndef __TEXDICPARSER_H
#define __TEXDICPARSER_H

#include <stdint.h>
#include <stddef.h>
#include "Streams/Stream.h"

namespace shsm
{

inline uint32_t endian32(uint32_t v)
{
    return ((v << 24) | ((v << 8) & 0xFF0000) | ((v >> 8) & 0xFF00) | (v >> 24));
}

inline uint16_t endian16(uint16_t v)
{
    return (v << 8) | (v >> 8);
}

class TexDicParser
{
protected:
    cg::Stream *stream;
    bool image_occurred, opened;
public:
    TexDicParser():stream(0)
    {
    }
    virtual bool open(cg::Stream *stream)
    {
        image_occurred = false;
        opened = false;
        if(!stream)
            return false;
        this->stream = stream;
        opened = true;
        return true;
    }

    virtual int getImageName(char* str) = 0;
    virtual bool parse() = 0;
    virtual int getImageWidth() = 0;
    virtual int getImageHeight() = 0;
    virtual int getImageSize() = 0;
    virtual int getImageFormat() = 0;
    virtual int getImageData(void *buf, size_t size) = 0;
    virtual int setImageData(void *buf, size_t size) = 0;
    virtual int getMipmapCount() = 0;

};

}

#endif /* __TEXDICPARSER_H */
