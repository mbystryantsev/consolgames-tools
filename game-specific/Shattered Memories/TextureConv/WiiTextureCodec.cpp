#include <Color.h>
#include "WiiTextureCodec.h"
#include "WiiSwizzling.h"
#include "dxt1.h"
#include "Quantize.h"
#include <WiiFormats.h>
#include <vector>
#include <algorithm>

using namespace ShatteredMemories;
using namespace Consolgames;

namespace
{

#pragma pack(push, 1)
struct RGB565
{
	RGB565() : v(0){}
	RGB565(uint32 v) : v(v){}

	union
	{
		struct
		{
			uint16 b : 5;
			uint16 g : 6;
			uint16 r : 5;
		};
		uint16 v;
	};
};

struct RGB5A3
{
	RGB5A3() : v(0){}
	RGB5A3(uint32 v) : v(v){}

	union
	{
		struct
		{
			uint16 b : 5;
			uint16 g : 5;
			uint16 r : 5;
			uint16 noAlpha : 1;
		} rgb555;
		
		struct
		{
			uint16 b : 4;
			uint16 g : 4;
			uint16 r : 4;
			uint16 a : 3;
			uint16 noAlpha : 1;
		} rgba4443;

		uint16 v;
	};
};

#pragma pack(pop)
}

static inline RGBA toRGBA(const RGB5A3& c)
{
	RGBA r;

	if (!c.rgb555.noAlpha)
	{
		r.r = expandColorTo32<4>(c.rgba4443.r);
		r.g = expandColorTo32<4>(c.rgba4443.g);
		r.b = expandColorTo32<4>(c.rgba4443.b);
		r.a = expandColorTo32<3>(c.rgba4443.a);
	}
	else
	{
		r.r = expandColorTo32<5>(c.rgb555.r);
		r.g = expandColorTo32<5>(c.rgb555.g);
		r.b = expandColorTo32<5>(c.rgb555.b);
		r.a = 255;
	}

	return r;
}

static inline RGBA toRGBA(const RGB565& c)
{
	RGBA r;
	r.r = expandColorTo32<5>(c.r);
	r.g = expandColorTo32<6>(c.g);
	r.b = expandColorTo32<5>(c.b);
	r.a = 255;
	return r;
}

static inline void fromRGBA(const RGBA& c, RGB5A3& r)
{
	if (c.a < 255)
	{
		r.rgba4443.r = collapseColor32<4>(c.r);
		r.rgba4443.g = collapseColor32<4>(c.g);
		r.rgba4443.b = collapseColor32<4>(c.b);
		r.rgba4443.a = collapseColor32<3>(c.a);
		r.rgba4443.noAlpha = 0;
	}
	else
	{
		r.rgb555.r = collapseColor32<5>(c.r);
		r.rgb555.g = collapseColor32<5>(c.g);
		r.rgb555.b = collapseColor32<5>(c.b);
		r.rgb555.noAlpha = 1;
	}
}

static inline void fromRGBA(const RGBA& c, RGB565& r)
{
	r.r = collapseColor32<5>(c.r);
	r.g = collapseColor32<6>(c.g);
	r.b = collapseColor32<5>(c.b);
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

template <typename Color>
static void encodeColorsFromRGBA(const void* colors, int count, void* dest)
{
	const RGBA* src = static_cast<const RGBA*>(colors);
	uint16* dst = static_cast<uint16*>(dest);

	while (count-- > 0)
	{
		Color c;
		fromRGBA(*src++, c);
		*dst++ = endian16(c.v);
	}
}

static bool encodeColorsFromRGBA(WiiFormats::PaletteFormat format, const void* colors, int count, void* dest)
{
	if (format == WiiFormats::paletteFormatRGB565)
	{
		encodeColorsFromRGBA<RGB565>(colors, count, dest);
		return true;
	}
	if (format == WiiFormats::paletteFormatRGB5A3)
	{
		encodeColorsFromRGBA<RGB5A3>(colors, count, dest);
		return true;
	}

	return false;
}

template <typename Color>
static void decodeColorsToRGBA(const void* colors, int count, void* dest)
{
	const uint16* src = static_cast<const uint16*>(colors);
	RGBA* dst = static_cast<RGBA*>(dest);

	while (count-- > 0)
	{
		*dst++ = toRGBA(Color(endian16(*src++)));
	}
}

static bool decodeColorsToRGBA(WiiFormats::PaletteFormat format, const void* colors, int count, void* dest)
{
	if (format == WiiFormats::paletteFormatRGB565)
	{
		decodeColorsToRGBA<RGB565>(colors, count, dest);
		return true;
	}
	if (format == WiiFormats::paletteFormatRGB5A3)
	{
		decodeColorsToRGBA<RGB5A3>(colors, count, dest);
		return true;
	}

	return false;
}

static void swapHalfBytes(uint8* data, int size)
{
	for (int i = 0; i < size; i++)
	{
		*data = (*data >> 4) | (*data << 4);
		data++;
	}
}

//////////////////////////////////////////////////////////////////////////

static const int s_defaultMipmapCount = 4;

bool WiiTextureCodec::isFormatSupported(int format) const
{
	return (format == WiiFormats::imageFormatDXT1 || format == WiiFormats::imageFormatC4 || format == WiiFormats::imageFormatC8 || format == WiiFormats::imageFormatRGBA8);
}

bool WiiTextureCodec::isPaletteFormatSupported(int format) const
{
	return (format == WiiFormats::paletteFormatNone || format == WiiFormats::paletteFormatRGB565 || format == WiiFormats::paletteFormatRGB5A3);
}

int WiiTextureCodec::bestSuitablePaletteFormatFor(int textureFormat) const
{
	if (textureFormat == WiiFormats::imageFormatDXT1 || textureFormat == WiiFormats::imageFormatRGBA8)
	{
		return WiiFormats::paletteFormatNone;
	}
	if (textureFormat == WiiFormats::imageFormatC4)
	{
		return WiiFormats::paletteFormatRGB565;
	}
	if (textureFormat == WiiFormats::imageFormatC8)
	{
		return WiiFormats::paletteFormatRGB5A3;
	}
	return WiiFormats::paletteFormatUndefined;
}

static int bitsPerPixel(int format)
{
	switch (format)
	{
		case WiiFormats::imageFormatC4:
		case WiiFormats::imageFormatDXT1:
			return 4;
		case WiiFormats::imageFormatC8:
			return 8;
		case WiiFormats::imageFormatRGBA8:
			return 32;
	}

	ASSERT(!"Unsupported format!");
	return 0;
}

static int blockSize(int format)
{
	switch (format)
	{
		case WiiFormats::imageFormatC4:
		case WiiFormats::imageFormatDXT1:
		case WiiFormats::imageFormatC8:
			return 32;
		case WiiFormats::imageFormatRGBA8:
			return 64;
	}

	ASSERT(!"Unsupported format!");
	return 0;
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
		mipmaps = format == WiiFormats::imageFormatDXT1 ? s_defaultMipmapCount : 1;
	}


	const int bpp = bitsPerPixel(format);
	const int minSize = blockSize(format);

	uint32 size = 0;
	while (mipmaps > 0)
	{
		size += std::max(minSize, (width * height * bpp) / 8);
		mipmaps--;
		width /= 2;
		height /= 2;
		width = std::max(width, 8);
		height = std::max(height, 8);
	}
	return size;
}

uint32 WiiTextureCodec::encodedPaletteSize(int format, int) const 
{
	if (format == WiiFormats::imageFormatC4)
	{
		return 16 * 2;
	}
	
	if (format == WiiFormats::imageFormatC8)
	{
		return 256 * 2;
	}

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

	if (format == WiiFormats::imageFormatDXT1)
	{
		ASSERT(mipmapsToDecode >= 1);
		ASSERT(palette == NULL);

		std::vector<nv::Color32> bgra(width * height);
		DXTCodec::decodeDXT1(image, &bgra[0], width, height, std::max(1, mipmapsToDecode));
		bgraToRgba(&bgra[0], result, bgra.size());
	
		return true;
	}
	if (format == WiiFormats::imageFormatRGBA8)
	{
		ASSERT(paletteFormat == WiiFormats::paletteFormatNone);
		if (paletteFormat != WiiFormats::paletteFormatNone)
		{
			return false;
		}

		wiiUnswizzle32(image, result, width, height);
		return true;
	}
	
	std::vector<uint8> buffer(encodedRasterSize(format, width, height, 1));

	if (format == WiiFormats::imageFormatC4)
	{
		ASSERT(palette != NULL);
		if (palette == NULL)
		{
			return false;
		}

		uint32 pal[16];
		decodeColorsToRGBA(static_cast<WiiFormats::PaletteFormat>(paletteFormat), palette, 16, pal);
		wiiUnswizzle4(image, &buffer[0], width, height);
		swapHalfBytes(&buffer[0], buffer.size());
		convertIndexed4ToRGBA(&buffer[0], width * height, pal, result);
		return true;
	}

	if (format == WiiFormats::imageFormatC8)
	{
		ASSERT(palette != NULL);
		if (palette == NULL)
		{
			return false;
		}

		uint32 pal[256];
		decodeColorsToRGBA(static_cast<WiiFormats::PaletteFormat>(paletteFormat), palette, 256, pal);
		wiiUnswizzle8(image, &buffer[0], width, height);
		convertIndexed8ToRGBA(&buffer[0], width * height, pal, result);
		return true;
	}

	ASSERT(!"Unsupported image format!");
	return false;
}

bool WiiTextureCodec::encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, int mipmaps)
{
	if (!isFormatSupported(format) || !isPaletteFormatSupported(paletteFormat))
	{
		ASSERT(!"Unsupported format!");
		return false;
	}
	
	if (format == WiiFormats::imageFormatDXT1)
	{
		ASSERT(palette == NULL);

		std::vector<nv::Color32> bgra(width * height);
		rgbaToBgra(image, &bgra[0], bgra.size());

		DXTCodec::encodeDXT1(&bgra[0], result, width, height, mipmaps == mipmapCountDefault ? s_defaultMipmapCount : mipmaps);
		return true;
	}
	if (format == WiiFormats::imageFormatRGBA8)
	{
		ASSERT(palette == NULL);
		if (palette != NULL)
		{
			return false;
		}
		
		wiiSwizzle32(image, result, width, height);
		return true;
	}

	std::vector<uint8> buffer(encodedRasterSize(format, width, height, mipmaps));

	if (buffer.empty())
	{
		return false;
	}

	if (format == WiiFormats::imageFormatC4)
	{
		ASSERT(palette != NULL);
		if (palette == NULL)
		{
			return false;
		}

		uint32 pal[16];
		quantize4(image, width, height, &buffer[0], pal);
		swapHalfBytes(&buffer[0], buffer.size());
		encodeColorsFromRGBA(static_cast<WiiFormats::PaletteFormat>(paletteFormat), pal, 16, palette);
		wiiSwizzle4(&buffer[0], result, width, height);
		return true;
	}
	if (format == WiiFormats::imageFormatC8)
	{
		ASSERT(palette != NULL);
		if (palette == NULL)
		{
			return false;
		}

		uint32 pal[256];
		quantize8(image, width, height, &buffer[0], pal);
		encodeColorsFromRGBA(static_cast<WiiFormats::PaletteFormat>(paletteFormat), pal, 256, palette);
		wiiSwizzle8(&buffer[0], result, width, height);
		return true;
	}

	return false;
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