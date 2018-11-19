#include "FontStreamRebuilderTests.h"
#include <FontStreamRebuilder.h>
#include <QtFileStream.h>
#include <QTest>
#include <memory>

using namespace Consolgames;
using namespace ShatteredMemories;

Q_DECLARE_METATYPE(Consolgames::Stream::ByteOrder);
Q_DECLARE_METATYPE(FontStreamRebuilder::Version);

static bool compareStreams(Stream* s1, Stream* s2)
{
	enum
	{
		c_bufSize = 1024
	};

	uint8 buf1[c_bufSize];
	uint8 buf2[c_bufSize];

	while (true)
	{
		const largesize_t readed1 = s1->read(buf1, c_bufSize);
		const largesize_t readed2 = s2->read(buf2, c_bufSize);
		if (readed1 != readed2)
		{
			return false;
		}

		if (!std::equal(buf1, buf1 + c_bufSize, buf2))
		{
			return false;
		}

		if (s1->atEnd() || s2->atEnd())
		{
			break;
		}
	}

	return true;
}

static void dumpStream(const QString& filename, Stream* stream)
{
	QtFileStream file(filename, QIODevice::WriteOnly);
	QVERIFY(file.isOpen());

	while (!stream->atEnd())
	{
		file.writeStream(stream, 0x4000);
	}
}

void FontStreamRebuilderTests::shatteredMemoriesTest()
{
	QFETCH(QString, sourceName);
	QFETCH(QString, expectedName);
	QFETCH(Stream::ByteOrder, byteOrder);
	QFETCH(FontStreamRebuilder::Version, version);

	std::shared_ptr<QtFileStream> stream(new QtFileStream(sourceName, QIODevice::ReadOnly));
	QVERIFY(stream->isOpen());

	std::shared_ptr<QtFileStream> fontStream(new QtFileStream("data/Font", QIODevice::ReadOnly));
	QVERIFY(fontStream->isOpen());

	FontStreamRebuilder rebuilder(stream, fontStream, byteOrder, version);

	QtFileStream expected(expectedName, QIODevice::ReadOnly);
	QVERIFY(expected.isOpen());
	
	bool success = compareStreams(&rebuilder, &expected);

	if (!success)
	{
		stream->seek(0, Stream::seekSet);
		fontStream->seek(0, Stream::seekSet);
		FontStreamRebuilder rebuilder(stream, fontStream, byteOrder, version);
		dumpStream(sourceName + ".result", &rebuilder);

		QFAIL(("Streams are different! Result stored as " + sourceName + ".result").toStdString().c_str());
	}
}

void FontStreamRebuilderTests::shatteredMemoriesTest_data()
{
	QTest::addColumn<QString>("sourceName");
	QTest::addColumn<QString>("expectedName");
	QTest::addColumn<Stream::ByteOrder>("byteOrder");
	QTest::addColumn<FontStreamRebuilder::Version>("version");

	QTest::newRow("shsm.ps2") << QString("data/FontEUR_shsm_ps2") << QString("data/FontEUR_shsm_ps2.expected") << Stream::orderLittleEndian << FontStreamRebuilder::versionShatteredMemories;
	QTest::newRow("shsm.ps2") << QString("data/FontEUR_shsm_wii") << QString("data/FontEUR_shsm_wii.expected") << Stream::orderBigEndian << FontStreamRebuilder::versionShatteredMemories;
	QTest::newRow("shsm.ps2") << QString("data/FontEUR_sh0_ps2") << QString("data/FontEUR_sh0_ps2.expected") << Stream::orderLittleEndian << FontStreamRebuilder::versionOrigins;
}