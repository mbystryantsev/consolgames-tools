#include "EulaPage.h"
#include "PatchWizard.h"
#include <QFile>
#include <QTextStream>

EulaPage::EulaPage() : Page<Ui_EulaPage>()
{
	VERIFY(connect(m_ui.eulaAccept, SIGNAL(stateChanged(int)), SIGNAL(completeChanged())));

	QFile eulaFile(":/eula.txt");
	eulaFile.open(QIODevice::ReadOnly);
	m_ui.eulaContent->setHtml(QTextStream(&eulaFile).readAll());
}

int EulaPage::nextId() const 
{
	return PatchWizard::PageImagePatch;
}

bool EulaPage::isComplete() const 
{
	return m_ui.eulaAccept->isChecked();
}
