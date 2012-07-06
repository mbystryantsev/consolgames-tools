#pragma once
#include "MessageSet.h"
#include "FontInfo.h"
#include <QPixmap>

#include <ft2build.h>
#include FT_FREETYPE_H

// For IDE parsing
#ifdef _DEBUG
#include <freetype/freetype.h>
#include <freetype/ftglyph.h>
#include <freetype/ftbitmap.h>
#include <freetype/ftadvanc.h>
#include <freetype/ftimage.h>
#include <freetype/ftoutln.h>
#endif

#define NVTT


// GIM Palette Formats
/*
enum GimPixelFormat
{
	pRgb565   = 0x00,
	Argb1555 = 0x01,
	Argb4444 = 0x02,
	Argb8888 = 0x03,
};


// GIM Data Formats
enum GimDataFormat
{
	Rgb565   = 0x00,
	Argb1555 = 0x01,
	Argb4444 = 0x02,
	Argb8888 = 0x03,
	Index4   = 0x04,
	Index8   = 0x05,
	Index16  = 0x06,
	Index32  = 0x07,
};
*/



#if defined(NVTT)
namespace nv
{
	class Image;
}
#endif

class GrayImage
{
public:
	GrayImage();
	GrayImage(int width, int height);

	void allocate(int width, int height);
	int width() const;
	int height() const;
	uint8* scanLine(int line);
	uint8* data();
	uint8& pixel(int x, int y);
	const uint8& pixel(int x, int y) const;
#if defined(NVTT)
	nv::Image toNvImage() const;
#endif

protected:
	int m_width;
	int m_height;
	std::vector<uint8> m_data;
};

class FontGenerator
{
public:
	FontGenerator();
	~FontGenerator();

	void addMessage(const QString& str);
	void addMessages(const QStringList& list);
	void setPixelSize(int size);
	QString alphabet() const;
	QPixmap texture() const;
	QList<CharRecord> charInfo() const;

private:

	void drawChar(nv::Image& image, uint32 c, int& x, int& y) const;

	void generateAlphabet() const;
	void generateFont() const;
	void generateFontData() const;

private:
	//! Generate 4bpp PSP raster raw data
	static void generatePSPRaster(const GrayImage& image, std::vector<uint8>& data);
	static void writeGIMFile(const char* filename, const std::vector<uint8>& raster);

private:
	QMap<QChar, int> m_charRepeats;
	int m_fontSize;

	mutable bool m_invalidated;
	mutable QString m_alphabet;
	mutable QList<CharRecord> m_charInfo;
	mutable QPixmap m_fontTexture;

	static int s_sourceSize;

	FT_Library m_ftLibrary;
	FT_Face m_fontFace;
};