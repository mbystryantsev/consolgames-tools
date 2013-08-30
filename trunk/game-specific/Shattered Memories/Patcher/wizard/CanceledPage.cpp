#include "CanceledPage.h"

CanceledPage::CanceledPage() : Page<Ui_CanceledPage>()
{
	setFinalPage(true);

	m_ui.infoLabel->setText(m_ui.infoLabel->text().replace("{TOPIC_URL}", TOPIC_URL));
}

void CanceledPage::initializePage()
{
	wizard()->setButtonLayout(QList<QWizard::WizardButton>() << QWizard::Stretch << QWizard::FinishButton);
}
