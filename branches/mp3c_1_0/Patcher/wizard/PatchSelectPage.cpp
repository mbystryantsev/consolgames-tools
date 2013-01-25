#include "PatchSelectPage.h"
#include "PatchWizard.h"

PatchSelectPage::PatchSelectPage() : Page<Ui_PatchSelectPage>()
{
}

int PatchSelectPage::nextId() const 
{
	if (m_ui.imagePatch->isChecked())
	{
		return PatchWizard::PageImagePatch;
	}
	return PatchWizard::PageRiivolutionPatch;
}
