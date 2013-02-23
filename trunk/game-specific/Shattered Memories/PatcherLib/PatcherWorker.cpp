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
}

void PatcherWorker::reset()
{
	m_resourcesPaths.clear();
}

void PatcherWorker::initialize()
{
	CHECK_CALL(m_patcher.openImage(m_imagePath));
	emit stepCompleted();
}

void PatcherWorker::rebuildArchives()
{
	CHECK_CALL(m_patcher.rebuildArchives(m_tempPath, m_bootArcInfo));
	emit stepCompleted();
}

void PatcherWorker::replaceArchives()
{
	emit stepCompleted();
}

void PatcherWorker::finalize()
{
	emit stepCompleted();
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

void PatcherWorker::setBootArcInfo(const QString& executableName, quint32 offset, quint32 maxSize, quint32 actualSizeValueOffset)
{
	m_bootArcInfo.executableName = executableName;
	m_bootArcInfo.offset = offset;
	m_bootArcInfo.size = maxSize;
	m_bootArcInfo.sizeOffset = actualSizeValueOffset;
}

}