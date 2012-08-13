#pragma once
#include "SimpleImage.h"
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

	bool load(const QString& fontFile, const QString& textureFile);
	bool save(const QString& fontFile, const QString& textureFile);
	bool loadFromEditorFormat(const QString& filename);
	
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
		struct Rect
		{
			float left;
			float top;
			float right;
			float bottom;
		}
		glyphRect;
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
