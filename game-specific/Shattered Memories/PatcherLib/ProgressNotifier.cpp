#include "ProgressNotifier.h"
#include <QCoreApplication>
#include <core.h>

namespace ShatteredMemories
{

ProgressNotifier::ProgressNotifier()
	: m_stopRequested(false)
{
	VERIFY(connect(this, SIGNAL(progressInit(int)), SLOT(onProgressInit())));
}

void ProgressNotifier::requestStop()
{
	m_stopRequested = true;
}

bool ProgressNotifier::stopRequested()
{
	if (m_timer.elapsed() >= 300)
	{
		m_timer.restart();
		QCoreApplication::processEvents();
	}

	return m_stopRequested;
}

void ProgressNotifier::onProgressInit()
{
	m_timer.start();
}

}