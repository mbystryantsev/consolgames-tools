#include "IntroPage.h"
#include "PatchWizard.h"
#include "PatchSpec.h"

IntroPage::IntroPage() : Page()
{
#if !defined(PRODUCTION)
	m_ui.introLabel->setText(m_ui.introLabel->text() + QString("\r\n\r\n")
		+ tr("ÄÀÍÍÀß ÂÅÐÑÈß ÏÀÒ×À ÏÐÅÄÍÀÇÍÀ×ÅÍÀ ÒÎËÜÊÎ ÄËß ÂÍÓÒÐÅÍÍÅÃÎ ÈÑÏÎËÜÇÎÂÀÍÈß È ÒÅÑÒÈÐÎÂÀÍÈß ÏÅÐÅÂÎÄÀ!"));
#endif

	setTitle(title().replace("{GAME_TITLE}", GAME_TITLE));
	setWindowTitle(windowTitle().replace("{GAME_TITLE}", GAME_TITLE));
	m_ui.introLabel->setText(m_ui.introLabel->text().replace("{GAME_TITLE}", GAME_TITLE));
}

int IntroPage::nextId() const 
{
	return PatchWizard::PageEula;
}