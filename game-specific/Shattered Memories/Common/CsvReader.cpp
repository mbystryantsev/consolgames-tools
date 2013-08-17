#include "CsvReader.h"
#include <core.h>

namespace ShatteredMemories
{

CsvReader::CsvReader(const QString& filename)
	: m_file(filename)
	, m_stream(&m_file)
{
	VERIFY(m_file.open(QIODevice::ReadOnly | QIODevice::Text));

	m_header = m_stream.readLine().trimmed().split(';');
	for (int i = 0; i < m_header.size(); i++)
	{
		m_header[i] = m_header[i].trimmed();
	}
}

bool CsvReader::opened()
{
	return (m_file.isOpen() && m_header.size() > 0);
}

QMap<QString, QString> CsvReader::readLine()
{
	QMap<QString, QString> result;
	m_stream.skipWhiteSpace();
	if (m_stream.atEnd())
	{
		return result;
	}

	const QStringList values = m_stream.readLine().trimmed().split(';');
	ASSERT(values.size() == m_header.size());

	for (int i = 0; i < m_header.size(); i++)
	{
		result[m_header[i]] = values[i].trimmed();
	}

	return result;
}

const QStringList& CsvReader::header() const
{
	return m_header;
}
}
