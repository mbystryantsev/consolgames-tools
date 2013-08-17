#include "WiiFormats.h"
#include <cstring>

namespace ShatteredMemories
{

const char* WiiFormats::imageFormatToString(ImageFormat format)
{
	switch (format)
	{
	case imageFormatI4:
		return "i4";
	case imageFormatI8:
		return "i8";
	case imageFormatIA4:
		return "ia4";
	case imageFormatIA8:
		return "ia8";
	case imageFormatRGB565:
		return "rgb565";
	case imageFormatRGB5A3:
		return "rgb5a3";
	case imageFormatRGBA8:
		return "rgba";
	case imageFormatC4:
		return "c4";
	case imageFormatC8:
		return "c8";
	case imageFormatC14X2:
		return "c14x2";
	case imageFormatDXT1:
		return "dxt1";
	}

	return "undefined";
}

WiiFormats::ImageFormat WiiFormats::imageFormatFromString(const char* str)
{
	if (strcmp(str, "i4") == 0)
	{
		return imageFormatI4;
	}
	if (strcmp(str, "i8") == 0)
	{
		return imageFormatI8;
	}
	if (strcmp(str, "ia4") == 0)
	{
		return imageFormatIA4;
	}
	if (strcmp(str, "ia8") == 0)
	{
		return imageFormatIA8;
	}
	if (strcmp(str, "rgb565") == 0)
	{
		return imageFormatRGB565;
	}
	if (strcmp(str, "rgb5a3") == 0)
	{
		return imageFormatRGB5A3;
	}
	if (strcmp(str, "rgba") == 0)
	{
		return imageFormatRGBA8;
	}
	if (strcmp(str, "c4") == 0)
	{
		return imageFormatC4;
	}
	if (strcmp(str, "c8") == 0)
	{
		return imageFormatC8;
	}
	if (strcmp(str, "c14x2") == 0)
	{
		return imageFormatC14X2;
	}
	if (strcmp(str, "dxt1") == 0)
	{
		return imageFormatDXT1;
	}

	return imageFormatUndefined;
}

const char* WiiFormats::paletteFormatToString(PaletteFormat format)
{
	switch (format)
	{
	case paletteFormatNone:
		return "none";
	case paletteFormatIA8:
		return "ia8";
	case paletteFormatRGB565:
		return "rgb565";
	case paletteFormatRGB5A3:
		return "rgb5a3";
	}

	return "undefined";
}

WiiFormats::PaletteFormat WiiFormats::paletteFormatFromString(const char* str)
{
	if (strcmp(str, "none") == 0)
	{
		return paletteFormatNone;
	}
	if (strcmp(str, "ia8") == 0)
	{
		return paletteFormatIA8;
	}
	if (strcmp(str, "rgb565") == 0)
	{
		return paletteFormatRGB565;
	}
	if (strcmp(str, "rgb5a3") == 0)
	{
		return paletteFormatRGB5A3;
	}

	return paletteFormatUndefined;
}

}
