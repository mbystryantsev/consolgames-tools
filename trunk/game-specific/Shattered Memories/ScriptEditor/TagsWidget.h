#pragma once
#include "ui_TagsWidget.h"
#include <QWidget>
#include <QStringList>

class TagsWidget : public QWidget
{
	Q_OBJECT

public:
	TagsWidget(QWidget* parent);

	Q_SLOT void setTags(const QStringList& tags, quint32 hash);

private:
	Q_SIGNAL void tagsChanged(const QStringList&, quint32);
	Q_SLOT void handleLink(const QString& link);
	Q_SLOT void editButtonClicked();
	Q_SLOT void tagsEdited();
	Q_SIGNAL void tagSelected(const QString& tag);

	
	QString tagsToHtml() const;
	QString tagsToPlainText() const;
	QStringList plainTextToTags() const;
	void updateView();
	bool parseAndExecuteCommand(const QString& command);

private:
	QStringList m_tags;
	quint32 m_hash;
	const QString c_htmlTemplate;
	Ui_TagsWidget m_ui;
};
