#include "FailedPage.h"
#include "PatchWizard.h"

FailedPage::FailedPage() : Page<Ui_FailedPage>()
{
	setFinalPage(true);
}

void FailedPage::initializePage()
{
	wizard()->setButtonLayout(QList<QWizard::WizardButton>() << QWizard::Stretch << QWizard::FinishButton);

	const PatchWizard* wiz = reinterpret_cast<PatchWizard*>(wizard());
	ASSERT(wiz != NULL);

	const QString errorText = m_ui.errorInfo->text().arg(wiz->errorCode()).arg(wiz->errorData());
	m_ui.errorInfo->setText(errorText);
}
