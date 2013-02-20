#pragma once
#include <Stream.h>

namespace ShatteredMemories
{

class TextureDictionaryParser
{
public:
	enum TextureFormat
	{
		Indexed16,
		Indexed256,
		DXT1,
		DXT5
	};

public:
	struct TextureMetaInfo
	{
		std::string name;
		int width;
		int height;
		int mipmapCount;
		int bitsPerPixel;
		TextureFormat format;
		int clutType;
		int rasterPosition;
		int rasterSize;
	};

public:

	virtual bool fetch(){return true;}
	virtual bool atEnd() const{return false;}
	virtual const TextureMetaInfo& metaInfo() const = 0;

	static const int s_dataStreamId;
};

}

