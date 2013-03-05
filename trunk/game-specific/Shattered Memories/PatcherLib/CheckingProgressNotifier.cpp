#include "CheckingProgressNotifier.h"

namespace ShatteredMemories
{

CheckingProgressNotifier::CheckingProgressNotifier(int size)
	: m_isFirst(true)
	, m_size(size)
{
}

CheckingProgressNotifier::~CheckingProgressNotifier()
{
	emit progressFinish();
}

void CheckingProgressNotifier::progress(int value)
{
	if (m_isFirst)
	{
		emit progressInit(m_size);
		m_isFirst = false;
	}

	emit progressChanged(value, QString());
}

}
