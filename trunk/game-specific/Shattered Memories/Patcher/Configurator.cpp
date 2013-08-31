#include "Configurator.h"
#include "version.h"
#include <PatcherController.h>
#include <QDir>

std::auto_ptr<Configurator> Configurator::s_instance;

static const QString s_resourcesPath = ":/patchdata/";

Configurator::Configurator()
	: m_game(gameShatteredMemories)
	, m_platform(platformWii)
	, m_isDebug(false)
	, m_tempPath(QDir::tempPath())
	, m_errorCode(0)
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

static Configurator::Platform platformValue(const QString& platformCode)
{
	for (int i = 0; i < Configurator::_platformCount; i++)
	{
		const Configurator::Platform platform = static_cast<Configurator::Platform>(i);
		if (::platformCode(platform) == platformCode)
		{
			return platform;
		}
	}

	return Configurator::platformUndefined;
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
}

Configurator& Configurator::instanse()
{
	if (s_instance.get() == NULL)
	{
		s_instance.reset(new Configurator());
	}

	return *s_instance;
}

void Configurator::setAvailablePlatforms(const QSet<Platform>& platforms)
{
	m_availablePlatforms = platforms;

	if (m_availablePlatforms.contains(m_platform))
	{
		return;
	}

	ASSERT(!m_availablePlatforms.isEmpty());
	m_platform = m_availablePlatforms.isEmpty() ? platformUndefined : m_availablePlatforms.values().last();
}

void Configurator::setDebug(bool debug)
{
	m_isDebug = debug;
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

void Configurator::setErrorData(const QString& data)
{
	m_errorData = data;
}

QSet<Configurator::Platform> Configurator::availablePlatforms() const
{
	return m_availablePlatforms;
}

Configurator::Platform Configurator::platform() const
{
	return m_platform;
}

int Configurator::errorCode() const
{
	return m_errorCode;
}

QString Configurator::errorData() const
{
	return m_errorData;
}

QString Configurator::version()
{
	return VER_PRODUCTVERSION_STR;
}

QSet<Configurator::Platform> Configurator::parsePlatforms(const QString& platforms)
{
	QSet<Platform> result;

	foreach (const QString& platformCode, platforms.split(','))
	{
		const Platform platform = platformValue(platformCode.trimmed());
		ASSERT(platform != platformUndefined);

		if (platform == platformUndefined)
		{
			return QSet<Platform>();
		}

		result.insert(platform);
	}

	return result;
}

QStringList Configurator::imageNameEuristicMasks() const
{
	QStringList list;

	if (m_game == gameShatteredMemories)
	{
		QString code;
		switch (m_platform)
		{
		case platformWii:
			code = "SHLPA4";
			break;
		case platformPS2:
			code = "SLES*555*69";
			break;
		case platformPSP:
			code = "ULES-01352";
			// ULUS-10450
			break;
		}

		list << "*shattered*.iso"
			<< "*memories*.iso"
			<< QString("*%1*.iso").arg(code)
			<< "*shsm*.iso";
	}
	else if (m_game == gameOrigins)
	{
		// ULES-00869, ULUS-10285
		const QString code = (m_platform == platformPS2 ? "SLES*551*47" : "ULES*00869");
		list << "*origins*.iso"
			<< QString("*%1*.iso").arg(code)
			<< "*sh0*.iso"
			<< "*sho*.iso";
	}

	return 	QStringList()
		<< "*silent*.iso"
		<< "*hill*.iso"
		<< list
		<< "*sh*.iso"
		<< "*silent*.iso"
		<< "*.iso";
}

Configurator::Game Configurator::gameByCode(const QString& code)
{
	if (code == "shsm")
	{
		return gameShatteredMemories;
	}
	if (code == "sh0")
	{
		return gameOrigins;
	}

	return gameUndefined;
}

void Configurator::setGame(Game game)
{
	ASSERT(game != gameUndefined);
	m_game = game;
}
