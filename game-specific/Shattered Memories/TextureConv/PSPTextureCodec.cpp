#include "PSPTextureCodec.h"
#include "PS2Swizzling.h"

void PSPTextureCodec::rotatePalette32(void*) const 
{
}

void PSPTextureCodec::unswizzle8(const void* source, void* dest, int width, int height) const 
{
	pspUnswizzle8(source, dest, width, height);
}

void PSPTextureCodec::unswizzle4(const void* source, void* dest, int width, int height) const 
{
	pspUnswizzle4(source, dest, width, height);
}

void PSPTextureCodec::swizzle4(const void* source, void* dest, int width, int height) const 
{
	pspSwizzle4(source, dest, width, height);
}

void PSPTextureCodec::swizzle8(const void* source, void* dest, int width, int height) const 
{
	pspSwizzle8(source, dest, width, height);
}

bool PSPTextureCodec::halfAlpha() const 
{
	return false;
}
