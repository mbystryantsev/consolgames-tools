#include "IntroPage.h"
#include "PatchWizard.h"

IntroPage::IntroPage() : Page()
{
#if !defined(PRODUCTION)
	m_ui.introLabel->setText(m_ui.introLabel->text() + QString::fromLocal8Bit("\n\n������ ������ ����� ������������� ������ ��� ����������� ������������� � ������������ ��������!"));
#endif
}

int IntroPage::nextId() const 
{
	return PatchWizard::PageEula;
}