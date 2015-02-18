#include "ExecutablePatcher.h"
#include <Hash.h>
#include <Stream.h>
#include <QtFileStream.h>
#include <QTextStream>
#include <QTextCodec>
#include <QStringList>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <vector>

using namespace Consolgames;

namespace ShatteredMemories
{

/*
; - comment
segment <name> <offset1>-<offset2> <fileOffset> - define segments to file mapping
<offset>: <type> <data> - apply <data> of <type> to <offset>, offset - hex string
space <offset1>-<offset2> - mark space from <offset1> to <offset2> as usable for place strings
messages <filename> - load messages from compiled file

types:
	byte <value>
	    store 8 bit value

	word <value>
	    store 16 bit value

	int  <value>
	    store 32 bit value

	string <name>
	    get string with <name> from loaded messages, place it on some offset in range defined by space command,
		and replace pointer at specified offset. Example:
			space      00001000-00002000
			messages   messages.bin
			012345678: string abc
			
			Get string with name "abc" from messages.bin, store it at offset 0x00001000,
			store ptr to 0x00001000 at 0x012345678.

	string @<name>[, <size>]
	    get string with <name> from loaded messages and place it DIRECTLY at specified offset.
		Cancel operation if string size greater than <size>.

	utf8 <name>
	utf8 @<name>[, <size>]
        The same as string, but result in utf-8
*/

ExecutablePatcher::ExecutablePatcher(const QString& filename)
	: m_loaded(false)
	, m_filename(filename)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		return;
	}

	QTextStream stream(&file);
	stream.setCodec(QTextCodec::codecForName("UTF-8"));
	m_loaded = loadFromStream(&stream);
}

static QList<quint32> strToValues(const QString& str, bool isPureOffsets = false)
{
	const QStringList offsetStrings = QString(str).replace("','", "0x2C").split(',');
	
	QList<quint32> values;
	values.reserve(offsetStrings.size());

	foreach (const QString& offsetStr, offsetStrings)
	{
		if (!isPureOffsets)
		{
			const QString trimmed = offsetStr.trimmed();
			if (trimmed.length() == 3 && trimmed.startsWith('\'') && trimmed.endsWith('\''))
			{
				values << trimmed[1].unicode();
				continue;
			}
		}

		bool ok = false;
		const quint32 value = offsetStr.trimmed().toUInt(&ok, isPureOffsets ? 16 : 0);
		if (!ok || (isPureOffsets && value == 0))
		{
			return QList<quint32>();
		}

		values << value;
	}

	return values;
}

bool ExecutablePatcher::loadFromStream(QTextStream* stream)
{
	while (!stream->atEnd())
	{
		QString line = stream->readLine().simplified();

		const int commentIndex = line.indexOf(';');
		if (commentIndex >= 0)
		{
			line = line.left(commentIndex).trimmed();
		}

		if (line.isEmpty())
		{
			continue;
		}

		if (line.startsWith("segment") || line.startsWith("space") || line.startsWith("messages"))
		{
			const QStringList args = line.split(' ', QString::SkipEmptyParts);
			const QString action = args.first();

			if (action == "segment")
			{
				if (args.size() != 4)
				{
					DLOG << "Invalid segment record: " << line;
					return false;
				}

				const QStringList spacePair = args[2].split('-');
				if (spacePair.size() != 2)
				{
					DLOG << "Invalid segment record: " << line;
					return false;
				}

				bool ok1 = false;
				bool ok2 = false;

				const quint32 offset1 = spacePair[0].toUInt(&ok1, 16);
				const quint32 offset2 = spacePair[1].toUInt(&ok2, 16);

				if (!ok1 || !ok2 || offset1 >= offset2)
				{
					DLOG << "Invalid segment range: " << args[2];
					return false;
				}

				bool ok = false;
				const quint32 fileOffset = args[3].toUInt(&ok, 16);

				if (!ok)
				{
					DLOG << "Invalid file offset: " << args[3];
					return false;
				}

				Segment segment;
				segment.name = args[1];
				segment.memoryOffset = offset1;
				segment.size = offset2 - offset1;
				segment.fileOffset = fileOffset;

				m_segments << segment;
			}
			else if (action == "space")
			{
				if (args.size() != 2)
				{
					DLOG << "Invalid space record: " << line;
					return false;
				}


				const QStringList spacePair = args[1].split('-');
				if (spacePair.size() != 2)
				{
					DLOG << "Invalid space record: " << line;
					return false;
				}

				const quint32 offset1 = spacePair[0].toUInt(NULL, 0);
				const quint32 offset2 = spacePair[1].toUInt(NULL, 0);

				if (offset1 == 0 || offset2 == 0 || offset1 >= offset2)
				{
					DLOG << "Invalid space range: " << args[1];
					return false;
				}

				SpaceRecord rec;
				rec.offset = offset1;
				rec.size = offset2 - offset1;

				m_spaceRecords << rec;
			}
			else if (action == "messages")
			{
				if (args.size() != 2)
				{
					DLOG << "Invalid messages record: " << line;
					return false;
				}

				if (!loadMessages(args[1]))
				{
					DLOG << "Unable to load messages: " << args[1];
					return false;
				}
			}
		}
		else
		{
			const QStringList parts = line.split(':');
			if (parts.size() != 2)
			{
				DLOG << "Invalid record: " << line;
				return false;
			}

			const QList<quint32> offsets = strToValues(parts[0], true);
			if (offsets.isEmpty())
			{
				DLOG << "Invalid offsets: " << parts[0];
				return false;
			}

			const QString valuesInfo = parts[1].trimmed();
			const QString typeStr = valuesInfo.split(' ').first();

			PatchRecord rec;
			rec.offsets = offsets;

			if (typeStr == "byte")
			{
				rec.type = typeByte;
			}
			else if (typeStr == "word")
			{
				rec.type = typeWord;
			}
			else if (typeStr == "int")
			{
				rec.type = typeInt;
			}
			else if (typeStr == "string")
			{
				rec.type = typeString;
			}
			else if (typeStr == "utf8")
			{
				rec.type = typeUtf8;
			}
			else
			{
				DLOG << "Invalid value type: " << typeStr;
				return false;
			}
			
			const QString valuesStr = valuesInfo.right(valuesInfo.length() - typeStr.length()).trimmed();

			switch (rec.type)
			{
				case typeByte:
				case typeWord:
				case typeInt:
				{
					rec.values = strToValues(valuesStr);
					if (rec.values.isEmpty())
					{
						DLOG << "Invalid values: " << valuesStr;
						return false;
					}
					break;
				}
				case typeString:
				case typeUtf8:
				{
					const QStringList values = valuesStr.trimmed().split(',');
					if (values.length() == 0)
					{
						DLOG << "Missing string arguments!";
						return false;
					}
					if (values.length() > 2)
					{
						DLOG << "Invalid string argument count: " << valuesStr;
						return false;
					}
					
					rec.inplace = false;
					QString name = values[0].trimmed();
					if (name.startsWith('@'))
					{
						rec.inplace = true;
						name = name.right(name.length() - 1);
						if (values.length() > 1)
						{
							bool ok = false;
							quint32 limit = values[1].toUInt(&ok, 0);
							if (!ok)
							{
								DLOG << "Invalid limit value: " << values[1];
								return false;
							}

							rec.limit = limit;
						}
						else
						{
							rec.limit = 0;
						}
					}

					const quint32 hash = Hash::calc(name.toUtf8().constData());
					if (hash == 0)
					{
						DLOG << "Invalid string id: " << valuesStr;
						return false;
					}
					rec.values << hash;
					break;
				}
				default:
					ASSERT(0);
			}

			m_patchRecords << rec;
		}
	}

	return !m_segments.isEmpty();
}

bool ExecutablePatcher::loaded() const
{
	return m_loaded;
}

bool ExecutablePatcher::loadMessages(const QString& filename)
{
	QString path = filename;

	if (QFileInfo(filename).isRelative())
	{
		path = QFileInfo(m_filename).absoluteDir().absoluteFilePath(filename);
	}

	struct MessageRecord
	{
		quint32 hash;
		quint32 offset;
	};

	QtFileStream stream(path, QIODevice::ReadOnly);
	if (!stream.opened())
	{
		DLOG << "Unable to open messages file";
		return false;
	}

	const int version = stream.readInt();
	if (version != 2)
	{
		DLOG << "Invalid version: " << version;
		return false;
	}

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

	for (int i = 0; i < stringCount; i++)
	{
		const quint32 hash = records[i].hash;
		if (m_messages.contains(hash))
		{
			DLOG << "Message with hash " << QString::number(hash, 16).toUpper().rightJustified(8, '0') << " already exists!";
			return false;
		}
		
		const quint32 ptr = records[i].offset * 2;
		const ushort* c = reinterpret_cast<const ushort*>(&data[ptr]);
		const int len = (i == stringCount - 1) ? dataSize - ptr : records[i + 1].offset * 2 - ptr; 

		m_messages[hash] = QByteArray(reinterpret_cast<const char*>(c), len);
	}

	return true;
}

static quint32 align(quint32 v)
{
	return ((v + 3) / 4) * 4;
}

quint32 ExecutablePatcher::allocSpace(QList<SpaceRecord>& space, int size)
{
	for (int i = 0; i < space.size(); i++)
	{
		if (space[i].size >= size)
		{
			const quint32 offset = space[i].offset;

			space[i].offset += align(size);
			space[i].size -= align(size);

			if (space[i].isNull())
			{
				space.removeAt(i);
			}

			return offset;
		}
	}

	return 0;
}

quint32 ExecutablePatcher::fileOffset(quint32 memOffset) const
{
	foreach (const Segment& segment, m_segments)
	{
		if (memOffset >= segment.memoryOffset && memOffset < segment.memoryOffset + segment.size)
		{
			return segment.fileOffset + (memOffset - segment.memoryOffset);
		}
	}

	return 0;
}

bool ExecutablePatcher::apply(Consolgames::Stream* executableStream) const
{
	if (!m_loaded || m_segments.isEmpty())
	{
		DLOG << "Invalid initialization!";
		return false;
	}

	QList<SpaceRecord> spaceRecords = m_spaceRecords;

	foreach (const PatchRecord& record, m_patchRecords)
	{
		if (record.type == typeString || record.type == typeUtf8)
		{
			const bool utf8 = (record.type == typeUtf8);

			ASSERT(record.values.size() == 1);
			const quint32 hash = record.values.first();

			ASSERT(m_messages.contains(hash));
			if (!m_messages.contains(hash))
			{
				DLOG << "Unable to find message!";
				return false;
			}

			const QByteArray str = utf8
				? QString::fromRawData(reinterpret_cast<const QChar*>(m_messages[hash].constData()), m_messages[hash].size() / 2).toUtf8()
				: m_messages[hash];

			if (record.inplace)
			{
				if (record.limit != 0 && str.size() > static_cast<int>(record.limit))
				{
					DLOG << "String " << Hash::toString(hash) << " too long: " << str.size() << " bytes when limit is " << record.limit;
					return false;
				}

				foreach (quint32 offset, record.offsets)
				{
					const quint32 fileStrOffset = fileOffset(offset);

					if (fileStrOffset == 0)
					{
						DLOG << "Unable to map memory address to file offset!";
						return false;
					}

					if (executableStream->seek(fileStrOffset, Stream::seekSet) != fileStrOffset)
					{
						DLOG << "Unable to seek!";
						return false;
					}

					if (executableStream->write(str.constData(), str.size()) != str.size())
					{
						DLOG << "Unable to write string!";
						return false;
					}
				}
			}
			else
			{
				const quint32 strOffset = allocSpace(spaceRecords, str.size());

				if (strOffset == 0)
				{
					DLOG << "Unable to allocate space for string!";
					return false;
				}

				const quint32 fileStrOffset = fileOffset(strOffset);

				if (fileStrOffset == 0)
				{
					DLOG << "Unable to map memory address to file offset!";
					return false;
				}

				if (executableStream->seek(fileStrOffset, Stream::seekSet) != fileStrOffset)
				{
					DLOG << "Unable to seek!";
					return false;
				}

				if (executableStream->write(str.constData(), str.size()) != str.size())
				{
					DLOG << "Unable to write string!";
					return false;
				}

				foreach (quint32 offset, record.offsets)
				{
					const quint32 fOffset = fileOffset(offset);
					
					if (fOffset == 0)
					{
						DLOG << "Unable to map memory address to file offset!";
						return false;
					}

					if (executableStream->seek(fOffset, Stream::seekSet) != fOffset)
					{
						DLOG << "Unable to seek!";
						return false;
					}

					executableStream->writeUInt32(strOffset);
				}
			}

			continue;
		}

		foreach (quint32 offset, record.offsets)
		{
			const quint32 fOffset = fileOffset(offset);

			if (fOffset == 0)
			{
				DLOG << "Unable to map memory address to file offset!";
				return false;
			}

			if (executableStream->seek(fOffset, Stream::seekSet) != fOffset)
			{
				DLOG << "Unable to seek!";
				return false;
			}

			foreach (quint32 value, record.values)
			{
				switch (record.type)
				{
				case typeByte:
					executableStream->writeUInt8(value);
					break;
				case typeWord:
					executableStream->writeUInt16(value);
					break;
				case typeInt:
					executableStream->writeUInt32(value);
					break;
				default:
					ASSERT(0);
				}
			}
		}
	}

	return true;
}

}
