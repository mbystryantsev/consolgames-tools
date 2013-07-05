#include "CompressionTests.h"
#include "Compressor.h"
#include "MemoryStream.h"
#include <QByteArray>
#include <QtTest>

using namespace Consolgames;
using namespace ResidentEvil;

void CompressionTests::test()
{
	QFETCH(QByteArray, data);

	MemoryStream compressionStream;
	Compressor::encode(&MemoryStream(data.constData(), data.size()), &compressionStream);

	compressionStream.seek(0, Stream::seekSet);
	MemoryStream resultStream;
	Compressor::decode(&compressionStream, &resultStream);

	const QByteArray result = QByteArray(static_cast<const char*>(resultStream.memory()), resultStream.size());
	QCOMPARE(result, data);
}

void CompressionTests::test_data()
{
	QTest::addColumn<QByteArray>("data");

	{
		QByteArray data;
		data.resize(1024 * 1024);
		data.fill('z');
		QTest::newRow("big") << data;
	}

	QTest::newRow("empty") << QByteArray("");
	QTest::newRow("single") << QByteArray("1");
	QTest::newRow("periodic") << QByteArray("abcabcabc");
	QTest::newRow("fill") << QByteArray("aaaaaaaaaaa");
	QTest::newRow("data1") << QByteArray("Times New Roman");
	QTest::newRow("data2") << QByteArray("Resident Evil");
	QTest::newRow("null") << QByteArray("\0");
	QTest::newRow("null2") << QByteArray("\0\0");
	QTest::newRow("null3") << QByteArray("\0\0\0");
	QTest::newRow("text") << QByteArray("1. Raccoon City’s Narrator"
		"(Screen: A picture of the Umbrella Corporation’s logo)"
		"Jill Valentine (Narration):  It all began as an ordinary day in September... "
		"An ordinary day in Raccoon City, a city controlled by Umbrella."
		"(Screen: Jill Valentine’s upper body moving from left-to-right)"
		"Jill Valentine:  No one dared to opposed them... and that lack of strength "
		"would ultimately lead to their destruction. I suppose they had to suffer the "
		"consequences for their actions, but there would be no forgiveness."
		"(Screen: Jill closes her eyes)"
		"Jill Valentine:  If only they had the courage to fight. It’s true once the "
		"wheels of justice began to turn, nothing can stop them. Nothing."
		"(Screen: Jill sitting on a bed, legs crossed, and loading a gun.)"
		"Jill Valentine:  It was Raccoon City’s last chance... and my last chance... "
		"My last escape.");
}

void CompressionTests::sizeTest()
{
	{
		MemoryStream result;
		Compressor::encode(&MemoryStream("aaaaaaaaaaaaaaa", 15), &result);
		QCOMPARE(static_cast<int>(result.size()), 11);
	}

}