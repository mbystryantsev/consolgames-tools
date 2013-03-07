#include "ScriptHighlighter.h"
#include <QPlainTextEdit>

//const QRegExp ScriptHighlighter::s_tagExpression = QRegExp("&[^;]*;");
const QRegExp ScriptHighlighter::s_tagExpression = QRegExp("<.(=\\d)?>");
const QRegExp ScriptHighlighter::s_refExpression = QRegExp("\\{REF:[0-9a-zA-Z]{8}\\}");

ScriptHighlighter::ScriptHighlighter(QPlainTextEdit* parent)
	: QSyntaxHighlighter(parent->document())
	, m_caseSensitivity(Qt::CaseInsensitive)
{
	m_tagFormat.setForeground(QBrush(Qt::gray));
	m_refFormat.setBackground(QBrush(QColor("#FAF")));
	m_refFormat.setFontWeight(QFont::DemiBold);
}

void ScriptHighlighter::setPattern(const QString& pattern)
{
	m_pattern = pattern;

	m_caseSensitivity = Qt::CaseInsensitive;
	if (m_pattern.startsWith('!'))
	{
		m_caseSensitivity = Qt::CaseSensitive;
		m_pattern = m_pattern.right(m_pattern.size() - 1);
	}
	if (m_pattern.startsWith('^'))
	{
		m_pattern = m_pattern.right(m_pattern.size() - 1);
	}
	if (m_pattern.endsWith('$'))
	{
		m_pattern.truncate(m_pattern.size() - 1);
	}

	rehighlight();
}

void ScriptHighlighter::highlightExpression(const QString& text, const QRegExp& regExp, const QTextCharFormat& format)
{
	QRegExp expression(regExp);

	int index = expression.indexIn(text);
	while (index >= 0)
	{
		const int length = expression.matchedLength();
		setFormat(index, length, format);
		index = expression.indexIn(text, index + length);
	}
}

void ScriptHighlighter::highlightBlock(const QString& text)
{
	highlightExpression(text, s_tagExpression, m_tagFormat);
	highlightExpression(text, s_refExpression, m_refFormat);

	highlightPattern(text);
}

void ScriptHighlighter::highlightPattern(const QString& text)
{
	if (m_pattern.isEmpty())
	{
		return;
	}

	int index = text.indexOf(m_pattern, 0, m_caseSensitivity);
	while (index >= 0)
	{
		QTextCharFormat currentFormat = format(index);
		currentFormat.setBackground(QBrush(Qt::yellow));
		setFormat(index, m_pattern.length(), currentFormat);
		index = text.indexOf(m_pattern, index + m_pattern.length(), m_caseSensitivity);
	}
}
