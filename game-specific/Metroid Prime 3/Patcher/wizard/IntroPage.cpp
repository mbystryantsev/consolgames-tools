#include "IntroPage.h"
#include "PatchWizard.h"

IntroPage::IntroPage() : Page()
{
}

int IntroPage::nextId() const 
{
	return PatchWizard::PageEula;
}