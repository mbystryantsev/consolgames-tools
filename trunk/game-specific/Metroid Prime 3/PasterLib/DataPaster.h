#pragma once
#include <pak.h>
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
	bool checkData(const QStringList& pakArchives, const QStringList& inputDirs, const QString& outDir);
	bool checkPaks(const QStringList& pakArchives, const QString& paksDir);
	void setProgressHandler(IPakProgressHandler* handler);
	void setMergeMap(const std::map<Hash,Hash>& mergeMap);
	static void loadMergeMap(const QString& filename, std::map<Hash,Hash>& mergeMap);

protected:
	static bool compareStreams(Consolgames::Stream* stream1, Consolgames::Stream* stream2, bool ignoreSize = false);

protected:
	QString m_imageFilename;
	Consolgames::WiiImage m_image;
	std::map<Hash,Hash> m_mergeMap;
	IPakProgressHandler* m_pakProgressHandler;
};