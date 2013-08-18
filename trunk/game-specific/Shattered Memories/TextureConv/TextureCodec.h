#pragma once
#include <core.h>

class TextureCodec
{
public:
	enum
	{
		mipmapCountDefault = 0,
		textureFormatUndefined = -1,
		paletteFormatUndefined = -2,
		paletteFormatNone = -1
	};

public:
	virtual bool isFormatSupported(int format) const = 0;
	virtual bool isPaletteFormatSupported(int format) const = 0;
	virtual int bestSuitablePaletteFormatFor(int textureFormat) const = 0;
	virtual uint32 encodedRasterSize(int format, int width, int height, int mipmaps = mipmapCountDefault) const = 0;
	virtual uint32 encodedPaletteSize(int format, int paletteFormat) const = 0;
	virtual bool decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat, int mipmapsToDecode = 1) = 0;
	virtual bool encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, int mipmaps = mipmapCountDefault) = 0;
	virtual int defaultMipmapCount() const = 0;

	virtual const char* textureFormatToString(int format) const = 0;
	virtual const char* paletteFormatToString(int format) const = 0;
	virtual int textureFormatFromString(const char* str) const = 0;
	virtual int paletteFormatFromString(const char* str) const = 0;
};