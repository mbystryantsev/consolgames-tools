#include "PS2Formats.h"
#include <cstring>

namespace ShatteredMemories
{

const uint32 PS2Formats::encodedRasterSize(ImageFormat format, int width, int height)
{
	if (format == imageFormatIndexed4)
	{
		return max(32, width) * height / 2;
	}
	if (format == imageFormatIndexed8)
	{
		return max(16, width) * height;
	}
	if (format == imageFormatRGBA)
	{
		return width * height * 4;
	}

	return 0;
}

const char* PS2Formats::imageFormatToString(ImageFormat format)
{
	switch (format)
	{
	case imageFormatIndexed4:
		return "indexed4";
	case imageFormatIndexed8:
		return "indexed8";
	case imageFormatRGBA:
		return "rgba";
	}

	return "undefined";
}

PS2Formats::ImageFormat PS2Formats::imageFormatFromString(const char* str)
{
	if (strcmp(str, "indexed4") == 0)
	{
		return imageFormatIndexed4;
	}
	if (strcmp(str, "indexed8") == 0)
	{
		return imageFormatIndexed8;
	}
	if (strcmp(str, "rgba") == 0)
	{
		return imageFormatRGBA;
	}

	return imageFormatUndefined;
}

const char* PS2Formats::paletteFormatToString(PaletteFormat format)
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

PS2Formats::PaletteFormat PS2Formats::paletteFormatFromString(const char* str)
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
