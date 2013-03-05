#pragma once
#include "ProgressNotifier.h"
#include <Archive.h>

namespace ShatteredMemories
{

class ArchiveProgressNotifier : public ProgressNotifier, public ShatteredMemories::Archive::IProgressListener
{
	Q_OBJECT;

public:
	ArchiveProgressNotifier();

	virtual void startProgress(int maxValue) override;
	virtual void progress(int value, const std::string& name) override;
	virtual void finishProgress() override;
	virtual bool stopRequested() override;
};

}