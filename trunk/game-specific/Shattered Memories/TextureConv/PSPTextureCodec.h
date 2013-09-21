#pragma once
#include "PSTextureCodec.h"

class PSPTextureCodec : public PSTextureCodec
{
protected:
	virtual void rotatePalette32(void* palette) const override;
	virtual void unswizzle8(const void* source, void* dest, int width, int height) const override;
	virtual void unswizzle4(const void* source, void* dest, int width, int height) const override;
	virtual void swizzle4(const void* source, void* dest, int width, int height) const override;
	virtual void swizzle8(const void* source, void* dest, int width, int height) const override;
	virtual bool halfAlpha() const override;
};
