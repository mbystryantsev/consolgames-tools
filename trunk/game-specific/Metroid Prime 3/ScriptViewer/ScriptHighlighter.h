#pragma once
#include <QSyntaxHighlighter>
#include <QRegExp>
#include <QTextCharFormat>

class QPlainTextEdit;

class ScriptHighlighter : public QSyntaxHighlighter
{
public:
	ScriptHighlighter(QPlainTextEdit* parent);

	virtual void highlightBlock(const QString &text) override;

protected:
	static const QRegExp s_tagExpression;
	QTextCharFormat m_tagFormat;
};
