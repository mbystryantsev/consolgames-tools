#pragma once
#include "Page.h"
#include "ui_CanceledPage.h"


class CanceledPage : public Page<Ui_CanceledPage>
{
	Q_OBJECT

public:
	CanceledPage();
	virtual void initializePage();
};