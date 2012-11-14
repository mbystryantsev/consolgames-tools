#pragma once
#include <DataPaster.h>
#include <memory>
#include <QStringList>

class ProgressHandler : public QObject, public IPakProgressHandler
{
	Q_OBJECT

public:
	ProgressHandler();

	Q_SIGNAL void progressInit(int size);
	Q_SIGNAL void progressChanged(int value, const QString& message);
	Q_SIGNAL void progressFinish();

	virtual void init(int size) override;
	virtual void progress(int value, const char* message) override;
	virtual void finish() override;
	virtual bool stopRequested() override;
	Q_SLOT void requestStop();

private:
	bool m_stopRequested;
};

class PatcherWorker : public QObject
{
	Q_OBJECT

public:
	PatcherWorker();
	~PatcherWorker();

private:
	Q_SLOT void setImagePath(const QString& path);
	Q_SLOT void addResourcesPath(const QString& path);
	Q_SLOT void setTempPath(const QString& path);

	// Steps
	Q_SLOT void initialize();
	Q_SLOT void rebuildPaks();
	Q_SLOT void checkData();
	Q_SLOT void replacePaks();
	Q_SLOT void checkPaks();
	Q_SLOT void checkImage();
	Q_SLOT void finalize();

	Q_SIGNAL void stepFailed(int errorCode, const QString& errorData, const QString& errorMessage, const QString& description);
	Q_SIGNAL void stepCompleted();

	Q_SIGNAL void actionInit(int maximum);
	Q_SIGNAL void actionProgress(int progress, const QString& message);
	Q_SIGNAL void actionFinish();
	Q_SIGNAL void subActionInit(int maximum);
	Q_SIGNAL void subActionProgress(int progress, const QString& message);
	Q_SIGNAL void subActionFinish();

private:
	void processError(const QString& errorMessage, const QString& description);
	void finalizeInternal();
	void removeTempFiles();

private:
	std::auto_ptr<DataPaster> m_paster;
	QStringList m_resourcesPaths;
	QString m_imagePath;
	QString m_imageResourcesPath;
	QString m_tempPath;
	QString m_pakTempPath;
	bool m_tempDirCreated;

	ProgressHandler m_actionProgressHandler;
	ProgressHandler m_subActionProgressHandler;

	static QStringList s_pakList;
	static const QString s_paksDirName;
};