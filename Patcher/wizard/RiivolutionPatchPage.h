#pragma once
#include "Page.h"
#include "ui_RiivolutionPatchPage.h"

class FreeSpaceChecker;
class ImageFileChecker;

class RiivolutionPatchPage : public Page<Ui_RiivolutionPatchPage>
{
	Q_OBJECT

public:
	RiivolutionPatchPage();

	virtual int nextId() const override;
	virtual void initializePage() override;
	virtual bool validatePage() override;
};