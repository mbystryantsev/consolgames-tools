#pragma once
#include <core.h>

class Quantizer;

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
	bool decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat, int mipmapsToDecode);
	bool encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, int mipmaps);
	uint32 encodedRasterSize(int format, int width, int height, int mipmaps) const;

	virtual bool isFormatSupported(int format) const = 0;
	virtual bool isPaletteFormatSupported(int format) const = 0;
	virtual bool isMipmapsSupported(int format) const = 0;
	virtual int bestSuitablePaletteFormatFor(int textureFormat) const = 0;
	virtual uint32 encodedRasterSize(int format, int width, int height) const = 0;
	virtual uint32 encodedPaletteSize(int format, int paletteFormat) const = 0;
	virtual bool decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat) = 0;
	virtual int defaultMipmapCount() const = 0;
	virtual int minWidth(int format) const = 0;
	virtual int minHeight(int format) const = 0;

	virtual const char* textureFormatToString(int format) const = 0;
	virtual const char* paletteFormatToString(int format) const = 0;
	virtual int textureFormatFromString(const char* str) const = 0;
	virtual int paletteFormatFromString(const char* str) const = 0;

protected:
	virtual bool encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, bool isMipmap, Quantizer& state) = 0;
};