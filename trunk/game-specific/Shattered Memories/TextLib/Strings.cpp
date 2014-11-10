#include "Strings.h"
#include <Hash.h>
#include <QtFileStream.h>
#include <QTextStream>

using namespace Consolgames;

namespace
{

struct MessageRecord
{
	MessageRecord()
	{
	}
	MessageRecord(quint32 hash, quint32 offset)
		: hash(hash)
		, offset(offset)
	{
	}

	quint32 hash;
	quint32 offset;
};

}

namespace ShatteredMemories
{

Message::Message()
{
}

Message::Message(quint32 hash, const QString& message)
	: hash(hash)
	, text(message)
{
}

static QString decodeTag(const ushort*& data)
{
	const int tagId = *data;
	if (tagId == 1)
	{
		return QString("<c=%1>").arg(static_cast<int>(*++data));
	}
	if (tagId == 2)
	{
		return "<p>";
	}
	if (tagId == 3)
	{
		return QString("<b=%1>").arg(*++data);
	}
	if (tagId == 4)
	{
		return QString("<w=%1>").arg(*++data);
	}
	
	DLOG << "UNKNOWN TAG: " << QString::number(tagId, 16).toUpper().rightJustified(4, '0');
	return QString();
}

MessageSet Strings::importMessages(const QString& filename)
{
	QtFileStream stream(filename, QIODevice::ReadOnly);
	if (!stream.opened())
	{
		return MessageSet();
	}

	const int version = stream.readInt();
	ASSERT(version == 2);
	Q_UNUSED(version);

	const int stringCount = stream.readInt();

	std::vector<MessageRecord> records(stringCount);
	for (int i = 0; i < stringCount; i++)
	{
		records[i].hash = stream.readUInt();
		records[i].offset = stream.readUInt();
	}

	const quint64 dataSize = stream.size() - stream.position();
	std::vector<quint8> data(dataSize);
	stream.read(&data[0], dataSize);

	MessageSet messages;
	messages.hashes.reserve(stringCount);
	for (int i = 0; i < stringCount; i++)
	{
		const quint32 hash = records[i].hash;
		messages.hashes << hash;

		const quint32 ptr = records[i].offset * 2;
		const ushort* c = reinterpret_cast<const ushort*>(&data[ptr]);

		QString text;
		for (; *c != 0; c++)
		{
			if (*c < 5)
			{
				text.append(decodeTag(c));
				continue;
			}

			text.append(QChar(*c));
		}

		messages.messages[hash] = Message(hash, text);
	}

	return messages;
}

static bool loadMessagesFromFile(const QString& filename, MessageSet& messages, QMap<QString, QList<quint32>>* filesMap = NULL)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		DLOG << file.errorString();
		return false;
	}

	const QString absolutePath = QFileInfo(filename).absoluteFilePath();
	QList<quint32> dummyHashList;
	QList<quint32>& fileHashList = (filesMap == NULL ? dummyHashList : (*filesMap)[absolutePath]);

	QTextStream stream(&file);
	stream.setCodec("UTF-8");

	QString bufferedLine;
	QString text;
	quint32 lastHash = 0;
	while (true)
	{
		const QString line = stream.readLine();
		const bool isHeader = (line.startsWith('[') && line.endsWith(']'));

		if ((isHeader || line.isNull()) && !text.isNull())
		{
			if (bufferedLine.trimmed().isEmpty())
			{
				bufferedLine.clear();
			}

			if (stream.atEnd())
			{
				if (!bufferedLine.isNull())
				{
					if (!text.isEmpty())
					{
						text.append("\n");
					}
					text.append(bufferedLine);
				}
			}

			messages.messages[lastHash] = Message(lastHash, text);
			text.clear();
		}
		if (line.isNull())
		{
			break;
		}
		if (isHeader)
		{
			const QString hashStr = line.mid(1, line.length() - 2);
			quint32 hash = Strings::strToHash(hashStr);

			if (hash == 0)
			{
				hash = Hash::calc(hashStr.toUtf8().constData());
			}

			if (hash == 0)
			{
				DLOG << "WARNING! Hash is null for id " << hashStr;
			}

			if (!messages.hashes.contains(hash))
			{
				messages.hashes << hash;
			}
			fileHashList << hash;
			lastHash = hash;
			continue;
		}
		if (!bufferedLine.isNull())
		{
			if (!text.isEmpty())
			{
				text.append("\n");
			}
			text.append(bufferedLine);
		}
		bufferedLine = line;
	}

	return true;
}

MessageSet Strings::loadMessages(const QString& path, QMap<QString, QList<quint32>>* filesMap)
{
	MessageSet messages;
	if (QFileInfo(path).isDir())
	{
		const QDir dir(path);
		const QStringList files = dir.entryList(QStringList() << "*.txt");
		foreach (const QString& filename, files)
		{
			loadMessagesFromFile(dir.absoluteFilePath(filename), messages, filesMap);
		}
	}
	else
	{
		loadMessagesFromFile(path, messages, filesMap);
	}
	return messages;
}

bool Strings::saveMessages(const QString& filename, const MessageSet& messages)
{
	return saveMessages(filename, messages.messages, messages.hashes);
}

bool Strings::saveMessages(const QString& filename, const MessageSet::Messages& messages, const QList<quint32>& hashList)
{
	QFile file(filename);
	if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		return false;
	}

	QTextStream stream(&file);
	stream.setCodec("UTF-8");
	foreach (quint32 hash, hashList)
	{
		const QString& text = messages[hash].text;
		stream << "[" << hashToStr(hash) << "]\n";
		stream << text;
		stream << "\n\n";
	}

	return true;
}

bool Strings::saveMessages(const QString& filename, const QMap<quint32,QString>& messages, const QList<quint32>& hashList)
{
	QMap<quint32,Message> nativeMessages;
	foreach (quint32 hash, messages.keys())
	{
		nativeMessages[hash] = Message(hash, messages[hash]);
	}

	return saveMessages(filename, nativeMessages, hashList);
}

bool Strings::saveMessages(const QString& filename, const QMap<quint32,QString>& messages)
{
	return saveMessages(filename, messages, messages.keys());
}

static QString encodeTags(const QString& text, QRegExp rx, int tagCode)
{
	QString result = text;

	int pos = 0;
	while (pos >= 0)
	{
		pos = rx.indexIn(result, pos);
		if (pos >= 0)
		{
			const QString valueStr = rx.capturedTexts()[1];

			bool ok = false;
			const ushort value = valueStr.toUShort(&ok);
			ASSERT(ok);

			QString toReplace;
			toReplace.append(QChar(tagCode)).append(QChar(value));
			result.replace(pos, rx.matchedLength(), toReplace);

			pos += 2;
		}
	}

	return result;
}

static QString encodeString(const QString& text)
{
	QString converted = encodeTags(text, QRegExp("<c=(\\d+)>"), 1);
	converted = encodeTags(converted, QRegExp("<b=(\\d+)>"), 3);
	converted = encodeTags(converted, QRegExp("<w=(\\d+)>"), 4);
	converted.replace("<p>", "\2");


	return converted.replace("\r\n", "\n");
}

bool Strings::exportMessages(const MessageSet& messageSet, const QString& filename)
{
	QtFileStream stream(filename, QIODevice::WriteOnly);
	if (!stream.opened())
	{
		DLOG << stream.file().errorString();
		return false;
	}

	const int version = 2;
	const int count = messageSet.messages.size();
	stream.writeUInt32(version);
	stream.writeUInt32(count);
	stream.seek(messageSet.messages.size() * 8, Stream::seekCur);

	QList<MessageRecord> records;
	records.reserve(count);

	quint32 currOffset = 0;
	QHash<QString, quint32> stringsOffsets;

	foreach (quint32 hash, messageSet.hashes)
	{
		const Message& message = messageSet.messages[hash];
		if (stringsOffsets.contains(message.text))
		{
			records << MessageRecord(hash, stringsOffsets[message.text]);
			continue;
		}

		records << MessageRecord(hash, currOffset);
		stringsOffsets[message.text] = currOffset;

		const QString encodedString = encodeString(message.text);
		const int len = encodedString.length() + 1;
		VERIFY(stream.write(encodedString.constData(), len * 2) == len * 2);
		currOffset += len;
	}

	stream.seek(8, Stream::seekSet);
	foreach (const MessageRecord& record, records)
	{
		stream.writeUInt32(record.hash);
		stream.writeUInt32(record.offset);
	}

	return true;
}

QString Strings::hashToStr(quint32 hash)
{
	return QString::number(hash, 16).toUpper().rightJustified(8, '0');
}

quint32 Strings::strToHash(const QString& hashStr)
{
	bool ok = false;
	const quint32 hash = hashStr.toUInt(&ok, 16);
	return ok ? hash : 0;	
}

bool Strings::collapseDuplicates(MessageSet::Messages& messages)
{
	QHash<QString, quint32> stringsMap;

	foreach (quint32 hash, messages.keys())
	{
		Message& message = messages[hash];
		if (stringsMap.contains(message.text))
		{
			message.text = QString("{REF:%1}").arg(hashToStr(stringsMap.value(message.text)));
		}
		else
		{
			stringsMap[message.text] = hash;
		}
	}

	return true;
}

const QRegExp referenceExp("\\{REF:([0-9A-Fa-f]{8})\\}");

bool Strings::expandReferences(MessageSet::Messages& messages)
{
	foreach (quint32 hash, messages.keys())
	{
		Message& message = messages[hash];
		if (isReference(message.text))
		{
			const quint32 sourceHash = extractReferenceHash(message.text);
			if (sourceHash == 0 || !messages.contains(hash))
			{
				DLOG << "References expand error (" << hashToStr(hash) << " -> " << hashToStr(sourceHash) << ")";
				return false;
			}
			message.text = messages[sourceHash].text;
		}
	}

	return true;
}

bool Strings::isReference(const QString& str)
{
	return referenceExp.exactMatch(str);
}

quint32 Strings::extractReferenceHash(const QString& str)
{
	QRegExp re(referenceExp);
	if (re.indexIn(str) < 0)
	{
		return 0;
	}
	return Strings::strToHash(re.cap(1));
}

}