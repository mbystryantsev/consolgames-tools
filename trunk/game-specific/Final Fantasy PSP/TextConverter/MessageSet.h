#pragma once
#include "FontInfo.h"
#include <MessageSetTypes.h>
#include <QDataStream>
#include <QStringList>
#include <QMap>

class MessageSet
{
public:
	void open(const QString& filename, const FontInfo& fontInfo);
	const QStringList& messages() const;
	
protected:
	void unserialize(QDataStream& stream, const FontInfo& fontInfo);
	static void buildCharMap(const EncodingMap& encodingMap, QMap<uint16, QChar>& charMap, uint16 charCount);
	void readMessages(QDataStream& stream, const QVector<uint32>& pointers, QMap<uint16, QChar>& charMap, int charCount);
	uint16 decodeChar(uint16 code);

protected:
	static QMap<uint16, QString> s_varMap;
	QStringList m_messages;
};