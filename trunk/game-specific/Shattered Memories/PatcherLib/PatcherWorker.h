#pragma once
#include "PatcherProcessor.h"
#include <QObject>
#include <QStringList>

namespace ShatteredMemories
{

class PatcherWorker: public QObject
{
	Q_OBJECT

public:
	PatcherWorker(QObject* parent = NULL);

	Q_SLOT void reset();
	Q_SLOT void initialize();
	Q_SLOT void rebuildArchives();
	Q_SLOT void replaceArchives();
	Q_SLOT void finalize();

	Q_SLOT void setImagePath(const QString& imagePath);
	Q_SLOT void setTempPath(const QString& tempPath);
	Q_SLOT void addResourcesPath(const QString& path);
	Q_SLOT void setBootArcInfo(const QString& executableName, quint32 offset, quint32 maxSize, quint32 actualSizeValueOffset);

private:
	Q_SIGNAL void stepCompleted();
	Q_SIGNAL void stepFailed(int errorCode, const QString& errorData);

	void processError();

private:
	PatcherProcessor m_patcher;

	QString m_imagePath;
	QString m_tempPath;
	QStringList m_resourcesPaths;
	PatcherProcessor::BootArcInfo m_bootArcInfo;
};

}