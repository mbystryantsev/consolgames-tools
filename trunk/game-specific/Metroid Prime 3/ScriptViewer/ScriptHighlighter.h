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

	virtual void highlightBlock(const QString &text) override;
	void highlightPattern(const QString& text);

protected:
	static const QRegExp s_tagExpression;
	QString m_pattern;
	QTextCharFormat m_tagFormat;
	Qt::CaseSensitivity m_caseSensitivity;
};
