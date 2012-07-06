#pragma once
#include <FontInfoTypes.h>
#include <QString>
#include <QVector>

class FontInfo
{
public:
	void open(const QString& filename);
	int charIndex(QChar c) const;
	const EncodingMap& encodingMap() const;
	int charCount() const;
	int height() const;

protected:
	void unserialize(QDataStream& stream);

protected:
	int m_height;
	QVector<CharRecord> m_charInfo;
	EncodingMap m_encodingMap;
};