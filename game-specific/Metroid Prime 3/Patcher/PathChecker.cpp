#include "PathChecker.h"
#include <QLineEdit>

PathChecker::PathChecker(QLineEdit* pathEdit, QObject* parent)
	: QObject(parent)
	, m_edit(pathEdit)
{
	VERIFY(connect(m_edit, SIGNAL(editingFinished()), SLOT(onPathChanged())));
	VERIFY(connect(m_edit, SIGNAL(textChanged(const QString&)), SLOT(onPathEdited())));
	VERIFY(connect(&m_timer, SIGNAL(timeout()), SLOT(onPathChanged()), Qt::QueuedConnection));
	m_timer.setInterval(500);
	m_timer.setSingleShot(true);
}

void PathChecker::onPathEdited()
{
	m_timer.start();
}

void PathChecker::setError()
{

	m_edit->setStyleSheet("QLineEdit { background-color: #FCC;}");
}

void PathChecker::resetError()
{
	m_edit->setStyleSheet("");
	emit errorReset();
}