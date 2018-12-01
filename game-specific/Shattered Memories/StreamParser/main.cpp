#include "TextureDictionaryParserWii.h"
#include "TextureDictionaryParserPS2.h"
#include "TextureDictionaryParserPSP.h"
#include <DataStreamParser.h>
#include <FileStream.h>
#include <QtFileStream.h>
#include <iomanip>
#include <QDir>
#include <QTextStream>
#include <QCoreApplication>

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

static std::unique_ptr<TextureDictionaryParser> makeTextureParserForPlatform(Platform platform)
{
	switch (platform)
	{
	case Wii:
		return std::unique_ptr<TextureDictionaryParser>(new TextureDictionaryParserWii());
	case PS2:
		return std::unique_ptr<TextureDictionaryParser>(new TextureDictionaryParserPS2());
	case PSP:
		return std::unique_ptr<TextureDictionaryParser>(new TextureDictionaryParserPSP());
	}

	return std::unique_ptr<TextureDictionaryParser>();
}

bool parseDictionary(Stream& stream, const QString& name, QTextStream& csv, Platform platform = Wii)
{
	ASSERT(stream.isOpen());
	std::unique_ptr<TextureDictionaryParser> dictParser = makeTextureParserForPlatform(platform);
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

	ASSERT(stream.isOpen());
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
				std::cerr << "WARNING: Segment end is not reached! " << std::hex << stream.position() << " != " << parser.nextSegmentPosition() << std::endl;
			}
		}
	}

	if (atLeastOneParsed && !parser.atEnd())
	{
		std::cerr << "WARNING: End is not reached! " << std::hex << stream.position() << " != " << stream.size() << std::endl;
	}

	return atLeastOneParsed;
}

static void printUsage(std::ostream& stream)
{
	stream <<
		"Shattered Memories & Origins Stream Parser by consolgames.ru\n"
		"Usage: \n"
		"  parse <wii|ps2|psp> <FilesDir> [OutputCSV]\n"
		"     Parse files for textures and write result into output CSV file or stdout\n"
		;
}

int main(int argc, char* argv[])
{
	QCoreApplication app(argc, argv);

	const QStringList args = QCoreApplication::arguments();
	const QString act = args.size() >= 2 ? args[1] : QString();

	if (act == "--help" || act == "help")
	{
		printUsage(std::cout);
	}
	else if (act == "parse" && args.size() >= 4 && args.size() <= 5)
	{
		const QString& platformStr = args[2];
		const QString& inDir = args[3];
		const QString outFile = args.size() >= 5 ? args[4] : "-";

		Platform platform;
		
		if (platformStr == "wii")
		{
			platform = Wii;
		}
		else if (platformStr == "ps2")
		{
			platform = PS2;
		}
		else if (platformStr == "psp")
		{
			platform = PSP;
		}
		else
		{
			std::cerr << "Invalid platform id, please use \"wii\", \"ps2\" or \"psp\"." << std::endl;
			return -1;
		}

		const QDir dir(inDir);
		if (!dir.exists())
		{
			std::cerr << "Input directory not exists!";
			return -1;
		}

		std::unique_ptr<QFile> csvFile;
		std::unique_ptr<QTextStream> csvStream;
		const bool usingSTDOUT = outFile == "-";
		if (usingSTDOUT)
		{
			csvStream.reset(new QTextStream(stdout, QIODevice::WriteOnly | QIODevice::Text));
		}
		else
		{
			csvFile.reset(new QFile(outFile));
			if (!csvFile->open(QIODevice::WriteOnly | QIODevice::Text))
			{
				std::cerr << "Unable to open CSV file!";
				return -1;
			}
			csvStream.reset(new QTextStream(csvFile.get()));
		}

		const bool useHashes = false;

		*csvStream << QString(useHashes ? "fileHash" : "fileName") + ";textureName;format;width;height;mipmapCount;rasterPosition;rasterSize;paletteFormat;palettePosition;paletteSize\n";

		const QStringList files = dir.entryList(QDir::Files);
		foreach (const QString& file, files)
		{
			if (!usingSTDOUT)
			{
				std::cout << "Trying to parse file: " << file.toLatin1().constData() << std::endl;
			}

			QtFileStream stream(dir.absoluteFilePath(file), QIODevice::ReadOnly);
			ASSERT(stream.isOpen());

	// 		if (stream.readUInt32() == 0xE0FFD8FF)
	// 		{
	// 			stream.file().close();
	// 			dir.rename(file, file.left(file.length() - 4) + ".jpg");
	// 			DLOG << "Renamed " << file;
	// 			continue;
	// 		}

			stream.seek(0, Stream::seekSet);

			bool parsed = parseDictionary(stream, file, *csvStream, platform);
			if (!parsed)
			{
				stream.seek(0, Stream::seekSet);
				parsed = parseStream(stream, file, *csvStream, platform);
			}
			if (!parsed)
			{
				std::cerr << "*** FILE NOT PARSED: " << file.toLatin1().constData();
			}
		}
	}
	else
	{
		printUsage(std::cerr);
		return -1;
	}

    return 0;
}
