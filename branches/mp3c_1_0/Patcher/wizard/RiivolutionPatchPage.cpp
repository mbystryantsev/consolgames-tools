#include "RiivolutionPatchPage.h"
#include "PatchWizard.h"

RiivolutionPatchPage::RiivolutionPatchPage() : Page<Ui_RiivolutionPatchPage>()
{
	setCommitPage(true);
}

int RiivolutionPatchPage::nextId() const 
{
	return PatchWizard::PageProgress;
}

void RiivolutionPatchPage::initializePage()
{
}

bool RiivolutionPatchPage::validatePage()
{
	return true;
}
