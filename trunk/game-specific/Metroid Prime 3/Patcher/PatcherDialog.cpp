#include "PatcherDialog.h"

PatcherDialog::PatcherDialog()
{
	setWindowIcon(QIcon(":/SamusHelmet.png"));
	m_ui.setupUi(this);
	m_ui.progressBar->start();
}