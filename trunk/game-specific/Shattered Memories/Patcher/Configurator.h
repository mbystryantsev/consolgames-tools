#pragma once
#include <QSet>
#include <QStringList>
#include <memory>

namespace ShatteredMemories
{
class PatcherController;
}

class Configurator
{
	Configurator();

public:
	enum Platform
	{
		platformUndefined = -1,
		platformWii,
		platformPS2,
		platformPSP,
		_platformCount
	};

	enum Game
	{
		gameUndefined = -1,
		gameShatteredMemories,
		gameOrigins
	};

public:
	static Configurator& instance();

	void configure(ShatteredMemories::PatcherController& controller) const;

	void setAvailablePlatforms(const QSet<Platform>& platforms);
	void setDebug(bool debug);
	void setImagePath(const QString& path);
	void setTempPath(const QString& path);
	void setErrorCode(int code);
	void setErrorData(const QString& data);
	void setGame(Game game);

	QStringList imageNameEuristicMasks() const;
	
	QSet<Platform> availablePlatforms() const;
	Platform platform() const;
	int errorCode() const;
	QString errorData() const;

	static QString version();
	static QSet<Platform> parsePlatforms(const QString& platforms);
	static Game gameByCode(const QString& code);
	static QString platformAbbr(Platform platform);
	static QString platformName(Platform platform);

private:
	static std::auto_ptr<Configurator> s_instance;

	Game m_game;
	QSet<Platform> m_availablePlatforms;
	Platform m_platform;
	bool m_isDebug;
	QString m_tempPath;
	QString m_imagePath;
	QStringList m_resourceDirectories;
	int m_errorCode;
	QString m_errorData;
};
