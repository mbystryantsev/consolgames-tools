#pragma once
#include <QSyntaxHighlighter>
#include <QRegExp>
#include <QTextCharFormat>

class QPlainTextEdit;

class ScriptHighlighter : public QSyntaxHighlighter
{
public:
	ScriptHighlighter(QPlainTextEdit* parent);

	Q_SLOT void setPattern(const QString& pattern);

	void highlightExpression(const QString& text, const QRegExp& expression, const QTextCharFormat& format);
	virtual void highlightBlock(const QString &text) override;
	void highlightPattern(const QString& text);

protected:
	static const QRegExp s_tagExpression;
	static const QRegExp s_refExpression;
	QString m_pattern;
	QTextCharFormat m_tagFormat;
	QTextCharFormat m_refFormat;
	Qt::CaseSensitivity m_caseSensitivity;
};
