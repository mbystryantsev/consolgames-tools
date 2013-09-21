#include "PS2TextureCodec.h"
#include "PS2Swizzling.h"

void PS2TextureCodec::rotatePalette32(void* palette) const 
{
	::rotatePalette32(palette);
}

void PS2TextureCodec::unswizzle8(const void* source, void* dest, int width, int height) const 
{
	::unswizzle8(source, dest, width, height);
}

void PS2TextureCodec::unswizzle4(const void* source, void* dest, int width, int height) const 
{
	::unswizzle4as8(source, dest, width, height);
}

void PS2TextureCodec::swizzle4(const void* source, void* dest, int width, int height) const 
{
	::swizzle4as8(source, dest, width, height);
}

void PS2TextureCodec::swizzle8(const void* source, void* dest, int width, int height) const 
{
	::swizzle8(source, dest, width, height);
}

bool PS2TextureCodec::halfAlpha() const 
{
	return true;
}
