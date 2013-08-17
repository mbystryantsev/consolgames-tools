#pragma once

namespace ShatteredMemories
{

// http://wiki.tockdom.com/wiki/Image_Formats
class WiiFormats
{
public:
	enum ImageFormat
	{
		//! invalid
		imageFormatUndefined = -1,

		//! gray, 4bpp
		imageFormatI4 = 0,

		//! gray, 8bpp
		imageFormatI8 = 1,

		//! gray + alpha, 8bpp
		imageFormatIA4 = 2,

		//! gray + alpha, 16bpp
		imageFormatIA8 = 3,

		//! 16bpp
		imageFormatRGB565 = 4,

		//! 16bpp
		imageFormatRGB5A3 = 5,

		//! 32bpp
		imageFormatRGBA8 = 6,

		//! 4bpp
		imageFormatC4 = 8,

		//! 8bpp
		imageFormatC8 = 9,

		//! 16bpp
		imageFormatC14X2 = 10,

		//! 4bpp
		imageFormatDXT1 = 14
	};

	enum PaletteFormat
	{
		paletteFormatUndefined = -2,
		paletteFormatNone = -1,
		paletteFormatIA8 = 0,
		paletteFormatRGB565 = 1,
		paletteFormatRGB5A3 = 2
	};

	static const char* imageFormatToString(ImageFormat format);
	static ImageFormat imageFormatFromString(const char* str);
	static const char* paletteFormatToString(PaletteFormat format);
	static PaletteFormat paletteFormatFromString(const char* str);
};

}
