#pragma once
#include "TextureCodec.h"

class WiiTextureCodec : public TextureCodec
{
public:
	virtual bool isFormatSupported(int format) const override;
	virtual bool isPaletteFormatSupported(int format) const override;
	virtual bool isMipmapsSupported(int format) const override;
	virtual int bestSuitablePaletteFormatFor(int textureFormat) const override;
	virtual uint32 encodedRasterSize(int format, int width, int height) const override;
	virtual uint32 encodedPaletteSize(int format, int paletteFormat) const override;
	virtual bool decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat) override;
	virtual int defaultMipmapCount() const override;
	virtual int minWidth(int format) const override;
	virtual int minHeight(int format) const override;

	virtual const char* textureFormatToString(int format) const override;
	virtual const char* paletteFormatToString(int format) const override;
	virtual int textureFormatFromString(const char* str) const override;
	virtual int paletteFormatFromString(const char* str) const override;

protected:
	virtual bool encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, bool isMipmap, Quantizer& state) override;
};
