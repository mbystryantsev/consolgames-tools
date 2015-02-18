#include "PSFormats.h"
#include <cstring>
#include <algorithm>

namespace ShatteredMemories
{

const uint32 PSFormats::encodedRasterSize(ImageFormat format, int width, int height)
{
	if (format == imageFormatIndexed4)
	{
		return std::max(32, width) * height / 2;
	}
	if (format == imageFormatIndexed8)
	{
		return std::max(16, width) * height;
	}
	if (format == imageFormatRGBA16)
	{
		return width * height * 2;
	}
	if (format == imageFormatRGBA)
	{
		return width * height * 4;
	}

	return 0;
}

const char* PSFormats::imageFormatToString(ImageFormat format)
{
	switch (format)
	{
	case imageFormatIndexed4:
		return "indexed4";
	case imageFormatIndexed8:
		return "indexed8";
	case imageFormatRGBA16:
		return "rgba16";
	case imageFormatRGBA:
		return "rgba";
	}

	return "undefined";
}

PSFormats::ImageFormat PSFormats::imageFormatFromString(const char* str)
{
	if (strcmp(str, "indexed4") == 0)
	{
		return imageFormatIndexed4;
	}
	if (strcmp(str, "indexed8") == 0)
	{
		return imageFormatIndexed8;
	}
	if (strcmp(str, "rgba16") == 0)
	{
		return imageFormatRGBA16;
	}
	if (strcmp(str, "rgba") == 0)
	{
		return imageFormatRGBA;
	}

	return imageFormatUndefined;
}

const char* PSFormats::paletteFormatToString(PaletteFormat format)
{
	switch (format)
	{
	case paletteFormatNone:
		return "none";
	case paletteFormatRGBA:
		return "rgba";
	}

	return "undefined";
}

PSFormats::PaletteFormat PSFormats::paletteFormatFromString(const char* str)
{
	if (strcmp(str, "none") == 0)
	{
		return paletteFormatNone;
	}
	if (strcmp(str, "rgba") == 0)
	{
		return paletteFormatRGBA;
	}

	return paletteFormatUndefined;
}

}
