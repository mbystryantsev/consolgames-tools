#include "FailedPage.h"
#include "PatchSpec.h"
#include "Configurator.h"
#include <QDesktopServices>
#include <QUrl>

FailedPage::FailedPage() : Page<Ui_FailedPage>()
{
	setFinalPage(true);

	m_ui.infoLabel->setText(m_ui.infoLabel->text().replace("{TOPIC_URL}", TOPIC_URL));
}

static QString wrapped(const QString& str, const QFont& font, int width)
{
	const QString wrap = "<br/>";
	const QFontMetrics metrics(font);
	const int totalWidth = metrics.width(str);

	QString res;
	res.reserve(totalWidth + totalWidth / wrap.length());

	int lineWidth = 0;
	const QChar* c = str.begin();
	while (c != str.end())
	{
		const int charWidth = metrics.width(*c);
		if (lineWidth + charWidth > width)
		{
			lineWidth = 0;
			res.append(wrap);
		}
		lineWidth += charWidth;
		res.append(*c);
		c++;
	}
	return res;
}

void FailedPage::initializePage()
{
	wizard()->setButtonLayout(QList<QWizard::WizardButton>() << QWizard::Stretch << QWizard::FinishButton);

	const Configurator& configurator = Configurator::instanse();

	const QString errorText = m_ui.errorInfo->text().arg(configurator.errorCode()).arg(wrapped(configurator.errorData(), m_ui.errorInfo->font(), 230));
	m_ui.errorInfo->setText(errorText);

	VERIFY(connect(wizard()->button(QWizard::FinishButton), SIGNAL(clicked()), SLOT(openForumThread())));
}

void FailedPage::openForumThread()
{
	if (m_ui.openThread->isChecked())
	{
		QDesktopServices::openUrl(QUrl(TOPIC_URL));
	}
}