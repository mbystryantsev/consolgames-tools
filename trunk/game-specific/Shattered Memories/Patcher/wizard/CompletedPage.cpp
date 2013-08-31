#include "CompletedPage.h"
#include "PatchSpec.h"
#include <QDesktopServices>
#include <QUrl>

CompletedPage::CompletedPage() : Page<Ui_CompletedPage>()
{
	setFinalPage(true);

	m_ui.infoLabel->setText(m_ui.infoLabel->text().replace("{TOPIC_URL}", TOPIC_URL));
	m_ui.infoLabel->setText(m_ui.infoLabel->text().replace("{PROJECT_URL}", PROJECT_URL));
}

void CompletedPage::initializePage()
{
	wizard()->setButtonLayout(QList<QWizard::WizardButton>() << QWizard::Stretch << QWizard::FinishButton);
	VERIFY(connect(wizard()->button(QWizard::FinishButton), SIGNAL(clicked()), SLOT(operURLs())));
}

void CompletedPage::operURLs()
{
	if (m_ui.openProjectPage->isChecked())
	{
		QDesktopServices::openUrl(QUrl(PROJECT_URL));
	}
	if (m_ui.openForumThread->isChecked())
	{
		QDesktopServices::openUrl(QUrl(TOPIC_URL));
	}
	if (m_ui.openVKGroup->isChecked())
	{
		QDesktopServices::openUrl(QUrl("http://vk.com/club18909038"));
	}
}