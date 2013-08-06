#include "Configurator.h"
#include <PatcherController.h>
#include <QDir>

std::auto_ptr<Configurator> Configurator::s_instance;

static const QString s_resourcesPath = ":/patchdata/";

Configurator::Configurator()
	: m_platform(platformWii)
	, m_isDebug(false)
	, m_tempPath(QDir::tempPath())
{
}

static QString platformCode(Configurator::Platform platform)
{
	switch (platform)
	{
	case Configurator::platformWii:
		return "wii";
	case Configurator::platformPS2:
		return "ps2";
	case Configurator::platformPSP:
		return "psp";
	}

	ASSERT(!"Invalid platform!");
	return QString();
}

void Configurator::configure(ShatteredMemories::PatcherController& controller) const
{
	ASSERT(!m_imagePath.isNull());
	ASSERT(!m_tempPath.isNull());
	
	controller.reset();
	controller.setImagePath(m_imagePath);
	controller.setTempPath(m_tempPath);
	controller.setCheckArchives(m_isDebug);
	controller.setCheckImage(m_isDebug);
	controller.addResourcesPath(QString("%1%2/").arg(s_resourcesPath).arg(platformCode(m_platform)));
	controller.addResourcesPath(s_resourcesPath);
	controller.setExecutableInfo("main.dol", 0x3FAC80, 0x41AC80);
}

Configurator& Configurator::instanse()
{
	if (s_instance.get() == NULL)
	{
		s_instance.reset(new Configurator());
	}

	return *s_instance;
}

void Configurator::setImagePath(const QString& path)
{
	m_imagePath = path;
}

void Configurator::setTempPath(const QString& path)
{
	m_tempPath = path;
}

void Configurator::setErrorCode(int code)
{
	m_errorCode = code;
}

void Configurator::setErrorData(const QByteArray& data)
{
	m_errorData = data;
}
