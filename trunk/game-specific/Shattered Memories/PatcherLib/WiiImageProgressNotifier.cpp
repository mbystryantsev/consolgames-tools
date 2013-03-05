#include "WiiImageProgressNotifier.h"

namespace ShatteredMemories
{

WiiImageProgressNotifier::WiiImageProgressNotifier()
	: ProgressNotifier()
{
}

void WiiImageProgressNotifier::startProgress(const char*, int maxValue)
{
	emit progressInit(maxValue);
}

void WiiImageProgressNotifier::progress(int value)
{
	emit progressChanged(value, QString());
}

void WiiImageProgressNotifier::finishProgress()
{
	emit progressFinish();
}

bool WiiImageProgressNotifier::stopRequested()
{
	return ProgressNotifier::stopRequested();
}


}
