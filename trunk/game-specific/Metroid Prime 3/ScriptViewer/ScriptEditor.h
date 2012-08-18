#pragma once
#include <QPlainTextEdit>

class ScriptEditor : public QPlainTextEdit
{
	Q_OBJECT;
public:
	ScriptEditor(const QByteArray& languageId, QWidget* parent);
	
	const QByteArray& languageId() const;
	Q_SIGNAL void textChanged(const QByteArray& languageId, const QString& text);

protected:
	Q_SLOT void onTextChangedInternal();

protected:
	const QByteArray m_languageId;
};
