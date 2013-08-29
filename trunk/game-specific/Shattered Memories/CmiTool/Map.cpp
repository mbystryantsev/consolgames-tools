#include "Map.h"
#include "MapDecoder.h"
#include "RowColMapEncoder.h"
#include "MapCommon.h"
#include <FileStream.h>
#include <Image.h>

using namespace Consolgames;

namespace Origins
{

Map::Map()
{
}

Map::Map(const std::wstring& filename)
{
	FileStream stream(filename, Stream::modeRead);
	if (stream.opened())
	{
		open(&stream);
	}
}

Map::Map(const std::string& filename)
{
	FileStream stream(filename, Stream::modeRead);
	if (stream.opened())
	{
		open(&stream);
	}
}

Map::Map(Stream* stream)
{
	open(stream);
}

void Map::open(Stream* stream)
{
	Header header;

	header.signature = stream->readUInt32();
	header.width = stream->readUInt32();
	header.height = stream->readUInt32();
	header.size = stream->readUInt32();
	header.layer1TileCount = stream->readUInt32();
	header.layer0TileCount = stream->readUInt32();
	header.bgLayerWH = stream->readUInt32();
	header.tilesCanvasWH = stream->readUInt32();

	uint32 palLayer0[16];
	stream->read(palLayer0, sizeof(palLayer0));

	uint32 palLayer1[16];
	stream->read(palLayer1, sizeof(palLayer1));

	uint32 palBG[16];
	stream->read(palBG, sizeof(palBG));

	std::vector<uint8> bgData(128 * 128 / 2);
	stream->read(&bgData[0], bgData.size());

	std::vector<uint32> indexesLayer1(0x2000);
	stream->read(&indexesLayer1[0], indexesLayer1.size() * 4);

	std::vector<uint32> indexesLayer0(0x800);
	stream->read(&indexesLayer0[0], indexesLayer0.size() * 4);

	std::vector<uint8> tilesCanvas(512 * 512 / 2);
	stream->read(&tilesCanvas[0], tilesCanvas.size());

	m_layer1Raster.resize(c_layer1Width * c_layer1Height);
	MapDecoder::decodeLayer1(&m_layer1Raster[0], &tilesCanvas[0], &indexesLayer1[0], palLayer1);

	m_layer0Raster.resize(c_layer0Width * c_layer0Height);
	MapDecoder::decodeLayer0(&m_layer0Raster[0], &tilesCanvas[0], &indexesLayer0[0], palLayer0);

	m_bgRaster.resize(c_bgWidthHeight * c_bgWidthHeight);
	MapDecoder::decodeBG(&m_bgRaster[0], &bgData[0], palBG);
}

bool Map::saveLayer1(const std::string& filename)
{
	if (m_layer1Raster.empty())
	{
		return false;
	}

	return savePNG(&m_layer1Raster[0], 1920, 1088, filename.c_str());
}

bool Map::saveLayer0(const std::string& filename)
{
	if (m_layer0Raster.empty())
	{
		return false;
	}

	return savePNG(&m_layer0Raster[0], 1920 / 2, 1088 / 2, filename.c_str());
}

bool Map::saveBG(const std::string& filename)
{
	if (m_bgRaster.empty())
	{
		return false;
	}

	return savePNG(&m_bgRaster[0], 128, 128, filename.c_str());
}

bool Map::save(const std::string& filename)
{
	if (m_bgRaster.empty() || m_layer1Raster.empty() || m_layer0Raster.empty())
	{
		return false;
	}

	std::vector<uint8> tilesCanvas(c_tilesCanvasWidthHeight * c_tilesCanvasWidthHeight / 2);

	RowColMapEncoder encoder;

	uint32 palBG[16];
	std::vector<uint8> bgPixels(c_bgWidthHeight * c_bgWidthHeight / 2);

	if (!encoder.encodeBG(&m_bgRaster[0], &bgPixels[0], palBG))
	{
		return false;
	}

	uint32 palLayer1[16];
	uint32 palLayer0[16];

	std::vector<uint32> indicesLayer1(0x2000);
	std::vector<uint32> indicesLayer0(0x800);

	if (!encoder.encodeLayers(&tilesCanvas[0], &m_layer1Raster[0], &m_layer0Raster[0], palLayer1, palLayer0, &indicesLayer1[0], &indicesLayer0[0]))
	{
		return false;
	}

	FileStream mapFile(filename, Stream::modeWrite);
	if (!mapFile.opened())
	{
		return false;
	}

	mapFile.writeUInt32(0x31494D43); // "CMI1" sugnature
	mapFile.writeUInt32(c_layer1Width);
	mapFile.writeUInt32(c_layer1Height);
	mapFile.writeUInt32(0x2C0E0); // File size
	mapFile.writeUInt32(0x2000); // Layer1 tile count
	mapFile.writeUInt32(0x800); // Layer0 tile count
	mapFile.writeUInt32(c_bgWidthHeight);
	mapFile.writeUInt32(c_tilesCanvasWidthHeight);

	mapFile.write(palLayer0, sizeof(palLayer0));
	mapFile.write(palLayer1, sizeof(palLayer0));
	mapFile.write(palBG, sizeof(palBG));

	mapFile.write(&bgPixels[0], bgPixels.size());
	mapFile.write(&indicesLayer1[0], indicesLayer1.size() * 4);
	mapFile.write(&indicesLayer0[0], indicesLayer0.size() * 4);
	mapFile.write(&tilesCanvas[0], tilesCanvas.size());

	return true;
}

bool Map::loadLayer1(const std::string& filename)
{
	if (m_layer1Raster.empty())
	{
		m_layer1Raster.resize(c_layer1Width * c_layer1Height * 4);
	}
	return loadImage(filename.c_str(), &m_layer1Raster[0], c_layer1Width, c_layer1Height);
}

bool Map::loadLayer0(const std::string& filename)
{
	if (m_layer0Raster.empty())
	{
		m_layer0Raster.resize(c_layer0Width * c_layer0Height * 4);
	}
	return loadImage(filename.c_str(), &m_layer0Raster[0], c_layer0Width, c_layer0Height);
}

bool Map::loadBG(const std::string& filename)
{
	if (m_bgRaster.empty())
	{
		m_bgRaster.resize(c_bgWidthHeight * c_bgWidthHeight * 4);
	}
	return loadImage(filename.c_str(), &m_bgRaster[0], c_bgWidthHeight, c_bgWidthHeight);
}

}