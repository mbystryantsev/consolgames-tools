#pragma once
#include <QFrame>
#include "ui_PatcherDialog.h"

class PatcherDialog : public QFrame
{
	Q_OBJECT
public:
	PatcherDialog();

protected:
	Ui_PatcherDialog m_ui;
};
