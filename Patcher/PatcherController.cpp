#include "PatcherController.h"
#include <QDir>

LOG_CATEGORY("PatcherController");

PatcherController::PatcherController(QObject* parent)
	: QObject(parent)
	, m_workerPtr(new PatcherWorker())
	, m_worker(m_workerPtr.get())
	, m_errorCode(0)
	, m_stopRequested(false)
{
	addResourcesPath(":/patchdata/");

	m_progressHandler.subscribe(m_worker);
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

bool PatcherController::processStep()
{
	ASSERT(m_workerThread.isRunning());
	if (m_steps.isEmpty())
	{
		return false;
	}

	m_currentStep = m_steps.takeFirst();
	m_progressHandler.setCurrentAction(QString::fromLatin1(m_currentStep));
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

void PatcherController::onStepFailed(int errorCode, const QString& errorData, const QString& errorMessage, const QString& errorDescription)
{
	if (m_stopRequested)
	{
		processCancel();
		return;
	}

	DLOG << "Step failed: " << m_currentStep;
	finish();
	emit failed(m_currentStep, errorCode, errorData, errorMessage, errorDescription);
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
	ASSERT(!m_workerThread.isRunning());
	ASSERT(!m_steps.isEmpty());

	m_worker->moveToThread(&m_workerThread);
	m_workerPtr.release();
	VERIFY(connect(m_worker, SIGNAL(stepCompleted()), SLOT(onStepCompleted()), Qt::QueuedConnection));
	VERIFY(connect(m_worker, SIGNAL(stepFailed(int, const QString&, const QString&, const QString&)), SLOT(onStepFailed(int, const QString&, const QString&, const QString&)), Qt::QueuedConnection));
	m_workerThread.start();
	processStep();
}

void PatcherController::finish()
{
	ASSERT(m_workerThread.isRunning());
	VERIFY(connect(m_worker, SIGNAL(destroyed()), &m_workerThread, SLOT(quit())));
	QMetaObject::invokeMethod(m_worker, "deleteLater");
}

QObject* PatcherController::progressHandler()
{
	return &m_progressHandler;
}
