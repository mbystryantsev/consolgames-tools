#include "PSTextureCodec.h"
#include "Quantize.h"
#include <PSFormats.h>
#include <vector>
#include <nvimage/Image.h>

using namespace ShatteredMemories;

namespace
{
#pragma pack(push, 1)

struct RGBA16
{
	uint16 r : 5;
	uint16 g : 5;
	uint16 b : 5;
	uint16 a : 1;
};

#pragma pack(pop)
}

static const uint8 s_alphaDecodingTable[129] =
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

static const uint8 s_alphaEncodingTable[256] =
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
		dst->a = (src->a > 0x80 ? 255 : s_alphaDecodingTable[src->a]);

		dst++;
		src++;
	}
}

static void decode16ColorsToRGBA(const void* colors, int count, void* dest)
{
	const RGBA16* src = static_cast<const RGBA16*>(colors);
	RGBA* dst = static_cast<RGBA*>(dest);

	while (count-- > 0)
	{
		dst->r = expandColorTo32<5>(src->r);
		dst->g = expandColorTo32<5>(src->g);
		dst->b = expandColorTo32<5>(src->b);
		dst->a = (src->a == 1 ? 255 : 0);

		dst++;
		src++;
	}
}

static void encode16ColorsFromRGBA(const void* colors, int count, void* dest)
{
	const RGBA* src = static_cast<const RGBA*>(colors);
	RGBA16* dst = static_cast<RGBA16*>(dest);

	while (count-- > 0)
	{
		dst->r = collapseColor32<5>(src->r);
		dst->g = collapseColor32<5>(src->g);
		dst->b = collapseColor32<5>(src->b);
		dst->a = src->a == 255 ? 1 : 0;

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
		dst->a = s_alphaEncodingTable[src->a];

		dst++;
		src++;
	}
}

//////////////////////////////////////////////////////////////////////////

bool PSTextureCodec::isFormatSupported(int format) const
{
	return (format == PSFormats::imageFormatIndexed4 || format == PSFormats::imageFormatIndexed8
		|| format == PSFormats::imageFormatRGBA || format == PSFormats::imageFormatRGBA16);
}

bool PSTextureCodec::isPaletteFormatSupported(int format) const
{
	return (format == PSFormats::paletteFormatNone || format == PSFormats::paletteFormatRGBA);
}

int PSTextureCodec::bestSuitablePaletteFormatFor(int textureFormat) const
{
	if (textureFormat == PSFormats::imageFormatRGBA || textureFormat == PSFormats::imageFormatRGBA16)
	{
		return PSFormats::paletteFormatNone;
	}
	if (textureFormat == PSFormats::imageFormatIndexed4 || textureFormat == PSFormats::imageFormatIndexed8)
	{
		return PSFormats::paletteFormatRGBA;
	}
	return PSFormats::paletteFormatUndefined;
}

uint32 PSTextureCodec::encodedRasterSize(int format, int width, int height, int mipmaps) const 
{
	ASSERT(mipmaps == 1 || mipmaps == mipmapCountDefault);
	
	if (mipmaps != 1 && mipmaps != mipmapCountDefault)
	{
		return 0;
	}

	return PSFormats::encodedRasterSize(static_cast<PSFormats::ImageFormat>(format), width, height);
}

uint32 PSTextureCodec::encodedPaletteSize(int format, int paletteFormat) const 
{
	UNUSED(paletteFormat);

	if (format == PSFormats::imageFormatIndexed4)
	{
		ASSERT(paletteFormat == PSFormats::paletteFormatRGBA);
		return 4 * 16;
	}
	else if (format == PSFormats::imageFormatIndexed8)
	{
		ASSERT(paletteFormat == PSFormats::paletteFormatRGBA);
		return 4 * 256;
	}
	else if (format == PSFormats::imageFormatRGBA || format == PSFormats::imageFormatRGBA16)
	{
		ASSERT(paletteFormat == PSFormats::paletteFormatNone);
		return 0;
	}

	ASSERT(!"Unsupported image format!");
	return 0;
}

bool PSTextureCodec::decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat, int mipmapsToDecode)
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

	if (format == PSFormats::imageFormatIndexed4)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PSFormats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PSFormats::paletteFormatRGBA)
		{
			return false;
		}

		uint32 pal[16];
		decode32ColorsToRGBA(palette, 16, pal);
		unswizzle4(image, &buffer[0], width, height);
		convertIndexed4ToRGBA(&buffer[0], width * height, pal, result);
		return true;
	}
	if (format == PSFormats::imageFormatIndexed8)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PSFormats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PSFormats::paletteFormatRGBA)
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
	if (format == PSFormats::imageFormatRGBA16)
	{
		ASSERT(paletteFormat == PSFormats::paletteFormatNone);
		if (paletteFormat != PSFormats::paletteFormatNone)
		{
			return false;
		}

		decode16ColorsToRGBA(image, width * height, result);
		return true;
	}
	if (format == PSFormats::imageFormatRGBA)
	{
		ASSERT(paletteFormat == PSFormats::paletteFormatNone);
		if (paletteFormat != PSFormats::paletteFormatNone)
		{
			return false;
		}

		decode32ColorsToRGBA(image, width * height, result);
		return true;
	}

	ASSERT(!"Unsupported image format!");
	return false;
}

bool PSTextureCodec::encode(void* result, const void* image, int format, int width, int height, void* palette, int paletteFormat, int mipmaps)
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

	if (format == PSFormats::imageFormatIndexed4)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PSFormats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PSFormats::paletteFormatRGBA)
		{
			return false;
		}

		uint32 pal[16];
		
		if (!quantize4(image, width, height, &buffer[0], pal))
		{
			return false;
		}

		encode32ColorsFromRGBA(pal, 16, palette);
		swizzle4(&buffer[0], result, width, height);
		return true;
	}
	if (format == PSFormats::imageFormatIndexed8)
	{
		ASSERT(palette != NULL);
		ASSERT(paletteFormat == PSFormats::paletteFormatRGBA);
		if (palette == NULL || paletteFormat != PSFormats::paletteFormatRGBA)
		{
			return false;
		}

		uint32 pal[256];
		if (!quantize8(image, width, height, &buffer[0], pal))
		{
			return false;
		}

		encode32ColorsFromRGBA(pal, 256, palette);
		rotatePalette32(palette);
		swizzle8(&buffer[0], result, width, height);
		return true;
	}
	if (format == PSFormats::imageFormatRGBA16)
	{
		ASSERT(paletteFormat == PSFormats::paletteFormatNone);
		if (paletteFormat != PSFormats::paletteFormatNone)
		{
			return false;
		}

		std::vector<uint32> data(width * height * 4);
		memcpy(&data[0], image, width * height * 4);
		floydSteinberg(&data[0], width, height, 5, 5, 5, 8);
		encode16ColorsFromRGBA(&data[0], width * height, result);
		return true;
	}
	if (format == PSFormats::imageFormatRGBA)
	{
		ASSERT(paletteFormat == PSFormats::paletteFormatNone);
		if (paletteFormat != PSFormats::paletteFormatNone)
		{
			return false;
		}

		encode32ColorsFromRGBA(image, width * height, result);
		return true;
	}
	ASSERT(!"Unsupported image format!");
	return false;
}

int PSTextureCodec::defaultMipmapCount() const 
{
	return 1;
}

const char* PSTextureCodec::textureFormatToString(int format) const
{
	return PSFormats::imageFormatToString(static_cast<PSFormats::ImageFormat>(format));
}

const char* PSTextureCodec::paletteFormatToString(int format) const
{
	return PSFormats::paletteFormatToString(static_cast<PSFormats::PaletteFormat>(format));
}

int PSTextureCodec::textureFormatFromString(const char* str) const
{
	return PSFormats::imageFormatFromString(str);
}

int PSTextureCodec::paletteFormatFromString(const char* str) const
{
	return PSFormats::paletteFormatFromString(str);
}

void PSTextureCodec::decode32ColorsToRGBA(const void* colors, int count, void* dest) const
{
	if (halfAlpha())
	{
		::decode32ColorsToRGBA(colors, count, dest);
	}
	else
	{
		memcpy(dest, colors, count * sizeof(RGBA));
	}
}

void PSTextureCodec::encode32ColorsFromRGBA(const void* colors, int count, void* dest) const
{
	if (halfAlpha())
	{
		::encode32ColorsFromRGBA(colors, count, dest);
	}
	else
	{
		memcpy(dest, colors, count * sizeof(RGBA));
	}
}