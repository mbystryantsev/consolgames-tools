#include "ProjectReader.h"
#include <core.h>
#include <QFileInfo>
#include <QDir>

bool ProjectReader::open(const QString& filename)
{
	QFileInfo info(filename);
	if (!info.exists())
	{
		return false;
	}
	m_file.setFileName(info.absoluteFilePath());

	initVariables();

	return true;
}

QByteArray ProjectReader::readLine()
{
	QByteArray line;
	bool appendMode = false;
	while (!m_file.atEnd())
	{
		const QByteArray readedLine = m_file.readLine().trimmed();
		if (appendMode)
		{
			line.append(readedLine);
		}
		else
		{
			line = readedLine;
		}
		if (line.endsWith('\\'))
		{
			line.remove(line.size() - 1, 1);
			appendMode = true;
			continue;
		}
		if (line.isEmpty())
		{
			continue;
		}
		break;
	}
	return line;
}

void ProjectReader::processLine(const QByteArray& line)
{
	const QList<QByteArray> keyValuePair = line.split('=');
	ASSERT(keyValuePair.size() == 2);

	const QByteArray key = keyValuePair[0].trimmed();
	const ValueList values = keyValuePair[1].simplified().split(' ');
}

void ProjectReader::initVariables()
{
	m_variables.clear();
	m_scripts.clear();

	m_variables["PWD"] << QFileInfo(m_file.fileName()).absolutePath().toAscii();
}

void ProjectReader::setVariable(const QByteArray& context, const QByteArray& name, const ValueList& values)
{
	if (name == "SCRIPTS")
	{
		m_scripts[context] = values;
	}
}
