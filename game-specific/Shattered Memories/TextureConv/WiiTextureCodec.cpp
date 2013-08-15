#include <Color.h>
#include "WiiTextureCodec.h"
#include "dxt1.h"
#include <vector>

namespace
{
#pragma pack(push, 1)
	struct RGBA {uint8 r, g, b, a;};
#pragma pack(pop)
}

static void rgbaToBgra(const void* image, void* result, int size)
{

	const RGBA* src = static_cast<const RGBA*>(image);
	nv::Color32* dst = static_cast<nv::Color32*>(result);
	for (int i = 0; i < size; i++)
	{
		dst->r = src->r;
		dst->g = src->g;
		dst->b = src->b;
		dst->a = src->a;
		src++;
		dst++;
	}
}

static void bgraToRgba(const void* image, void* result, int size)
{
	const nv::Color32* src = static_cast<const nv::Color32*>(image);
	RGBA* dst = static_cast<RGBA*>(result);
	for (int i = 0; i < size; i++)
	{
		dst->r = src->r;
		dst->g = src->g;
		dst->b = src->b;
		dst->a = src->a;
		src++;
		dst++;
	}
}

static const int s_defaultMipmapCount = 4;

bool WiiTextureCodec::formatIsSupported(Format format) const
{
	return (format == formatDXT1);
}

uint32 WiiTextureCodec::encodedRasterSize(Format format, int width, int height, int mipmaps) const 
{
	if (format != formatDXT1)
	{
		ASSERT(!"Unsupported format!");
		return 0;
	}

	if (mipmaps == mipmapCountDefault)
	{
		mipmaps = s_defaultMipmapCount;
	}

	uint32 size = 0;
	while (mipmaps > 0)
	{
		size += width * height / 2;
		mipmaps--;
		width /= 2;
		height /= 2;
		width = max(width, 8);
		height = max(height, 8);
	}
	return size;
}

uint32 WiiTextureCodec::encodedPaletteSize(Format format) const 
{
	ASSERT(format == formatDXT1);
	return 0;
}

bool WiiTextureCodec::decode(void* result, const void* image, int width, int height, Format format, const void* palette, int mipmapsToDecode)
{
	if (format != formatDXT1)
	{
		ASSERT(!"Unsupported format!");
		return false;
	}

	ASSERT(mipmapsToDecode >= 1);
	ASSERT(palette == NULL);

	std::vector<nv::Color32> bgra(width * height);
	DXTCodec::decodeDXT1(image, &bgra[0], width, height, max(1, mipmapsToDecode));

	bgraToRgba(&bgra[0], result, bgra.size());
	return true;
}

bool WiiTextureCodec::encode(void* result, const void* image, int width, int height, Format format, void* palette, int mipmaps)
{
	if (format != formatDXT1)
	{
		ASSERT(!"Unsupported format!");
		return false;
	}
	ASSERT(palette == NULL);

	std::vector<nv::Color32> bgra(width * height);
	rgbaToBgra(image, &bgra[0], bgra.size());

	DXTCodec::encodeDXT1(&bgra[0], result, width, height, mipmaps == mipmapCountDefault ? s_defaultMipmapCount : mipmaps);
	return true;
}
