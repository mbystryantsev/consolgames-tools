#pragma once
#include "Page.h"
#include "ui_IntroPage.h"

class IntroPage : public Page<Ui_IntroPage>
{
public:
	IntroPage();
	virtual int nextId() const override;
};
