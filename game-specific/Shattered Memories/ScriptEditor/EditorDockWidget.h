#pragma once
#include <QDockWidget>

class ScriptEditor;

class EditorDockWidget : public QDockWidget
{
	Q_OBJECT;

public:
	EditorDockWidget(const QByteArray& languageId, bool editable, QWidget* parent);

	ScriptEditor* editor();

	virtual void closeEvent(QCloseEvent *event) override;
	Q_SIGNAL void closing(const QByteArray& languageId);

protected:
	ScriptEditor* m_editor;
};
