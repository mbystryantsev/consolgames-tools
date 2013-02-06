#pragma once
#include <QPlainTextEdit>

class ScriptHighlighter;

namespace ShatteredMemories
{
struct Message;
}

class ScriptEditor : public QPlainTextEdit
{
	Q_OBJECT;
public:
	ScriptEditor(const QByteArray& languageId, QWidget* parent);
	
	const QByteArray& languageId() const;
	Q_SLOT void setFilterPattern(const QString& pattern);
	Q_SLOT void setText(const QString& text, quint32 hash);
	Q_SLOT void setText(const ShatteredMemories::Message& message);
	Q_SIGNAL void textChanged(const QString& text, const QByteArray& languageId, quint32 hash);

protected:
	Q_SLOT void onTextChangedInternal();

protected:
	const QByteArray m_languageId;
	ScriptHighlighter* m_highlighter;
	quint32 m_hash;
	bool m_isUpdating;
};
