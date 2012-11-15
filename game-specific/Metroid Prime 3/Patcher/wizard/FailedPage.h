#pragma once
#include "Page.h"
#include "ui_FailedPage.h"

class FreeSpaceChecker;

class FailedPage : public Page<Ui_FailedPage>
{
	Q_OBJECT

public:
	FailedPage();

	virtual void initializePage() override;
	Q_SLOT void openForumThread();
};