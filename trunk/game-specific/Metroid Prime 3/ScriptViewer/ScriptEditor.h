#pragma once
#include <QPlainTextEdit>

class ScriptHighlighter;

class ScriptEditor : public QPlainTextEdit
{
	Q_OBJECT;
public:
	ScriptEditor(const QByteArray& languageId, QWidget* parent);
	
	const QByteArray& languageId() const;
	Q_SLOT void setFilterPattern(const QString& pattern);
	Q_SIGNAL void textChanged(const QByteArray& languageId, const QString& text);

protected:
	Q_SLOT void onTextChangedInternal();

protected:
	const QByteArray m_languageId;
	ScriptHighlighter* m_highlighter;
};
