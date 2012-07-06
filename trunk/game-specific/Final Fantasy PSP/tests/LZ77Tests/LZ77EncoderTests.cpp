#include "LZ77EncoderTests.h"
#include <QTest>
#include <QFile>

void LZ77EncoderTests::initTestCase()
{

}

void LZ77EncoderTests::prefixTest()
{
	const char c_prefix[] = {0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0, 0, 1, 2, 3, 0, 0, 0, 0, 0, 0};
	QByteArray prefix(c_prefix, _countof(c_prefix));

	wchar_t c_str[] = L"PARTICIPATE IN PARACHUTE";
	char c_actualPrefix[_countof(c_prefix)];
	calcPrefix(SimpleStream(c_str, _countof(c_str) - 1), c_actualPrefix);
	QByteArray actualPrefix(c_actualPrefix, _countof(c_actualPrefix));

	QCOMPARE(actualPrefix, prefix);
}

void LZ77EncoderTests::findPatternTest()
{
	QString str("abc abcd abcdef abcde abc a");
	QString pattern("abcdefghijklmnopq");

	std::pair<int, int> result = findBestMatch(SimpleStream(pattern.data(), pattern.size()), SimpleStream(str.data(), str.size()));

	QCOMPARE(result.first, 9);
	QCOMPARE(result.second, 6);
}

void LZ77EncoderTests::findPatternLastSymbolTest()
{
	QString str("abcd");
	QString pattern("abce");

	std::pair<int, int> result = findBestMatch(SimpleStream(pattern.data(), pattern.size()), SimpleStream(str.data(), str.size()));

	QCOMPARE(result.first, 0);
	QCOMPARE(result.second, 3);
}

void LZ77EncoderTests::findPatternCyclicTest1()
{
	QString str("abc abcd abcdabcd abcde abc a");
	const char patternStr[s_maxLength + 1] = "abcdabcd";
	QString pattern(patternStr);

	std::pair<int, int> result = findBestMatch(SimpleStream(pattern.data(), pattern.size()), SimpleStream(str.data(), str.size()));

	QCOMPARE(result.first, 9);
	QCOMPARE(result.second, 8);
}

void LZ77EncoderTests::findPatternCyclicTest2()
{
	QString str("abcabcadc");
	QString pattern("abcadc");

	std::pair<int, int> result = findBestMatch(SimpleStream(pattern.data(), pattern.size()), SimpleStream(str.data(), str.size()));

	QCOMPARE(result.first, 3);
	QCOMPARE(result.second, 6);
}

void LZ77EncoderTests::findPatternCyclicWithAdditionalTest()
{
	QString str("aaaaaaa");
	QString pattern("aaaaaaa");

	std::pair<int, int> result = findBestMatch(SimpleStream(pattern.data(), pattern.size()), SimpleStream(str.data(), 1), 6);

	QCOMPARE(result.first, 0);
	QCOMPARE(result.second, 7);
}

void LZ77EncoderTests::compressionDifferentTest()
{
	QString str("abcdefgh");
	QByteArray result(20, Qt::Uninitialized);

	encodeChunk(SimpleStream(str.data(), str.size()), SimpleStream(result.data(), result.size() / 2));

	wchar_t c_expected[] = {0x00FF, 0x0000, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
	QByteArray expected = QByteArray::fromRawData(reinterpret_cast<const char*>(c_expected), sizeof(c_expected));

	QCOMPARE(result, expected);

}

void LZ77EncoderTests::compressionPeriodicTest1()
{
	QString str("aaaaaaa");
	wchar_t c_expected[] = {0x0001, 0x0000, 'a', PackedReference(1, 6).value};
	QByteArray expected = QByteArray::fromRawData(reinterpret_cast<const char*>(c_expected), sizeof(c_expected));
	QByteArray result(expected.size(), Qt::Uninitialized);

	encodeChunk(SimpleStream(str.data(), str.size()), SimpleStream(result.data(), result.size() / 2));
	
	QCOMPARE(result, expected);
}

void LZ77EncoderTests::compressionPeriodicTest2()
{
	QString str("abababa");
	wchar_t c_expected[] = {0x0003, 0x0000, 'a', 'b', PackedReference(2, 5).value};
	QByteArray expected = QByteArray::fromRawData(reinterpret_cast<const char*>(c_expected), sizeof(c_expected));
	QByteArray result(expected.size(), Qt::Uninitialized);

	encodeChunk(SimpleStream(str.data(), str.size()), SimpleStream(result.data(), result.size() / 2));

	QCOMPARE(result, expected);
}

void LZ77EncoderTests::compressionPeriodicTest3()
{
	QString str("abcabcabc");
	wchar_t c_expected[] = {0x0007, 0x0000, 'a', 'b', 'c', PackedReference(3, 6).value};
	QByteArray expected = QByteArray::fromRawData(reinterpret_cast<const char*>(c_expected), sizeof(c_expected));
	QByteArray result(expected.size(), Qt::Uninitialized);

	encodeChunk(SimpleStream(str.data(), str.size()), SimpleStream(result.data(), result.size() / 2));

	QCOMPARE(result, expected);
}

void LZ77EncoderTests::compressionZeroPaddingTest()
{

}

void LZ77EncoderTests::compressionZeroPaddingTestWithChunk()
{

}

//////////////////////////////////////////////////////////////////////////

class Decoder : public LZ77Decoder
{
public:
	CodingResult decodeChunk(void *data, int size, void* outData, int outSize)
	{
		return LZ77Decoder::decodeChunk(data, size, outData, outSize);
	}
};

void LZ77EncoderTests::compressionDecompressionTest(const QString& str)
{
	Decoder decoder;

	QString actual(1024, Qt::Uninitialized);
	QByteArray result(1024, Qt::Uninitialized);

	CodingResult encodingResult = encodeChunk(SimpleStream(str.data(), str.size()), SimpleStream(result.data(), result.size() / 2));
	CodingResult decodingResult = decoder.decodeChunk(result.data(), encodingResult.resultSize, actual.data(), actual.size() * 2);

	QCOMPARE(decodingResult.resultSize, str.size() * 2);

	if (decodingResult.resultSize == str.size() * 2)
	{
		actual.resize(decodingResult.resultWordCount());
		QCOMPARE(actual, str);
	}
}

void LZ77EncoderTests::compressionDecompressionFileTest(const QByteArray& data)
{
	Decoder decoder;
	QByteArray actual(16384, Qt::Uninitialized);
	QByteArray result(16384, Qt::Uninitialized);

	CodingResult encodingResult = encodeChunk(SimpleStream(data.data(), data.size() / 2), SimpleStream(result.data(), result.size() / 2));
	CodingResult decodingResult = decoder.decodeChunk(result.data(), encodingResult.resultSize, actual.data(), actual.size());

// 	{
// 		QFile file("test.data");
// 		file.open(QIODevice::WriteOnly);
// 		file.write(actual.data(), actual.size());
// 	}

	QCOMPARE(decodingResult.resultSize, data.size());

	if (decodingResult.resultSize == data.size())
	{
		actual.resize(decodingResult.resultSize);
		QVERIFY(actual == data);
	}
}

void LZ77EncoderTests::compressionDecompressionTest1()
{
	compressionDecompressionTest("Per aspera ad astra");
}

void LZ77EncoderTests::compressionDecompressionTest2()
{
	compressionDecompressionTest("The compression and the decompression leave an impression!");
}

void LZ77EncoderTests::compressionDecompressionTest3()
{
	compressionDecompressionTest
	(
		"I am Jayne, Queen of Cornelia. Please...\n"
		"please bring my daughter...my Sarah...\n"
		"back to me safely.\n"
		"\n"
		"Jayne: I don't know how I could ever\n"
		"thank you for rescuing Sarah.\n"
		"\n"
		"My s-s-sister... I w-want my s-sister!\n"
		"\n"
		"My sister's back! And it's all thanks to\n"
		"you guys, isn't it! I could just kiss you!\n"
		"-\n"
		"Mwah!\n"
	);
}

void LZ77EncoderTests::compressionDecompressionFileTest()
{
	QFile file("data/FM_SHOPUS.DATA");
	QVERIFY(file.open(QIODevice::ReadOnly));
	compressionDecompressionFileTest(file.readAll());
}