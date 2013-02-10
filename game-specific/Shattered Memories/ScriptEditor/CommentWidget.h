#pragma once
#include <QStackedWidget>

class HtmlHighlighter;
class QPlainTextEdit;
class QLabel;

class CommentWidget : public QStackedWidget
{
	Q_OBJECT

public:
	CommentWidget(QWidget* parent);
	
	Q_SLOT void setText(const QString& text, quint32 hash);
	Q_SIGNAL void commentChanged(const QString& text, quint32 hash);

protected:
	Q_SLOT void handleLink(const QString& link);
	Q_SLOT void commentEdited();
	Q_SLOT void commentEditCancelled();
	void updateView();
	bool parseAndExecuteCommand(const QString& command);

protected:
	HtmlHighlighter* m_highlighter;
	QPlainTextEdit* m_edit;
	QLabel* m_view;
	quint32 m_hash;
	QString m_text;
	const QString c_htmlTemplate;
};
