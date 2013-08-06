#include "CanceledPage.h"

CanceledPage::CanceledPage() : Page<Ui_CanceledPage>()
{
	setFinalPage(true);
}

void CanceledPage::initializePage()
{
	wizard()->setButtonLayout(QList<QWizard::WizardButton>() << QWizard::Stretch << QWizard::FinishButton);
}
