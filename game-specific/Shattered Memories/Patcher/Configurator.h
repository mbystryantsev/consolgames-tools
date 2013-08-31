#pragma once
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
		platformWii,
		platformPS2,
		platformPSP
	};

public:
	static Configurator& instanse();

	void configure(ShatteredMemories::PatcherController& controller) const;

	void setPlatforms(const QSet<Platform>& platforms);
	void setDebug(bool debug);
	void setImagePath(const QString& path);
	void setTempPath(const QString& path);
	void setErrorCode(int code);
	void setErrorData(const QString& data);
	int errorCode() const;
	QString errorData() const;

	static QString version();
	
private:
	static std::auto_ptr<Configurator> s_instance;

	bool m_isDebug;
	Platform m_platform;
	QString m_tempPath;
	QString m_imagePath;
	QStringList m_resourceDirectories;
	int m_errorCode;
	QString m_errorData;
};
