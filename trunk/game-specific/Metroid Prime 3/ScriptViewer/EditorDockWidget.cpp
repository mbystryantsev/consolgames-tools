#include "EditorDockWidget.h"
#include "ScriptEditor.h"

EditorDockWidget::EditorDockWidget(const QByteArray& languageId, QWidget* parent)
	: QDockWidget(languageId, parent)
	, m_editor(new ScriptEditor(languageId, this))
{
	setWidget(m_editor);
}

ScriptEditor* EditorDockWidget::editor()
{
	return m_editor;
}

void EditorDockWidget::closeEvent(QCloseEvent *event)
{
	emit closing(m_editor->languageId());
	QDockWidget::closeEvent(event);
}
