#include "MapDecoder.h"
#include "MapCommon.h"
#include <vector>

namespace Origins
{

static void copyTile(const uint32_t* canvas, int tileX, int tileY, uint32_t* dest, int destX, int destY, int destWidth, int destHeight)
{
	for (int y = 0; y < 16; y++)
	{
		if (destY + y >= destHeight || tileY + y >= c_tilesCanvasWidthHeight)
		{
			break;
		}

		uint32_t* dst = dest + (destY + y) * destWidth + destX;
		const uint32_t* src = canvas + (tileY + y) * c_tilesCanvasWidthHeight + tileX;
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

static bool decodeLayer(void* result, const void* tilesCanvas, const uint32_t* indexes, const uint32_t* palette, int width, int height)
{
	std::vector<uint32_t> canvas(c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight);
	{
		std::vector<uint8_t> tilesData(c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight / 2);
		deswizzle4(tilesCanvas, &tilesData[0], c_tilesCanvasWidthHeight, c_tilesCanvasWidthHeight);
		indexed4ToRGBA(&tilesData[0], palette, &canvas[0], c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight);
	}

	uint32_t* dest = static_cast<uint32_t*>(result);
	const uint32_t* idxPtr = indexes;

	std::fill_n(dest, width * height, palette[0]);

	for (int y = 0; y < height; y+=16)
	{
		for (int x = 0; x < width; x+=16)
		{
			const uint32_t index = *idxPtr++;
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

bool MapDecoder::decodeLayer1(void* result, const void* tilesCanvas, const uint32_t* indexes, const uint32_t* palette)
{
	return decodeLayer(result, tilesCanvas, indexes, palette, c_layer1Width, c_layer1Height);
}

bool MapDecoder::decodeLayer0(void* result, const void* tilesCanvas, const uint32_t* indexes, const uint32_t* palette)
{
	return decodeLayer(result, tilesCanvas, indexes, palette, c_layer0Width, c_layer0Height);
}

bool MapDecoder::decodeBG(void* result, const void* bgData, const uint32_t* palette)
{
	uint8_t raster[c_bgWidthHeight * c_bgWidthHeight / 2];
	deswizzle4(bgData, raster, c_bgWidthHeight, c_bgWidthHeight);
	indexed4ToRGBA(raster, palette, static_cast<uint32_t*>(result), c_bgWidthHeight * c_bgWidthHeight);
	return true;
}

}

