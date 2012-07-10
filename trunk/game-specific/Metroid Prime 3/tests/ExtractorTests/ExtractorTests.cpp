#include "ExtractorTests.h"
#include "HashStream.h"
#include <QTest>
#include <QFile>
#include <vector>

void ExtractorTests::initTestCase()
{
	loadHashDatabase();
	QVERIFY(m_pakArchive.open("testdata/Worlds.pak"));
}

void ExtractorTests::extractTest()
{
	std::vector<Hash> fileList = m_pakArchive.fileNamehashesList();
	foreach (const Hash hash, fileList)
	{
		if (!m_hashes.contains(hash))
		{
			QWARN("Hash not found in database!");
			continue;
		}

		HashStream stream;
		QVERIFY(m_pakArchive.extractFile(hash, &stream));
		QVERIFY2(stream.hash() == m_hashes[hash], QByteArray::number(hash, 16).constData());
	}
}

void ExtractorTests::rebuildTest()
{
	// TODO: Implement
}

void ExtractorTests::loadHashDatabase()
{
	QFile file("testdata/Worlds.hashdb");
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

		QVERIFY(!m_hashes.contains(nameHash));
		m_hashes[nameHash] = dataHash;
	}
}