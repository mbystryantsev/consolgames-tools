#include "ScriptHighlighter.h"
#include <QPlainTextEdit>

const QRegExp ScriptHighlighter::s_tagExpression = QRegExp("&[^;]*;");

ScriptHighlighter::ScriptHighlighter(QPlainTextEdit* parent) : QSyntaxHighlighter(parent->document())
{
	m_tagFormat.setForeground(QBrush(Qt::gray));
}

void ScriptHighlighter::highlightBlock(const QString &text)
{
	QRegExp expression(s_tagExpression);
	
	int index = expression.indexIn(text);
	while (index >= 0)
	{
		const int length = expression.matchedLength();
		setFormat(index, length, m_tagFormat);
		index = expression.indexIn(text, index + length);
	}
}
