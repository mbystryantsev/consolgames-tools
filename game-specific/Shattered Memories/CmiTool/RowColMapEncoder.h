#pragma once
#include "MapEncoder.h"

namespace Origins
{

struct FillInfo;

class RowColMapEncoder : public MapEncoder
{
public:
	virtual bool encodeLayers(void* tilesCanvas, const void* layer1Pixels, const void* layer0Pixels, uint32* layer1palette, uint32* layer0Palette, uint32* layer1Indices, uint32* layer0Indices) override;

private:
	bool encodeLayer(FillInfo& fillInfo, const void* pixels, int width, int height, uint8* canvas, uint32* palette, uint32* indices);
};

}
