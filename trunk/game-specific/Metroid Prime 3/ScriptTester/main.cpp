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
	std::cout << "  -ct, --calc-tags <filename> <outfile>:\n";
	std::cout << "    Calculate tag count in a file and store it in an out file.\n";
	std::cout << "  -t, --test <filename> <testdata> [--ignore-tags <ignorefile>] [--identifiers <idsfile>]:\n";
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
	const QStringList args = QCoreApplication::arguments();
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

	if (QCoreApplication::arguments().size() == 4 && (QCoreApplication::arguments()[1] == "-ct" || QCoreApplication::arguments()[1] == "--calc-tags"))
	{
		const QString scriptFile = app.arguments()[2];
		const QString outFile = app.arguments()[3];

		ScriptTester tester;
		tester.loadScript(scriptFile);
		TESTER_VERIFY(tester.calculateTags(outFile));
	}
	else if (QCoreApplication::arguments().size() >= 4 && (QCoreApplication::arguments()[1] == "-t" || QCoreApplication::arguments()[1] == "--test"))
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
	else if (QCoreApplication::arguments().size() == 5 && (QCoreApplication::arguments()[1] == "-i" || QCoreApplication::arguments()[1] == "--detect-identifiers"))
	{
		const QString scriptFile = app.arguments()[2];
		const QString externalScriptFile = app.arguments()[3];
		const QString outFile = app.arguments()[4];

		ScriptTester tester;
		TESTER_VERIFY(tester.loadScript(scriptFile));
		TESTER_VERIFY(tester.detectIdentifiers(externalScriptFile, outFile));
	}
	else if (QCoreApplication::arguments().size() == 3 && (QCoreApplication::arguments()[1] == "-e" || QCoreApplication::arguments()[1] == "--exec"))
	{
		const QString batchFile = app.arguments()[2];
		TESTER_VERIFY(ScriptTester::exec(batchFile));
	}
	else if (QCoreApplication::arguments().size() == 4 && (QCoreApplication::arguments()[1] == "-gm" || QCoreApplication::arguments()[1] == "--generate-mergemap"))
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
	else
	{
		printUsage();
	}
	return 0;
}