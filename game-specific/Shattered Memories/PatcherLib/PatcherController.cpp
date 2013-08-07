#include "PatcherController.h"
#include <QDir>
#include <QMetaEnum>

LOG_CATEGORY("PatcherController");

namespace ShatteredMemories
{

PatcherController::PatcherController(QObject* parent)
	: QObject(parent)
	, m_started(false)
	, m_worker(NULL)
	, m_errorCode(0)
	, m_stopRequested(false)
	, m_checkArchivesData(false)
	, m_checkArchivesInImage(false)
	, m_checkImage(false)
{
//	addResourcesPath(":/patchdata/");
	reset();
	//m_progressHandler.subscribe(m_worker);
}

void PatcherController::buildActionList()
{
	m_steps.clear();
	addStep("initialize");
	addStep("rebuildArchives");
	addStep("replaceArchives");
	if (m_checkArchivesInImage)
	{
		addStep("checkArchives");
	}
	if (m_checkImage)
	{
		addStep("checkImage");
	}
	addStep("finalize");
}

QList<QByteArray> PatcherController::actionList()
{
	if (!m_started)
	{
		buildActionList();
	}
	return m_steps;
}

bool PatcherController::runStep(const QByteArray& step)
{
	ASSERT(m_workerThread.isRunning());
	return QMetaObject::invokeMethod(m_worker, step.constData());
}

void PatcherController::addStep(const QByteArray& step)
{
	ASSERT(!m_steps.contains(step));
	ASSERT(!m_workerThread.isRunning());
	m_steps << step;
}

void PatcherController::reset()
{
	m_workerPtr.reset(new PatcherWorker());
	m_worker = m_workerPtr.get();
	ASSERT(!m_workerThread.isRunning());
	VERIFY(QMetaObject::invokeMethod(m_worker, "reset"));
}

void PatcherController::setImagePath(const QString& path)
{
	ASSERT(!m_workerThread.isRunning());
	VERIFY(QMetaObject::invokeMethod(m_worker, "setImagePath", Q_ARG(const QString&, path)));
}

void PatcherController::addResourcesPath(const QString& path)
{
	ASSERT(!m_workerThread.isRunning());
	ASSERT(QDir(path).exists());
	VERIFY(QMetaObject::invokeMethod(m_worker, "addResourcesPath", Q_ARG(const QString&, path)));
}

void PatcherController::setTempPath(const QString& path)
{
	ASSERT(!m_workerThread.isRunning());
	VERIFY(QMetaObject::invokeMethod(m_worker, "setTempPath", Q_ARG(const QString&, path)));
}

void PatcherController::setExecutableInfo(const QString& executableName, quint32 bootArcOffset, quint32 headersOffset)
{
	ASSERT(!m_workerThread.isRunning());
	VERIFY(QMetaObject::invokeMethod(m_worker, "setExecutableInfo", Q_ARG(const QString&, executableName), Q_ARG(quint32, bootArcOffset), Q_ARG(quint32, headersOffset)));
}

void PatcherController::setCheckArchives(bool check)
{
	m_checkArchivesInImage = check;
}

void PatcherController::setCheckImage(bool check)
{
	m_checkImage = check;
}

bool PatcherController::processStep()
{
	ASSERT(m_workerThread.isRunning());
	if (m_steps.isEmpty())
	{
		return false;
	}

	m_currentStep = m_steps.takeFirst();
	//m_progressHandler.setCurrentAction(QString::fromLatin1(m_currentStep));
	DLOG << "Step started: " << m_currentStep;
	emit stepStarted(m_currentStep);
	VERIFY(QMetaObject::invokeMethod(m_worker, m_currentStep));
	return true;
}

void PatcherController::processCancel()
{
	VERIFY(QMetaObject::invokeMethod(m_worker, "finalizeInternal"));
	emit canceled(m_currentStep);
	finish();
}

void PatcherController::onStepCompleted()
{
	if (m_stopRequested)
	{
		processCancel();
		return;
	}

	DLOG << "Step completed: " << m_currentStep;
	emit stepCompleted(m_currentStep);
	if (!processStep())
	{
		finish();
		emit completed();
	}
}

void PatcherController::onStepFailed(int errorCode, const QString& errorData)
{
	if (m_stopRequested)
	{
		processCancel();
		return;
	}

	DLOG << "Step failed: " << m_currentStep;
	finish();
	emit failed(m_currentStep, errorCode, errorData);
}

void PatcherController::requestStop()
{
	if (!m_stopRequested)
	{
		VERIFY(QMetaObject::invokeMethod(m_worker, "requestStop"));
		m_stopRequested = true;
	}
}

int PatcherController::errorCode() const
{
	return m_errorCode;
}

QString PatcherController::errorData() const
{
	return m_errorData;
}

QString PatcherController::errorMessage() const
{
	return m_errorMessage;
}

QString PatcherController::errorDescription() const
{
	return m_errorDescription;
}

void PatcherController::waitForWorker()
{
	m_workerThread.wait(5000);
}

void PatcherController::start()
{
	if (m_workerThread.isRunning())
	{
		m_workerThread.wait(2000);
	}

	ASSERT(!m_workerThread.isRunning());
	ASSERT(!m_started);

	m_started = true;

	buildActionList();

	m_worker->moveToThread(&m_workerThread);
	m_workerPtr.release();

	VERIFY(connect(m_worker, SIGNAL(stepCompleted()), SLOT(onStepCompleted()), Qt::QueuedConnection));
	VERIFY(connect(m_worker, SIGNAL(stepFailed(int, const QString&)), SLOT(onStepFailed(int, const QString&)), Qt::QueuedConnection));
	VERIFY(connect(m_worker, SIGNAL(progressInit(int)), SIGNAL(progressInit(int)), Qt::QueuedConnection));
	VERIFY(connect(m_worker, SIGNAL(progressChanged(int, const QString&)), SIGNAL(progressChanged(int, const QString&)), Qt::QueuedConnection));
	VERIFY(connect(m_worker, SIGNAL(progressFinish()), SIGNAL(progressFinish()), Qt::QueuedConnection));

	m_stopRequested = false;

	m_workerThread.start();
	processStep();
}

void PatcherController::finish()
{
	ASSERT(m_workerThread.isRunning());
	VERIFY(connect(m_worker, SIGNAL(destroyed()), &m_workerThread, SLOT(quit())));
	QMetaObject::invokeMethod(m_worker, "deleteLater");

	m_started = false;
}

bool PatcherController::isStarted() const
{
	return m_started;
}

bool PatcherController::isStopRequested() const
{
	return m_stopRequested;
}

QString PatcherController::errorName(int code)
{
	const int index = PatcherProcessor::staticMetaObject.indexOfEnumerator("ErrorCode");
	ASSERT(index >= 0);
	if (index < 0)
	{
		return QString();
	}

	const QMetaEnum metaEnum = PatcherProcessor::staticMetaObject.enumerator(index);
	return metaEnum.valueToKey(code);
}

}
