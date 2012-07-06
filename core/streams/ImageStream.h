#ifndef __IMAGESTREAM_H
#define __IMAGESTREAM_H

#include "Stream.h"

namespace Consolgames
{

class ImageFileStream;

class ImageStream: public IFileStream
{
public:
    virtual bool seekToFile(const char* path) = 0;
    virtual ImageFileStream *findFile(const char* filename) = 0;
};

}

#endif /* __IMAGESTREAM_H */
