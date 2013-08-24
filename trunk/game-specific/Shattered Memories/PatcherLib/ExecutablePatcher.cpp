#include "ExecutablePatcher.h"
#include <Hash.h>
#include <Stream.h>
#include <QtFileStream.h>
#include <QTextStream>
#include <QStringList>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <vector>

using namespace Consolgames;

namespace ShatteredMemories
{

ExecutablePatcher::ExecutablePatcher(const QString& filename)
	: m_loaded(false)
	, m_executableStartOffset(0)
	, m_executableLoadOffset(0)
	, m_filename(filename)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		return;
	}

	QTextStream stream(&file);
	m_loaded = loadFromStream(&stream);
}

static QList<quint32> strToValues(const QString& str, bool isPureOffsets = false)
{
	const QStringList offsetStrings = str.split(',');
	
	QList<quint32> values;
	values.reserve(offsetStrings.size());

	foreach (const QString& offsetStr, offsetStrings)
	{
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

		if (line.startsWith("start") || line.startsWith("load") || line.startsWith("space") || line.startsWith("messages"))
		{
			const QStringList args = line.split(' ', QString::SkipEmptyParts);
			const QString action = args.first();

			if (action == "start")
			{
				if (m_executableStartOffset != 0)
				{
					DLOG << "Executable start offset already defined!";
					return false;
				}

				if (args.size() != 2)
				{
					DLOG << "Invalid start record: " << line;
					return false;
				}

				m_executableStartOffset = args[1].toUInt(NULL, 0);

				if (m_executableStartOffset == 0)
				{
					DLOG << "Invalid start offset: " << args[1];
					return false;
				}
			}
			else if (action == "load")
			{
				if (m_executableLoadOffset != 0)
				{
					DLOG << "Executable load offset already defined!";
					return false;
				}

				if (args.size() != 2)
				{
					DLOG << "Invalid load record: " << line;
					return false;
				}

				m_executableLoadOffset = args[1].toUInt(NULL, 0);

				if (m_executableLoadOffset == 0)
				{
					DLOG << "Invalid load offset: " << args[1];
					return false;
				}
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
			if (typeStr == "word")
			{
				rec.type = typeWord;
			}
			if (typeStr == "int")
			{
				rec.type = typeInt;
			}
			else if (typeStr == "string")
			{
				rec.type = typeString;
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
				{
					const quint32 hash = Hash::calc(valuesStr.toUtf8().constData());
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

	return (m_executableLoadOffset != 0 && m_executableStartOffset != 0);
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
	return m_executableStartOffset + (memOffset - m_executableLoadOffset);
}

bool ExecutablePatcher::apply(Consolgames::Stream* executableStream) const
{
	if (!m_loaded || m_executableLoadOffset == 0 || m_executableStartOffset == 0)
	{
		DLOG << "Invalid initialization!";
		return false;
	}

	QList<SpaceRecord> spaceRecords = m_spaceRecords;

	foreach (const PatchRecord& record, m_patchRecords)
	{
		if (record.type == typeString)
		{
			ASSERT(record.values.size() == 1);
			const quint32 hash = record.values.first();

			ASSERT(m_messages.contains(hash));
			if (!m_messages.contains(hash))
			{
				DLOG << "Unable to find message!";
				return false;
			}

			const QByteArray str = m_messages[hash];
			const quint32 strOffset = allocSpace(spaceRecords, str.size());

			if (strOffset == 0)
			{
				DLOG << "Unable to allocate space for string!";
				return false;
			}

			const quint32 fileStrOffset = fileOffset(strOffset);
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
				
				if (executableStream->seek(fOffset, Stream::seekSet) != fOffset)
				{
					DLOG << "Unable to seek!";
					return false;
				}

				executableStream->writeUInt32(strOffset);
			}

			continue;
		}

		foreach (quint32 offset, record.offsets)
		{
			const quint32 fOffset = fileOffset(offset);

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
