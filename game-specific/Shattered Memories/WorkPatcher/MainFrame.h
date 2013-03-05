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
	Q_SLOT void onActionStarted(const QByteArray& action);
	Q_SLOT void onActionCompleted(const QByteArray& action);
	Q_SLOT void onFailed(const QByteArray& action, int errorCode, const QString& errorData);
	Q_SLOT void onCanceled(const QByteArray& action);
	Q_SLOT void onActionProgress(int value, const QString& message);

	Q_SLOT void storeSettings() const;

	Q_SLOT void onProgressInit(int max);
	Q_SLOT void onProgressChanged(int value, const QString& message);
	Q_SLOT void onProgressFinish();

	virtual void closeEvent(QCloseEvent* event) override;

	void reset();

	void loadSettings();

protected:
	Ui_MainFrame m_ui;
	ShatteredMemories::PatcherController m_patcher;
	QByteArray m_currentAction;
	bool m_settingsIsActive;
	QList<QByteArray> m_actions;
};
