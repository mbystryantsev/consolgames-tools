#pragma once
#include <ScriptParser.h>
#include <QVector>
#include <QMap>
#include <QPair>
#include <QSet>

class ScriptTester
{
public:
	enum ErrorType
	{
		NoError = 0,
		InputFileError = -1,
		OutputFileError = -2,
		NoExpectedData = -3,
		DataMismatch = -4

	};
	struct TestDataRecord
	{
		int count;
		int idCount;
		int version;
		QVector<int> tagCount;
	};

	struct TestData
	{
		QMap<quint64, TestDataRecord> mappedHashes;
	};

public:
	ErrorType loadTestData(const QString& filename);
	ErrorType loadIgnoreData(const QString& filename);
	ErrorType loadIdentifiers(const QString& filename);
	ErrorType loadScript(const QString& filename);
	ErrorType detectIdentifiers(const QString& externalScriptFile, const QString& outFile);
	ErrorType runTests();
	ErrorType calculateTags(const QString& outFile);

	static ErrorType exec(const QString& filename);
	static const char* errorString(ErrorType error);
	static QString lastErrorData();
	static QMap<quint64,quint64> generateMergeMap(const QString& inputDir);

protected:
	const MessageSet* findMessageSet(quint64 hash);

protected:
	static QString s_lastErrorData;
	QVector<MessageSet> m_script;
	QString m_scriptName;
	TestData m_testData;
	QSet<QPair<quint64, int>> m_ignoredStrings;
	QMap<QPair<quint64, int>, QString> m_identifiers;
	int m_failedCount;
};