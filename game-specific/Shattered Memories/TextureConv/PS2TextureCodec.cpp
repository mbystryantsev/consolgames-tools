#include "PS2TextureCodec.h"
#include "PS2Swizzling.h"
#include <PS2Formats.h>
#include <libimagequant.h>
#include <vector>

using namespace ShatteredMemories;

namespace
{
#pragma pack(push, 1)
struct RGBA
{
	uint8 r, g, b, a;
};
#pragma pack(pop)
}

static const uint8 s_colorDecodingTable[129] =
{
	0,   2,   4,   6,   8,   10,  12,  14,  16,  18,  20,  22,  24,  26,  28,  30,
	32,  34,  36,  38,  40,  42,  44,  46,  48,  50,  52,  54,  56,  58,  60,  62,
	64,  66,  68,  70,  72,  74,  76,  78,  80,  82,  84,  86,  88,  90,  92,  94,
	96,  98,  100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126,
	128, 129, 131, 133, 135, 137, 139, 141, 143, 145, 147, 149, 151, 153, 155, 157,
	159, 161, 163, 165, 167, 169, 171, 173, 175, 177, 179, 181, 183, 185, 187, 189,
	191, 193, 195, 197, 199, 201, 203, 205, 207, 209, 211, 213, 215, 217, 219, 221,
	223, 225, 227, 229, 231, 233, 235, 237, 239, 241, 243, 245, 247, 249, 251, 253,
	255
};

static const uint8 s_colorEncodingTable[256] =
{
	0,   1,   1,   2,   2,   3,   3,   4,   4,   5,   5,   6,   6,   7,   7,   8,
	8,   9,   9,   10,  10,  11,  11,  12,  12,  13,  13,  14,  14,  15,  15,  16,
	16,  17,  17,  18,  18,  19,  19,  20,  20,  21,  21,  22,  22,  23,  23,  24,
	24,  25,  25,  26,  26,  27,  27,  28,  28,  29,  29,  30,  30,  31,  31,  32,
	32,  33,  33,  34,  34,  35,  35,  36,  36,  37,  37,  38,  38,  39,  39,  40,
	40,  41,  41,  42,  42,  43,  43,  44,  44,  45,  45,  46,  46,  47,  47,  48,
	48,  49,  49,  50,  50,  51,  51,  52,  52,	 53,  53,  54,  54,  55,  55,  56,
	56,  57,  57,  58,  58,  59,  59,  60,  60,  61,  61,  62,  62,  63,  63,  64,
	64,  65,  65,  66,  66,  67,  67,  68,  68,  69,  69,  70,  70,  71,  71,  72,
	72,  73,  73,  74,  74,  75,  75,  76,  76,  77,  77,  78,  78,  79,  79,  80,
	80,  81,  81,  82,  82,  83,  83,  84,  84,  85,  85,  86,  86,  87,  87,  88,
	88,  89,  89,  90,  90,  91,  91,  92,  92,  93,  93,  94,  94,  95,  95,  96,
	96,  97,  97,  98,  98,  99,  99,  100, 100, 101, 101, 102, 102, 103, 103, 104,
	104, 105, 105, 106, 106, 107, 107, 108, 108, 109, 109, 110, 110, 111, 111, 112,
	112, 113, 113, 114, 114, 115, 115, 116, 116, 117, 117, 118, 118, 119, 119, 120,
	120, 121, 121, 122, 122, 123, 123, 124, 124, 125, 125, 126, 126, 127, 127, 128
};

static void decode32ColorsToRGBA(const void* colors, int count, void* dest)
{
	const RGBA* src = static_cast<const RGBA*>(colors);
	RGBA* dst = static_cast<RGBA*>(dest);

	while (count-- > 0)
	{
		dst->r = src->r;
		dst->g = src->g;
		dst->b = src->b;
		dst->a = (src->r > 0x80 ? 255 : s_colorDecodingTable[src->a]);

		dst++;
		src++;
	}
}

static void encode32ColorsFromRGBA(const void* colors, int count, void* dest)
{
	const RGBA* src = static_cast<const RGBA*>(colors);
	RGBA* dst = static_cast<RGBA*>(dest);

	while (count-- > 0)
	{
		dst->r = src->r;
		dst->g = src->g;
		dst->b = src->b;
		dst->a = s_colorEncodingTable[src->a];

		dst++;
		src++;
	}
}

static void convertIndexed4ToRGBA(const void* indexed4Data, int count, const void* palette, void* dest)
{
	const uint32* pal = static_cast<const uint32*>(palette);

	const uint8* src = static_cast<const uint8*>(indexed4Data);
	uint32* dst = static_cast<uint32*>(dest);
	for (int i = 0; i < count; i += 2)
	{
		*dst++ = pal[*src & 0xF];
		*dst++ = pal[*src >> 4];
		src++;
	}	
}

static void convertIndexed8ToRGBA(const void* indexed8Data, int count, const void* palette, void* dest)
{
	const uint32* pal = static_cast<const uint32*>(palette);

	const uint8* src = static_cast<const uint8*>(indexed8Data);
	uint32* dst = static_cast<uint32*>(dest);
	for (int i = 0; i < count; i++)
	{
		*dst++ = pal[*src++];
	}	
}

static void quantize(const void* data, int colorCount, int width, int height, void* dest, void* palette)
{
	liq_attr *attr = liq_attr_create();
	liq_set_max_colors(attr, colorCount);

	liq_image *image = liq_image_create_rgba(attr, const_cast<void*>(data), width, height, 0);

	liq_result *res = liq_quantize_image(attr, image);

	liq_write_remapped_image(res, image, dest, width * height);
	const liq_palette *pal = liq_get_palette(res);

	RGBA* c = static_cast<RGBA*>(palette);
	for (int i = 0; i < colorCount; i++)
	{
		c->r = pal->entries[i].r;
		c->g = pal->entries[i].g;
		c->b = pal->entries[i].b;
		c->a = pal->entries[i].a;
		c++;
	}
	//memcpy(palette, pal, 4 * colorCount);

	liq_attr_destroy(attr);
	liq_image_destroy(image);
	liq_result_destroy(res);
}

static void quantize8(const void* data, int width, int height, void* dest, void* palette)
{
	quantize(data, 256, width, height, dest, palette);
}

static void quantize4(const void* data, int width, int height, void* dest, void* palette)
{
	std::vector<uint8> buffer(width * height);
	quantize(data, 16, width, height, &buffer[0], palette);

	const uint8* src = &buffer[0];
	uint8* dst = static_cast<uint8*>(dest);

	const int rasterSize = (width * height) / 2;
	for (int i = 0; i < rasterSize; i++)
	{
		const uint8 c1 = *src++;
		const uint8 c2 = *src++;
		ASSERT(c1 < 16 && c2 < 16);
		*dst++ = (c1 & 0xF) | (c2 << 4);
	}
}

//////////////////////////////////////////////////////////////////////////

bool PS2TextureCodec::isFormatSupported(int format) const
{
	return (format == PS2Formats::imageFormatIndexed4 || format == PS2Formats::imageFormatIndexed8 || format == PS2Formats::imageFormatRGBA);
}

bool PS2TextureCodec::isPaletteFormatSupported(int format) const
{
	return (format == PS2Formats::paletteFormatNone || format == PS2Formats::paletteFormatRGBA);
}

int PS2TextureCodec::bestSuitablePaletteFormatFor(int textureFormat) const
{
	if (textureFormat == PS2Formats::imageFormatRGBA)
	{
		return PS2Formats::paletteFormatNone;
	}
	if (textureFormat == PS2Formats::imageFormatIndexed4 || textureFormat == PS2Formats::imageFormatIndexed8)
	{
		return PS2Formats::paletteFormatRGBA;
	}
	return PS2Formats::paletteFormatUndefined;
}

uint32 PS2TextureCodec::encodedRasterSize(int format, int width, int height, int mipmaps) const 
{
	ASSERT(mipmaps == 1 || mipmaps == mipmapCountDefault);
	
	if (mipmaps != 1 && mipmaps != mipmapCountDefault)
	{
		return 0;
	}

	return PS2Formats::encodedRasterSize(static_cast<PS2Formats::ImageFormat>(format), width, height);
}

uint32 PS2TextureCodec::encodedPaletteSize(int format, int paletteFormat) const 
{
	if (format == PS2Formats::imageFormatIndexed4)
	{
		ASSERT(paletteFormat == PS2Formats::paletteFormatRGBA);
		return 4 * 16;
	}
	else if (format == PS2Formats::imageFormatIndexed8)
	{
		ASSERT(paletteFormat == PS2Formats::paletteFormatRGBA);
		return 4 * 256;
	}
	else if (format == PS2Formats::imageFormatRGBA)
	{
		ASSERT(paletteFormat == PS2Formats::paletteFormatNone);
		return 0;
	}

	ASSERT(!"Unsupported image format!");
	return 0;
}

bool PS2TextureCodec::decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat, int mipmapsToDecode)
{
	ASSERT(mipmapsToDecode == 1);
	if (mipmapsToDecode != 1)
	{
		return false;
	}

	std::vector<uint8> buffer(encodedRasterSize(format, width, height));

	if (buffer.empty())
	{
		return false;
	}

	if (format == PS2Formats::imageFormatIndexed4)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PS2Formats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PS2Formats::paletteFormatRGBA)
		{
			return false;
		}

		uint32 pal[16];
		decode32ColorsToRGBA(palette, 16, pal);
		unswizzle4as8(image, &buffer[0], width, height);
		convertIndexed4ToRGBA(&buffer[0], width * height, pal, result);
		return true;
	}
	if (format == PS2Formats::imageFormatIndexed8)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PS2Formats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PS2Formats::paletteFormatRGBA)
		{
			return false;
		}

		uint32 pal[256];
		decode32ColorsToRGBA(palette, 256, pal);
		rotatePalette32(pal);
		unswizzle8(image, &buffer[0], width, height);
		convertIndexed8ToRGBA(&buffer[0], width * height, pal, result);
		return true;
	}
	if (format == PS2Formats::imageFormatRGBA)
	{
		ASSERT(paletteFormat == PS2Formats::paletteFormatNone);
		if (paletteFormat != PS2Formats::paletteFormatNone)
		{
			return false;
		}

		decode32ColorsToRGBA(image, width * height, result);
		return true;
	}

	ASSERT(!"Unsupported image format!");
	return false;
}

bool PS2TextureCodec::encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, int mipmaps)
{
	ASSERT(mipmaps == 1 || mipmaps == mipmapCountDefault);
	if (mipmaps != 1 && mipmaps != mipmapCountDefault)
	{
		return false;
	}

	std::vector<uint8> buffer(encodedRasterSize(format, width, height));

	if (buffer.empty())
	{
		return false;
	}

	if (format == PS2Formats::imageFormatIndexed4)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PS2Formats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PS2Formats::paletteFormatRGBA)
		{
			return false;
		}

		uint32 pal[16];
		quantize4(image, width, height, &buffer[0], pal);
		encode32ColorsFromRGBA(pal, 16, palette);
		swizzle4as8(&buffer[0], result, width, height);
		return true;
	}
	if (format == PS2Formats::imageFormatIndexed8)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PS2Formats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PS2Formats::paletteFormatRGBA)
		{
			return false;
		}

		uint32 pal[256];
		quantize8(image, width, height, &buffer[0], pal);
		encode32ColorsFromRGBA(pal, 256, palette);
		rotatePalette32(palette);
		swizzle8(&buffer[0], result, width, height);
		return true;
	}
	if (format == PS2Formats::imageFormatRGBA)
	{
		ASSERT(paletteFormat == PS2Formats::paletteFormatNone);
		if (paletteFormat != PS2Formats::paletteFormatNone)
		{
			return false;
		}

		encode32ColorsFromRGBA(image, width * height, result);
		return true;
	}
	ASSERT(!"Unsupported image format!");
	return false;
}

int PS2TextureCodec::defaultMipmapCount() const 
{
	return 1;
}

const char* PS2TextureCodec::textureFormatToString(int format) const
{
	return PS2Formats::imageFormatToString(static_cast<PS2Formats::ImageFormat>(format));
}

const char* PS2TextureCodec::paletteFormatToString(int format) const
{
	return PS2Formats::paletteFormatToString(static_cast<PS2Formats::PaletteFormat>(format));
}

int PS2TextureCodec::textureFormatFromString(const char* str) const
{
	return PS2Formats::imageFormatFromString(str);
}

int PS2TextureCodec::paletteFormatFromString(const char* str) const
{
	return PS2Formats::paletteFormatFromString(str);
}
