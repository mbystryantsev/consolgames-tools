#include "MainDolPatcher.h"
#include <pak.h>
#include <MemoryStream.h>
#include <core.h>
#include <lzo/include/lzo/lzo1x.h>
#include <QStringList>
#include <QTextStream>

using namespace Consolgames;

namespace
{

static const int s_messageCount = 4;
static const int s_languageCount = 6;

struct BlockInfo
{
	quint32 offset;
	quint32 size;
	quint32 ptrsOffset;
};

static const BlockInfo s_systemFontInfo = {0x57F290, 0xA38};
static const BlockInfo s_systemFontTextureInfo = {0x57FCC8, 0x7C0};
static const BlockInfo s_systemMessagesInfo[4] =
{
	{0x5747B8, 0x1B8, 0x574970},
	{0x574988, 0x428, 0x574DB0},
	{0x574DC8, 0x238, 0x575000},
	{0x575018, 0x1D8, 0x5751F0}
};

static quint32 s_systemFontSize = 0x1664;
static quint32 s_systemFontTextureSize = 0xA34;

static const quint32 s_ptrDiff = 0x80003F20;

}

bool MainDolPatcher::open(const QString& filename)
{
	m_fileStream.reset(new QtFileStream(filename, QIODevice::ReadWrite));
	if (m_fileStream->opened())
	{
		m_fileStream->setByteOrder(Stream::orderBigEndian);
	}
	return m_fileStream->opened();
}

static QStringList loadMessages(const QString& filename)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		return QStringList();
	}

	QTextStream stream(&file);
	stream.setCodec("UTF-8");
	QString message;
	QStringList messages;
	while (true)
	{
		const QString line = stream.readLine();
		if (line.isEmpty())
		{
			messages << message;
			message.clear();
			continue;
		}
		if (!message.isEmpty())
		{
			message.append('\n');
		}
		message.append(line);

		if (stream.atEnd())
		{
			break;
		}
	}
	return messages;
}


bool MainDolPatcher::patchStrings(const QString& messagesFilename)
{
	const QStringList messages = loadMessages(messagesFilename);
	ASSERT(messages.size() == s_messageCount);
	if (messages.size() != s_messageCount)
	{
		return false;
	}

	for (int i = 0; i < s_messageCount; i++)
	{
		const BlockInfo& info = s_systemMessagesInfo[i];

		m_fileStream->seek(info.ptrsOffset, Stream::seekSet);
		const quint32 ptrValue = info.offset + s_ptrDiff;
		for (int j = 0; j < s_languageCount; j++)
		{
			m_fileStream->write32(ptrValue);
		}

		const int avaibleLen = info.size / 2 - 1;
		ASSERT(messages[i].size() <= avaibleLen);
		if (messages[i].size() > avaibleLen)
		{
			return false;
		}

		m_fileStream->seek(info.offset, Stream::seekSet);
		foreach (const QChar c, messages[i])
		{
			m_fileStream->write16(c.unicode());
		}
		m_fileStream->write16(0);
	}

	return true;
}

bool MainDolPatcher::patchCompressedItem(const QString& filename, quint32 offset, quint32 size, quint32 originalSize)
{
	QtFileStream file(filename, QIODevice::ReadOnly);
	if (!file.opened())
	{
		return false;
	}
	if (file.size() > originalSize)
	{
		return false;
	}

	std::vector<quint8> data(originalSize);
	file.read(&data[0], file.size());
	file.close();

	std::vector<quint8> buf(LZO1X_999_MEM_COMPRESS);
	MemoryStream stream(&data[0], data.size());

	m_fileStream->seek(offset, Stream::seekSet);
	const quint32 lzoSize = PakArchive::compressLzo(&stream, stream.size(), m_fileStream.get(), &buf[0]);
	ASSERT(lzoSize <= size - 2);
	if (lzoSize > size - 2)
	{
		return false;
	}
	for (quint32 i = lzoSize; i < size; i++)
	{
		m_fileStream->write8(0);
	}

	return true;
}

bool MainDolPatcher::patch(const QString& messagesFilename, const QString& fontFilename, const QString& fontTextureFilename)
{
	if (!patchStrings(messagesFilename))
	{
		return false;
	}
	if (!patchCompressedItem(fontFilename, s_systemFontInfo.offset, s_systemFontInfo.size, s_systemFontSize))
	{
		return false;
	}
	if (!patchCompressedItem(fontTextureFilename, s_systemFontTextureInfo.offset, s_systemFontTextureInfo.size, s_systemFontTextureSize))
	{
		return false;
	}
	m_fileStream->flush();

	return true;
}