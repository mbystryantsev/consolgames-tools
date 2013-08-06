#include "IntroPage.h"
#include "PatchWizard.h"

IntroPage::IntroPage() : Page()
{
#if !defined(PRODUCTION)
	m_ui.introLabel->setText(m_ui.introLabel->text() + QString("\r\n\r\n")
		+ tr("дюммюъ бепяхъ оюрвю опедмюгмювемю рнкэйн дкъ бмсрпеммецн хяонкэгнбюмхъ х реярхпнбюмхъ оепебндю!"));
#endif
}

int IntroPage::nextId() const 
{
	return PatchWizard::PageEula;
}