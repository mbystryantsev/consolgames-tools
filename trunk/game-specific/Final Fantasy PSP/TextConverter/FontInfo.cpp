#include "FontInfo.h"
#include <QFile>
#include <QDataStream>

void FontInfo::open(const QString& filename)
{
	QFile file(filename);
	file.open(QIODevice::ReadOnly);
	QDataStream stream(&file);
	stream.setByteOrder(QDataStream::LittleEndian);
	unserialize(stream);
}

void FontInfo::unserialize(QDataStream& stream)
{
	FontHeader header;
	stream >> header.height;
	stream >> header.charCount;
	
	m_height = header.height;

	stream.readRawData(reinterpret_cast<char*>(&m_encodingMap[0]), sizeof(m_encodingMap));
	
	m_charInfo.resize(header.charCount);
	stream.readRawData(reinterpret_cast<char*>(&m_charInfo[0]), sizeof(CharRecord) * header.charCount);
}

int FontInfo::charIndex(QChar c) const
{
	int code = c.unicode();

	if (code >= 0 && code < _countof(m_encodingMap))
	{
		return static_cast<int>(m_encodingMap[code]);
	}

	return -1;
}

const EncodingMap& FontInfo::encodingMap() const
{
	return m_encodingMap;
}

int FontInfo::charCount() const
{
	return m_charInfo.size();
}

int FontInfo::height() const
{
	return m_height;
}