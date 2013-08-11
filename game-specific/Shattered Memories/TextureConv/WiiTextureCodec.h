#pragma once
#include "TextureCodec.h"

class WiiTextureCodec : public TextureCodec
{
public:
	virtual uint32 encodedRasterSize(Format format, int width, int height, int mipmaps) const override;
	virtual uint32 encodedPaletteSize(Format format) const override;
	virtual void decode(void* result, const void* image, int width, int height, Format format, const void* palette, int mipmapsToDecode = 1) override;
	virtual void encode(void* result, const void* image, int width, int height, Format format, void* palette, int mipmaps) override;
};
