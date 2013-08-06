#include "Configurator.h"

std::auto_ptr<Configurator> Configurator::s_instance;

Configurator::Configurator()
{
}

Configurator& Configurator::instanse()
{
	if (s_instance.get() == NULL)
	{
		s_instance.reset(new Configurator());
	}

	return *s_instance;
}

QString Configurator::imagePath() const
{
	return m_imagePath;
}

QString Configurator::tempPath() const
{
	return m_tempPath;
}

QStringList Configurator::resourceDirectories() const
{
	return m_resourceDirectories;
}

void Configurator::setErrorCode(int code)
{
	m_errorCode = code;
}

void Configurator::setErrorData(const QByteArray& data)
{
	m_errorData = data;
}

void Configurator::setImagePath(const QString& path)
{
	m_imagePath = path;
}

void Configurator::setTempPath(const QString& path)
{
	m_tempPath = path;
}

bool Configurator::checkArchives() const
{
	return m_checkArchives;
}

bool Configurator::checkImage() const
{
	return m_checkImage;
}