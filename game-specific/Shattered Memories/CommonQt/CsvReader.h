#pragma once
#include <QFile>
#include <QTextStream>
#include <QStringList>

namespace ShatteredMemories
{

class CsvReader
{
public:
	CsvReader(const QString& filename);
	bool isOpen();
	QMap<QString, QString> readLine();
	const QStringList& header() const;

private:
	QFile m_file;
	QTextStream m_stream;
	QStringList m_header;
};

}