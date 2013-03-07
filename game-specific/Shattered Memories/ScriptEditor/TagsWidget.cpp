#include "TagsWidget.h"
#include "HtmlHighlighter.h"
#include "ui_CommentEdit.h"
#include <QPlainTextEdit>
#include <QLabel>
#include <QPushButton>

static QString loadHtmlTemplate()
{
	QFile file(":/resources/tagsTemplate.html");
	VERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));

	return QString::fromUtf8(file.readAll());
}

enum
{
	indexView,
	indexEdit
};

TagsWidget::TagsWidget(QWidget* parent)
	: QWidget(parent)
	, m_hash(0)
	, c_htmlTemplate(loadHtmlTemplate())
{
	m_ui.setupUi(this);
	VERIFY(connect(m_ui.view, SIGNAL(linkActivated(const QString&)), SLOT(handleLink(const QString&))));
	VERIFY(connect(m_ui.okButton, SIGNAL(pressed()), SLOT(tagsEdited())));
	VERIFY(connect(m_ui.edit, SIGNAL(returnPressed()), SLOT(tagsEdited())));
	VERIFY(connect(m_ui.editButton, SIGNAL(pressed()), SLOT(editButtonClicked())));
	updateView();
}

QString TagsWidget::tagsToHtml() const
{
	if (m_tags.isEmpty())
	{
		return "No tags";
	}

	QString result;
	foreach (const QString& tag, m_tags)
	{
		if (!result.isEmpty())
		{
			result.append(", ");
		}
		result += QString("<a href=\"tag:%1\">%1</a>").arg(tag);
	}

	return result;
}

QString TagsWidget::tagsToPlainText() const
{
	QString result;
	foreach (const QString& tag, m_tags)
	{
		if (!result.isEmpty())
		{
			result.append(", ");
		}
		result += tag;
	}

	return result;
}

QStringList TagsWidget::plainTextToTags() const
{
	QStringList result = m_ui.edit->text().split(',');
	for (int i = 0; i < result.size(); i++)
	{
		result[i] = result[i].trimmed();
	}

	return result;
}

void TagsWidget::updateView()
{
	m_ui.view->setText(QString(c_htmlTemplate).arg(tagsToHtml()));
}

void TagsWidget::handleLink(const QString& link)
{
	DLOG << "Link activated: " << link;
	parseAndExecuteCommand(link);
}

bool TagsWidget::parseAndExecuteCommand(const QString& command)
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

	if (parts.first() == "tag")
	{
		emit tagSelected(parts[1]);
		return true;
	}

	return false;
}

void TagsWidget::editButtonClicked()
{
	m_ui.edit->setText(tagsToPlainText());
	m_ui.stackedWidget->setCurrentIndex(indexEdit);
}

void TagsWidget::tagsEdited()
{
	m_tags = plainTextToTags();
	m_ui.stackedWidget->setCurrentIndex(indexView);
	updateView();
	emit tagsChanged(m_tags, m_hash);
}

void TagsWidget::setTags(const QStringList& tags, quint32 hash)
{
	m_tags = tags;
	m_hash = hash;
	m_ui.stackedWidget->setCurrentIndex(indexView);
	updateView();
}