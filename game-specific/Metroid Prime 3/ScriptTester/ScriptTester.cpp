#include "ScriptTester.h"
#include <TagCalculator.h>
#include <MetroidFont.h>
#include <QFile>
#include <QTextStream>
#include <QRegExp>
#include <QStringList>
#include <QString>
#include <QDir>
#include <iostream>

QString ScriptTester::s_lastErrorData;

static QString hashToStr(quint64 hash)
{
	return QString::number(hash, 16).toUpper().rightJustified(16, '0');
}

ScriptTester::ErrorType ScriptTester::calculateTags(const QString& outFile)
{
	if (m_script.isEmpty())
	{
		s_lastErrorData = "";
		return NoExpectedData;
	}

	QFile file(outFile);
	if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		s_lastErrorData = outFile;
		return OutputFileError;
	}
	QTextStream stream(&file);
	stream << "nameHashes;count;idCount;version;tagCount\n";

	foreach (const MessageSet& set, m_script)
	{
		bool isFirst = true;
		foreach (quint64 hash, set.nameHashes)
		{
			if (!isFirst)
			{
				stream << ',';
			}
			else
			{
				isFirst = false;
			}
			stream << hashToStr(hash);
		}
		stream << ';' << set.definedCount << ';' << set.idCount << ';' << set.version << ';';
		isFirst = true;
		foreach (const Message& message, set.messages)
		{
			if (!isFirst)
			{
				stream << ',';
			}
			else
			{
				isFirst = false;
			}
			const int tagCount = TagCalculator::calcTags(message.text);
			stream << tagCount;
		}
		stream << '\n';
	}
	return NoError;
}

ScriptTester::ErrorType ScriptTester::loadTestData(const QString& filename)
{
	m_testData.mappedHashes.clear();

	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		s_lastErrorData = filename;
		return InputFileError;
	}

	file.readLine();

	while (!file.atEnd())
	{
		QByteArray line = file.readLine().trimmed();
		if (line.isEmpty())
		{
			continue;
		}
		QList<QByteArray> values = line.split(';');
		TestDataRecord record;
		record.count = values[1].toInt();
		record.idCount = values[2].toInt();
		record.version = values[3].toInt();
		const QList<QByteArray> tagCountStrings = values[4].split(',');
		record.tagCount.resize(tagCountStrings.size());
		for (int i = 0; i < tagCountStrings.size(); i++)
		{
			record.tagCount[i] = tagCountStrings[i].toInt();
		}

		const QList<QByteArray> hashes = values[0].split(',');
		for (int i = 0; i < hashes.size(); i++)
		{
			m_testData.mappedHashes[hashes[i].toULongLong(NULL, 16)] = record;
		}

	}
	return NoError;
}

ScriptTester::ErrorType ScriptTester::loadIgnoreData(const QString& filename)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly))
	{
		s_lastErrorData = filename;
		return InputFileError;
	}

	m_ignoredStrings.clear();

	file.readLine();
	while (!file.atEnd())
	{
		QByteArray line = file.readLine().trimmed();
		if (line.isEmpty())
		{
			continue;
		}

		const QList<QByteArray> values = line.split(';');
		m_ignoredStrings.insert(QPair<quint64, int>(values[0].toULongLong(NULL, 16), values[1].toInt()));
	}
	return NoError;
}


ScriptTester::ErrorType ScriptTester::loadIdentifiers(const QString& filename)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		s_lastErrorData = filename;
		return InputFileError;
	}

	m_identifiers.clear();

	file.readLine();
	while (!file.atEnd())
	{
		QByteArray line = file.readLine().trimmed();
		if (line.isEmpty())
		{
			continue;
		}

		const QList<QByteArray> values = line.split(';');
		QString text = values[2];

		text.replace("\\r", "\r");
		text.replace("\\n", "\n");
		text.replace("\\059", ";");
		m_identifiers[QPair<quint64,int>(values[0].toULongLong(NULL, 16), values[1].toInt())] = text;
	}
	return NoError;
}

ScriptTester::ErrorType ScriptTester::loadScript(const QString& filename)
{
	m_scriptName.clear();
	m_script = ScriptParser::loadFromFile(filename);
	if (m_script.isEmpty())
	{
		s_lastErrorData = filename;
		return InputFileError;
	}

	m_scriptName = filename.split(QRegExp("[/\\\\]")).last().split('.').first();

	return NoError;
}


#define SVERIFY(hash, index, expr, message, action) \
	if (!(expr)) { \
		if (failedCount == 0) std::cout << std::endl; \
		failedCount++; \
		std::cout << "FAIL: " << hashToStr(hash).constData(); \
		if (index != -1) std::cout << ": " << index; \
		std::cout << ": " << message.toStdString() << std::endl; \
		action; \
	}

#define SVERIFYH(expr, message, action) SVERIFY(hash, -1, expr, message, action)
#define SVERIFYHI(expr, message, action) SVERIFY(hash, i, expr, message, action)

ScriptTester::ErrorType ScriptTester::runTests()
{
	int failedCount = 0;

	std::cout << "TESTING: " << m_scriptName.toStdString() << "... ";

	if (m_testData.mappedHashes.isEmpty())
	{
		std::cout << std::endl << "FAILED! No expected test data!" << std::endl;
		s_lastErrorData = "Test data";
		return NoExpectedData;
	}

	if (m_script.isEmpty())
	{
		std::cout << std::endl << "FAILED! No script data loaded!" << std::endl;
		s_lastErrorData = "Script";
		return NoExpectedData;
	}

	foreach (const MessageSet& set, m_script)
	{
		SVERIFY(set.nameHashes[0], -1, set.definedCount == set.messages.count(), QString("Defined message count (%1) differs from real count (%2)!").arg(set.definedCount).arg(set.messages.count()), continue);
		foreach (quint64 hash, set.nameHashes)
		{
			SVERIFYH(m_testData.mappedHashes.contains(hash), QString("Test data for hash does not exists!"), continue);
			const TestDataRecord& record = m_testData.mappedHashes[hash];
			for (int i = 0; i < set.definedCount; i++)
			{
				QPair<quint64, int> id(hash, i);
				if (m_ignoredStrings.contains(id))
				{
					continue;
				}
				const int actualTagCount = TagCalculator::calcTags(set.messages[i].text);
				const int expectedTagCount = record.tagCount[i];
				SVERIFYHI(actualTagCount == expectedTagCount, QString("actualTagCount (%1) differs of expected (%2)").arg(actualTagCount).arg(expectedTagCount), continue);

				if (m_identifiers.contains(id))
				{
					const QString actual = set.messages[i].text;
					const QString expected = m_identifiers[id];
					SVERIFYHI(actual == expected, QString("Technical text does not match!"), continue);
				}
			}
		}
	}
	
	std::cout << "DONE! (" << failedCount << " fails)" << std::endl;

	return NoError;
}


const char* ScriptTester::errorString(ErrorType error)
{
	switch (error)
	{
	case NoError:
		return "No error";
	case InputFileError:
		return "Input file error";
	case OutputFileError:
		return "Output file error";
	case NoExpectedData:
		return "No expected data";
	case DataMismatch:
		return "Data mismatch";
	}
	return "undefined";
}

const MessageSet* ScriptTester::findMessageSet(quint64 hash)
{
	foreach (const MessageSet& messageSet, m_script)
	{
		foreach (quint64 nameHash, messageSet.nameHashes)
		{
			if (hash == nameHash)
			{
				return &messageSet;
			}
		}
	}
	return NULL;
}

ScriptTester::ErrorType ScriptTester::detectIdentifiers(const QString& externalScriptFile, const QString& outFile)
{
	if (m_script.isEmpty())
	{
		s_lastErrorData = "Script";
		return NoExpectedData;
	}

	QVector<MessageSet> externalScript = ScriptParser::loadFromFile(externalScriptFile);
	if (externalScript.isEmpty())
	{
		s_lastErrorData = externalScriptFile;
		return InputFileError;
	}

	QFile file(outFile);
	if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		s_lastErrorData = outFile;
		return OutputFileError;
	}

	QTextStream stream(&file);
	stream << "hash;index;text\n";

	foreach (const MessageSet& externalSet, externalScript)
	{
		foreach (quint64 hash, externalSet.nameHashes)
		{
			const MessageSet* messageSet = findMessageSet(hash);
			if (messageSet == NULL)
			{
				s_lastErrorData = QString("Message set %1").arg(hashToStr(hash)); 
				return NoExpectedData;
			}
			if (externalSet.messages.size() != messageSet->messages.size())
			{
				s_lastErrorData = QString("Messages size (%1, %2 != %3)").arg(hashToStr(hash)).arg(externalSet.messages.size()).arg(messageSet->messages.size());
				return DataMismatch;
			}
			for (int i = 0; i < externalSet.messages.size(); i++)
			{
				QString text = externalSet.messages[i].text;
				if (text == messageSet->messages[i].text && !text.trimmed().isEmpty())
				{
					text.replace('\r', "\\r");
					text.replace('\n', "\\n");
					text.replace(';', "\\059");
					stream << hashToStr(hash) << ';' << i << ';' << text << '\n';
				}
			}
		}
	}
	return NoError;
}

#define TESTER_VERIFY(expr) {\
		ErrorType result = expr; \
		if (result != NoError) return result; \
	}

ScriptTester::ErrorType ScriptTester::exec(const QString& filename)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		s_lastErrorData = filename;
		return InputFileError;
	}

	file.readLine();
	while (!file.atEnd())
	{
		QByteArray line = file.readLine().trimmed();
		if (line.isEmpty())
		{
			continue;
		}

		QList<QByteArray> values = line.split(';');

		const QString scriptFile = values[0];
		const QString testDataFile = values[1];
		const QString ignoreTagsFile = values[2];
		const QString identifiersFile = values[3];

		ScriptTester tester;
		TESTER_VERIFY(tester.loadScript(scriptFile));
		TESTER_VERIFY(tester.loadTestData(testDataFile));
		if (!ignoreTagsFile.isEmpty())
		{
			TESTER_VERIFY(tester.loadIgnoreData(ignoreTagsFile));
		}
		if (!identifiersFile.isEmpty())
		{
			TESTER_VERIFY(tester.loadIdentifiers(identifiersFile));
		}
		
		TESTER_VERIFY(tester.runTests());
	}

	return NoError;
}

QString ScriptTester::lastErrorData()
{
	return s_lastErrorData;
}

ScriptTester::ErrorType ScriptTester::loadScriptFromDir(const QString& inputDir)
{
	QDir dir(inputDir);
	foreach (const QString& filename, dir.entryList(QStringList("*.txt"), QDir::Files))
	{
		m_script << ScriptParser::loadFromFile(inputDir + "/" + filename);
	}

	return NoError;
}

QMap<quint64,quint64> ScriptTester::generateMergeMap(const QString& inputDir)
{
	QDir dir(inputDir);
	QMap<quint64,quint64> mergeMap;
	foreach (const QString& filename, dir.entryList(QStringList("*.txt"), QDir::Files))
	{
		const QVector<MessageSet> script = ScriptParser::loadFromFile(inputDir + "/" + filename);
		if (script.isEmpty())
		{
			continue;
		}
		foreach (const MessageSet& messageSet, script)
		{
			for (int i = 1; i < messageSet.nameHashes.size(); i++)
			{
				mergeMap[messageSet.nameHashes[i]] = messageSet.nameHashes[0];
			}
		}
	}

	return mergeMap;
}

ScriptTester::ErrorType ScriptTester::checkCharacters()
{
	if (m_script.isEmpty() || m_charSet.isEmpty())
	{
		return NoExpectedData;
	}

	ErrorType error = NoError;

	foreach (const MessageSet& messages, m_script)
	{
		int index = 0;
		foreach (const Message& message, messages.messages)
		{
			bool tagMode = false;
			int charIndex = 0;
			int line = 0;
			int charIndexInLine = 0;
			bool skip = false;
			foreach (const QChar c, message.text)
			{
				if (c == '\n')
				{
					line++;
					charIndexInLine = 0;
				}
				if (!tagMode && c == '&')
				{
					tagMode = true;
				}
				else if (tagMode && c == ';')
				{
					tagMode = false;
				}
				if (tagMode)
				{
					skip = true;
				}
				if (!skip && c.unicode() > 0x20 && !m_charSet.contains(c))
				{
					std::cout << "Invalid character used: `" << c.toLatin1() << "` (0x" << QString::number(c.unicode(), 16).toLatin1().constData() << " at item ("
						<< hashToStr(messages.nameHashes[0]).toLatin1().constData() << "," << index << ")" << std::endl;
					std::cout << "Line " << (line + 1) << ", char " << charIndexInLine << ", char index " << charIndex << std::endl;
					error = DataMismatch;
				}
				charIndex++;
				charIndexInLine++;
			}
			index++;
		}
	}
	return error;
}

ScriptTester::ErrorType ScriptTester::loadFont(const QString& filename)
{
	Consolgames::MetroidFont font;
	if (!font.loadFromEditorFormat(filename))
	{
		return InputFileError;
	}
	m_charSet = font.charList().toSet();
	return NoError;
}

ScriptTester::ErrorType ScriptTester::loadScriptFromDirOrFile(const QString& inputPath)
{
	QFileInfo info(inputPath);
	if (info.isDir())
	{
		return loadScriptFromDir(inputPath);
	}
	return loadScript(inputPath);
}

ScriptTester::ErrorType ScriptTester::checkTags()
{
	if (m_script.isEmpty())
	{
		return NoExpectedData;
	}
	ErrorType error = NoError;
	foreach (const MessageSet& messages, m_script)
	{
		int index = 0;
		foreach (const Message& message, messages.messages)
		{
			if (TagCalculator::calcTags(message.text) < 0)
			{
				error = DataMismatch;
				std::cout << "Tag error occured at (" << hashToStr(messages.nameHashes[0]).toLatin1().constData() << "," << index << ")" << std::endl;
			}
			index++;
		}
	}
	return error;
}

ScriptTester::ErrorType ScriptTester::checkMessageCount(const QString& originalPath)
{
	if (m_script.isEmpty())
	{
		return NoExpectedData;
	}

	ScriptTester tester;
	TESTER_VERIFY(tester.loadScriptFromDirOrFile(originalPath));

	QMap<quint64, const MessageSet*> messageMap;
	foreach (const MessageSet& messages, tester.m_script)
	{
		foreach (quint64 hash, messages.nameHashes)
		{
			messageMap[hash] = &messages;
		}
	}

	ErrorType error = NoError;

	foreach (const MessageSet& messages, m_script)
	{
		const quint64 hash = messages.nameHashes[0];
		if (!messageMap.contains(hash))
		{
			std::cout << "Original message set with hash " << hashToStr(hash).toLatin1().constData() << " not found!" << std::endl;
			return NoExpectedData;
		}
		const MessageSet& originalMessages = *messageMap[hash];
		if (messages.messages.size() != originalMessages.messages.size())
		{
			std::cout << "Message count mismatch (" << messages.messages.size() << ", " << originalMessages.messages.size() << ") at item "
				<< hashToStr(hash).toLatin1().constData() << "!" << std::endl;
			error = DataMismatch;
		}
	}

	return error;
}
