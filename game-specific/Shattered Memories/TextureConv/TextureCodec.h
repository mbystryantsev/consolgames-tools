#pragma once
#include <core.h>

class TextureCodec
{
public:
	enum Format
	{
		formatUndefined = -1,
		formatDXT1,
		formatIndexed4,
		formatIndexed8
	};

	enum
	{
		mipmapCountDefault = 0
	};

public:
	virtual bool formatIsSupported(Format format) const = 0;
	virtual uint32 encodedRasterSize(Format format, int width, int height, int mipmaps = mipmapCountDefault) const = 0;
	virtual uint32 encodedPaletteSize(Format format) const = 0;
	virtual void decode(void* result, const void* image, int width, int height, Format format, const void* palette, int mipmapsToDecode = 1) = 0;
	virtual void encode(void* result, const void* image, int width, int height, Format format, void* palette, int mipmaps = mipmapCountDefault) = 0;
};