#include "ActionListWidget.h"
#include <core.h>
#include <QLabel>
#include <QGridLayout>

QMap<ActionListWidget::State,QPixmap> ActionListWidget::s_pixmaps;
QStringList ActionListWidget::s_accessibleActions;

ActionListWidget::ActionListWidget(QWidget* parent)
	: QWidget(parent)
	, m_row(0)
{
	if (s_pixmaps.isEmpty())
	{
		s_pixmaps[Wait] = QPixmap(":/clock16.png");
		s_pixmaps[Completed] = QPixmap(":/ok16.png");
		s_pixmaps[Failed] = QPixmap(":/error16.png");
		s_pixmaps[Canceled] = QPixmap(":/cancel16.png");
	}
	if (s_accessibleActions.isEmpty())
	{
		s_accessibleActions
			<< "initialize"
			<< "rebuildPaks"
			<< "checkData"
			<< "replacePaks"
			<< "checkPaks"
			<< "checkImage"
			<< "finalize";
	}

	m_layout = new QGridLayout(this);
}

void ActionListWidget::addAction(const QString& id, const QString& label)
{
	ASSERT(s_accessibleActions.contains(id));

	ActionControls action;
	action.icon = new QLabel(this);
	action.label = new QLabel(label, this);
	m_items[id] = action;

	m_layout->addWidget(action.icon, m_row, 0);
	m_layout->addWidget(action.label, m_row, 1);
	m_row++;

	setActionState(id, Wait);
}

void ActionListWidget::setActionState(const QString& id, State state)
{
	ASSERT(m_items.contains(id));

	ActionControls& controls = m_items[id];
	if (state == Running)
	{
		QMovie* movie = new QMovie(":/loading.gif", QByteArray(), controls.icon);
		controls.icon->setMovie(movie);
		movie->start();
	}
	else
	{
		if (controls.icon->movie() != NULL)
		{
			controls.icon->movie()->stop();
		}
		controls.icon->setPixmap(s_pixmaps[state]);
	}
}
