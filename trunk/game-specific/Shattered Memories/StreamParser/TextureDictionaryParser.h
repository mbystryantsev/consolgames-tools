#pragma once
#include <FileStream.h>

namespace ShatteredMemories
{

class TextureDictionaryParser
{
public:
	enum TextureFormat
	{
		formatIndexed4,
		formatIndexed8,
		formatDXT1,
		formatRGBA
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
		uint32 rasterPosition;
		uint32 rasterSize;
		uint32 palettePosition;
		uint32 paletteSize;
	};

public:
	bool open(const std::wstring& filename);

	virtual bool open(Consolgames::Stream* stream) = 0;
	virtual bool initSegment() = 0;
	virtual bool fetch() = 0;
	virtual bool atEnd() const = 0;
	virtual const TextureMetaInfo& metaInfo() const = 0;

private:
	std::auto_ptr<Consolgames::Stream> m_streamHolder;
};

}

