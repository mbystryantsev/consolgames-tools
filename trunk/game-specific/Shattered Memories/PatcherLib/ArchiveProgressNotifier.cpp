#include "ArchiveProgressNotifier.h"
#include <QCoreApplication>

namespace ShatteredMemories
{

ArchiveProgressNotifier::ArchiveProgressNotifier()
	: ProgressNotifier()
{
}

void ArchiveProgressNotifier::startProgress(int maxValue)
{
	emit progressInit(maxValue);
}

void ArchiveProgressNotifier::progress(int value, const std::string& name)
{
	emit progressChanged(value, QString::fromStdString(name));
}

void ArchiveProgressNotifier::finishProgress()
{
	emit progressFinish();
}

bool ArchiveProgressNotifier::stopRequested()
{
	return ProgressNotifier::stopRequested();
}

}
