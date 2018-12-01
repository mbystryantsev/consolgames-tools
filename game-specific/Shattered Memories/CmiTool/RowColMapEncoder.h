#pragma once
#include "MapEncoder.h"

namespace Origins
{

struct FillInfo;

class RowColMapEncoder : public MapEncoder
{
public:
	virtual bool encodeLayers(void* tilesCanvas, const void* layer1Pixels, const void* layer0Pixels, uint32_t* layer1palette, uint32_t* layer0Palette, uint32_t* layer1Indices, uint32_t* layer0Indices) override;

private:
	bool encodeLayer(FillInfo& fillInfo, const void* pixels, int width, int height, uint8_t* canvas, uint32_t* palette, uint32_t* indices);
};

}
