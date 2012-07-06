#pragma once
#include <LZ77.h>
#include <DataPackage.h>
#include <QObject>
#include <QByteArray>

class LZ77DecoderTests : public QObject, LZ77Decoder
{
	Q_OBJECT;

private:
	Q_SLOT void initTestCase();

	Q_SLOT void decompressionTest();
	Q_SLOT void decompressionStateTest();
	Q_SLOT void decompressionStateHardTest();
	Q_SLOT void decompressionAllTest();

private:
	QByteArray m_compressedData;
	QByteArray m_decompressedSample;

};
