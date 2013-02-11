#pragma once
#include <QtCore>

namespace ShatteredMemories
{

struct Message
{
	Message();
	Message(quint32 hash, const QString& message);

	quint32 hash;
	QString text;
};

struct MessageSet
{
	QMap<quint32,Message> messages;
	QList<quint32> hashes;

	bool isEmpty() const
	{
		return messages.isEmpty();
	}
};

class Strings
{
public:
	static MessageSet importMessages(const QString& filename);
	static MessageSet loadMessages(const QString& filename, QMap<QString, QList<quint32>>* filesMap = NULL);
	static bool saveMessages(const QString& filename, const MessageSet& messages);
	static bool saveMessages(const QString& filename, const QMap<quint32,Message>& messages, const QList<quint32>& hashList);
	static bool saveMessages(const QString& filename, const QMap<quint32,QString>& messages, const QList<quint32>& hashList);
	static bool saveMessages(const QString& filename, const QMap<quint32,QString>& messages);
	static bool exportMessages(const MessageSet& messages, const QString& filename);
	static QString hashToStr(quint32 hash);
	static quint32 strToHash(const QString& hashStr);
	static bool collapseDuplicates(MessageSet& messages);
	static bool expandReferences(MessageSet& messages);

	static bool isReference(const QString& str);
	static quint32 extractReferenceHash(const QString& str);
};

}