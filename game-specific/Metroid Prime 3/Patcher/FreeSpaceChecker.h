#pragma once
#include <QTimer>

class QLineEdit;

class FreeSpaceChecker : public QObject
{
	Q_OBJECT

public:
	FreeSpaceChecker(QLineEdit* pathEdit);
	Q_SLOT void check();

public:
	Q_SIGNAL void pathError();
	Q_SIGNAL void freeSpaceError(quint64);
	Q_SIGNAL void errorReset();

private:
	Q_SLOT void onPathEdited();
	Q_SLOT void onPathChanged();
	Q_SLOT void setError();
	Q_SLOT void resetError();

private:
	QLineEdit* m_edit;
	QTimer m_timer;
};
