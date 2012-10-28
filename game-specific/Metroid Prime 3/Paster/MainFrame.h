#pragma once
#include "PasterThread.h"
#include "ui_main.h"
#include <QFrame>
#include <QFileDialog>

class MainFrame : public QFrame
{
	Q_OBJECT;

public:
	MainFrame();

	void addPak(const QString& name, const QString& description, bool checked);
	QStringList selectedPaks() const;

protected:
	Q_SIGNAL void aboutToClosing();

	Q_SLOT void onStartPressed();
	Q_SLOT void onImageSelectPressed();
	Q_SLOT void onDataPathSelectPressed();
	Q_SLOT void onTempPathSelectPressed();

	Q_SLOT void setProgressSize(int size);
	Q_SLOT void setProgressValue(int index, const char* message);
	Q_SLOT void onActionStarted(int action);
	Q_SLOT void onActionCompleted(bool success);

	Q_SLOT void storeSettings() const;

	virtual void closeEvent(QCloseEvent* event) override;

	void loadSettings();

protected:
	Ui_MainFrame m_ui;
	PasterThread m_paster;
	PasterThread::Action m_step;
	int m_currentAction;
	bool m_settingsIsActive;
};
