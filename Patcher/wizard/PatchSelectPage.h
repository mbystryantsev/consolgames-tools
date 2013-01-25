#pragma once
#include "Page.h"
#include "ui_PatchSelectPage.h"

class PatchSelectPage : public Page<Ui_PatchSelectPage>
{
public:
	PatchSelectPage();

	virtual int nextId() const override;
};