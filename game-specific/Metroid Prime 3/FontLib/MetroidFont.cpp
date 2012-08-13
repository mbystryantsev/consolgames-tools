#include "MetroidFont.h"
#include "TextureCodec.h"
#include "TextureAtlas.h"
#include <QFile>
#include <QVector>
#include <QSet>

#ifdef _DEBUG
#include <QImage>

static void saveTexture(const Consolgames::SimpleImage& texture, const QString& filename, const quint16* palette = NULL)
{
	QImage image(texture.data(), texture.width(), texture.height(), texture.width(), QImage::Format_Indexed8);
	image.setColorCount(256);
	if (palette == NULL)
	{
		image.setColor(0, qRgba(0, 0, 0, 255));
		image.setColor(1, qRgba(255, 255, 255, 255));
		image.setColor(2, qRgba(127, 127, 127, 255));
		image.setColor(3, qRgba(63, 63, 63, 255));
	}
	else
	{
		for (int i = 0; i < 16; i++)
		{
			image.setColor(i, Consolgames::TextureCodec::decodeColor(palette[i]));
		}
	}
	image.save(filename);
}
#endif

namespace Consolgames
{

bool MetroidFont::load(const QString& fontFile, const QString& textureFile)
{
	QFile file(fontFile);
	if (!file.open(QIODevice::ReadOnly))
	{
		return false;
	}
	QDataStream stream(&file);
	stream.setByteOrder(QDataStream::BigEndian);

	m_header = readHeader(stream);
	m_name = readString(stream);

	stream >> m_textureHash;
	stream >> m_textureColors;

	int charCount = 0;
	stream >> charCount;
	
	readChars(stream, charCount);

	int kerningRecords = 0;
	stream >> kerningRecords;
	
	readKerning(stream, kerningRecords);

	return readCanvases(textureFile);
}

bool MetroidFont::save(const QString& fontFile, const QString& textureFile)
{
	QFile file(fontFile);
	if (!file.open(QIODevice::WriteOnly))
	{
		return false;
	}
	QDataStream stream(&file);
	stream.setByteOrder(QDataStream::BigEndian);

	writeHeader(stream);
	writeString(stream, m_name);

	stream << m_textureHash;
	stream << m_textureColors;
	
	writeCharsAndKerning(stream);

	return writeCanvases(textureFile);
}

MetroidFont::Header MetroidFont::readHeader(QDataStream& stream)
{
	Header header;

	int dummy = 0;

	stream >> dummy; // Signature
	stream >> header.unknown04;
	stream >> header.maxCharWidth;
	stream >> header.unknown0C;
	stream >> header.fontHeight;
	stream >> header.unknown14;
	stream >> header.unknown18;
	stream >> header.unknown1C;
	stream >> header.unknown1E;

	return header;
}

QString MetroidFont::readString(QDataStream& stream)
{
	qint8 c = 0;
	QString str;
	forever
	{
		stream >> c;
		if (c == 0)
		{
			break;
		}
		str.append(c);
	}
	return str;
}

union IntDbl
{
	quint32 i;
	float f;
};

MetroidFont::CharRecord MetroidFont::readCharRecord(QDataStream& stream)
{
	CharRecord record;

	stream >> record.code;

	IntDbl temp;
	stream >> temp.i;
	record.glyphRect.left = temp.f;
	stream >> temp.i;
	record.glyphRect.top = temp.f;
	stream >> temp.i;
	record.glyphRect.right = temp.f;
	stream >> temp.i;
	record.glyphRect.bottom = temp.f;

	stream >> record.layer;
	stream >> record.leftIdent;
	stream >> record.ident;
	stream >> record.rightIdent;
	stream >> record.glyphWidth;
	stream >> record.glyphHeight;
	stream >> record.baselineOffset;
	stream >> record.kerningIndex;

	return record;
}


void MetroidFont::writeCharRecord(QDataStream& stream, const CharRecord& record)
{
	stream << record.code;

	IntDbl temp;
	temp.f = record.glyphRect.left;
	stream << temp.i;
	temp.f = record.glyphRect.top;
	stream << temp.i;
	temp.f = record.glyphRect.right;
	stream << temp.i;
	temp.f = record.glyphRect.bottom;
	stream << temp.i;
	stream << record.layer;
	stream << record.leftIdent;
	stream << record.ident;
	stream << record.rightIdent;
	stream << record.glyphWidth;
	stream << record.glyphHeight;
	stream << record.baselineOffset;
	stream << record.kerningIndex;
}

MetroidFont::KerningRecord MetroidFont::readKerningRecord(QDataStream& stream)
{
	KerningRecord record;
	stream >> record.first;
	stream >> record.second;
	stream >> record.kerning;
	return record;
}

MetroidFont::TextureHeader MetroidFont::readTextureHeader(QDataStream& stream)
{
	TextureHeader header;
	stream >> header.type;
	stream >> header.width;
	stream >> header.height;
	stream >> header.mipmaps;
	return header;
}

void MetroidFont::writeTextureHeader(QDataStream& stream, const TextureHeader& header)
{
	stream << header.type;
	stream << header.width;
	stream << header.height;
	stream << header.mipmaps;
}

void MetroidFont::writeIndexedTextureSubheader(QDataStream& stream, const IndexedTextureSubheader& header)
{
	stream << header.bitCount;
	stream << header.colorFormat;
	stream << header.colorCount;
}

MetroidFont::IndexedTextureSubheader MetroidFont::readIndexedTextureSubheader(QDataStream& stream)
{
	IndexedTextureSubheader subheader;
	stream >> subheader.bitCount;
	stream >> subheader.colorFormat;
	stream >> subheader.colorCount;
	return subheader;
}

void MetroidFont::readChars(QDataStream& stream, int charCount)
{
	m_chars.clear();
	for (int i = 0; i < charCount; i++)
	{
		CharRecord record = readCharRecord(stream);
		m_chars[record.code] = record;
	}
}

void MetroidFont::readKerning(QDataStream& stream, int kerningCount)
{
	m_kerning.clear();
	for (int i = 0; i < kerningCount; i++)
	{
		KerningRecord record = readKerningRecord(stream);
		m_kerning[KerningPair(record.first, record.second)] = record.kerning;
	}
}

bool MetroidFont::readCanvases(const QString& textureName)
{
	QFile file(textureName);
	if (!file.open(QIODevice::ReadOnly))
	{
		return false;
	}
	
	QDataStream stream(&file);
	stream.setByteOrder(QDataStream::BigEndian);

	m_textureHeader = readTextureHeader(stream);
	m_textureSubheader = readIndexedTextureSubheader(stream);
	for (int i = 0; i < 16; i++)
	{
		stream >> m_palette[i];
	}

	QByteArray textureData(m_textureHeader.width * m_textureHeader.height / 2, Qt::Uninitialized);
	stream.readRawData(textureData.data(), textureData.size());

	const int layerCount = (m_textureColors > 2) ? 2 : 4;
	m_textures.clear();
	m_textures.reserve(layerCount);

	for (int i = 0; i < layerCount; i++)
	{
		const int pixelCount = m_textureHeader.width * m_textureHeader.height;
		QVector<quint8> data(pixelCount * layerCount);

		for (int i = 0; i < layerCount; i++)
		{
			m_textures.append(SimpleImage(m_textureHeader.width, m_textureHeader.height));
			if (layerCount == 2)
			{
				TextureCodec::decodeImage2bpp(textureData.constData(), m_textures.last().data(), m_textureHeader.width, m_textureHeader.height, i);
			}
			else
			{
				TextureCodec::decodeImage1bpp(textureData.constData(), m_textures.last().data(), m_textureHeader.width, m_textureHeader.height, i);
			}
		}
	}

	return true;
}

const int s_charSize = 64;

struct EditorCharData
{
	quint8 tile[s_charSize * s_charSize];

	bool operator ==(const EditorCharData& other) const
	{
		return qEqual(tile, tile + sizeof(tile), other.tile);
	}
};

static int calcGlyphRightBorder(const EditorCharData& data)
{
	for (int x = s_charSize - 1; x >= 0; x--)
	{
		for (int y = 0; y < s_charSize; y++)
		{
			if (data.tile[y * s_charSize + x] != 0)
			{
				return x + 1;
			}
		}
	}
	return 1;
}

static int calcGlyphLeftBorder(const EditorCharData& data)
{
	for (int x = 0; x < s_charSize; x++)
	{
		for (int y = 0; y < s_charSize; y++)
		{
			if (data.tile[y * s_charSize + x] != 0)
			{
				return x;
			}
		}
	}
	return 0;
}

static int calcGlyphBottomBorder(const EditorCharData& data)
{
	for (int y = s_charSize - 1; y >= 0; y--)
	{
		for (int x = 0; x < s_charSize; x++)
		{
			if (data.tile[y * s_charSize + x] != 0)
			{
				return y + 1;
			}
		}
	}
	return 1;
}

static int calcGlyphTopBorder(const EditorCharData& data)
{
	for (int y = 0; y < s_charSize; y++)
	{
		for (int x = 0; x < s_charSize; x++)
		{
			if (data.tile[y * s_charSize + x] != 0)
			{
				return y;
			}
		}
	}
	return 0;
}

static int findCharData(int endIndex, const QVector<EditorCharData>& data, const EditorCharData& pattern)
{
	for (int i = 0; i < endIndex; i++)
	{
		if (data[i] == pattern)
		{
			return i;
		}
	}
	return 0;
}

static void copyCharRect(const EditorCharData& data, int left, int top,
						 SimpleImage& texture, const TextureAtlas::Rect& destRect)
{
	const int width = destRect.x2 - destRect.x1;
	const int height = destRect.y2 - destRect.y1;
	for (int i = 0; i < height; i++)
	{
		const quint8* srcPixel = &data.tile[(i + top) * s_charSize + left];
		quint8* destPixel = texture.scanLine(i + destRect.y1) + destRect.x1;
		for (int j = 0; j < width; j++)
		{
			*destPixel++ = *srcPixel++;
		}
	}
}

bool MetroidFont::loadFromEditorFormat(const QString& filename)
{
	// TODO: Extract methods and this method to import class

	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly))
	{
		return false;
	}

	QDataStream stream(&file);
	stream.setByteOrder(QDataStream::LittleEndian);

	m_header = readHeader(stream);

	
	m_textureHeader = readTextureHeader(stream);
	
	stream >> m_textureSubheader.bitCount;

	// Order inverted (endianness issuess i.e. short pairs saved as ints)
	stream >> m_textureSubheader.colorCount;
	stream >> m_textureSubheader.colorFormat;
	
	stream >> m_palette[1];
	stream >> m_palette[0];
	stream >> m_palette[3];
	stream >> m_palette[2];
	stream >> m_palette[5];
	stream >> m_palette[4];
	stream >> m_palette[7];
	stream >> m_palette[6];
	stream >> m_palette[9];
	stream >> m_palette[8];
	stream >> m_palette[11];
	stream >> m_palette[10];
	stream >> m_palette[13];
	stream >> m_palette[12];
	stream >> m_palette[15];
	stream >> m_palette[14];

	stream.setByteOrder(QDataStream::BigEndian);
	stream >> m_textureHash;

	stream.setByteOrder(QDataStream::LittleEndian);
	stream >> m_textureColors;

	int charCount = 0;
	stream >> charCount;

	int kerningCount = 0;
	stream >> kerningCount;

	int nameLength = 0;
	stream >> nameLength;

	QByteArray name(nameLength, Qt::Uninitialized);
	stream.readRawData(name.data(), nameLength);
	m_name = QString::fromLatin1(name);


	m_chars.clear();
	QVector<CharRecord> chars(charCount);
	for (int i = 0; i < charCount; i++)
	{
		chars[i] = readCharRecord(stream);
	}

	readKerning(stream, kerningCount);

	QVector<EditorCharData> charData(charCount);
	stream.readRawData(reinterpret_cast<char*>(&charData.first()), charCount * sizeof(EditorCharData));

	const int layerCount = (m_textureColors > 2) ? 2 : 4;
	m_textures.clear();
	m_textures.reserve(layerCount);
	for (int i = 0; i < layerCount; i++)
	{
		m_textures.append(SimpleImage(m_textureHeader.width, m_textureHeader.height));
		m_textures.last().clear();
	}

	TextureAtlas atlas(m_textureHeader.width, m_textureHeader.height, layerCount);

	for (int i = 0; i < charData.size(); i++)
	{
		const int index = findCharData(i, charData, charData[i]);
		if (index > 0)
		{
			chars[i].baselineOffset = chars[index].baselineOffset;
			chars[i].glyphWidth = chars[index].glyphWidth;
			chars[i].glyphHeight = chars[index].glyphHeight;
			chars[i].layer = chars[index].layer;
			chars[i].glyphRect = chars[index].glyphRect;
			continue;
		}

		TextureAtlas::Rect rect;
		rect.x1 = calcGlyphLeftBorder(charData[i]);
		rect.x2 = calcGlyphRightBorder(charData[i]);
		rect.y1 = calcGlyphTopBorder(charData[i]);
		rect.y2 = calcGlyphBottomBorder(charData[i]);

		chars[i].glyphWidth = rect.x2 - rect.x1;
		chars[i].glyphHeight = rect.y2 - rect.y1;
		chars[i].baselineOffset = m_header.fontHeight - rect.y1;

		const TextureAtlas::Node* node = atlas.insert(chars[i].glyphWidth + 1, chars[i].glyphHeight + 1);
		if (node == NULL)
		{
			return false;
		}

		const float textureWidth = m_textureHeader.width;
		const float textureHeight = m_textureHeader.height;
		chars[i].glyphRect.left = static_cast<float>(node->rect.x1) / textureWidth;
		chars[i].glyphRect.right = static_cast<float>(node->rect.x2 - 1) / textureWidth;
		chars[i].glyphRect.top = static_cast<float>(node->rect.y1) / textureHeight;
		chars[i].glyphRect.bottom = static_cast<float>(node->rect.y2 - 1) / textureHeight;
		chars[i].layer = node->layer;

		copyCharRect(charData[i], rect.x1, rect.y1, m_textures[chars[i].layer], node->rect);
	}

	for (int i = 0; i < charCount; i++)
	{
		m_chars[chars[i].code] = chars[i];
	}

	return true;
}

void MetroidFont::writeHeader(QDataStream& stream) const
{
	const quint32 signature = 0x464F4E54; // "FONT"

	stream << signature;
	stream << m_header.unknown04;
	stream << m_header.maxCharWidth;
	stream << m_header.unknown0C;
	stream << m_header.fontHeight;
	stream << m_header.unknown14;
	stream << m_header.unknown18;
	stream << m_header.unknown1C;
	stream << m_header.unknown1E;
}

void MetroidFont::writeString(QDataStream& stream, const QString& str)
{
	const QByteArray s = str.toLatin1();
	stream.writeRawData(s.constData(), s.size() + 1);
}

int MetroidFont::firstKerningIndex(QChar code) const
{
	int index = 0;
	foreach (const KerningPair& pair, m_kerning.keys())
	{
		if (pair.first == code)
		{
			return index;
		}
		index++;
	}
	return -1;
}

void MetroidFont::writeCharsAndKerning(QDataStream& stream) const
{
	stream << m_chars.size();

	QList<CharRecord> records = m_chars.values();

	for (int i = 0; i < records.size(); i++)
	{
		records[i].kerningIndex = firstKerningIndex(records[i].code);
		writeCharRecord(stream, records[i]);
	}

	stream << m_kerning.size();
	foreach (const KerningPair& pair, m_kerning.keys())
	{
		stream << pair.first;
		stream << pair.second;
		stream << m_kerning[pair];
	}
}

bool MetroidFont::writeCanvases(const QString& textureName) const
{
	QFile file(textureName);
	if (!file.open(QIODevice::WriteOnly))
	{
		return false;
	}

	QDataStream stream(&file);
	stream.setByteOrder(QDataStream::BigEndian);

	writeTextureHeader(stream, m_textureHeader);
	writeIndexedTextureSubheader(stream, m_textureSubheader);
	for (int i = 0; i < 16; i++)
	{
		stream << m_palette[i];
	}

	const int layerCount = (m_textureColors > 2) ? 2 : 4;
	const int pixelCount = m_textureHeader.width * m_textureHeader.height;

	QByteArray textureData(pixelCount / 2, Qt::Uninitialized);
	textureData.fill(0);
	for (int i = 0; i < layerCount; i++)
	{
		for (int i = 0; i < layerCount; i++)
		{
			if (layerCount == 2)
			{
				TextureCodec::encodeImage2bpp(m_textures[i].data(), textureData.data(), m_textureHeader.width, m_textureHeader.height, i);
			}
			else
			{
				TextureCodec::encodeImage1bpp(m_textures[i].data(), textureData.data(), m_textureHeader.width, m_textureHeader.height, i);
			}
		}
	}

	stream.writeRawData(textureData.data(), textureData.size());

	return true;
}

}
