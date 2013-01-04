#include "ScriptTester.h"
#include <QStringList>
#include <QCoreApplication>
#include <QFile>
#include <QMap>
#include <QByteArray>
#include <QPair>
#include <iostream>

void printUsage()
{
	std::cout << "ScriptTester for Metroid Prime 3: Corruption by consolgames.ru.\n";
	std::cout << "Usage: \n";
	std::cout << "  -ct, --check-tags <input>:\n";
	std::cout << "    Check tags in input file or directory.\n";
	std::cout << "  -cl, --calc-tags <filename> <outfile>:\n";
	std::cout << "    Calculate tag count in a file and store it in an out file.\n";
	std::cout << "  -cn, --check-count <input> <original>:\n";
	std::cout << "    Check message count.\n";
	std::cout << "  -tt, --test-tags <filename> <testdata> [--ignore-tags <ignorefile>] [--identifiers <idsfile>]:\n";
	std::cout << "    Check tags with use of a precalculated tags count.\n";
	std::cout << "  -i, --detect-identifiers <filename> <externalfile> <outfile>:\n";
	std::cout << "    Create list of identifiers.\n";
	std::cout << "  -e, --exec <filename>:\n";
	std::cout << "    Execute batch csv (script;testdata;ignoredata;identifiers).\n";
	std::cout << "  -gm, --generate-mergemap <inputdir> <filename>:\n";
	std::cout << "    Generate merge map.\n";
}

void parseArgument(const QByteArray& name, const QString& argName, const QStringList& args, QMap<QByteArray, QString>& out)
{
	int index = args.indexOf(argName);
	if (index != -1 && index + 1 < args.size())
	{
		out[name] = args[index + 1];
	}
}

QMap<QByteArray, QString> parseArgs()
{
	const QStringList args = args;
	QMap<QByteArray, QString> result;

	result["scriptFile"] = args[2];
	result["testDataFile"] = args[3];
	parseArgument("tagsIgnoreFile", "--ignore-tags", args, result);
	parseArgument("idsFile", "--identifiers", args, result);
	return result;
}

int checkForError(ScriptTester::ErrorType result)
{
	if (result != ScriptTester::NoError)
	{
		std::cout << "Error: " << ScriptTester::errorString(result) << ": " << ScriptTester::lastErrorData().toStdString() << std::endl;
	}
	return result;
}

#define TESTER_VERIFY(expr) \
	{ \
		ScriptTester::ErrorType result = expr; \
		int ret = checkForError(result); \
		if (ret != 0) return ret; \
	}

int main(int argc, char** argv)
{
	QCoreApplication app(argc, argv);
	const QStringList args = QCoreApplication::arguments();

	if (args.size() == 3 && (args[1] == "-ct" || args[1] == "--check-tags"))
	{
		const QString inputPath = app.arguments()[2];

		ScriptTester tester;
		TESTER_VERIFY(tester.loadScriptFromDirOrFile(inputPath));
		TESTER_VERIFY(tester.checkTags());

		std::cout << "Tags check successfully completed!" << std::endl;
	}	
	if (args.size() == 4 && (args[1] == "-cn" || args[1] == "--check-count"))
	{
		const QString inputPath = app.arguments()[2];
		const QString inputOriginalPath = app.arguments()[3];

		ScriptTester tester;
		TESTER_VERIFY(tester.loadScriptFromDirOrFile(inputPath));
		TESTER_VERIFY(tester.checkMessageCount(inputOriginalPath));

		std::cout << "Message count check successfully completed!" << std::endl;
	}
	else if (args.size() == 4 && (args[1] == "-cl" || args[1] == "--calc-tags"))
	{
		const QString scriptFile = app.arguments()[2];
		const QString outFile = app.arguments()[3];

		ScriptTester tester;
		tester.loadScript(scriptFile);
		TESTER_VERIFY(tester.calculateTags(outFile));
	}
	else if (args.size() == 4 && (args[1] == "-ct" || args[1] == "--check-count"))
	{
		const QString scriptFile = app.arguments()[2];
		const QString outFile = app.arguments()[3];

		ScriptTester tester;
		tester.loadScript(scriptFile);
		TESTER_VERIFY(tester.calculateTags(outFile));
	}
	else if (args.size() >= 4 && (args[1] == "-tt" || args[1] == "--test-tags"))
	{
		QMap<QByteArray, QString> args = parseArgs();

		ScriptTester tester;
		TESTER_VERIFY(tester.loadScript(args["scriptFile"]));
		TESTER_VERIFY(tester.loadTestData(args["testDataFile"]));
		if (args.contains("tagsIgnoreFile"))
		{
			TESTER_VERIFY(tester.loadIgnoreData(args["tagsIgnoreFile"]));
		}
		if (args.contains("idsFile"))
		{
			TESTER_VERIFY(tester.loadIdentifiers(args["idsFile"]));
		}
		TESTER_VERIFY(tester.runTests());
	}
	else if (args.size() == 5 && (args[1] == "-i" || args[1] == "--detect-identifiers"))
	{
		const QString scriptFile = app.arguments()[2];
		const QString externalScriptFile = app.arguments()[3];
		const QString outFile = app.arguments()[4];

		ScriptTester tester;
		TESTER_VERIFY(tester.loadScript(scriptFile));
		TESTER_VERIFY(tester.detectIdentifiers(externalScriptFile, outFile));
	}
	else if (args.size() == 3 && (args[1] == "-e" || args[1] == "--exec"))
	{
		const QString batchFile = app.arguments()[2];
		TESTER_VERIFY(ScriptTester::exec(batchFile));
	}
	else if (args.size() == 4 && (args[1] == "-gm" || args[1] == "--generate-mergemap"))
	{
		const QString inputDir = app.arguments()[2];
		const QString filename = app.arguments()[3];
		std::cout << "Generating merge map..." << std::endl;
		QMap<quint64,quint64> mergeMap = ScriptTester::generateMergeMap(inputDir);
		QFile file(filename);
		if (!file.open(QIODevice::WriteOnly))
		{
			std::cout << "Unable to open file!" <<  std::endl;
			return -1;
		}

		QDataStream stream(&file);
		stream.setByteOrder(QDataStream::BigEndian);

		foreach (const quint64 baseHash, mergeMap.keys())
		{
			const quint64 resultHash = mergeMap[baseHash];
			stream << baseHash << resultHash;
		}
		std::cout << "Done!" << std::endl;
	}
	else if (args.size() == 4 && (args[1] == "-cc" || args[1] == "--check-chars"))
	{
		const QString inputDir = app.arguments()[2];
		const QString fontFile = app.arguments()[3];

		ScriptTester tester;
		TESTER_VERIFY(tester.loadScriptFromDir(inputDir));
		TESTER_VERIFY(tester.loadFont(fontFile));
		TESTER_VERIFY(tester.checkCharacters());

		std::cout << "Character check successfully completed!" << std::endl;
	}
	else if (args.size() == 1 ||  (args.size() == 2 && (args[1] == "--help" || args[1] == "-h")))
	{
		printUsage();
	}
	else if (args.size() > 1)
	{
		std::cout << "Invalid arguments passed! Run program with no command line or with `--help` argument to view usage." << std::endl;
		return -1;
	}
	return 0;
}