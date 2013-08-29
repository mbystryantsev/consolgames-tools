#include "MapDecoder.h"
#include "MapCommon.h"
#include <vector>

namespace Origins
{

static void copyTile(const uint32* canvas, int tileX, int tileY, uint32* dest, int destX, int destY, int destWidth, int destHeight)
{
	for (int y = 0; y < 16; y++)
	{
		if (destY + y >= destHeight || tileY + y >= c_tilesCanvasWidthHeight)
		{
			break;
		}

		uint32* dst = dest + (destY + y) * destWidth + destX;
		const uint32* src = canvas + (tileY + y) * c_tilesCanvasWidthHeight + tileX;
		for (int x = 0; x < c_tileWidthHeight; x++)
		{
			if (destX + x >= destWidth || tileX + x >= c_tilesCanvasWidthHeight)
			{
				break;
			}

			*dst++ = *src++;
		}
	}

}

static bool decodeLayer(void* result, const void* tilesCanvas, const uint32* indexes, const uint32* palette, int width, int height)
{
	std::vector<uint32> canvas(c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight);
	{
		std::vector<uint8> tilesData(c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight / 2);
		deswizzle4(tilesCanvas, &tilesData[0], c_tilesCanvasWidthHeight, c_tilesCanvasWidthHeight);
		indexed4ToRGBA(&tilesData[0], palette, &canvas[0], c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight);
	}

	uint32* dest = static_cast<uint32*>(result);
	const uint32* idxPtr = indexes;

	std::fill_n(dest, width * height, palette[0]);

	for (int y = 0; y < height; y+=16)
	{
		for (int x = 0; x < width; x+=16)
		{
			const uint32 index = *idxPtr++;
			if (index == -1)
			{
				continue;
			}

			const int tx = index % c_tilesCanvasWidthHeight;
			const int ty = index / c_tilesCanvasWidthHeight;
			copyTile(&canvas[0], tx, ty, dest, x, y, width, height);
		}
	}

	return true;
}

bool MapDecoder::decodeLayer1(void* result, const void* tilesCanvas, const uint32* indexes, const uint32* palette)
{
	return decodeLayer(result, tilesCanvas, indexes, palette, c_layer1Width, c_layer1Height);
}

bool MapDecoder::decodeLayer0(void* result, const void* tilesCanvas, const uint32* indexes, const uint32* palette)
{
	return decodeLayer(result, tilesCanvas, indexes, palette, c_layer0Width, c_layer0Height);
}

bool MapDecoder::decodeBG(void* result, const void* bgData, const uint32* palette)
{
	uint8 raster[c_bgWidthHeight * c_bgWidthHeight / 2];
	deswizzle4(bgData, raster, c_bgWidthHeight, c_bgWidthHeight);
	indexed4ToRGBA(raster, palette, static_cast<uint32*>(result), c_bgWidthHeight * c_bgWidthHeight);
	return true;
}

}

