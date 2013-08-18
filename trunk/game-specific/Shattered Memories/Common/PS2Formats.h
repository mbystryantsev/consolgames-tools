#pragma once
#include <core.h>

namespace ShatteredMemories
{

class PS2Formats
{
public:
	enum ImageFormat
	{
		imageFormatUndefined = -1,
		imageFormatIndexed4 = 0,
		imageFormatIndexed8 = 1,
		imageFormatRGBA = 2
	};

	enum PaletteFormat
	{
		paletteFormatUndefined = -2,
		paletteFormatNone = -1,
		paletteFormatRGBA = 0
	};

	static const uint32 encodedRasterSize(ImageFormat format, int width, int height);
	static const char* imageFormatToString(ImageFormat format);
	static ImageFormat imageFormatFromString(const char* str);
	static const char* paletteFormatToString(PaletteFormat format);
	static PaletteFormat paletteFormatFromString(const char* str);
};

}
