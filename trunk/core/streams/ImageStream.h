#pragma once
#include "Stream.h"

namespace Consolgames
{

class ImageFileStream;

class ImageStream: public Stream
{
public:
    virtual bool seekToFile(const char* path) = 0;
    virtual ImageFileStream *findFile(const char* filename) = 0;
};

}
