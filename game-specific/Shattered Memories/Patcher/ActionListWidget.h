#pragma once
#include <QHash>
#include <QMap>
#include <QWidget>
#include <QMovie>

class QBoxLayout;
class QLabel;
class QGridLayout;

class ActionListWidget : public QWidget
{
public:
	enum State
	{
		Wait,
		Running,
		Completed,
		Failed,
		Canceled
	};

public:
	ActionListWidget(QWidget* parent = NULL);

	Q_SLOT void addAction(const QString& id, const QString& label);
	Q_SLOT void setActionState(const QString& id, State state);

private:
	struct ActionControls
	{
		QLabel* icon;
		QLabel* label;
	};

private:
	QHash<QString,ActionControls> m_items;
	QGridLayout* m_layout;
	int m_row;
	
	static QMap<State,QPixmap> s_pixmaps;
	static QStringList s_accessibleActions;
};
