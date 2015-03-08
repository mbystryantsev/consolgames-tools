#include "WiiSwizzling.h"
#include <core.h>

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