#include <Strings.h>
#include <QCoreApplication>
#include <QFile>
#include <QTextStream>
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
		"     Extract text from Strings.XXX file with some order and messages as in BaseStrings.txt\n"
		"  -el <Strings.XXX> <List.txt>\n"
		"     Extract message name (hash) list from Strings.XXX\n"
		"  -b <Strings.txt> <Strings.XXX>\n"
		"     Build Strings.XXX file from source text file\n";
		"  -bs <Strings.txt> <BaseStrings.txt> <Strings.XXX>\n"
		"     Build Strings.XXX file from source text file with some order and messages as in BaseStrings.txt\n"
		"  -bl <Strings.txt> <List.txt> <Strings.XXX>\n"
		"     Build Strings.XXX file with order from List.txt\n";
}

QList<quint32> loadHashesFromList(const QString& filename)
{
	QList<quint32> result;

	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		cout << "Unable to open list file!" << endl;
		return result;
	}
	
	QTextStream stream(&file);
	while (!stream.atEnd())
	{
		const QString line = stream.readLine().trimmed();
		if (line.isEmpty())
		{
			continue;
		}

		const quint32 hash = Strings::strToHash(line);
		if (hash == 0)
		{
			cout << "Invalid hash: " << line.toStdString() << endl;
			return QList<quint32>();
		}

		result << hash;
	}

	return result;
}


MessageSet messagesByList(const MessageSet& messages, const QList<quint32>& list)
{
	foreach (quint32 hash, list)
	{
		if (!messages.messages.contains(hash))
		{
			cout << "Hash " << Strings::hashToStr(hash).toStdString() << " not found in input messages!" << endl;
			return MessageSet();
		}
	}

	const QSet<quint32> listHashes = list.toSet();

	MessageSet newMessages = messages;

	if (!Strings::expandReferences(newMessages))
	{
		cout << "Unable to expand references!" << endl;
		return MessageSet();
	}

	foreach (quint32 hash, messages.hashes)
	{
		if (!listHashes.contains(hash))
		{
			newMessages.messages.remove(hash);
		}
	}

	newMessages.hashes = list;
	return newMessages;
}

bool extractMessagesByList(const QString& filename, const QList<quint32>& list, const QString& destFilename)
{
	const MessageSet messages = Strings::importMessages(filename);
	if (messages.isEmpty())
	{
		cout << "Invalid strings file!" << endl;
		return false;
	}

	MessageSet newMessages = messagesByList(messages, list);
	if (newMessages.isEmpty())
	{
		cout << "Unable to extract messages!" << endl;
		return false;
	}

	Strings::collapseDuplicates(newMessages);
	if (!Strings::saveMessages(destFilename, newMessages))
	{
		cout << "Unable to save target file!" << endl;
		return false;
	}

	return true;
}

bool extractMessagesByListFile(const QString& filename, const QString& listFilename, const QString& destFilename)
{
	const QList<quint32> list = loadHashesFromList(listFilename);
	if (list.isEmpty())
	{
		cout << "Unable to load list!" << endl;
		return false;
	}

	return extractMessagesByList(filename, list, destFilename);
}

bool extractMessagesByBaseStrings(const QString& filename, const QString& baseFilename, const QString& destFilename)
{
	const MessageSet baseMessages = Strings::importMessages(baseFilename);
	if (baseMessages.isEmpty())
	{
		cout << "Unable to load base strings file!" << endl;
		return false;
	}

	return extractMessagesByList(filename, baseMessages.hashes, destFilename);
}

bool buildMessagesByList(const MessageSet& messages, const QList<quint32>& list, const QString& destFilename)
{
	MessageSet newMessages = messagesByList(messages, list);

	if (!Strings::exportMessages(newMessages, destFilename))
	{
		cout << "Unable to build strings file!" << endl;
		return false;
	}

	return true;
}

bool buildMessagesByBaseStrings(const QString& filename, const QString& baseFilename, const QString& destFilename)
{
	const MessageSet baseMessages = Strings::loadMessages(baseFilename);
	if (baseMessages.isEmpty())
	{
		cout << "Unable to load base strings file!" << endl;
		return false;
	}

	const MessageSet messages = Strings::loadMessages(filename);
	if (baseMessages.isEmpty())
	{
		cout << "Unable to load strings file!" << endl;
		return false;
	}

	return buildMessagesByList(messages, baseMessages.hashes, destFilename);
}

int main(int argc, char **argv)
{
	QCoreApplication application(argc, argv);

	const QStringList args = QCoreApplication::arguments();
	const QString act = args.size() >= 2 ? args[1] : QString();

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

		if (!Strings::saveMessages(outFile, messages))
		{
			cout << "Unable to save target file!" << endl;
			return -1;
		}

		cout << "Text extracted successfully!" << endl;
	}
	else if (act == "-es" && args.size() == 5)
	{
		const QString& inputFile = args[2];
		const QString& baseFile = args[3];
		const QString& outFile = args[4];

		if (!extractMessagesByBaseStrings(inputFile, baseFile, outFile))
		{
			return -1;
		}

		cout << "Strings extracted sucessfully!" << endl;
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
	else if (act == "-bs" && args.size() == 5)
	{
		const QString& inputFile = args[2];
		const QString& baseFile = args[3];
		const QString& outFile = args[4];

		if (!buildMessagesByBaseStrings(inputFile, baseFile, outFile))
		{
			cout << "Unable to build strings" << endl;
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
