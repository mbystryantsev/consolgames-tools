#include "ExtractorTests.h"
#include "HashStream.h"
#include <QTest>
#include <QFile>

void ExtractorTests::initTestCase()
{
	loadHashDatabase("testdata/Worlds.hashdb", m_hashes);
	QVERIFY(m_pakArchive.open("testdata/Worlds.pak"));
}

void ExtractorTests::extractTest()
{
	compareHashes(m_pakArchive, m_hashes);
}

void ExtractorTests::rebuildSimplyTest()
{
	testRebuild(m_pakArchive, m_hashes, std::vector<std::string>());
}

void ExtractorTests::rebuildTest()
{
	QMap<Hash, QByteArray> hashes = m_hashes;
	loadHashDatabase("testdata/Worlds_rebuilded.hashdb", hashes);
	std::vector<std::string> dirs(1, "testdata");
	testRebuild(m_pakArchive, hashes, dirs);
}

void ExtractorTests::loadHashDatabase(const QString& hashesFile, QMap<Hash, QByteArray>& hashes)
{
	QFile file(hashesFile);
	QVERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));

	while (!file.atEnd())
	{
		const QByteArray line = file.readLine().trimmed();
		if (line.isEmpty())
		{
			continue;
		}

		const QList<QByteArray> values = line.split(' ');
		QCOMPARE(values.size(), 2);

		bool ok = false;
		const Hash nameHash = values[0].toULongLong(&ok, 16);
		QVERIFY(ok);

		const QByteArray dataHash = QByteArray::fromHex(values[1]);
		QVERIFY(!dataHash.isEmpty() && dataHash.size() == 16);

		hashes[nameHash] = dataHash;
	}
}

void ExtractorTests::compareHashes(PakArchive& pak, const QMap<Hash, QByteArray>& hashes)
{
	std::vector<Hash> fileList = pak.fileNamehashesList();
	foreach (const Hash hash, fileList)
	{
		if (!hashes.contains(hash))
		{
			QWARN("Hash not found in database!");
			continue;
		}

		HashStream stream;
		QVERIFY(pak.extractFile(hash, &stream));
		QVERIFY2(stream.hash() == hashes[hash], QByteArray::number(hash, 16).constData());
	}
}

void ExtractorTests::testRebuild(PakArchive& pak, const QMap<Hash, QByteArray>& hashes, const std::vector<std::string>& inputDirs)
{
	const QString rebuildedFile = "pak.rebuilded";
	pak.rebuild(rebuildedFile.toStdString(), inputDirs);
	{
		PakArchive rebuildedPak;
		QVERIFY(rebuildedPak.open(rebuildedFile.toStdString()));
		compareHashes(rebuildedPak, hashes);
	}
	QVERIFY(QFile::remove(rebuildedFile));
}