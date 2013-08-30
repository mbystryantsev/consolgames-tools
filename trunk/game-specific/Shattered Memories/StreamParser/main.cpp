#include <DataStreamParser.h>
#include "TextureDictionaryParserWii.h"
#include "TextureDictionaryParserPS2.h"
#include <FileStream.h>
#include <QtFileStream.h>
#include <iomanip>
#include <QDir>
#include <QTextStream>

using namespace Consolgames;
using namespace ShatteredMemories;

/*
    10000000 - DXT3
    10100010 - 8BPP, 256 colors
    11000001 - 4BPP, 16 colors
*/

enum Platform
{
	Wii,
	PS2,
	PSP
};

static QString hashToStr(quint32 hash)
{
	return QString::number(hash, 16).toUpper().rightJustified(8, '0');
}

static std::auto_ptr<TextureDictionaryParser> makeTextureParserForPlatform(Platform platform)
{
	switch (platform)
	{
	case Wii:
		return std::auto_ptr<TextureDictionaryParser>(new TextureDictionaryParserWii());
	case PS2:
		return std::auto_ptr<TextureDictionaryParser>(new TextureDictionaryParserPS2());
	//case PSP:
		//return std::auto_ptr<TextureDictionaryParser>(new TextureDictionaryParserPSP());
	}

	return std::auto_ptr<TextureDictionaryParser>();
}

bool parseDictionary(Stream& stream, const QString& name, QTextStream& csv, Platform platform = Wii)
{
	ASSERT(stream.opened());
	std::auto_ptr<TextureDictionaryParser> dictParser = makeTextureParserForPlatform(platform);
	ASSERT(dictParser.get() != NULL);

	dictParser->open(&stream);

	bool atLeastOneParsed = false;
	if (dictParser->initSegment())
	{
		atLeastOneParsed = true;
		while (dictParser->fetch())
		{
			const TextureDictionaryParser::TextureMetaInfo& info = dictParser->metaInfo();
			//std::cout << info.name << ';' << std::dec << info.width << ';' << info.height << ';' << info.mipmapCount << ';' << std::hex << info.rasterPosition << ';' << info.rasterSize << std::endl;
			
			if (info.width == 1 && info.height == 1)
			{
				continue;
			}
			
			csv << name << ';' << QString::fromStdString(info.name) << ';' << dictParser->textureFormatToString(info.textureFormat) << ';' << info.width << ';' << info.height << ';' 
				<< info.mipmapCount << ';' << QString::number(info.rasterPosition, 16) << ';' << QString::number(info.rasterSize, 16) << ';'
				<< dictParser->paletteFormatToString(info.paletteFormat) << ';' << QString::number(info.palettePosition, 16) << ';' << QString::number(info.paletteSize, 16) << '\n';
		}
	}

	return atLeastOneParsed;
}

bool parseStream(Stream& stream, const QString& name, QTextStream& csv, Platform platform = Wii)
{
	DataStreamParser parser(platform == Wii ? Stream::orderBigEndian : Stream::orderLittleEndian);

	ASSERT(stream.opened());
	parser.open(&stream);

	bool atLeastOneParsed = false;
	while (parser.initSegment())
	{
		if (parser.metaInfo().typeId == "rwID_TEXDICTIONARY")
		{
			while (parser.fetch())
			{
				atLeastOneParsed = true;
				parseDictionary(stream, name, csv, platform);
			}

			if (atLeastOneParsed && !parser.atSegmentEnd())
			{
				std::cout << "WARNING: Segment end is not reached! " << std::hex << stream.position() << " != " << parser.nextSegmentPosition() << std::endl;
			}
		}
	}

	if (atLeastOneParsed && !parser.atEnd())
	{
		std::cout << "WARNING: End is not reached! " << std::hex << stream.position() << " != " << stream.size() << std::endl;
	}

	return atLeastOneParsed;
}

int main(int argc, char* argv[])
{
	QFile csv("test.csv");
	VERIFY(csv.open(QIODevice::WriteOnly | QIODevice::Text));
	QTextStream csvStream(&csv);

	const bool useHashes = false;

	csvStream << QString(useHashes ? "fileHash" : "fileName") + ";textureName;format;width;height;mipmapCount;rasterPosition;rasterSize;paletteFormat;palettePosition;paletteSize\n";

	QDir dir("D:/rev/origins/data");
	//QDir dir("E:/_job/SHSM/ps2/test");
	const QStringList files = dir.entryList(QDir::Files);
	foreach (const QString& file, files)
	{
#if 0
		if (file == "B1A96880.BIN")
		{
			continue;
		}
#endif

		/*
		if (file.right(4).toLower() != ".bin" && file.size() != 8)
		{
			continue;
		}

		bool ok = false;
		const quint32 hash = file.left(8).toUInt(&ok, 16);
		if (!ok)
		{
			continue;
		}

		*/

		std::cout << "Trying to parse file: " << file.toLatin1().constData() << std::endl;

		QtFileStream stream(dir.absoluteFilePath(file), QIODevice::ReadOnly);
		//QtFileStream stream(dir.absoluteFilePath("01CCE413.BIN"), QIODevice::ReadOnly);
		ASSERT(stream.opened());

// 		if (stream.readUInt32() == 0xE0FFD8FF)
// 		{
// 			stream.file().close();
// 			dir.rename(file, file.left(file.length() - 4) + ".jpg");
// 			DLOG << "Renamed " << file;
// 			continue;
// 		}
		stream.seek(0, Stream::seekSet);

		const Platform platform = PS2;

		bool parsed = parseDictionary(stream, file, csvStream, platform);
		if (!parsed)
		{
			stream.seek(0, Stream::seekSet);
			parsed = parseStream(stream, file, csvStream, platform);
		}
		if (!parsed)
		{
			DLOG << "FILE NOT PARSED: " << file;
		}

		//break;
	}
    return 0;
}
