#include "CommentWidget.h"
#include "HtmlHighlighter.h"
#include "ui_CommentEdit.h"
#include <QPlainTextEdit>
#include <QLabel>
#include <QPushButton>
#include <QDesktopServices>
#include <QUrl>

static QString loadHtmlTemplate()
{
	QFile file(":/resources/commentTemplate.html");
	VERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));

	return QString::fromUtf8(file.readAll());
}

enum
{
	indexEdit,
	indexView
};

CommentWidget::CommentWidget(QWidget* parent)
	: QStackedWidget(parent)
	, m_hash(0)
	, c_htmlTemplate(loadHtmlTemplate())
{
	{
		QWidget* commentEdit = new QWidget(this);
		Ui_CommentEdit ui;
		ui.setupUi(commentEdit);
		m_edit = ui.edit;
		m_highlighter = new HtmlHighlighter(m_edit);
		
		VERIFY(connect(ui.okButton, SIGNAL(pressed()), SLOT(commentEdited())));
		VERIFY(connect(ui.cancelButton, SIGNAL(pressed()), SLOT(commentEditCancelled())));
		insertWidget(indexEdit, commentEdit);
	}

	m_view = new QLabel(this);
	m_view->setTextFormat(Qt::RichText);
	m_view->setWordWrap(true);
	m_view->setAlignment(Qt::AlignLeft | Qt::AlignTop);
	m_view->setMargin(5);
	m_view->setTextInteractionFlags(Qt::TextBrowserInteraction);
	m_view->setStyleSheet("border: 1px solid grey");
	insertWidget(indexView, m_view);

	m_view->setText("<b>HTML</b> is <i>supported</i>.");

	VERIFY(connect(m_view, SIGNAL(linkActivated(const QString&)), SLOT(handleLink(const QString&))));

	setCurrentIndex(indexView);
}

void CommentWidget::updateView()
{
	m_view->setText(QString(c_htmlTemplate).arg(m_text.isEmpty() ? "<i>No comments</i>" : m_text));
}

void CommentWidget::setText(const QString& text, quint32 hash)
{
	setCurrentIndex(indexView);
	m_hash = hash;
	m_text = text;
	updateView();
}

void CommentWidget::handleLink(const QString& link)
{
	DLOG << "Link activated: " << link;
	if (!parseAndExecuteCommand(link))
	{
		QDesktopServices::openUrl(QUrl(link));
	}
}

bool CommentWidget::parseAndExecuteCommand(const QString& command)
{
	if (!command.contains(':'))
	{
		return false;
	}
	
	QStringList parts = command.split(':');
	if (parts.size() != 2)
	{
		return false;
	}

	if (parts.first() == "action")
	{
		if (parts[1] == "edit")
		{
			m_edit->setPlainText(m_text);
			setCurrentIndex(indexEdit);
			return true;
		}
	}

	return false;
}

void CommentWidget::commentEdited()
{
	m_text = m_edit->toPlainText();
	updateView();
	setCurrentIndex(indexView);
	emit commentChanged(m_text, m_hash);
}

void CommentWidget::commentEditCancelled()
{
	setCurrentIndex(indexView);
}