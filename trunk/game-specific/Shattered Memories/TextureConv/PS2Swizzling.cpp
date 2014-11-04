#include "PS2Swizzling.h"
#include <core.h>
#include <algorithm>

static int odd(int v)
{
	return (v % 2);
}

static const int s_tileMatrix[2] = {4, -4};
static const int s_matrix[4] = {0, 1, -1, 0};
static const int s_interlaceMatrix[8] = {0x00, 0x10, 0x02, 0x12, 0x11, 0x01, 0x13, 0x03};

namespace
{

struct Unswizzle8Func
{
	Unswizzle8Func(const void* swizzledData, void* outData)
		: swizzledData(static_cast<const uint8*>(swizzledData))
		, outData(static_cast<uint8*>(outData))
	{
	}

	void operator () (int swizzledIndex, int rasterIndex) const
	{
		outData[rasterIndex] = swizzledData[swizzledIndex];
	}

	const uint8* const swizzledData;
	uint8* const outData;
};

struct Swizzle8Func
{
	Swizzle8Func(const void* srcData, void* outSwizzledData)
		: srcData(static_cast<const uint8*>(srcData))
		, outSwizzledData(static_cast<uint8*>(outSwizzledData))
	{
	}

	void operator () (int swizzledIndex, int rasterIndex) const
	{
		outSwizzledData[swizzledIndex] = srcData[rasterIndex];
	}

	const uint8* const srcData;
	uint8* const outSwizzledData;
};


#pragma pack(push, 1)
struct PixelPair4bpp
{
	uint8 p1 : 4;
	uint8 p2 : 4;
};
#pragma pack(pop)

struct Unswizzle4as8Func
{
	Unswizzle4as8Func(const void* swizzledData, void* outData)
		: swizzledData(swizzledData)
		, outData(outData)
	{
	}

	void operator () (int swizzledIndex, int rasterIndex) const
	{
		const PixelPair4bpp* src =  (const PixelPair4bpp*)swizzledData;
		PixelPair4bpp* dst = (PixelPair4bpp*)outData;

		const uint8 value = ((swizzledIndex % 2) == 0) ? src[swizzledIndex / 2].p1 : src[swizzledIndex / 2].p2;

		if (odd(rasterIndex))
		{
			dst[rasterIndex / 2].p2 = value;
		}
		else
		{
			dst[rasterIndex / 2].p1 = value;
		}
	}

	const void* const swizzledData;
	void* const outData;
};

struct Swizzle4as8Func
{
	Swizzle4as8Func(const void* srcData, void* outSwizzledData)
		: srcData(srcData)
		, outSwizzledData(outSwizzledData)
	{
	}

	void operator () (int swizzledIndex, int rasterIndex) const
	{
		const PixelPair4bpp* src =  (const PixelPair4bpp*)srcData;
		PixelPair4bpp* dst = (PixelPair4bpp*)outSwizzledData;

		const uint8 value = odd(rasterIndex) ? src[rasterIndex / 2].p2 : src[rasterIndex / 2].p1;

		if (odd(swizzledIndex))
		{
			dst[swizzledIndex / 2].p2 = value;
		}
		else
		{
			dst[swizzledIndex / 2].p1 = value;
		}
	}

	const void* const srcData;
	void* const outSwizzledData;
};

template <class Func>
void swizzle8Proc(Func func, int width, int height, int encodedWidth)
{
	for (int y = 0; y < height; y++)
	{
		for (int x = 0; x < width; x++)
		{
			const int xx = x + odd(y / 4) * s_tileMatrix[odd(x / 4)];
			const int yy = y + s_matrix[y % 4];

			const int swizzledIndex = s_interlaceMatrix[(x / 4) % 4 + 4 * odd(y)] + ((x * 4) % 16) + (x / 16) * 32 + ((y - odd(y)) * encodedWidth);
			const int rasterIndex = yy * width + xx;

			if (swizzledIndex < encodedWidth * height)
			{
				func(swizzledIndex, rasterIndex);
			}
		}
	}
}

}

void unswizzle4as8(const void* source, void* dest, int width, int height)
{
	swizzle8Proc(Unswizzle4as8Func(source, dest), width, height, std::max(32, width));
}

void unswizzle8(const void* source, void* dest, int width, int height)
{
	swizzle8Proc(Unswizzle8Func(source, dest), width, height, std::max(16, width));
}

void swizzle4as8(const void* source, void* dest, int width, int height)
{
	swizzle8Proc(Swizzle4as8Func(source, dest), width, height, std::max(32, width));
}

void swizzle8(const void* source, void* dest, int width, int height)
{
	swizzle8Proc(Swizzle8Func(source, dest), width, height, std::max(16, width));
}

//////////////////////////////////////////////////////////////////////////

namespace
{

template <class Func>
void pspSwizzle8Proc(Func func, int width, int height, int encodedWidth)
{
	int swizzledIndex = 0;

	for (int ty = 0; ty < height; ty+=8)
	{
		for (int tx = 0; tx < width; tx+=16)
		{
			for (int y = ty; y < ty + 8; y++)
			{
				int deswizzledIndex = y * width + tx;
				for (int x = tx; x < tx + 16; x++)
				{
					if (swizzledIndex >= encodedWidth * height)
					{
						break;
					}
					func(swizzledIndex++, deswizzledIndex++);
				}
			}
		}
	}
}

}

void pspUnswizzle4(const void* source, void* dest, int width, int height)
{
	pspSwizzle8Proc(Unswizzle8Func(source, dest), width / 2, height, std::max(16, width / 2));
}

void pspUnswizzle8(const void* source, void* dest, int width, int height)
{
	pspSwizzle8Proc(Unswizzle8Func(source, dest), width, height, std::max(16, width));
}

void pspSwizzle4(const void* source, void* dest, int width, int height)
{
	pspSwizzle8Proc(Swizzle8Func(source, dest), width / 2, height, std::max(16, width / 2));
}

void pspSwizzle8(const void* source, void* dest, int width, int height)
{
	pspSwizzle8Proc(Swizzle8Func(source, dest), width, height, std::max(16, width));
}

//////////////////////////////////////////////////////////////////////////

template <typename Color>
void rotPal(void* palette)
{
	typedef Color Block[8];
	typedef Block Palette[32];

	Palette& pal = *static_cast<Palette*>(palette);

	for (int x = 1; x < 30; x+=4)
	{
		// swap x and x + 1
		Block block;
		memcpy(&block, &pal[x], sizeof(Block));
		memcpy(&pal[x], &pal[x + 1], sizeof(Block));
		memcpy(&pal[x + 1], &block, sizeof(Block));
	}
}

void rotatePalette16(void* palette)
{
	rotPal<uint16>(palette);
}

void rotatePalette24(void* palette)
{
#pragma pack(push, 1)
	struct RGB {uint8 r, g, b;};
#pragma pack(pop)
	rotPal<RGB>(palette);
}

void rotatePalette32(void* palette)
{
	rotPal<uint32>(palette);
}
