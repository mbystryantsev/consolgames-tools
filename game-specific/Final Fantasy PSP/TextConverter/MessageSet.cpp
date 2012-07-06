#include "MessageSet.h"
#include <QFile>

QMap<uint16, QString> MessageSet::s_varMap;

void MessageSet::open(const QString& filename, const FontInfo& fontInfo)
{
	QFile file(filename);
	file.open(QIODevice::ReadOnly);
	QDataStream stream(&file);
	stream.setByteOrder(QDataStream::LittleEndian);
	unserialize(stream, fontInfo);
}

void MessageSet::unserialize(QDataStream& stream, const FontInfo& fontInfo)
{
	MessageSetHeader header;
	stream.readRawData(reinterpret_cast<char*>(&header), sizeof(header));

	QVector<uint32> pointers(header.stringCount);
	stream.readRawData(reinterpret_cast<char*>(&pointers[0]), header.stringCount * 4);

	QMap<uint16, QChar> charMap;
	buildCharMap(fontInfo.encodingMap(), charMap, fontInfo.charCount());

	readMessages(stream, pointers, charMap, fontInfo.charCount());
}

void MessageSet::buildCharMap(const EncodingMap& encodingMap, QMap<uint16, QChar>& charMap, uint16 charCount)
{
	for (int i = 0; i < _countof(encodingMap); i++)
	{
		if (encodingMap[i] != 0xFFFF)
		{
			charMap[encodingMap[i]] = QChar(i);
		}
	}

	charMap[charCount] = '\0';
	charMap[charCount + 1] = '\n';
	//charMap[charCount + 2] = '?';
	charMap[charCount + 3] = '\n';
}

void MessageSet::readMessages(QDataStream& stream, const QVector<uint32>& pointers, QMap<uint16, QChar>& charMap, int charCount)
{
// 	if (s_varMap.isEmpty())
// 	{
// 		s_varMap[0x0A] = "name";
// 		s_varMap[0x0B] = "count";
// 		s_varMap[0x2C] = "gil";
// 		s_varMap[0x31] = "hour";
// 		s_varMap[0x32] = "min";
// 		s_varMap[0x33] = "sec";
// 		s_varMap[0x34] = "battles";
// 	}

	m_messages.clear();

	foreach (uint32 pointer, pointers)
	{
		QString string;
		stream.device()->seek(pointer);
		while (!stream.atEnd())
		{
			uint8 byte = 0;
			stream >> byte;
			uint16 charIndex = byte;
		
			if (charIndex >= 0x80)
			{
				stream >> byte;
				charIndex = decodeChar((charIndex << 8) | byte);
			}

			if (charIndex == charCount + 3)
			{
				string.append("\n-");
				continue;
			}
			
			if (!charMap.contains(charIndex))
			{
				if (charIndex >= charCount)
				{
					if (s_varMap.contains(charIndex - charCount))
					{
						string.append("{" + s_varMap[charIndex - charCount] + "}");
					}
					else
					{
						string.append(QString("{VAR:%1}").arg(charIndex - charCount, 2, 16, QChar('0')));
					}
				}
				else
				{
					string.append("{" + QString::number(charIndex, 16) + "}");
				}
				continue;
			}
			
			QChar c = charMap[charIndex];
			if (c.unicode() == 0)
			{
				break;
			}
			

			string.append(c);
		}
		
		m_messages.append(string);
	}

}

uint16 MessageSet::decodeChar(uint16 code)
{
	return ((code & 0x1F00) >> 2) | (code & 0x3F);
}

const QStringList& MessageSet::messages() const
{
	return m_messages;
}