#include "LZ77DecoderTests.h"
#include <QTest>
#include <QFile>
#include <QTextStream>
#include <QCryptographicHash>

void LZ77DecoderTests::initTestCase()
{
	{
		QFile file("data/FM_SHOPUS.PCK");
		QVERIFY(file.open(QIODevice::ReadOnly));
		m_compressedData = file.readAll();
	}
	{
		QFile file("data/FM_SHOPUS.DATA");
		QVERIFY(file.open(QIODevice::ReadOnly));
		m_decompressedSample = file.readAll();
	}
	QVERIFY(sizeof(PackedReference) == 2);
}

void LZ77DecoderTests::decompressionTest()
{
	LZ77Decoder decoder;
	const uint32 size = *reinterpret_cast<uint32*>(&m_compressedData.data()[4]);
	QByteArray output(size, Qt::Uninitialized);

	decoder.decodeChunk(&m_compressedData.data()[8], m_compressedData.size() - 8, output.data(), output.size());

	QVERIFY(output == m_decompressedSample);
}

void LZ77DecoderTests::decompressionStateTest()
{
}

void LZ77DecoderTests::decompressionStateHardTest()
{
}

void LZ77DecoderTests::decompressionAllTest()
{
	DataPackage pak;
	if (!pak.open("data/ff1psp.dpk", DataPackage::ReadOnly))
	{
		QSKIP("ff1psp.dpk file is not presented, skipping.", SkipAll);
	}

	QMap<QByteArray, QPair<int, QByteArray>> hashBase;
	{
		QFile hashFile("data/hashbase.txt");
		QVERIFY(hashFile.open(QIODevice::ReadOnly));
		QTextStream stream(&hashFile);
	
		while (!stream.atEnd())
		{
			QString line = stream.readLine();
			QStringList items = line.split(' ');
			QVERIFY(items.size() == 3);

			const QByteArray name = items[0].toLatin1();
			QVERIFY(!name.isNull());

			bool ok = false;
			const int size = items[1].toInt(&ok);
			QVERIFY(ok);

			const QByteArray hash = QByteArray::fromHex(items[2].toLatin1());
			QVERIFY(!hash.isNull());
			QVERIFY(hash.size() == 16);

			hashBase[name] = QPair<int, QByteArray>(size, hash);
		}
	}

	static char bufferUncompressed[1024 * 1024 * 16];
	static char bufferCompressed[1024 * 1024 * 16];

	for (int i = 0; i < pak.fileCount(); i++)
	{
		const FileRecord& file = pak.files()[i];
		if (file.isPacked())
		{
			pak.seekTo(file);
			pak.readRaw(&bufferCompressed[0], file.packedSize);
			
			LZ77Decoder decoder;
			CodingResult result = decoder.decodeChunk(&bufferCompressed[8], file.packedSize - 8, &bufferUncompressed[0], file.fileSize);
			QCOMPARE(result.resultSize, static_cast<int>(file.fileSize));

			if (result.resultSize == file.fileSize)
			{
				QCryptographicHash hash(QCryptographicHash::Md5);
				hash.addData(bufferUncompressed, result.resultSize);
				if (hash.result() != hashBase[QByteArray(file.name)].second)
				{
					{
						QFile file(QString("%1.test").arg(file.name));
						file.open(QIODevice::WriteOnly);
						file.write(bufferUncompressed, result.resultSize);
					}
					QFAIL(QString("File %1 is not match!").arg(file.name).toLatin1().data());
				}
			}
		}
	}

}