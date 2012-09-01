#include "ScriptHighlighter.h"
#include <QPlainTextEdit>

const QRegExp ScriptHighlighter::s_tagExpression = QRegExp("&[^;]*;");

ScriptHighlighter::ScriptHighlighter(QPlainTextEdit* parent) : QSyntaxHighlighter(parent->document())
{
	m_tagFormat.setForeground(QBrush(Qt::gray));
}

void ScriptHighlighter::setPattern(const QString& pattern)
{
	m_pattern = pattern;
	rehighlight();
}

void ScriptHighlighter::highlightBlock(const QString& text)
{
	QRegExp expression(s_tagExpression);
	
	int index = expression.indexIn(text);
	while (index >= 0)
	{
		const int length = expression.matchedLength();
		setFormat(index, length, m_tagFormat);
		index = expression.indexIn(text, index + length);
	}

	highlightPattern(text);
}

void ScriptHighlighter::highlightPattern(const QString& text)
{
	if (m_pattern.isEmpty())
	{
		return;
	}

	int index = text.indexOf(m_pattern, 0, Qt::CaseInsensitive);
	while (index >= 0)
	{
		QTextCharFormat currentFormat = format(index);
		currentFormat.setBackground(QBrush(Qt::yellow));
		setFormat(index, m_pattern.length(), currentFormat);
		index = text.indexOf(m_pattern, index + m_pattern.length(), Qt::CaseInsensitive);
	}
}
