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
	bool open(const std::wstring& filename);
	bool open(const std::string& filename);
	bool open(Consolgames::Stream* stream);

	bool saveLayer1(const std::string& filename);
	bool saveLayer0(const std::string& filename);
	bool saveBG(const std::string& filename);

	bool loadLayer1(const std::string& filename);
	bool loadLayer0(const std::string& filename);
	bool loadBG(const std::string& filename);

	bool save(const std::string& filename);

private:
	struct Header
	{
		uint32_t signature;
		uint32_t width;
		uint32_t height;
		uint32_t size;
		uint32_t layer1TileCount;
		uint32_t layer0TileCount;
		uint32_t bgLayerWH;
		uint32_t tilesCanvasWH;
	};

private:
	std::vector<uint32_t> m_layer1Raster;
	std::vector<uint32_t> m_layer0Raster;
	std::vector<uint32_t> m_bgRaster;
};

}
