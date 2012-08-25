#include "ScriptParser.h"
#include <QStringList>
#include <QRegExp>
#include <QFile>
#include <QTextStream>

const QString ScriptParser::s_headerExpr = "\\[@([a-zA-Z0-9\\|]+),(\\d+),(\\d+)(?:,(\\d+))?\\]\\r?\\n\\r?\\n";
const QString ScriptParser::s_messageExpr = "(?:\\[ID:([^\\]]+)\\]\\r?\\n)?(?:(.*)\\r\\n\\{E\\}|(.*[^\\r])\\n\\{E\\}|\\n\\{E\\})\\r?\\n\\r?\\n";

Message ScriptParser::parseMessage(const QString& string, int offset, int* parsedLength)
{
	QRegExp expr(s_messageExpr, Qt::CaseSensitive, QRegExp::RegExp2);
	expr.setMinimal(true);

	Message message;
	if (expr.indexIn(string, offset) != -1)
	{
		message.id = expr.cap(1);
		message.text = expr.cap(2).isNull() ? expr.cap(3) : expr.cap(2);

		if (parsedLength != NULL)
		{
			*parsedLength = expr.matchedLength();
		}
	}
	else if (parsedLength != NULL)
	{
		*parsedLength = 0;
	}
	return message;
}

MessageSet ScriptParser::parseMessageSet(const QString& string, int offset, int* outLength)
{
	MessageSet messageSet;

	if (outLength != NULL)
	{
		*outLength = 0;
	}

	QRegExp expr(s_headerExpr);
	expr.setMinimal(true);

	if (expr.indexIn(string, offset) == -1)
	{
		return messageSet;	
	}
	
	const QString hashes = expr.cap(1);
	foreach (const QString& hashStr, hashes.split('|'))
	{
		messageSet.nameHashes.append((hashStr.toULongLong(NULL, 16)));
	}
	messageSet.definedCount = expr.cap(2).toInt();
	messageSet.idCount = expr.cap(3).toInt();
	messageSet.version = expr.captureCount() == 4 ? expr.cap(4).toInt() : 3;

	offset += expr.matchedLength();		
	if (outLength != NULL)
	{
		*outLength += expr.matchedLength();
	}

	forever
	{
		if (expr.indexIn(string, offset) == offset)
		{
			break;
		}

		int length = 0;
		Message message = parseMessage(string, offset, &length);
		if (length == 0)
		{
			break;
		}
		messageSet.messages.append(message);
		if (outLength != NULL)
		{
			*outLength += length;
		}
		offset += length;
	}
	return messageSet;
}

QVector<MessageSet> ScriptParser::loadFromFile(const QString& filename)
{
	QVector<MessageSet> script;
	QString allText;
	{
		QFile file(filename);
		file.open(QIODevice::ReadOnly);
		QTextStream stream(&file);
		allText = stream.readAll();
	}

	int offset = 0;
	forever
	{
		int length = 0;
		MessageSet messages = parseMessageSet(allText, offset, &length);
		if (length == 0)
		{
			break;
		}
		script.append(messages);
		offset += length;
	}

	return script;
}

static QString hashToStr(quint64 hash)
{
	const QString temp = QString::number(hash, 16).toUpper();
	QString hashStr(16, '0');
	qCopy(temp.begin(), temp.end(), hashStr.end() - temp.size());
	return hashStr;
}

bool ScriptParser::saveToFile(const QString& filename, const QVector<MessageSet>& messages)
{
	QFile file(filename);
	if (!file.open(QIODevice::WriteOnly))
	{
		return false;
	}

	QTextStream stream(&file);
	stream.setCodec("UTF-16LE");
	stream.setGenerateByteOrderMark(true);
	foreach (const MessageSet& messageSet, messages)
	{
		// Write header
		stream << "[@";
		for (int i = 0; i < messageSet.nameHashes.size(); i++)
		{
			if (i > 0)
			{
				stream << "|";
			}
			stream << hashToStr(messageSet.nameHashes[i]);
		}
		stream << "," << messageSet.messages.size() << ',' << messageSet.idCount;
		if (messageSet.version != 0)
		{
			stream << ',' << messageSet.version;
		}
		stream << "]\n\n";

		// Write messages
		foreach (const Message& message, messageSet.messages)
		{
			if (!message.id.isEmpty())
			{
				stream << "[ID:" << message.id << "]\n";
			}
			stream << message.text << "\n{E}\n\n";
		}
	}
}
