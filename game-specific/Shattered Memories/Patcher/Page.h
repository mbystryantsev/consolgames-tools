#pragma once
#include <QWizardPage>

template <typename PageUI>
class Page : public QWizardPage
{
public:
	Page(QWidget* parent = NULL) : QWizardPage(parent)
	{
		m_ui.setupUi(this);
	}
	virtual ~Page()
	{
	}

protected:
	PageUI m_ui;
};
