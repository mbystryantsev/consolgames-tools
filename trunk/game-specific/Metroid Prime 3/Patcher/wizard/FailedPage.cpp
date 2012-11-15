#include "FailedPage.h"
#include "PatchWizard.h"
#include <QDesktopServices>
#include <QUrl>

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

	VERIFY(connect(wizard()->button(QWizard::FinishButton), SIGNAL(clicked()), SLOT(openForumThread())));
}

void FailedPage::openForumThread()
{
	if (m_ui.openThread->isChecked())
	{
		QDesktopServices::openUrl(QUrl("http://consolgames.ru/forum/"));
	}
}