#include "RowColMapEncoder.h"
#include "MapCommon.h"
#include <vector>

namespace Origins
{

struct FillInfo
{
	int rows[32];
	int cols[32];
};

inline uint32 tileIndex(int x, int y)
{
	return y * c_tilesCanvasWidthHeight + x;
}

static bool compareTile(int compareWidth, int compareHeight, uint8* canvas, int canvasX, int canvasY, const uint8* image, int width, int, int tileX, int tileY)
{
	for (int y = 0; y < compareHeight; y++)
	{
		const uint8* canvasPixels = canvas + (canvasY + y) * c_tilesCanvasWidthHeight + canvasX;
		const uint8* imagePixels = image + (tileY + y) * width + tileX;
		if (!std::equal(canvasPixels, canvasPixels + compareWidth, imagePixels))
		{
			return false;
		}
	}

	return true;
}

static void copyRect(const uint8* image, int width, int, int tileX, int tileY, uint8* canvas, int canvasX, int canvasY)
{
	for (int y = 0; y < c_tileWidthHeight; y++)
	{
		uint8* canvasPixels = canvas + (canvasY + y) * c_tilesCanvasWidthHeight + canvasX;
		const uint8* imagePixels = image + (tileY + y) * width + tileX;
		std::copy(imagePixels, imagePixels + c_tileWidthHeight, canvasPixels);
	}
}

static uint32 placeTile(FillInfo& fillInfo, uint8* canvas, uint8* image, int width, int height, int tileX, int tileY)
{
	uint32 bestPos = c_nullTileIndex;
	int bestMatch = -1;

	for (int rcOffset = 0; rcOffset < c_tilesCanvasWidthHeight; rcOffset += c_tileWidthHeight)
	{
		const int rc = rcOffset / c_tileWidthHeight;

		const int maxLookupX = max(rcOffset, min(c_tilesCanvasWidthHeight - c_tileWidthHeight, fillInfo.rows[rc]));
		for (int x = rcOffset; x <= maxLookupX; x++)
		{
			const int weight = min(c_tileWidthHeight, max(0, fillInfo.rows[rc] - x));
			if (compareTile(weight, c_tileWidthHeight, canvas, x, rcOffset, image, width, height, tileX, tileY))
			{
				if (weight > bestMatch)
				{
					bestMatch = weight;
					bestPos = tileIndex(x, rcOffset);
					if (bestMatch == c_tileWidthHeight)
					{
						break;
					}
				}
			}
		}

		const int maxLookupY = max(rcOffset, min(c_tilesCanvasWidthHeight - c_tileWidthHeight, fillInfo.cols[rc]));
		for (int y = rcOffset; y <= maxLookupY; y++)
		{
			const int weight = min(c_tileWidthHeight, max(0, fillInfo.cols[rc] - y));
			if (compareTile(c_tileWidthHeight, weight, canvas, rcOffset, y, image, width, height, tileX, tileY))
			{
				if (weight > bestMatch)
				{
					bestMatch = weight;
					bestPos = tileIndex(rcOffset, y);
					if (bestMatch == c_tileWidthHeight)
					{
						break;
					}
				}
			}
		}
	}

	if (bestPos == c_nullTileIndex)
	{
		return c_nullTileIndex;
	}

	const int x = bestPos % c_tilesCanvasWidthHeight;
	const int y = bestPos / c_tilesCanvasWidthHeight;
	const int row = x / c_tileWidthHeight;
	const int col = y / c_tileWidthHeight;

	fillInfo.rows[col] = max(fillInfo.rows[col], x + c_tileWidthHeight);
	fillInfo.cols[row] = max(fillInfo.cols[row], y + c_tileWidthHeight);

	copyRect(image, width, height, tileX, tileY, canvas, x, y);

	return bestPos;
}

static bool isEmptyTile(uint8* image, int width, int, int tileX, int tileY)
{
	for (int y = 0; y < c_tileWidthHeight; y++)
	{
		const uint8* imagePixels = image + (tileY + y) * width + tileX;
		for (int x = 0; x < c_tileWidthHeight; x++)
		{
			if (*imagePixels++ != 0)
			{
				return false;
			}
		}
	}

	return true;
}

bool RowColMapEncoder::encodeLayer(FillInfo& fillInfo, const void* pixels, int width, int height, uint8* canvas, uint32* palette, uint32* indices)
{
	std::fill_n(indices, (width * height) / (c_tileWidthHeight * c_tileWidthHeight), c_nullTileIndex);

	std::vector<uint8> indexedImage(width * height);
	
	if (!quantize(pixels, width, height, &indexedImage[0], palette, true))
	{
		return false;
	}

	bool fail = false;

	uint32* tileIndex = indices;
	for (int y = 0; y < height; y += c_tileWidthHeight)
	{
		if (fail)
		{
			break;
		}
		for (int x = 0; x < width; x += c_tileWidthHeight)
		{
			if (isEmptyTile(&indexedImage[0], width, height, x, y))
			{
				*tileIndex++ = c_nullTileIndex;
				continue;
			}

			const uint32 index = placeTile(fillInfo, &canvas[0], &indexedImage[0], width, height, x, y);
			if (index == c_nullTileIndex)
			{
				fail = true;
				break;
			}

			*tileIndex++ = index;
		}
	}

	return !fail;
}

bool RowColMapEncoder::encodeLayers(void* tilesCanvas, const void* layer1Pixels, const void* layer0Pixels, uint32* layer1Palette, uint32* layer0Palette, uint32* layer1Indices, uint32* layer0Indices)
{
	std::vector<uint8> canvas(c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight);

	FillInfo fillInfo;
	std::fill_n(fillInfo.cols, 32, 0);
	std::fill_n(fillInfo.rows, 32, 0);

	if (!encodeLayer(fillInfo, layer1Pixels, c_layer1Width, c_layer1Height, &canvas[0], layer1Palette, layer1Indices)
		|| !encodeLayer(fillInfo, layer0Pixels, c_layer0Width, c_layer0Height, &canvas[0], layer0Palette, layer0Indices)
	)
	{
		return false;
	}

	std::vector<uint8> canvas4bpp(c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight / 2);
	indexed8ToIndexed4(&canvas[0], &canvas4bpp[0], c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight);		
	swizzle4(&canvas4bpp[0], tilesCanvas, c_tilesCanvasWidthHeight, c_tilesCanvasWidthHeight);

	return true;
}

}
