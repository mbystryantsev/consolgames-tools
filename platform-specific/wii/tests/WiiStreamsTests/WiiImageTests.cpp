#include "WiiImageTests.h"
#include <QTest>
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <memory>

using namespace Consolgames;

const std::string WiiImageTests::s_imageFilename = "D:/rev/corruption/Metroid_3_cor[pal].iso";

struct FileRecord
{
	QString name;
	qint64 offset;
	qint64 size;
	QByteArray hash;
};

FileRecord records[] = 
{
 	{"boot.bin", 0, 0x440, "76E14F10FBDA5051EFB2AECF01D6690C"},
 	{"bi2.bin", 0x440, 0x2000, "5DDE0016B7AEFBDC9E313D5DA522926E"},
 	{"apploader.img", 0x0002440, 0x034A3C, "A5571D39EB412D0A18FD41D2275F95B4"},
 	{"main.dol", 0x36F00, 0x5C6760, "36D5982B25A852287F250C958926C7E2"},
	{"fst.bin", 0x5FD700, 0x1C50, "862FA84880FDE0495FF55E5D4C1979D6"},
	{"Audio/Bryyo/Boss_BryyoSeedBoss.fsb", 0x9FC61B8C, 0x4B00E0, "5C4A2002B6C1BE0029542929986E9A57"},
	{"Video/Game/Cannon_Destroys_Phazon_Seed.thp", 0x2657730C, 0x421D940, ""},
	{"Video/Game/GameEnding_Best.thp", 0x2A794C4C, 0x52E4860, ""},
	{"Video/Game/GameEnding_Good.thp", 0x2FA794AC, 0x6FB1FA0, ""},
	{"FrontEnd.pak", 0xFC762360, 0x1AA13C0, ""},
	{"Metroid1.pak", 0xCE1D934C, 0x2E15B3C0, ""},
	{"Metroid3.pak", 0xA2E001AC, 0x299E7840, ""},
	{"Metroid4.pak", 0x7112C2EC, 0x2BFDEAC0, ""},
	{"Metroid5.pak", 0x4D4F2A4C, 0x226F30C0, ""},
	{"Metroid6.pak", 0x42B9EECC, 0x7909000, ""},
	{"Metroid7.pak", 0x383D282C, 0x971A7C0, ""},
	{"Metroid8.pak", 0x4A4A7ECC, 0x1FA2940, ""},
	{"Worlds.pak",   0xFC637F0C, 0x0012A280, "8C72242D5B7C58B59C12107B853C1780"},
	{"Worlds.txt",   0xFC76218C, 0x000001D4, "46DC5937984694CAA3491BFD524A5E5E"},
};

void WiiImageTests::initTestCase()
{
	QVERIFY(m_image.open(s_imageFilename, Stream::modeRead));
}

void WiiImageTests::filesTest()
{
	m_image.setDataPartition();
	for (int i = 0; i < _countof(records); i++)
	{
		Tree<FileInfo>::Node* node = m_image.findFile(records[i].name.toStdString());
		QVERIFY2(node != NULL, records[i].name.toLatin1().constData());
		if (node != NULL)
		{
			QCOMPARE((*node)->offset, records[i].offset);
			QCOMPARE((*node)->size, records[i].size);
			if (!records[i].hash.isEmpty())
			{
				QByteArray expectedHash = QByteArray::fromHex(records[i].hash);
				QCryptographicHash hash(QCryptographicHash::Md5);
				
				qint64 size = node->data().size;
				offset_t offset = node->data().offset;
				char data[1024 * 64];
				while (size > 0)
				{
					int readed = m_image.io_read_part(data, qMin<qint64>(size, sizeof(data)), m_image.currentPartition(), offset);
					hash.addData(data, readed);
					size -= readed;
					offset += readed;
				}
				QVERIFY2(hash.result() == expectedHash, QString("Hash mistmatch: %1").arg(records[i].name).toLatin1().constData());
			}
		}
	}
}

void WiiImageTests::fileStreamsTest()
{
	m_image.setDataPartition();
	for (int i = 0; i < _countof(records); i++)
	{
		std::auto_ptr<Stream> file(m_image.openFile(records[i].name.toStdString(), Stream::modeRead));
		QVERIFY2(file.get() != NULL, records[i].name.toLatin1().constData());
		if (file.get() != NULL)
		{
			QCOMPARE(file->size(), records[i].size);
			if (!records[i].hash.isEmpty())
			{
				QByteArray expectedHash = QByteArray::fromHex(records[i].hash);
				QByteArray actualHash = calcHash(file.get());

				QVERIFY2(actualHash == expectedHash, QString("Hash mistmatch: %1").arg(records[i].name).toLatin1().constData());
			}
		}
	}
}

void WiiImageTests::cleanupTestCase()
{
	m_image.close();
}

void WiiImageTests::writeFileTest()
{
	const QString filename = QDir::tempPath() + QDir::separator() + "mp3c_test.pak";
	if (!QFile::exists(filename))
	{
		QVERIFY(QFile::copy(QString::fromStdString(s_imageFilename), filename));
	}

	WiiImage image;
	QVERIFY(image.open(filename.toStdString(), Stream::modeReadWrite));
	image.setDataPartition();
	std::auto_ptr<Stream> file(image.openFile("Worlds.txt", Stream::modeWrite));
	QVERIFY(file.get() != NULL);

	FileStream testFile("testdata/World_replace.txt", Stream::modeRead);
	QVERIFY(testFile.isOpen());
	QCOMPARE(testFile.size(), file->size());

	QCOMPARE(file->writeStream(&testFile, testFile.size()), testFile.size());
	file->seek(0, FileStream::seekSet);

	QByteArray expectedHash = calcHash(file.get());
	QByteArray actualHash = calcHash(&testFile);
	QCOMPARE(actualHash, expectedHash);
}

QByteArray WiiImageTests::calcHash(Stream* file)
{
	qint64 size = file->size();
	char data[1024 * 64];
	file->seek(0, Stream::seekSet);

	QCryptographicHash hash(QCryptographicHash::Md5);
	while (size > 0)
	{
		int readed = file->read(data, qMin<qint64>(size, sizeof(data)));
		hash.addData(data, readed);
		size -= readed;
	}
	return hash.result();
}

quint64 WiiImageTests::getFreeSpace()
{
#if !defined(_WIN32) && !defined(_WIN64)
	return 0;
#else
	MEMORYSTATUSEX memoryStatus;
	ZeroMemory(&memoryStatus, sizeof(MEMORYSTATUSEX));
	memoryStatus.dwLength = sizeof(MEMORYSTATUSEX);
	if (GlobalMemoryStatusEx(&memoryStatus))
	{
		return memoryStatus.ullTotalPhys;
	}
	else
	{
		return 0;
	}
#endif
}