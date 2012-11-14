#pragma once
#include "Page.h"
#include "ui_CompletedPage.h"

class FreeSpaceChecker;

class CompletedPage : public Page<Ui_CompletedPage>
{
	Q_OBJECT

public:
	CompletedPage();
};