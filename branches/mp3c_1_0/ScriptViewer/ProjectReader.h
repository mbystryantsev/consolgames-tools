#pragma once
#include <QFile>
#include <QMap>
#include <QByteArray>

class ProjectReader
{
public:
	ProjectReader(const QString& filename);

protected:
	typedef QList<QByteArray> ValueList;

	bool open(const QString& filename);
	QByteArray readLine();
	void processLine(const QByteArray& line);
	void setVariable(const QByteArray& context, const QByteArray& name, const ValueList& values);
	void initVariables();
protected:

	QFile m_file;
	QMap<QByteArray,ValueList> m_variables;
	QMap<QByteArray,ValueList> m_scripts;
};
