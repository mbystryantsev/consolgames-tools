#pragma once
#include <pak.h>
#include <DataPaster.h>
#include <QThread>
#include <QReadWriteLock>
#include <QStringList>
#include <QString>
#include <memory>
#include <QCoreApplication>

class QString;
class QStringList;

class ProgressHandler: public QObject, public IPakProgressHandler
{
	Q_OBJECT;

public:
	ProgressHandler() : m_stopRequested(false)
	{
	}

	Q_SLOT void requestStop()
	{
		m_stopRequested = true;
	}

private:
	virtual void init(int size) override
	{
		m_stopRequested = false;
		emit initProgress(size);
	}
	virtual void progress(int value, const char* message)
	{
		emit changeProgress(value, message);
		QCoreApplication::processEvents();
	}
	virtual void finish()
	{
		emit finishProgress();
	}
	virtual bool stopRequested()
	{
		return m_stopRequested;
	}

	Q_SIGNAL void initProgress(int size);
	Q_SIGNAL void changeProgress(int index, const QString& message);
	Q_SIGNAL void finishProgress();

private:
	bool m_stopRequested;
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
		CheckImage,
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
	Q_SLOT bool startPatching();

private:
	Q_SLOT void setImageFile(const QString& imageFilename);
	Q_SLOT void setPakList(const QStringList& paks);
	Q_SLOT void setDataDirectories(const QStringList& dataDirs);
	Q_SLOT void setTempDirectory(const QString& tempDir);
	Q_SLOT void setCheckData(bool check);
	Q_SLOT void setCheckPaks(bool check);
	Q_SLOT void setCheckImage(bool check);
	Q_SLOT void requestStop();

	QString imageFile() const;
	QStringList pakList() const;
	QStringList dataDirectories() const;
	QString tempDirectory() const;
	bool checkDataOn() const;
	bool checkPaksOn() const;
	bool checkImageOn() const;

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
	bool checkImage();

	Q_SIGNAL void initProgress(int size);
	Q_SIGNAL void changeProgress(int index, const QString& message);
	Q_SIGNAL void finishProgress();

	Q_SIGNAL void initActionProgress(int size);
	Q_SIGNAL void changeActionProgress(int index, const QString& message);
	Q_SIGNAL void finishActionProgress();

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
	bool m_checkImage;
	mutable QReadWriteLock m_lock;
	ProgressHandler m_pakProgressHandler;
	ProgressHandler m_actionProgressHandler;
	bool m_stopRequested;
};