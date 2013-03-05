#include "CompoundProgressNotifier.h"

LOG_CATEGORY("PatcherLib.CompoundProgressNotifier");

namespace ShatteredMemories
{

const int CompoundProgressNotifier::s_progressSize = 10000;

CompoundProgressNotifier::CompoundProgressNotifier()
	: ProgressNotifier()
	, m_currentCoeff(0)
	, m_processedCoeffSum(0)
	, m_currentMax(0)
	, m_currentNotifier(NULL)
	, m_progressFinished(true)
{
}

CompoundProgressNotifier::~CompoundProgressNotifier()
{
	checkForForceEnd();
}

void CompoundProgressNotifier::reset()
{
	m_currentCoeff = 0;
	m_processedCoeffSum = 0;
	m_currentMax = 0;
	m_currentNotifier = NULL;
	m_progressFinished = true;
}

void CompoundProgressNotifier::requestStop()
{
	ProgressNotifier::requestStop();
	if (m_currentNotifier != NULL)
	{
		VERIFY(QMetaObject::invokeMethod(m_currentNotifier, "requestStop"));
	}
}

void CompoundProgressNotifier::setCurrentNotifier(QObject* notifier, double coeff)
{
	m_processedCoeffSum += m_currentCoeff;
	m_currentCoeff = coeff;
	m_currentNotifier = notifier;

	VERIFY(connect(notifier, SIGNAL(progressInit(int)), SLOT(onProgressInit(int)), Qt::DirectConnection));
	VERIFY(connect(notifier, SIGNAL(progressChanged(int, const QString&)), SLOT(onProgressChanged(int, const QString&)), Qt::DirectConnection));
	VERIFY(connect(notifier, SIGNAL(progressFinish()), SLOT(onProgressFinished()), Qt::DirectConnection));

	if (stopRequested())
	{
		VERIFY(QMetaObject::invokeMethod(m_currentNotifier, "requestStop"));
	}
}

void CompoundProgressNotifier::onProgressInit(int maxValue)
{
	m_currentMax = maxValue;
	m_progressFinished = false;

	if (m_processedCoeffSum == 0)
	{
		emit progressInit(s_progressSize);
	}
}

void CompoundProgressNotifier::onProgressChanged(int value, const QString& message)
{
	const int floor = static_cast<double>(s_progressSize) * m_processedCoeffSum;
	const double range = static_cast<double>(s_progressSize) * (m_currentCoeff == 0 ? 1.0 - m_processedCoeffSum : m_currentCoeff);
	const double ratio = static_cast<double>(range) / static_cast<double>(m_currentMax);
	const int progress = floor + static_cast<double>(value) * ratio;

	emit progressChanged(progress, message);
}

void CompoundProgressNotifier::onProgressFinished()
{
	VERIFY(m_currentNotifier->disconnect(this));

	if (m_currentCoeff == 0)
	{
		m_progressFinished = true;
		emit progressFinish();
	}
}

void CompoundProgressNotifier::checkForForceEnd()
{
	if (!m_progressFinished)
	{
		DLOG << "WARNING! Forced progress finish!";
		emit progressFinish();
	}
}

CompoundProgressNotifier::ProgressGuard::ProgressGuard(CompoundProgressNotifier& notifier)
	: m_notifier(notifier)
{
	m_notifier.reset();
}

CompoundProgressNotifier::ProgressGuard::~ProgressGuard()
{
	m_notifier.checkForForceEnd();
}

}
