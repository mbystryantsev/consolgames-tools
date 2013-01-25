#pragma once
#include "Page.h"
#include "ui_EulaPage.h"

class EulaPage : public Page<Ui_EulaPage>
{
public:
	EulaPage();

	virtual int nextId() const override;
	virtual bool isComplete() const override;
};