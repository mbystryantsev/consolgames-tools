#include "ExtractorTests.h"
#include "HashStream.h"
#include <QTest>
#include <QFile>

void ExtractorTests::initTestCase()
{
	loadHashDatabase("testdata/Worlds.hashdb", m_hashes);
	QVERIFY(m_pakArchive.open(L"testdata/Worlds.pak"));
}

void ExtractorTests::extractTest()
{
	compareHashes(m_pakArchive, m_hashes);
}

void ExtractorTests::rebuildSimplyTest()
{
	testRebuild(m_pakArchive, m_hashes, std::vector<std::wstring>());
}

void ExtractorTests::rebuildTest()
{
	QMap<Hash, QByteArray> hashes = m_hashes;
	loadHashDatabase("testdata/Worlds_rebuilded.hashdb", hashes);
	std::vector<std::wstring> dirs(1, L"testdata");
	testRebuild(m_pakArchive, hashes, dirs);
}

void ExtractorTests::rebuildTestMerged()
{
	QMap<Hash, QByteArray> hashes = m_hashes;
	loadHashDatabase("testdata/Worlds_rebuilded.hashdb", hashes);
	loadHashDatabase("testdata/Worlds_rebuilded_merged.hashdb", hashes);
	std::vector<std::wstring> dirs(1, L"testdata");

	std::map<Hash,Hash> mergeMap;
	mergeMap[0x0129F5BFB15311E3] = 0x009A7BEE0B63A3B8;
	mergeMap[0x015FFC59DF162302] = 0x009A7BEE0B63A3B8;
	mergeMap[0x01718C2F4C5E2C02] = 0x009A7BEE0B63A3B8;
	mergeMap[0x0186558498F41E3C] = 0x009A7BEE0B63A3B8;
	mergeMap[0x02DCB521DE4674B5] = 0x009A7BEE0B63A3B8;
	mergeMap[0x03759A7C14CED0D4] = 0x009A7BEE0B63A3B8;
	mergeMap[0x03B7CF6D0F2467F9] = 0x009A7BEE0B63A3B8;
	mergeMap[0x03C82F2EA130D594] = 0x009A7BEE0B63A3B8;
	mergeMap[0x04103F903B11D9E0] = 0x009A7BEE0B63A3B8;
	mergeMap[0x043C2CD8DA48E564] = 0x009A7BEE0B63A3B8;
	mergeMap[0x05630E8EB047656B] = 0x009A7BEE0B63A3B8;
	testRebuild(m_pakArchive, hashes, dirs, mergeMap);
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

void ExtractorTests::testRebuild(PakArchive& pak, const QMap<Hash, QByteArray>& hashes,
								 const std::vector<std::wstring>& inputDirs, const std::map<Hash,Hash>& mergeMap)
{
	const QString rebuildedFile = "pak.rebuilded";
	pak.rebuild(rebuildedFile.toStdWString(), inputDirs, std::set<ResType>(), mergeMap);
	{
		PakArchive rebuildedPak;
		QVERIFY(rebuildedPak.open(rebuildedFile.toStdWString()));
		compareHashes(rebuildedPak, hashes);
	}
	//QVERIFY(QFile::remove(rebuildedFile));
}