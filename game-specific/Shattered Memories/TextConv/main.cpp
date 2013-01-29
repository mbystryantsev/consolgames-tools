#include <Strings.h>
#include <QCoreApplication>
#include <iostream>

using namespace ShatteredMemories;
using namespace std;

void printUsage()
{
	cout << 
		"Shattered Memories Text Converter by consolgames.ru\n"
		"Usage: \n"
		"  -e <Strings.XXX> <Strings.txt>\n"
		"     Extract text from Strings.XXX file\n"
		"  -es <Strings.XXX> <BaseStrings.txt> <Strings.txt>\n"
		"     Extract text from Strings.XXX file with some order and messages that in BaseStrings.txt\n"
		"  -b <Strings.txt> <Strings.XXX>\n"
		"     Build Strings.XXX file from source text file\n";
}

int main(int argc, char **argv)
{
	QCoreApplication application(argc, argv);

	const QStringList args = QCoreApplication::arguments();
	const QString& act = args[1];

	if (act == "-e" && args.size() == 4)
	{
		const QString& inputFile = args[2];
		const QString& outFile = args[3];
		MessageSet messages = Strings::importMessages(inputFile);
		if (messages.isEmpty())
		{
			cout << "Invalid strings file!" << endl;
			return -1;
		}

		if (!Strings::collapseDuplicates(messages))
		{
			cout << "Unable to process strings!";
			return -1;
		}

		if (!Strings::saveMessages(messages, outFile))
		{
			cout << "Unable to save target file!" << endl;
			return -1;
		}

		cout << "Text extracted successfully!" << endl;
	}
	else if (act == "-es" && args.size() == 5)
	{
		cout << "Not implemented yet." << endl;
		return -1;
	}
	else if (act == "-b" && args.size() == 4)
	{
		const QString& inputFile = args[2];
		const QString& outFile = args[3];
		MessageSet messages = Strings::loadMessages(inputFile);
		if (messages.isEmpty())
		{
			cout << "Unable to load messages!" << endl;
			return -1;
		}

		if (!Strings::expandReferences(messages))
		{
			cout << "Unable to expand references!" << endl;
			return -1;
		}

		if (!Strings::exportMessages(messages, outFile))
		{
			cout << "Unable to bild strings file!" << endl;
			return -1;
		}

		cout << "Strings builded sucessfully!" << endl;
	}
	else
	{
		if (args.size() > 1 && args.first() != "--help")
		{
			cout << "Invalid arguments passed! Run without parameters to view usage.";
			return -1;
		}
		printUsage();
	}

	return 0;
}
