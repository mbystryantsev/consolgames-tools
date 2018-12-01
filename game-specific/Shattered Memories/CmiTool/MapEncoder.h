#pragma once
#include <core.h>

namespace Origins
{

class MapEncoder
{
public:
	virtual bool encodeLayers(void* tilesCanvas, const void* layer1Pixels, const void* layer0Pixles, uint32_t* layer1palette, uint32_t* layer0Palette, uint32_t* layer0Indices, uint32_t* layer1Indices) = 0;
	virtual bool encodeBG(const void* pixels, void* result, uint32_t* palette);

protected:
	bool quantize(const void* pixels, int width, int height, void* result, uint32_t* palette, bool indexed8 = false);
};

}
