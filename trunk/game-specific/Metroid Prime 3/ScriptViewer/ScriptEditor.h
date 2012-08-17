#pragma once
#include <QPlainTextEdit>

class ScriptEditor : public QPlainTextEdit
{
	Q_OBJECT;
public:
	ScriptEditor(const QByteArray& languageId, QWidget* parent);
	
	const QByteArray& languageId() const;

protected:
	const QByteArray m_languageId;
};
