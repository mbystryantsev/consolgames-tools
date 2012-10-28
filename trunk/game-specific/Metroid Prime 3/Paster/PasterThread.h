#pragma once
#include <pak.h>
#include <DataPaster.h>
#include <QThread>
#include <QReadWriteLock>
#include <QStringList>
#include <QString>
#include <memory>

class QString;
class QStringList;

class PakProgressHandler: public QObject, public IPakProgressHandler
{
	Q_OBJECT;

	virtual void init(int size) override
	{
		emit initProgress(size);
	}
	virtual void progress(int value, const char* message)
	{
		emit changeProgress(value, message);
	}
	virtual void finish()
	{
		emit finishProgress();
	}

	Q_SIGNAL void initProgress(int size);
	Q_SIGNAL void changeProgress(int index, const char* message);
	Q_SIGNAL void finishProgress();
};

class PasterThread : public QThread
{
	Q_OBJECT;

public:
	enum Action
	{
		Init,
		RebuildPaks,
		CheckData,
		ReplacePaks,
		CheckPaks,
		Done
	};

	enum ResultCodes
	{
		Success = 0,
		AlreadyRunning = -1,
		ImageError = -2,
		InvalidDataPath = -3
	};

public:
	PasterThread();

	void setImageFile(const QString& imageFilename);
	void setPakList(const QStringList& paks);
	void setDataDirectories(const QStringList& dataDirs);
	void setTempDirectory(const QString& tempDir);
	void setCheckData(bool check);
	void setCheckPaks(bool check);

	QString imageFile() const;
	QStringList pakList() const;
	QStringList dataDirectories() const;
	QString tempDirectory() const;
	bool checkDataOn() const;
	bool checkPaksOn() const;

	Q_SLOT bool startPatching();

	Q_SIGNAL void actionStarted(int action);
	Q_SIGNAL void actionCompleted(bool success);

protected:
	Q_INVOKABLE void patch();

protected:
	bool openImage(const QString& imageFilename);
	bool closeImage();
	bool rebuildPaks(const QStringList& paks, const QStringList& inputDirs, const QString& outDir);
	bool replacePaks(const QStringList& paks, const QString& inputDir);
	bool checkData(const QStringList& paks, const QStringList& inputDirs, const QString& outDir);
	bool checkPaks(const QStringList& paks, const QString& inputDir);

	Q_SIGNAL void initProgress(int size);
	Q_SIGNAL void changeProgress(int index, const char* message);
	Q_SIGNAL void finishProgress();

protected:
	virtual void run() override;

protected:
	std::auto_ptr<DataPaster> m_paster;
	Action m_action;

	QString m_imageFilename;
	QString m_tempDirectory;
	QStringList m_pakList;
	QStringList m_dataDirectories;
	bool m_checkData;
	bool m_checkPaks;
	mutable QReadWriteLock m_lock;
	PakProgressHandler m_pakProgressHandler;
};