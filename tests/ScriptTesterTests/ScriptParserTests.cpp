#include "ScriptParserTests.h"
#include <ScriptParser.h>
#include <QtTest>

void ScriptParserTests::parseMessage()
{
	Message message = ScriptParser::parseMessage(
		"[ID:abc]\r\n"
		"text\r\n"
		"{E}\r\n"
		"\r\n"
		);
	QCOMPARE(message.id, QString("abc"));
	QCOMPARE(message.text, QString("text"));
}

void ScriptParserTests::parseMessageCrLf()
{
	Message message = ScriptParser::parseMessage(
		"[ID:abc]\n"
		"text\r\n"
		"{E}\n"
		"\r\n"
		);
	QCOMPARE(message.id, QString("abc"));
	QCOMPARE(message.text, QString("text"));
}

void ScriptParserTests::parseMessageCrLf2()
{
	Message message = ScriptParser::parseMessage(
		"[ID:abc]\r\n"
		"text\n"
		"{E}\r\n"
		"\n"
		);
	QCOMPARE(message.id, QString("abc"));
	QCOMPARE(message.text, QString("text"));
}

void ScriptParserTests::parseMessageCrLf3()
{
	Message message = ScriptParser::parseMessage(
		"[ID:abc]\n"
		"text\n"
		"{E}\n"
		"\n"
		);
	QCOMPARE(message.id, QString("abc"));
	QCOMPARE(message.text, QString("text"));
}

void ScriptParserTests::parseMessageMultiline()
{
	Message message = ScriptParser::parseMessage(
		"line1\r\n"
		"line2\n"
		"line3\r\n"
		"{E}\r\n"
		"\r\n"
		);
	QCOMPARE(message.id, QString(""));
	QCOMPARE(message.text, QString("line1\r\nline2\nline3"));
}

void ScriptParserTests::parseMessageFromSet()
{
	Message message = ScriptParser::parseMessage(
		"text\r\n"
		"{E}\r\n"
		"\r\n"
		"text2\r\n"
		"{E}\r\n"
		"\r\n"
		);
	QCOMPARE(message.id, QString(""));
	QCOMPARE(message.text, QString("text"));
}

void ScriptParserTests::parseEmptyMessage()
{
	Message message = ScriptParser::parseMessage(
		"\r\n"
		"{E}\r\n"
		"\r\n"
		"text\r\n"
		"{E}\r\n"
		"\r\n"
	);

	QCOMPARE(message.id, QString(""));
	QCOMPARE(message.text, QString(""));
}

void ScriptParserTests::parseEmptyMessageCrLf()
{
	Message message = ScriptParser::parseMessage(
		"\n"
		"{E}\r\n"
		"\r\n"
		"text\r\n"
		"{E}\r\n"
		"\r\n"
		);

	QCOMPARE(message.id, QString(""));
	QCOMPARE(message.text, QString(""));
}

void ScriptParserTests::parseMessageSet()
{
	MessageSet messageSet = ScriptParser::parseMessageSet(
		"[@0123456789ABCDEF,3,1,2]\r\n"
		"\r\n"
		"text1\r\n"
		"{E}\r\n"
		"\r\n"
		"[ID:ID]\r\n"
		"text2\r\n"
		"{E}\r\n"
		"\r\n"
		"text3\r\n"
		"{E}\r\n"
		"\r\n"
		);


	QCOMPARE(messageSet.nameHashes.size(), 1);
	QCOMPARE(messageSet.nameHashes[0], 0x0123456789ABCDEFULL);
	QCOMPARE(messageSet.messages.size(), 3);
	QCOMPARE(messageSet.definedCount, 3);
	QCOMPARE(messageSet.idCount, 1);
	QCOMPARE(messageSet.version, 2);

	if (messageSet.messages.size() == 3)
	{
		QCOMPARE(messageSet.messages[0].id, QString(""));
		QCOMPARE(messageSet.messages[0].text, QString("text1"));

		QCOMPARE(messageSet.messages[1].id, QString("ID"));
		QCOMPARE(messageSet.messages[1].text, QString("text2"));

		QCOMPARE(messageSet.messages[2].id, QString(""));
		QCOMPARE(messageSet.messages[2].text, QString("text3"));
	}
}

void ScriptParserTests::parseEmptyMessageSet()
{
	MessageSet messageSet = ScriptParser::parseMessageSet("[@0123456789ABCDEF,3,1,2]\r\n\r\n");
	
	QCOMPARE(messageSet.nameHashes.size(), 1);
	QCOMPARE(messageSet.nameHashes[0], 0x0123456789ABCDEFULL);
	QCOMPARE(messageSet.messages.size(), 0);
	QCOMPARE(messageSet.definedCount, 3);
	QCOMPARE(messageSet.idCount, 1);
	QCOMPARE(messageSet.version, 2);
}

void ScriptParserTests::parseMultiHashesMessageSet()
{
	MessageSet messageSet = ScriptParser::parseMessageSet("[@0123456789ABCDEF|AAAAAAAAAAAAAAAA|BBBBBBBBBBBBBBBB,3,1,2]\r\n\r\n");

	QCOMPARE(messageSet.nameHashes.size(), 3);
	QCOMPARE(messageSet.nameHashes[0], 0x0123456789ABCDEFULL);
	QCOMPARE(messageSet.nameHashes[1], 0xAAAAAAAAAAAAAAAAULL);
	QCOMPARE(messageSet.nameHashes[2], 0xBBBBBBBBBBBBBBBBULL);
	QCOMPARE(messageSet.messages.size(), 0);
	QCOMPARE(messageSet.definedCount, 3);
	QCOMPARE(messageSet.idCount, 1);
	QCOMPARE(messageSet.version, 2);
}

void ScriptParserTests::readScript()
{
	QVector<MessageSet> script = ScriptParser::loadFromFile("testdata/script_sample.txt");

	QCOMPARE(script.size(), 4);
	QCOMPARE(script[0].definedCount, 3);
	QCOMPARE(script[0].messages.size(), 3);
	QCOMPARE(script[0].idCount, 3);
	QCOMPARE(script[0].version, 3);
	QCOMPARE(script[0].nameHashes.size(), 1);
	QCOMPARE(script[0].nameHashes[0], 0x0CEBFA1FFB30CA80ULL);
	QCOMPARE(script[0].messages[0].id, QString("Activate_Mii Bobble Head"));
	QCOMPARE(script[0].messages[1].id, QString("Activate_On"));
	QCOMPARE(script[0].messages[2].id, QString("Activate_Off"));

	QCOMPARE(script[1].definedCount, 1);
	QCOMPARE(script[1].messages.size(), 1);
	QCOMPARE(script[1].idCount, 0);
	QCOMPARE(script[1].version, 1);
	QCOMPARE(script[1].nameHashes.size(), 1);
	QCOMPARE(script[1].nameHashes[0], 0x460D232B4E5A60FEULL);

	QCOMPARE(script[2].definedCount, 1);
	QCOMPARE(script[2].messages.size(), 1);
	QCOMPARE(script[2].idCount, 1);
	QCOMPARE(script[2].version, 3);
	QCOMPARE(script[2].nameHashes.size(), 1);
	QCOMPARE(script[2].nameHashes[0], 0xDA1BFA4E4C3872C0ULL);

	QCOMPARE(script[3].definedCount, 3);
	QCOMPARE(script[3].messages.size(), 3);
	QCOMPARE(script[3].idCount, 0);
	QCOMPARE(script[3].version, 3);
	QCOMPARE(script[3].nameHashes.size(), 2);
	QCOMPARE(script[3].nameHashes[0], 0x026EFCDA326E764AULL);
	QCOMPARE(script[3].nameHashes[1], 0xBD2119C8D1F5B7E1ULL);
}
