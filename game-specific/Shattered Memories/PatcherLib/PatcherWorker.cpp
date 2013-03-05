#include "PatcherWorker.h"

namespace ShatteredMemories
{

#define CHECK_CALL(c) \
	if (!c) \
	{ \
		return processError(); \
	} \


PatcherWorker::PatcherWorker(QObject* parent)
	: QObject(parent)
{
	VERIFY(connect(m_patcher.progressNotifier(), SIGNAL(progressInit(int)), SIGNAL(progressInit(int)), Qt::DirectConnection));
	VERIFY(connect(m_patcher.progressNotifier(), SIGNAL(progressChanged(int, const QString&)), SIGNAL(progressChanged(int, const QString&)), Qt::DirectConnection));
	VERIFY(connect(m_patcher.progressNotifier(), SIGNAL(progressFinish()), SIGNAL(progressFinish()), Qt::DirectConnection));
}

void PatcherWorker::reset()
{
	m_resourcesPaths.clear();
}

void PatcherWorker::requestStop()
{
	VERIFY(QMetaObject::invokeMethod(m_patcher.progressNotifier(), "requestStop"));
}

void PatcherWorker::initialize()
{
	CHECK_CALL(m_patcher.openImage(m_imagePath));
	emit stepCompleted();
}

void PatcherWorker::rebuildArchives()
{
	CHECK_CALL(m_patcher.rebuildArchives(m_tempPath, m_resourcesPaths, m_executableInfo));
	emit stepCompleted();
}

void PatcherWorker::replaceArchives()
{
	CHECK_CALL(m_patcher.replaceArchives(m_tempPath, m_executableInfo));
	emit stepCompleted();
}

void PatcherWorker::checkArchives()
{
	CHECK_CALL(m_patcher.checkArchives(m_tempPath, m_executableInfo));
	emit stepCompleted();
}

void PatcherWorker::checkImage()
{
	CHECK_CALL(m_patcher.checkImage());
	emit stepCompleted();
}

void PatcherWorker::finalize()
{
	finalizeInternal();
	emit stepCompleted();
}

void PatcherWorker::finalizeInternal()
{
}

void PatcherWorker::processError()
{
	emit stepFailed(m_patcher.errorCode(), m_patcher.errorData());
}

void PatcherWorker::setImagePath(const QString& imagePath)
{
	m_imagePath = imagePath;
}

void PatcherWorker::setTempPath(const QString& tempPath)
{
	m_tempPath = tempPath;
}

void PatcherWorker::addResourcesPath(const QString& path)
{
	m_resourcesPaths.append(path);
}

void PatcherWorker::setExecutableInfo(const QString& executableName, quint32 bootArcOffset, quint32 headersOffset)
{
	m_executableInfo.executablePath = executableName;
	m_executableInfo.bootArcOffset = bootArcOffset;
	m_executableInfo.headersOffset = headersOffset;
}

}