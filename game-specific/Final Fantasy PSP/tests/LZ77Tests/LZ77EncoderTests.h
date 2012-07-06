#pragma once
#include <LZ77.h>
#include <QObject>
#include <QByteArray>

class LZ77EncoderTests : public QObject, LZ77Encoder
{
	Q_OBJECT;

private:
	void compressionDecompressionTest(const QString& str);
	void compressionDecompressionFileTest(const QByteArray& str);

	Q_SLOT void initTestCase();

	Q_SLOT void prefixTest();
	Q_SLOT void findPatternTest();
	Q_SLOT void findPatternLastSymbolTest();
	Q_SLOT void findPatternCyclicTest1();
	Q_SLOT void findPatternCyclicTest2();
	Q_SLOT void findPatternCyclicWithAdditionalTest();

	Q_SLOT void compressionDifferentTest();
	Q_SLOT void compressionPeriodicTest1();
	Q_SLOT void compressionPeriodicTest2();
	Q_SLOT void compressionPeriodicTest3();
	Q_SLOT void compressionZeroPaddingTest();
	Q_SLOT void compressionZeroPaddingTestWithChunk();
	Q_SLOT void compressionDecompressionTest1();
	Q_SLOT void compressionDecompressionTest2();
	Q_SLOT void compressionDecompressionTest3();
	Q_SLOT void compressionDecompressionFileTest();
};
