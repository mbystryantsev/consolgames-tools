#include "WiiSwizzling.h"
#include <core.h>

using namespace Consolgames;

namespace
{

enum Type
{
	typeSwizzle,
	typeUnswizzle

};

template <Type>
struct SwizzleOp
{
};

template <>
struct SwizzleOp<typeUnswizzle>
{
	template <typename A, typename B> void operator()(A swizzled, B unswizzled) { *unswizzled = *swizzled; }
};

template <>
struct SwizzleOp<typeSwizzle>
{
	template <typename A, typename B> void operator()(A swizzled, B unswizzled) { *swizzled = *unswizzled; }
};

template <Type swizzleType, int blockW, int blockH, typename Swizzled, typename Unswizzled>
void swizzleProc(Swizzled* swizzled, Unswizzled* unswizzled, int width, int height)
{
	const int bw = (width + blockW - 1) / blockW;
	const int bh = (height + blockH - 1) / blockH;
	const int rowSize = bw * blockW;
	SwizzleOp<swizzleType> op;

	for (int by = 0; by < bh; by++)
	{
		for (int bx = 0; bx < bw; bx++)
		{
			for (int y = 0; y < blockH; y++)
			{
				Unswizzled u = 0;
				for (int x = 0; x < blockW; x++)
				{
					const int ix = bx * blockW + x;
					const int offset = (by * blockH + y) * rowSize + ix;
					op(swizzled++, ix < width ? unswizzled + offset : &u);
				}
			}
		}
	}
}

}

//////////////////////////////////////////////////////////////////////

static void swapDecode32(void* data, int width, int height, const char* map)
{
	static const char s_map[] = {4, 0, 5, 1, 6, 2, 7, 3};

	uint16* a = static_cast<uint16*>(data);

	for (int i = 0; i < width * height; i+=4)
	{
		uint16 v[8];
		std::copy(a, a + 8, v);
		
		for (int j = 0; j < 8; j++)
		{
			a[j] = endian16(v[map[j]]);
		}
		
		a += 8;
	}
}

static void swapDecode32(void* data, int width, int height)
{
	static const char s_map[] = {4, 0, 5, 1, 6, 2, 7, 3};

	uint16* a = static_cast<uint16*>(data);

	for (int i = 0; i < width * height; i+=4)
	{
		uint16 v[8];
		std::copy(a, a + 8, v);
		
		for (int j = 0; j < 8; j++)
		{
			a[j] = endian16(v[s_map[j]]);
		}
		
		a += 8;
	}
}

static void swapEncode32(void* data, int width, int height)
{
	uint16* a = static_cast<uint16*>(data);

	for (int i = 0; i < width * height; i+=16)
	{
		for (int j = 0; j < 4; j++)
		{
			uint16* b = a + 16;
			uint16 v[8] = {a[0], a[1], a[2], a[3], b[0], b[1], b[2], b[3]};

			a[0] = endian16(v[1]);
			a[1] = endian16(v[3]);
			a[2] = endian16(v[5]);
			a[3] = endian16(v[7]);
			b[0] = endian16(v[0]);
			b[1] = endian16(v[2]);
			b[2] = endian16(v[4]);
			b[3] = endian16(v[6]);

			a += 4;
		}
		
		a += 16;
	}
}

void wiiUnswizzle32(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeUnswizzle, 8, 4>(static_cast<const uint8*>(src), static_cast<uint8*>(dst), width * 4, height);
	swapDecode32(dst, width, height);
}

void wiiSwizzle32(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeSwizzle, 8, 4>(static_cast<uint8*>(dst), static_cast<const uint8*>(src), width * 4, height);
	swapEncode32(dst, width, height);
}

void wiiUnswizzle16(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeUnswizzle, 8, 4>(static_cast<const uint8*>(src), static_cast<uint8*>(dst), width * 2, height);
}

void wiiSwizzle16(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeSwizzle, 8, 4>(static_cast<uint8*>(dst), static_cast<const uint8*>(src), width * 2, height);
}

void wiiUnswizzle8(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeUnswizzle, 8, 4>(static_cast<const uint8*>(src), static_cast<uint8*>(dst), width, height);
}

void wiiSwizzle8(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeSwizzle, 8, 4>(static_cast<uint8*>(dst), static_cast<const uint8*>(src), width, height);
}

void wiiUnswizzle4(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeUnswizzle, 4, 8>(static_cast<const uint8*>(src), static_cast<uint8*>(dst), width / 2, height);
}

void wiiSwizzle4(const void* src, void* dst, int width, int height)
{
	swizzleProc<typeSwizzle, 4, 8>(static_cast<uint8*>(dst), static_cast<const uint8*>(src), width / 2, height);
}