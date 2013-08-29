#pragma once
#include <core.h>

namespace Origins
{

class MapDecoder
{
public:
	static bool decodeLayer1(void* result, const void* tilesCanvas, const uint32* indexes, const uint32* palette);
	static bool decodeLayer0(void* result, const void* tilesCanvas, const uint32* indexes, const uint32* palette);
	static bool decodeBG(void* result, const void* bgData, const uint32* palette);
};

}