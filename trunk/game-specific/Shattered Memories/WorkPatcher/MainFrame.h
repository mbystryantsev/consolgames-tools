#pragma once
#include "ui_main.h"
#include <PatcherController.h>
#include <QFrame>
#include <QFileDialog>

class MainFrame : public QFrame
{
	Q_OBJECT;

public:
	MainFrame();

protected:
	Q_SIGNAL void aboutToClosing();

	Q_SLOT void onStartPressed();
	Q_SLOT void onImageSelectPressed();
	Q_SLOT void onDataPathSelectPressed();
	Q_SLOT void onTempPathSelectPressed();

	Q_SLOT void setProgressSize(int size);
	Q_SLOT void setProgressValue(int index, const QString&);
	Q_SLOT void setMessage(const QString&);
	Q_SLOT void onActionStarted(int action);
	Q_SLOT void onActionCompleted(bool success);
	Q_SLOT void onActionProgress(int value, const QString& message);

	Q_SLOT void storeSettings() const;

	virtual void closeEvent(QCloseEvent* event) override;

	void reset();

	void loadSettings();

protected:
	Ui_MainFrame m_ui;
	ShatteredMemories::PatcherController m_patcher;
	QByteArray m_currentAction;
	bool m_settingsIsActive;
	bool m_isPatching;
};
