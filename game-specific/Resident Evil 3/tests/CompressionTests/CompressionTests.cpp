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

	QTest::newRow("text") << QByteArray("31. Gas Station (Any other scenario except for above)\r\n"
		"(Screen: Jill enters the gas station. She walks up to the counter, then turns \r\n"
		"when she hears someone come in.)\r\n"
		"Carlos Oliviera: Jill!\r\n"
		" (Screen: Jill Valentine and Carlos Oliviera hear moaning outside)\r\n"
		"Carlos Oliviera: Hey, the zombies are getting restless.\r\n"
		"Jill Valentine: I know. I can hear them. What’s going on?!\r\n"
		" (Screen: Jill Valentine tries to go behind the counter.)\r\n"
		"Carlos Oliviera (looking outside): Jill! \r\n"
		"Jill Valentine (turns around): What’s wrong?!\r\n"
		" (Screen: Zombies are walking towards the gas station.)\r\n"
		"Carlos Oliviera: They’re coming! They must’ve sniffed us out! They know we’re \r\n"
		"here!\r\n"
		" (Screen: Jill Valentine raises an arm.)\r\n"
		"Jill Valentine: Hey, calm down.\r\n"
		"Carlos Oliviera (turning around and cocking his gun): Any objections to my \r\n"
		"playing hero this time?\r\n"
		"Jill Valentine: What are you doing?!\r\n"
		" (Screen: Carlos Oliviera turns and leaves the gas station.)\r\n"
		"Jill Valentine: Carlos!\r\n"
		" (Screen: Jill Valentine looks outside the glad door. Carlos Oliviera is \r\n"
		"firing at the advancing zombies.)\r\n"
		"Carlos Oliviera: Eat this! (yells)\r\n"
		" (Screen: Jill Valentine runs behind the counter and cracks the code to the \r\n"
		"electronic lock. She collects the item inside, then turns to leave the \r\n"
		"counter.)\r\n"
		" (Screen: Sparks fly from a cut wire, causing the garage to explode. Jill \r\n"
		"Valentine dodges the wave of fire that came out, setting the gas station on \r\n"
		"fire. She runs for the door, looking at the garage one last time fore going \r\n"
		"outside. Carlos Oliviera is leaning against the gas station on his rear, \r\n"
		"appearing unconscious.)\r\n"
		"Jill Valentine: Carlos! (falls to her knees) No!\r\n"
		"Carlos Oliviera (takes a breath and looks at her): Relax. I’m not dead yet.\r\n"
		"Jill Valentine: Are you okay? (stands up)\r\n"
		"Carlos Oliviera (pants as he stand up, one arm around his middle): I’m fine. \r\n"
		"Huh, that hero stuff is harder than it looks.\r\n"
		" (Screen: They run away from the gas station)\r\n"
		"(Screen: Fire continues to engulf the gas station. Jill Valentine turns back \r\n"
		"to see small explosion, holding up her arms with a cry as she runs. The gas \r\n"
		"station finally explodes, sending Jill Valentine flying and screaming. She \r\n"
		"and Carlos Oliviera slowly get up.)\r\n"
		"Carlos Oliviera: Ouch. My ears are ringing. We both should be deaf by now. \r\n"
		"Olay, I’m gonna scrounge some equipment. There might not be any at our \r\n"
		"destination.\r\n"
		" (Screen: Carlos Oliviera leaves)\r\n"
		"\r\n"
		" 32. The Worm\r\n"
		" (Screen: Jill Valentine is running through the park when the area starts \r\n"
		"shaking again. She stops, then yells as the ground gives way. Jill Valentine \r\n"
		"falls into a sewer, standing up as she hears noises. She looks at the wall \r\n"
		"behind her, then walks backwards as the wall burst, a creature with four \r\n"
		"fangs and a large mouth bursting through to try and bite her before going \r\n"
		"back into the wall.)\r\n"
		"\r\n"
		"\r\n");
}

void CompressionTests::sizeTest()
{
	{
		MemoryStream result;
		Compressor::encode(&MemoryStream("aaaaaaaaaaaaaaa", 15), &result);
		QCOMPARE(static_cast<int>(result.size()), 11);
	}

}