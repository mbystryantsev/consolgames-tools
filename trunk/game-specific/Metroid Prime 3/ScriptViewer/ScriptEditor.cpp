#include "ScriptEditor.h"
#include "ScriptHighlighter.h"

ScriptEditor::ScriptEditor(const QByteArray& languageId, QWidget* parent)
	: QPlainTextEdit(parent)
	, m_languageId(languageId)
{
 	new ScriptHighlighter(this);
}

const QByteArray& ScriptEditor::languageId() const
{
	return m_languageId;
}
