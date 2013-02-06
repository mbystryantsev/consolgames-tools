#include "ScriptEditor.h"
#include "ScriptHighlighter.h"
#include <Strings.h>

using namespace ShatteredMemories;

ScriptEditor::ScriptEditor(const QByteArray& languageId, QWidget* parent)
	: QPlainTextEdit(parent)
	, m_languageId(languageId)
	, m_hash(0)
	, m_isUpdating(false)
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

void ScriptEditor::setText(const QString& text, quint32 hash)
{
	m_isUpdating = true;
	m_hash = hash;
	setPlainText(text);
	m_isUpdating = false;
}

void ScriptEditor::setText(const Message& message)
{
	setText(message.text, message.hash);
}
void ScriptEditor::onTextChangedInternal()
{
	if (!isReadOnly() && !m_isUpdating)
	{
		emit textChanged(toPlainText(), m_languageId, m_hash);
	}
}