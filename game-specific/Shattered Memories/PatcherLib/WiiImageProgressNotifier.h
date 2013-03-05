#pragma once
#include "ProgressNotifier.h"
#include <WiiImage.h>

namespace ShatteredMemories
{

class WiiImageProgressNotifier : public ProgressNotifier, public Consolgames::WiiImage::IProgressHandler
{
	Q_OBJECT;

public:
	WiiImageProgressNotifier();

	virtual void startProgress(const char* action, int maxValue) override;
	virtual void progress(int value) override;
	virtual void finishProgress() override;
	virtual bool stopRequested() override;
};

}