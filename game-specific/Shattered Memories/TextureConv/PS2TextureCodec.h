#pragma once
#include "TextureCodec.h"

class PS2TextureCodec : public TextureCodec
{
public:
	virtual bool isFormatSupported(int format) const;
	virtual bool isPaletteFormatSupported(int format) const;
	virtual int bestSuitablePaletteFormatFor(int textureFormat) const;
	virtual uint32 encodedRasterSize(int format, int width, int height, int mipmaps = mipmapCountDefault) const override;
	virtual uint32 encodedPaletteSize(int format, int paletteFormat) const override;
	virtual bool decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat, int mipmapsToDecode = 1) override;
	virtual bool encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, int mipmaps = mipmapCountDefault) override;

	virtual const char* textureFormatToString(int format) const override;
	virtual const char* paletteFormatToString(int format) const override;
	virtual int textureFormatFromString(const char* str) const override;
	virtual int paletteFormatFromString(const char* str) const override;
};
