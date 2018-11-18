#include <FontStreamRebuilder.h>
#include <QtFileStream.h>
#include <qcoreapplication.h>
#include <QStringList>
#include <iostream>

using namespace ShatteredMemories;

static void printUsage()
{
	std::cout << 
		"Shattered Memories Text Converter by consolgames.ru\n"
		"Usage: \n"
		"  replace <shsm|sh0> <wii|ps2|psp> <FontFile> <FontEUR IN> <FontEUR OUT>\n"
		"     Replace font file in resource stream (\"FontEUR\" file)\n"
		;
}

int main(int argc, char** argv)
{
	QCoreApplication app(argc, argv);

	const QStringList args = QCoreApplication::arguments();
	const QString act = args.size() >= 2 ? args[1] : QString();

	if (act == "replace" && args.size() == 7)
	{
		const QString& gameStr = args[2];
		const QString& platformStr = args[3];
		const QString& fontFile = args[4];
		const QString& inFile = args[5];
		const QString& outFile = args[6];

		FontStreamRebuilder::Version version;

		if (gameStr == "shsm")
		{
			version = FontStreamRebuilder::versionShatteredMemories;
		}
		else if (gameStr == "sh0")
		{
			version = FontStreamRebuilder::versionOrigins;
		}
		else
		{
			std::cerr << "Invalid game id, please use \"shsm\" for Shattered Memories or \"sh0\" for Origins." << std::endl;
			return -1;
		}

		Consolgames::Stream::ByteOrder byteOrder;

		if (platformStr == "wii")
		{
			byteOrder = Consolgames::Stream::orderBigEndian;
		}
		else if (platformStr == "ps2" || platformStr == "psp")
		{
			byteOrder = Consolgames::Stream::orderLittleEndian;
		}
		else
		{
			std::cerr << "Invalid platform id, please use \"wii\", \"ps2\" or \"psp\"." << std::endl;
			return -1;
		}
			   
		std::tr1::shared_ptr<QtFileStream> fontStream(new QtFileStream(fontFile, QIODevice::ReadOnly));
		
		if (!fontStream->opened())
		{
			std::cerr << "Unable to open font file!" << std::endl;
			return -1;
		}

		std::tr1::shared_ptr<QtFileStream> inStream(new QtFileStream(inFile, QIODevice::ReadOnly));

		if (!inStream->opened())
		{
			std::cerr << "Unable to open input FontEUR stream!";
			return -1;
		}

		QtFileStream outStream(outFile, QIODevice::WriteOnly);

		if (!outStream.opened())
		{
			std::cerr << "Unable to open output FontEUR file!" << std::endl;
			return -1;
		}

		FontStreamRebuilder rebuilderStream(inStream, fontStream, byteOrder, version);

		largesize_t written = 0;
		char buf[4096];

		while (true)
		{
			const auto size = rebuilderStream.read(buf, sizeof(buf));
			if (size == 0)
			{
				break;
			}

			written += size;
			outStream.write(buf, size);
		}

		if (written == 0)
		{
			std::cerr << "Invalid FontEUR stream or input parameters!" << std::endl;
			return -1;
		}

		std::cout << "Font replaced successfully!" << std::endl;
	}
	else
	{
		if (args.size() > 1 && args.first() != "help" && args.first() != "--help")
		{
			std::cerr << "Invalid arguments passed! Run without parameters to view usage." << std::endl;
			return -1;
		}
		printUsage();
	}

	return 0;
}
