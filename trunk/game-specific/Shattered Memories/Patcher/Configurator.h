#pragma once
#include <memory>

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

	void setPlatforms(const QSet<Platform>& platforms);
	void setCheckArchives(bool enabled);
	void setCheckImage(bool enabled);
	void setErrorCode(int code);
	void setErrorData(const QByteArray& data);
	void setImagePath(const QString& path);
	void setTempPath(const QString& path);

	QString imagePath() const;
	QString tempPath() const;
	bool checkArchives() const;
	bool checkImage() const;
	QStringList resourceDirectories() const;

private:
	static std::auto_ptr<Configurator> s_instance;

	QString m_tempPath;
	QString m_imagePath;
	QStringList m_resourceDirectories;
	int m_errorCode;
	QByteArray m_errorData;
	bool m_checkArchives;
	bool m_checkImage;
};
