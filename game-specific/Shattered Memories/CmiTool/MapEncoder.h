#pragma once
#include <core.h>

namespace Origins
{

class MapEncoder
{
public:
	virtual bool encodeLayers(void* tilesCanvas, const void* layer1Pixels, const void* layer0Pixles, uint32* layer1palette, uint32* layer0Palette, uint32* layer0Indices, uint32* layer1Indices) = 0;
	virtual bool encodeBG(const void* pixels, void* result, uint32* palette);

protected:
	bool quantize(const void* pixels, int width, int height, void* result, uint32* palette, bool indexed8 = false);
};

}
