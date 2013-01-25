#pragma once
#include "SimpleImage.h"
#include "TextureAtlas.h"
#include <QString>
#include <QMap>
#include <QRect>
#include <QPair>

class QDataStream;

namespace Consolgames
{

class MetroidFont
{
public:
	struct Rect
	{
		Rect()
		{
		}
		Rect(float l, float t, float r, float b) : left(l), top(t), right(r), bottom(b)
		{
		}
		float left;
		float top;
		float right;
		float bottom;
	};
	struct CharMetrics
	{
		CharMetrics() : leftIdent(0), bodyWidth(0), rightIdent(0), layer(0)
		{
		}
		bool isNull() const
		{
			return (leftIdent == 0 && bodyWidth == 0 && rightIdent == 0);
		}
		int leftIdent;
		int bodyWidth;
		int rightIdent;
		int layer;
		int glyphWidth;
		int glyphHeight;
		int baselineOffset;
		Rect glyphRect;
	};

public:

	bool load(const QString& fontFile, const QString& textureFile);
	bool save(const QString& fontFile, const QString& textureFile);
	bool loadFromEditorFormat(const QString& filename, bool interpolationHint = false);

	int layerCount() const;
	const SimpleImage& layerTexture(int layer) const;
	int height() const;

	CharMetrics charMetrics(QChar c) const;
	int kerning(QChar a, QChar b) const;
	quint64 textureHash() const;
	QList<QChar> charList() const;
	
protected:
	struct Header
	{
		int maxCharWidth;
		int fontHeight;

		int unknown04;
		int unknown0C;
		int unknown14;
		int unknown18;
		short unknown1C;
		int unknown1E;
	};

	struct CharRecord
	{
		QChar code;
		Rect glyphRect;
		quint8 layer;
		qint8 leftIdent;
		qint8 ident;
		qint8 rightIdent;
		qint8 glyphWidth;
		qint8 glyphHeight;
		qint8 baselineOffset;
		qint16 kerningIndex;
	};

	struct KerningRecord
	{
		QChar first;
		QChar second;
		int kerning;
	};

	struct TextureHeader
	{
		int type;
		quint16 width;
		quint16 height;
		int mipmaps;
	};
	
	struct IndexedTextureSubheader
	{
		int bitCount; // ???
		short colorFormat; // ???
		short colorCount;
	};

	typedef QPair<QChar,QChar> KerningPair;

protected:
	static Header readHeader(QDataStream& stream);
	static QString readString(QDataStream& stream);
	static CharRecord readCharRecord(QDataStream& stream);
	static KerningRecord readKerningRecord(QDataStream& stream);
	static TextureHeader readTextureHeader(QDataStream& stream);
	static IndexedTextureSubheader readIndexedTextureSubheader(QDataStream& stream);
	static void writeCharRecord(QDataStream& stream, const CharRecord& record);
	static void writeTextureHeader(QDataStream& stream, const TextureHeader& header);
	static void writeIndexedTextureSubheader(QDataStream& stream, const IndexedTextureSubheader& header);

	void writeHeader(QDataStream& stream) const;
	void writeCharsAndKerning(QDataStream& stream) const;
	static void writeString(QDataStream& stream, const QString& str);

	void readChars(QDataStream& stream, int charCount);
	void readKerning(QDataStream& stream, int kerningCount);

	bool readCanvases(const QString& textureName);
	bool writeCanvases(const QString& textureName) const;

	int firstKerningIndex(QChar code) const;
	
protected:
	Header m_header;
	QString m_name;
	quint64 m_textureHash;
	int m_textureColors;

	TextureHeader m_textureHeader;
	IndexedTextureSubheader m_textureSubheader;
	quint16 m_palette[16];

	QMap<QChar, CharRecord> m_chars;
	QMap<KerningPair, int> m_kerning;
	QList<SimpleImage> m_textures;
};

}
