#pragma once
#include <core.h>

namespace Origins
{

enum
{
	c_tilesCanvasWidthHeight = 512,
	c_layer1Width = 1920,
	c_layer1Height = 1088,
	c_layer0Width = c_layer1Width / 2,
	c_layer0Height = c_layer1Height / 2,
	c_bgWidthHeight = 128,
	c_tileWidthHeight = 16,
	c_nullTileIndex = -1
};

void deswizzle8(const void* src, void* dest, int width, int height);
void deswizzle4(const void* src, void* dest, int width, int height);
void swizzle8(const void* src, void* dest, int width, int height);
void swizzle4(const void* src, void* dest, int width, int height);
bool savePNG(const void* image, int width, int height, const char* filename);
void indexed4ToRGBA(const void* indexed, const uint32* palette, uint32* rgba, int count);
void indexed8ToRGBA(const void* indexed, const uint32* palette, uint32* rgba, int count);
void indexed8ToIndexed4(const void* indexed8, void* indexed4, int count);
void indexed4ToIndexed8(const void* indexed4, void* indexed8, int count);

}
