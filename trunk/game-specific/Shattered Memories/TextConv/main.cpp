#include <Strings.h>
#include <QCoreApplication>
#include <QFile>
#include <QTextStream>
#include <iostream>

using namespace ShatteredMemories;
using namespace std;

static void printUsage()
{
	cout << 
		"Shattered Memories Text Converter by consolgames.ru\n"
		"Usage: \n"
		"  -e <Strings.XXX> <Strings.txt>\n"
		"     Extract text from Strings.XXX file\n"
		"  -es <Strings.XXX> <BaseStrings.txt> <Strings.txt>\n"
		"     Extract text from Strings.XXX file with some order and messages as in BaseStrings.txt\n"
		"  -el <Strings.XXX> <List.txt> <Strings.txt>\n"
		"     Extract message name (hash) list from Strings.XXX\n"
		"  -b <Strings.txt> <Strings.XXX>\n"
		"     Build Strings.XXX file from source text file\n";
		"  -bs <BaseStrings.txt> <Strings.XXX> <InputStrings1.txt> [... InputStringsN.txt]  \n"
		"     Build Strings.XXX file from source text files with some order and messages as in BaseStrings.txt\n"
		"     Input files will be merged according to loading order.\n"
		"  -bl <List.txt> <Strings.XXX> <InputStrings1.txt> [... InputStringsN.txt]\n"
		"     Build Strings.XXX file from source text files with order from List.txt\n"
		"     Input files will be merged according to loading order.\n"
		;
}

static QList<quint32> loadHashesFromList(const QString& filename)
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

static MessageSet messagesByList(const MessageSet::Messages& messages, const QList<quint32>& list)
{
	foreach (quint32 hash, list)
	{
		if (!messages.contains(hash))
		{
			cout << "Hash " << Strings::hashToStr(hash).toStdString() << " not found in input messages!" << endl;
			return MessageSet();
		}
	}

	const QSet<quint32> listHashes = list.toSet();

	MessageSet newMessages;
	newMessages.messages = messages;

	if (!Strings::expandReferences(newMessages.messages))
	{
		cout << "Unable to expand references!" << endl;
		return MessageSet();
	}

	foreach (quint32 hash, messages.keys())
	{
		if (!listHashes.contains(hash))
		{
			newMessages.messages.remove(hash);
		}
	}

	newMessages.hashes = list;
	return newMessages;
}

static bool extractMessagesByList(const QString& filename, const QList<quint32>& list, const QString& destFilename)
{
	const MessageSet messages = Strings::importMessages(filename);
	if (messages.isEmpty())
	{
		cout << "Invalid strings file!" << endl;
		return false;
	}

	MessageSet newMessages = messagesByList(messages.messages, list);
	if (newMessages.isEmpty())
	{
		cout << "Unable to extract messages!" << endl;
		return false;
	}

	Strings::collapseDuplicates(newMessages.messages);
	if (!Strings::saveMessages(destFilename, newMessages))
	{
		cout << "Unable to save target file!" << endl;
		return false;
	}

	return true;
}

static bool extractMessagesByListFile(const QString& filename, const QString& listFilename, const QString& destFilename)
{
	const QList<quint32> list = loadHashesFromList(listFilename);
	if (list.isEmpty())
	{
		cout << "Unable to load list!" << endl;
		return false;
	}

	return extractMessagesByList(filename, list, destFilename);
}

static bool extractMessagesByBaseStrings(const QString& filename, const QString& baseFilename, const QString& destFilename)
{
	const MessageSet baseMessages = Strings::importMessages(baseFilename);
	if (baseMessages.isEmpty())
	{
		cout << "Unable to load base strings file!" << endl;
		return false;
	}

	return extractMessagesByList(filename, baseMessages.hashes, destFilename);
}

static bool buildMessagesByList(const MessageSet::Messages& messages, const QList<quint32>& list, const QString& destFilename)
{
	MessageSet newMessages = messagesByList(messages, list);

	if (!Strings::exportMessages(newMessages, destFilename))
	{
		cout << "Unable to build strings file!" << endl;
		return false;
	}

	return true;
}

static MessageSet::Messages loadMessagesFromFiles(const QStringList& filenames)
{
	MessageSet::Messages messages;
	foreach (const QString& filename, filenames)
	{
		const MessageSet messageSet = Strings::loadMessages(filename);
		if (messageSet.isEmpty())
		{
			cout << "Unable to load strings file!" << endl;
			return MessageSet::Messages();
		}

		for (MessageSet::Messages::const_iterator it = messageSet.messages.begin(); it != messageSet.messages.end(); it++)
		{
			messages[it->hash] = *it;
		}
	}

	return messages;
}

static bool buildMessagesByBaseStrings(const QStringList& filenames, const QString& baseFilename, const QString& destFilename)
{
	const MessageSet baseMessages = Strings::loadMessages(baseFilename);
	if (baseMessages.isEmpty())
	{
		cout << "Unable to load base strings file!" << endl;
		return false;
	}

	const MessageSet::Messages messages = loadMessagesFromFiles(filenames);
	if (messages.isEmpty())
	{
		cout << "Unable to load base strings file!" << endl;
		return false;
	}

	return buildMessagesByList(messages, baseMessages.hashes, destFilename);
}

static bool buildMessagesByListFile(const QStringList& filenames, const QString& listFilename, const QString& destFilename)
{
	const QList<quint32> list = loadHashesFromList(listFilename);
	if (list.isEmpty())
	{
		cout << "Unable to load list!" << endl;
		return false;
	}
	
	const MessageSet::Messages messages = loadMessagesFromFiles(filenames);
	if (messages.isEmpty())
	{
		cout << "Unable to load base strings file!" << endl;
		return false;
	}

	return buildMessagesByList(messages, list, destFilename);
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

		if (!Strings::collapseDuplicates(messages.messages))
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
	else if (act == "-el" && args.size() == 5)
	{
		const QString& inputFile = args[2];
		const QString& listFile = args[3];
		const QString& outFile = args[4];

		if (!extractMessagesByListFile(inputFile, listFile, outFile))
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

		if (!Strings::expandReferences(messages.messages))
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
	else if (act == "-bs" && args.size() >= 5)
	{
		const QString& baseFile = args[2];
		const QString& outFile = args[3];
		const QStringList inputFiles = args.mid(4);

		if (!buildMessagesByBaseStrings(inputFiles, baseFile, outFile))
		{
			cout << "Unable to build strings" << endl;
			return -1;
		}

		cout << "Strings builded sucessfully!" << endl;
	}
	else if (act == "-bl" && args.size() >= 5)
	{
		const QString& listFile = args[2];
		const QString& outFile = args[3];
		const QStringList inputFiles = args.mid(4);

		if (!buildMessagesByListFile(inputFiles, listFile, outFile))
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
