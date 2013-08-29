#include <Color.h>
#include "MapCommon.h"
#include <pnglite.h>
#include <Image.h>

namespace Origins
{

namespace
{
#pragma pack(push, 1)
struct RGBA
{
	uint8 r, g, b, a;
};
#pragma pack(pop)
}

void deswizzle8(const void* src, void* dest, int width, int height)
{
	const uint8* sb = static_cast<const uint8*>(src);

	for (int ty = 0; ty < height; ty+=8)
	{
		for (int tx = 0; tx < width; tx+=16)
		{
			for (int y = ty; y < ty + 8; y++)
			{
				uint8* db = static_cast<uint8*>(dest) + y * width + tx;
				for (int x = tx; x < tx + 16; x++)
				{
					*db++ = *sb++;
				}
			}
		}
	}
}

void deswizzle4(const void* src, void* dest, int width, int height)
{
	deswizzle8(src, dest, width / 2, height);
}

void swizzle8(const void* src, void* dest, int width, int height)
{
	uint8* db = static_cast<uint8*>(dest);

	for (int ty = 0; ty < height; ty+=8)
	{
		for (int tx = 0; tx < width; tx+=16)
		{
			for (int y = ty; y < ty + 8; y++)
			{
				const uint8* sb = static_cast<const uint8*>(src) + y * width + tx;
				for (int x = tx; x < tx + 16; x++)
				{
					*db++ = *sb++;
				}
			}
		}
	}
}

void swizzle4(const void* src, void* dest, int width, int height)
{
	swizzle8(src, dest, width / 2, height);
}

bool savePNG(const void* image, int width, int height, const char* filename)
{
	png_t png;
	if (png_open_file_write(&png, filename) != PNG_NO_ERROR)
	{
		return false;
	}

	bool result = true;
	if (png_set_data(&png, width, height, 8, PNG_TRUECOLOR_ALPHA, static_cast<unsigned char*>(const_cast<void*>(image))) != PNG_NO_ERROR)
	{
		result = false;
	}

	png_close_file(&png);

	return result;
}

void indexed4ToRGBA(const void* indexed, const uint32* palette, uint32* rgba, int count)
{
	const uint8* src = static_cast<const uint8*>(indexed);

	for (int i = 0; i < count / 2; i++)
	{
		*rgba++ = palette[*src & 0xF];
		*rgba++ = palette[*src >> 4];
		src++;
	}
}

void indexed8ToRGBA(const void* indexed, const uint32* palette, uint32* rgba, int count)
{
	const uint8* src = static_cast<const uint8*>(indexed);

	for (int i = 0; i < count; i++)
	{
		*rgba++ = palette[*src++];
	}
}

void indexed8ToIndexed4(const void* indexed8, void* indexed4, int count)
{
	const uint8* src = static_cast<const uint8*>(indexed8);
	uint8* dst = static_cast<uint8*>(indexed4);

	for (int i = 0; i < count / 2; i++)
	{
		*dst++ = (src[0] & 0xF) | (src[1] << 4);
		src += 2;
	}
}

void indexed4ToIndexed8(const void* indexed4, void* indexed8, int count)
{
	const uint8* src = static_cast<const uint8*>(indexed4);
	uint8* dst = static_cast<uint8*>(indexed8);

	for (int i = 0; i < count; i++)
	{
		*dst++ = *src & 0xF;
		*dst++ = *src >> 4;
		src++;
	}
}

static void abgrToRgba(const void* abgr, void* rgba, int count)
{
	const nv::Color32* src = static_cast<const nv::Color32*>(abgr);
	RGBA* dst = static_cast<RGBA*>(rgba);

	for (int i = 0; i < count; i++)
	{
		dst->r = src->r;
		dst->g = src->g;
		dst->b = src->b;
		dst->a = src->a;
		dst++;
		src++;
	}
}

bool loadImage(const char* filename, void* data, int width, int height)
{
	nv::Image image;
	if (!image.load(filename))
	{
		return false;
	}

	if (image.width() != width || image.height() != height)
	{
		return false;
	}

	abgrToRgba(image.pixels(), data, width * height);
	return true;
}

}
