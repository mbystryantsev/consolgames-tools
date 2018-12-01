#pragma once
#include <FileStream.h>

namespace ShatteredMemories
{

class TextureDictionaryParser
{
public:
	struct TextureMetaInfo
	{
		std::string name;
		int width;
		int height;
		int mipmapCount;
		int bitsPerPixel;
		int textureFormat;
		int paletteFormat;
		uint32_t rasterPosition;
		uint32_t rasterSize;
		uint32_t palettePosition;
		uint32_t paletteSize;
	};

public:
	bool open(const std::wstring& filename);

	virtual bool open(Consolgames::Stream* stream) = 0;
	virtual bool initSegment() = 0;
	virtual bool fetch() = 0;
	virtual bool atEnd() const = 0;
	virtual const TextureMetaInfo& metaInfo() const = 0;

	virtual const char* textureFormatToString(int format) const = 0;
	virtual const char* paletteFormatToString(int format) const = 0;

private:
	std::unique_ptr<Consolgames::Stream> m_streamHolder;
};

}

