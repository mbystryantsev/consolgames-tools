#include "FontGenerator.h"
#include <QRegExp>
#include <QPair>
#include <QPainter>
#include <QFont>
#include <QFontMetrics>
#include <QImage>
#include <QFile>

#define VERIFY(expr) expr

#include <nvimage/Image.h>
#include <nvimage/FloatImage.h>
#include <nvimage/Filter.h>
#include <nvimage/ImageIO.h>
#include <nvmath/Color.h>
#include <memory.h>
#include <fstream>

void gaussian(nv::Image& image, nv::Image& result)
{

	nv::Image tmp(image);

	double linc_r = 0;
	double linc_g = 0;
	double linc_b = 0;

	//Remember these ?
	static const int gauss_w = 7;                            // Level(+1)
	static const int mask[gauss_w] = {1,6,15,20,15,6,1}; // Mask
	int gauss_sum = 64;                           // Sum

	//For every pixel on the temporary bitmap ...
	for(int i=gauss_w-1;i<tmp.height()-1;i++)
	{
		for(int j=1;j<tmp.width()-1;j++)
		{
			// 			sumr=0;
			// 			sumg=0;
			// 			sumb=0;
			for(int k=0;k<gauss_w;k++)
			{
				nv::Color32 color = image.pixel(j, i - (gauss_w - 1) + k);
				linc_r += color.r * mask[k];
				linc_g += color.g * mask[k];
				linc_b += color.b * mask[k];
			}
			tmp.pixel(i, j) = nv::Color32(linc_r/gauss_sum, linc_g/gauss_sum, linc_b/gauss_sum);
		}
	}
	//For every pixel on the output bitmap ...
	for(int i=1;i<result.height()-1;i++)
	{
		for(int j=gauss_w;j<result.width()-1;j++)
		{
			// 			sumr=0;
			// 			sumg=0;
			// 			sumb=0;
			for(int k=0;k<gauss_w;k++)
			{
				nv::Color32 color = tmp.pixel(j - (gauss_w - 1) + k, i);

				linc_r += color.r * mask[k];
				linc_g += color.g * mask[k];
				linc_b += color.b * mask[k];
			}

			result.pixel(i, j) = nv::Color32(linc_r / gauss_sum, linc_g / gauss_sum, linc_b / gauss_sum);
		}
	}
}

int pixelSum(const nv::Image& image, int x1, int y1, int x2, int y2)
{
	int sum = 0;
	for (int y = y1; y <= y2; y++)
	{
		for (int x = x1; x <= x2; x++)
		{
			sum += image.pixel(x, y).r;
		}
	}
	return sum;
}


void blur(nv::Image& image)
{
	nv::Image result(image);
	for (int y = 0; y < image.height(); y++)
	{
		for (int x = 0; x < image.width(); x++)
		{
			const int bX1 = qMax<int>(x - 2, 0);
			const int bX2 = qMin<int>(x + 2, image.width() - 1);
			const int bY1 = qMax<int>(y - 2, 0);
			const int bY2 = qMin<int>(y + 2, image.height() - 1);

			int sum = pixelSum(image, bX1, bY1, bX2, bY2);
			int c = qMin(sum / ((bX2 - bX1) * (bY2 - bY1)), 255);
			result.pixel(x, y) = nv::Color32(c, c, c);
		}
	}
	image = result;
}



int FontGenerator::s_sourceSize = 18;

FontGenerator::FontGenerator() : m_invalidated(true), m_fontSize(-1)
{
	FT_Init_FreeType(&m_ftLibrary);
	FT_New_Face(m_ftLibrary, "times_ce.ttf", 0, &m_fontFace);
	setPixelSize(18);
}

FontGenerator::~FontGenerator()
{
	FT_Done_Face(m_fontFace);
	FT_Done_FreeType(m_ftLibrary);
}

void FontGenerator::addMessage(const QString& str)
{
	QRegExp varExp("\\{VAR:[0-9a-f][0-9a-f]\\}");
	QString s(str);
	s.replace("\r\n", "\n").replace("\n-\n", "\r").replace(varExp, "");
	foreach (QChar c, s)
	{
		m_charRepeats[c]++;
	}
	m_charRepeats['\0']++;
}

void FontGenerator::addMessages(const QStringList& list)
{
	foreach (const QString& str, list)
	{
		addMessage(str);
	}
}

QString FontGenerator::alphabet() const
{
	if (m_invalidated)
	{
		generateAlphabet();
	}
	return m_alphabet;
}

QPixmap FontGenerator::texture() const
{
	if (m_invalidated)
	{
		generateFont();
	}
	return m_fontTexture;
}

void FontGenerator::generateAlphabet() const
{
	QVector<QPair<int,QChar>> pairs;
	pairs.reserve(m_charRepeats.size());
	foreach (QChar key, m_charRepeats.keys())
	{
		pairs.append(QPair<int,QChar>(m_charRepeats[key], key));
	}
	qSort(pairs);

	m_alphabet.clear();
	for (QVector<QPair<int,QChar>>::ConstIterator it = pairs.constEnd(); it != pairs.constBegin();)
	{
		it--;
		m_alphabet.append(it->second);
	}
}

void FontGenerator::generateFont() const
{
	if (!m_invalidated)
	{
		return;
	}

	generateAlphabet();
	generateFontData();


	m_invalidated = false;
}

void blur(QImage& image, const QRect& rect, int radius, bool alphaOnly = false)
{
	int tab[] = { 14, 10, 8, 6, 5, 5, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2 };
	int alpha = (radius < 1) ? 16 : (radius > 17) ? 1 : tab[radius-1];

	if (image.format() != QImage::Format_Indexed8)
	{
		return;
	}

	int r1 = rect.top();
	int r2 = rect.bottom();
	int c1 = rect.left();
	int c2 = rect.right();

	int bpl = image.bytesPerLine();
	int rgba;
	unsigned char* p;

	int i1 = 0;
	int i2 = 3;

	if (alphaOnly)
		i1 = i2 = (QSysInfo::ByteOrder == QSysInfo::BigEndian ? 0 : 3);

	for (int col = c1; col <= c2; col++)
	{
		p = image.scanLine(r1) + col * 4;
			rgba = *p << 4;

		p += bpl;
		for (int j = r1; j < r2; j++, *p += bpl)
				*p = (rgba += ((*p << 4) - rgba) * alpha / 16) >> 4;
	}

	for (int row = r1; row <= r2; row++)
	{
		p = image.scanLine(row) + c1 * 4;
		rgba = *p << 4;

		p++;
		for (int j = c1; j < c2; j++, p++)
			*p = (rgba += ((*p << 4) - rgba) * alpha / 16) >> 4;
	}

	for (int col = c1; col <= c2; col++)
	{
		p = image.scanLine(r2) + col * 4;
		rgba = *p << 4;

		p -= bpl;
		for (int j = r1; j < r2; j++, p -= bpl)
			*p = (rgba += ((*p << 4) - rgba) * alpha / 16) >> 4;
	}

	for (int row = r1; row <= r2; row++)
	{
		p = image.scanLine(row) + c2 * 4;
		for (int i = i1; i <= i2; i++)
			rgba = *p << 4;

		p--;
		for (int j = c1; j < c2; j++, p--)
			*p = (rgba += ((*p << 4) - rgba) * alpha / 16) >> 4;
	}
}

void blurred(QImage& image, const QRect& rect, int radius, bool alphaOnly = false)
{
	int tab[] = { 14, 10, 8, 6, 5, 5, 4, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2 };
	int alpha = (radius < 1)  ? 16 : (radius > 17) ? 1 : tab[radius-1];

	//image = image.convertToFormat(QImage::Format_ARGB32_Premultiplied);
	QImage& result = image;
	int r1 = rect.top();
	int r2 = rect.bottom();
	int c1 = rect.left();
	int c2 = rect.right();

	int bpl = result.bytesPerLine();
	int rgba[4];
	unsigned char* p;

	int i1 = 0;
	int i2 = 3;

	if (alphaOnly)
		i1 = i2 = (QSysInfo::ByteOrder == QSysInfo::BigEndian ? 0 : 3);

	for (int col = c1; col <= c2; col++) {
		p = result.scanLine(r1) + col * 4;
		for (int i = i1; i <= i2; i++)
			rgba[i] = p[i] << 4;

		p += bpl;
		for (int j = r1; j < r2; j++, p += bpl)
			for (int i = i1; i <= i2; i++)
				p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
	}

	for (int row = r1; row <= r2; row++) {
		p = result.scanLine(row) + c1 * 4;
		for (int i = i1; i <= i2; i++)
			rgba[i] = p[i] << 4;

		p += 4;
		for (int j = c1; j < c2; j++, p += 4)
			for (int i = i1; i <= i2; i++)
				p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
	}

	for (int col = c1; col <= c2; col++) {
		p = result.scanLine(r2) + col * 4;
		for (int i = i1; i <= i2; i++)
			rgba[i] = p[i] << 4;

		p -= bpl;
		for (int j = r1; j < r2; j++, p -= bpl)
			for (int i = i1; i <= i2; i++)
				p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
	}

	for (int row = r1; row <= r2; row++) {
		p = result.scanLine(row) + c2 * 4;
		for (int i = i1; i <= i2; i++)
			rgba[i] = p[i] << 4;

		p -= 4;
		for (int j = c1; j < c2; j++, p -= 4)
			for (int i = i1; i <= i2; i++)
				p[i] = (rgba[i] += ((p[i] << 4) - rgba[i]) * alpha / 16) >> 4;
	}
}

void FontGenerator::generateFontData() const
{
	{
		nv::Image canvas;
		canvas.allocate(512, 512);
		canvas.fill(nv::Color32(0));

		int x = 0;
		int y = 0;
		drawChar(canvas, 'j', x, y);
		drawChar(canvas, 'u', x, y);
		drawChar(canvas, 'm', x, y);
		drawChar(canvas, 'p', x, y);
		drawChar(canvas, ' ', x, y);
		drawChar(canvas, 't', x, y);
		drawChar(canvas, 'o', x, y);
		drawChar(canvas, ' ', x, y);
		drawChar(canvas, 'h', x, y);
		drawChar(canvas, 'e', x, y);
		drawChar(canvas, 'l', x, y);
		drawChar(canvas, 'l', x, y);
		drawChar(canvas, '!', x, y);

		//blur(canvas);
		nv::Image result(canvas);
		gaussian(canvas, result);
		nv::ImageIO::save("hell.tga", &result);
	}
	return;


	QImage texture(512, m_fontSize * 16, QImage::Format_ARGB32_Premultiplied);
	texture.fill(QColor(0, 0, 0, 0));

	QFont font("Times New Roman");
	font.setPixelSize(m_fontSize + 1);
	font.setWeight(62);
	font.setStretch(112);
	font.setBold(true);
	font.setStyleStrategy(QFont::PreferAntialias);
	QFontMetrics metrics(font);
		

	int x = 0;
	int row = 0;
	{
		QPainter painter(&texture);
		painter.setRenderHint(QPainter::SmoothPixmapTransform, true);
		painter.setFont(font);
		painter.setPen(Qt::white);

		m_charInfo.clear();
		foreach (QChar c, m_alphabet)
		{
			const int totalWidth = metrics.leftBearing(c) + metrics.width(c) + metrics.rightBearing(c);
			if (x + totalWidth >= texture.width())
			{
				row++;
				x = 0;
			}

			m_charInfo.append(CharRecord(x, row * m_fontSize, totalWidth));
			x += metrics.leftBearing(c);
			painter.drawText(x, row * m_fontSize + metrics.overlinePos() - metrics.descent(), QString(c));
			x += metrics.width(c) + metrics.rightBearing(c);

			//blurred(texture, QRect(m_charInfo.last().x, m_charInfo.last().y, totalWidth, m_fontSize), 5, true);
		}
	}

// 	for (int i = 0; i < texture.height(); i++)
// 	{
// 		QRgb* color = reinterpret_cast<QRgb*>(texture.scanLine(i));
// 		for (x = 0; x < texture.width(); x++)
// 		{
// 			if (*color != 0)
// 			{
// 				*color |= 0xFFFFFF;
// 			}
// 			color++;
// 		}
// 	}
	




	
// 	QImage blurTexture = texture.convertToFormat(QImage::Format_ARGB32_Premultiplied);
 	foreach (const CharRecord& record, m_charInfo)
 	{
 		//blur(texture, QRect(record.x, record.y, record.width, m_fontSize), 1, true);
 	}

	{
		QFile f("test.bin");
		f.open(QFile::WriteOnly);
		for (int i = 0; i < texture.height(); i++)
		{
			f.write(reinterpret_cast<char*>(texture.scanLine(i)), texture.bytesPerLine());
		}
	}

// 	QImage result(512, (row + 1) * m_fontSize * 2, QImage::Format_ARGB32_Premultiplied);
// 	result.fill(QColor(0, 0, 0, 0));
// 	{
// 		QPainter painter(&result);
// 		painter.drawImage(QPoint(0, 0), texture);
// 		painter.drawImage(QPoint(0, (row + 1) * m_fontSize), blurTexture);
// 	}
	

	m_fontTexture = QPixmap::fromImage(texture);
}

void FontGenerator::setPixelSize(int size)
{
	m_fontSize = size;
	FT_Set_Pixel_Sizes(m_fontFace, 0, m_fontSize + 1);
}


void FontGenerator::drawChar(nv::Image& image, uint32 c, int& x, int& y) const
{
	int glyphIndex = FT_Get_Char_Index(m_fontFace, c);
	FT_Load_Glyph(m_fontFace, glyphIndex, FT_LOAD_RENDER);
	FT_Bitmap bitmap = m_fontFace->glyph->bitmap;

	const int glyphWidth = m_fontFace->glyph->advance.x / 64 - m_fontFace->glyph->metrics.horiBearingX / 64 + 1;
	const int glyphHeight = m_fontSize;
	const int offsetX = 0;//m_fontFace->glyph->metrics.horiBearingX / 64;
	const int offsetY = m_fontSize - m_fontFace->glyph->bitmap_top - (m_fontSize / 4);
	//const int offsetY = m_fontFace->glyph->metrics.horiBearingY / 64;//m_fontFace->glyph->metrics.vertAdvance / 64 + m_fontFace->glyph->metrics.vertBearingY / 64;

	//m_fontFace->glyph->metrics.vertBearingY / 64;

	if (glyphWidth + x > 512)
	{
		y += m_fontSize;
		x = 0;
	}


	for (int iY = 0; iY < bitmap.rows; iY++)
	{
		if (iY + offsetY < 0 || iY + offsetY >= glyphHeight)
		{
			continue;
		}

		uint8* gray = &bitmap.buffer[iY * bitmap.pitch];
		nv::Color32* color = image.scanline(y + iY + offsetY) + offsetX + x;

		for (int iX = 0; iX < bitmap.width; iX++)
		{
			*color = nv::Color32(*gray, *gray, *gray);
			color++;
			gray++;
		}
	}

	x += glyphWidth;
}

void FontGenerator::generatePSPRaster(const GrayImage& image, std::vector<uint8>& data)
{
	const int tileWidth = image.width() / 16;  // 8 bytes per line
	const int tileHeight = (image.height() + 7) / 8; // 8 lines in tile

	data.resize(tileWidth * tileHeight * 32, 0);

	std::vector<uint8>::iterator pixelPair = data.begin();
	for (int tx = 0; tx < tileWidth; tx++)
	{
		for (int ty = 0; ty < tileHeight; ty++)
		{
			for (int y = ty * 8; y <= ty * 8 + 8; y++)
			{
				if (y >= image.height())
				{
					continue;
				}
				for (int x = 0; x < 8; x++)
				{
					const uint16 color1 = std::max(image.pixel(tx * 16 + x * 2 + 0, y) + 8, 255);
					const uint16 color2 = std::max(image.pixel(tx * 16 + x * 2 + 1, y) + 8, 255);
					*pixelPair++ = (color1 / 16) | ((color2 / 16) << 8);
				}
			}
		}
	}
}

#define writeUInt(v) write(reinterpret_cast<const char*>(&uint32(v)), 4)

void FontGenerator::writeGIMFile(const char* filename, const std::vector<uint8>& raster)
{
	static const char signature[16] = "MIG.00.1PSP";
	static const uint32 formatId = 2;
	static const uint32 magic0x10 = 0x10;
	static const uint32 magic0x03 = 0x03;

	const uint32 rasterSize = raster.size();
	//const uint32 pale

	const uint32 dataSize = raster.size() + 0;


	std::ofstream file;
	file.open(filename, std::ios_base::out);

	file.write(signature, sizeof(signature));
//	file.writeUInt(formatId);
//	file.writeUInt(dataSize);
	file.write(reinterpret_cast<const char*>(&magic0x10), 4);
	file.write(reinterpret_cast<const char*>(&magic0x10), 4);
	file.write(reinterpret_cast<const char*>(&magic0x03), 4);
	file.write(reinterpret_cast<const char*>(&dataSize), 4);
	file.write(reinterpret_cast<const char*>(&dataSize), 4);

	file.close();
}

#undef writeUInt

/*
void FontGenerator::drawChar(nv::Image& image, uint32 c, int& x, int& y) const
{
	int glyphIndex = FT_Get_Char_Index(m_fontFace, c);
	FT_Load_Glyph(m_fontFace, glyphIndex, FT_LOAD_RENDER | FT_LOAD_NO_AUTOHINT);
	FT_Bitmap bitmap = m_fontFace->glyph->bitmap;

	const int glyphWidth = m_fontFace->glyph->advance.x / 64;
	const int glyphHeight = s_sourceSize;
	const int offsetX = 0;//m_fontFace->glyph->metrics.horiBearingX / 64;
	const int offsetY = s_sourceSize - m_fontFace->glyph->bitmap_top - s_sourceSize / 4;//m_fontFace->glyph->metrics.vertBearingY / 64;

	nv::Image glyph;
	glyph.allocate(glyphWidth, glyphHeight);
	glyph.fill(nv::Color32(0));

	for (int iY = 0; iY < bitmap.rows; iY++)
	{
		if (iY + offsetY < 0 || iY + offsetY >= glyphHeight)
		{
			continue;
		}

		uint8* gray = &bitmap.buffer[iY * bitmap.pitch];
		nv::Color32* color = glyph.scanline(iY + offsetY) + offsetX;

		for (int iX = 0; iX < bitmap.width; iX++)
		{
			*color++ = nv::Color32(*gray, *gray, *gray);
			gray++;
		}
	}


	//nv::ImageIO::save("test1.tga", &glyph);
	
	nv::FloatImage floatGlyph(&glyph);
	
	double ratio = static_cast<double>(glyphWidth) / glyphHeight;

	std::auto_ptr<nv::FloatImage> resized(floatGlyph.resize(nv::LanczosFilter(), m_fontSize * ratio, m_fontSize, nv::FloatImage::WrapMode_Clamp));
	std::auto_ptr<nv::Image> newGlyph(resized->createImage());

	if (newGlyph->width() + x > 512)
	{
		y += m_fontSize;
		x = 0;
	}

	for (int iY = 0; iY < newGlyph->height(); iY++)
	{
		nv::Color32* src = newGlyph->scanline(iY);
		nv::Color32* dest = image.scanline(iY + y) + x;
		for (int iX = 0; iX < newGlyph->width(); iX++)
		{
			*dest++ = *src++;
		}
	}

	x += newGlyph->width();
}*/


GrayImage::GrayImage() : m_width(0), m_height(0)
{

}

GrayImage::GrayImage(int width, int height)
{
	allocate(width, height);
}

void GrayImage::allocate(int width, int height)
{
	m_data.resize(width * height);
	m_width = width;
	m_height = height;
}

int GrayImage::width() const
{
	return m_width;
}

int GrayImage::height() const
{
	return m_height;
}

uint8* GrayImage::scanLine(int line)
{
	if (line < 0 || line >= m_height)
	{
		return NULL;
	}
	return &m_data[line * m_width];
}

uint8* GrayImage::data()
{
	return &m_data[0];
}

uint8& GrayImage::pixel(int x, int y)
{
	return m_data[y * m_width + x];
}

const uint8& GrayImage::pixel(int x, int y) const
{
	return m_data[y * m_width + x];
}

#if defined(NVTT)
nv::Image GrayImage::toNvImage() const
{
	nv::Image image;
	image.allocate(m_width, m_height);
	for (int y = 0; y < m_height; y++)
	{
		for (int x = 0; x < m_width; x++)
		{
			uint8 gray = pixel(x, y);
			image.pixel(x, y) = nv::Color32(gray, gray, gray);
		}
	}
	return image;
}
#endif
