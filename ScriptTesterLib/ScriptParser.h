#pragma once
#include <QVector>
#include <QString>

struct Message
{
	QString id;
	QString text;
};

struct MessageSet
{
	QVector<quint64> nameHashes;
	int definedCount;
	int idCount;
	int version;
	QVector<Message> messages;
};

class ScriptParser
{
public:
	static Message parseMessage(const QString& string, int offset = 0, int* parsedLength = NULL);
	static MessageSet parseMessageSet(const QString& string, int offset = 0, int* outLength = NULL);

	static QVector<MessageSet> loadFromFile(const QString& filename);
	static bool saveToFile(const QString& filename, const QVector<MessageSet>& messages);

protected:
	static const QString s_messageExpr;
	static const QString s_headerExpr;
	
};