#include "IntroPage.h"
#include "PatchWizard.h"

IntroPage::IntroPage() : Page()
{
#if !defined(PRODUCTION)
	m_ui.introLabel->setText(m_ui.introLabel->text() + QString::fromLocal8Bit("\n\nдюммюъ бепяхъ оюрвю опедмюгмювемю рнкэйн дкъ бмсрпеммецн хяонкэгнбюмхъ х реярхпнбюмхъ оепебндю!"));
#endif
}

int IntroPage::nextId() const 
{
	return PatchWizard::PageEula;
}