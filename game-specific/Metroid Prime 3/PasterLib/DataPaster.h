#pragma once
#include <WiiImage.h>
#include <QString>
#include <string>

class QStringList;

class DataPaster
{
public:
	DataPaster(const QString& wiiImageFile);

	bool open();
	bool rebuildPaks(const QStringList& pakArchives, const std::vector<std::string>& inputDirs, const std::string& outDir);
	bool replacePaks(const QStringList& pakArchives, const QString& inputDir);

protected:
	QString m_imageFilename;
	Consolgames::WiiImage m_image;
};