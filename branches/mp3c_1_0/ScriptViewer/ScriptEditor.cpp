#include "ScriptEditor.h"
#include "ScriptHighlighter.h"
#include <core.h>

ScriptEditor::ScriptEditor(const QByteArray& languageId, QWidget* parent)
	: QPlainTextEdit(parent)
	, m_languageId(languageId)
{
 	m_highlighter = new ScriptHighlighter(this);
	VERIFY(connect(this, SIGNAL(textChanged()), SLOT(onTextChangedInternal())));
}

const QByteArray& ScriptEditor::languageId() const
{
	return m_languageId;
}

void ScriptEditor::setFilterPattern(const QString& pattern)
{
	m_highlighter->setPattern(pattern);
}

void ScriptEditor::onTextChangedInternal()
{
	emit textChanged(toPlainText(), m_languageId);
}