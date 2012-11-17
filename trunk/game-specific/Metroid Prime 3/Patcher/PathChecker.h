#pragma once
#include <QTimer>

class QLineEdit;

class PathChecker : public QObject
{
	Q_OBJECT

public:
	PathChecker(QLineEdit* pathEdit, QObject* parent = NULL);

	Q_SIGNAL void errorReset();
	virtual bool hasError() const;

protected:
	Q_SLOT virtual void onPathEdited();
	Q_SLOT virtual void onPathChanged() = 0;
	Q_SLOT virtual void setError();
	Q_SLOT virtual void resetError();

protected:
	QLineEdit* m_edit;
	QTimer m_timer;
	bool m_hasError;
};
