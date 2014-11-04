#include <Color.h>
#include "WiiTextureCodec.h"
#include "dxt1.h"
#include <WiiFormats.h>
#include <vector>
#include <algorithm>

using namespace ShatteredMemories;

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

//////////////////////////////////////////////////////////////////////////

static const int s_defaultMipmapCount = 4;

bool WiiTextureCodec::isFormatSupported(int format) const
{
	return (format == WiiFormats::imageFormatDXT1);
}

bool WiiTextureCodec::isPaletteFormatSupported(int format) const
{
	return (format == WiiFormats::paletteFormatNone);
}

int WiiTextureCodec::bestSuitablePaletteFormatFor(int textureFormat) const
{
	if (textureFormat == WiiFormats::imageFormatDXT1)
	{
		return WiiFormats::paletteFormatNone;
	}
	return WiiFormats::paletteFormatUndefined;
}

uint32 WiiTextureCodec::encodedRasterSize(int format, int width, int height, int mipmaps) const 
{
	if (!isFormatSupported(format))
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
		width = std::max(width, 8);
		height = std::max(height, 8);
	}
	return size;
}

uint32 WiiTextureCodec::encodedPaletteSize(int format, int paletteFormat) const 
{
	UNUSED(format);
	UNUSED(paletteFormat);
	ASSERT(format == WiiFormats::imageFormatDXT1 && paletteFormat == WiiFormats::paletteFormatNone);
	return 0;
}

bool WiiTextureCodec::decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat, int mipmapsToDecode)
{
	UNUSED(palette);

	if (!isFormatSupported(format) || !isPaletteFormatSupported(paletteFormat))
	{
		ASSERT(!"Unsupported format!");
		return false;
	}

	ASSERT(mipmapsToDecode >= 1);
	ASSERT(palette == NULL);

	std::vector<nv::Color32> bgra(width * height);
	DXTCodec::decodeDXT1(image, &bgra[0], width, height, std::max(1, mipmapsToDecode));

	bgraToRgba(&bgra[0], result, bgra.size());
	return true;
}

bool WiiTextureCodec::encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, int mipmaps)
{
	UNUSED(palette);

	if (!isFormatSupported(format) || !isPaletteFormatSupported(paletteFormat))
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

int WiiTextureCodec::defaultMipmapCount() const 
{
	return s_defaultMipmapCount;
}

const char* WiiTextureCodec::textureFormatToString(int format) const
{
	return WiiFormats::imageFormatToString(static_cast<WiiFormats::ImageFormat>(format));
}

const char* WiiTextureCodec::paletteFormatToString(int format) const
{
	return WiiFormats::paletteFormatToString(static_cast<WiiFormats::PaletteFormat>(format));
}

int WiiTextureCodec::textureFormatFromString(const char* str) const 
{
	return WiiFormats::imageFormatFromString(str);
}

int WiiTextureCodec::paletteFormatFromString(const char* str) const 
{
	return WiiFormats::paletteFormatFromString(str);
}