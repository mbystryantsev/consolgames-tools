#include "PasterThread.h"
#include <QObject>
#include <QDir>
#include <QString>
#include <QStringList>
#include <QMetaObject>

LOG_CATEGORY("PASTER")

PasterThread::PasterThread()
	: m_checkData(true)
	, m_checkPaks(true)
{
	moveToThread(this);

	VERIFY(connect(&m_pakProgressHandler, SIGNAL(initProgress(int)), SIGNAL(initProgress(int))));
	VERIFY(connect(&m_pakProgressHandler, SIGNAL(changeProgress(int, const char*)), SIGNAL(changeProgress(int, const char*))));
	VERIFY(connect(&m_pakProgressHandler, SIGNAL(finishProgress()), SIGNAL(finishProgress())));

	start();
}

void PasterThread::run()
{
	exec();
}

#define RUNCHECK() 

bool PasterThread::startPatching()
{
	if (!isRunning())
	{
		return false;
	}

	return QMetaObject::invokeMethod(this, "patch", Qt::QueuedConnection);
}


bool PasterThread::rebuildPaks(const QStringList& paks, const QStringList& inputDirs, const QString& outDir)
{
	std::vector<std::string> inputDirList(inputDirs.size());
	for (int i = 0; i < inputDirs.size(); i++)
	{
		inputDirList[i] = inputDirs[i].toStdString();
	}

	std::map<Hash,Hash> mergeMap;
	foreach (const QString& dir, inputDirs)
	{
		const QString filename = dir + "/mergemap.bin";
		if (QFile::exists(filename))
		{
			DataPaster::loadMergeMap(filename, mergeMap);
		}
	}

	m_paster->setMergeMap(mergeMap);
	return m_paster->rebuildPaks(paks, inputDirList, outDir.toStdString());
}

bool PasterThread::replacePaks(const QStringList& paks, const QString& inputDir)
{
	return m_paster->replacePaks(paks, inputDir);
}

bool PasterThread::checkData(const QStringList& paks, const QStringList& inputDirs, const QString& outDir)
{
	return m_paster->checkData(paks, inputDirs, outDir);
}

bool PasterThread::checkPaks(const QStringList& paks, const QString& inputDir)
{
	return m_paster->checkPaks(paks, inputDir);
}

bool PasterThread::openImage(const QString& imageFilename)
{
	m_paster.reset(new DataPaster(imageFilename));
	m_paster->setProgressHandler(&m_pakProgressHandler);
	return m_paster->open();
}

bool PasterThread::closeImage()
{
	m_paster.reset();
	return true;
}

void PasterThread::setImageFile(const QString& imageFilename)
{
	QWriteLocker locker(&m_lock);
	m_imageFilename = imageFilename;
}

void PasterThread::setPakList(const QStringList& paks)
{
	QWriteLocker locker(&m_lock);
	m_pakList = paks;
}

void PasterThread::setDataDirectories(const QStringList& dataDirs)
{
	QWriteLocker locker(&m_lock);
	m_dataDirectories = dataDirs;
}

void PasterThread::setTempDirectory(const QString& tempDir)
{
	QWriteLocker locker(&m_lock);
	m_tempDirectory = tempDir;
}

void PasterThread::setCheckData(bool check)
{
	QWriteLocker locker(&m_lock);
	m_checkData = check;

}

void PasterThread::setCheckPaks(bool check)
{
	QWriteLocker locker(&m_lock);
	m_checkPaks = check;
}

QString PasterThread::imageFile() const
{
	return m_imageFilename;
}

QStringList PasterThread::pakList() const
{
	return m_pakList;
}

QStringList PasterThread::dataDirectories() const
{
	return m_dataDirectories;
}

QString PasterThread::tempDirectory() const
{
	return m_tempDirectory;
}

bool PasterThread::checkDataOn() const
{
	return m_checkData;
}

bool PasterThread::checkPaksOn() const
{
	return m_checkPaks;
}

#define EXECUTE_ACTION(step, act) \
	{ \
		DLOG << "Action executed: " #step; \
		emit actionStarted(step); \
		const bool result = act; \
		emit actionCompleted(result); \
		if (!result) \
		{ \
			DLOG << "Action failed: " #step; \
			m_paster.reset(); \
			return; \
		} \
	}

#define EXECUTE_ACTION_IF(flag, step, act) if(flag){ EXECUTE_ACTION(step, act); }

void PasterThread::patch()
{
	m_lock.lockForRead();
	const QString imageFilename = m_imageFilename;
	const QStringList paks = m_pakList;
	const QStringList dataDirs = m_dataDirectories;
	const QString tempDir = m_tempDirectory;
	const bool makeDataCheck = m_checkData;
	const bool makePaksCheck = m_checkPaks;
	m_lock.unlock();

	EXECUTE_ACTION(Init, openImage(imageFilename));
	EXECUTE_ACTION(RebuildPaks, rebuildPaks(paks, dataDirs, tempDir));
	EXECUTE_ACTION_IF(makeDataCheck, CheckData, checkData(paks, dataDirs, tempDir));
	EXECUTE_ACTION(ReplacePaks, replacePaks(paks, tempDir));
	EXECUTE_ACTION_IF(makePaksCheck, CheckPaks, checkPaks(paks, tempDir));
	EXECUTE_ACTION(Done, closeImage());
}
