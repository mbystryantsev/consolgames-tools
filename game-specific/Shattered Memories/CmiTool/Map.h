#pragma once
#include <core.h>
#include <string>
#include <vector>

namespace Consolgames
{
class Stream;
}

namespace Origins
{

class Map
{
public:
	Map(const std::wstring& filename);
	Map(const std::string& filename);
	Map(Consolgames::Stream* stream);

	bool isNull() const;

	bool saveLayer1(const std::string& filename);
	bool saveLayer0(const std::string& filename);
	bool saveBG(const std::string& filename);

	bool save(const std::string& filename);

private:
	struct Header
	{
		uint32 signature;
		uint32 width;
		uint32 height;
		uint32 size;
		uint32 layer1TileCount;
		uint32 layer0TileCount;
		uint32 bgLayerWH;
		uint32 tilesCanvasWH;
	};

private:
	void open(Consolgames::Stream* stream);

private:
	std::vector<uint32> m_layer1Raster;
	std::vector<uint32> m_layer0Raster;
	std::vector<uint32> m_bgRaster;
};

}
