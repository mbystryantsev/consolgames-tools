#pragma once
#include "MessageSetModel.h"
#include <ScriptParser.h>
#include <QMainWindow>
#include <QSet>

class QListWidget;
class QListView;
class QTreeView;
class ScriptEditor;
class ScriptViewWidget;

class ScriptViewer : public QMainWindow
{
	Q_OBJECT;

public:
	ScriptViewer(QWidget* parent = NULL);

	void loadMainLanguage(const QByteArray& languageId, const QString& path);
	void addLanguage(const QByteArray& languageId);

	QByteArray mainLanguage() const;

protected:
	void openEditor(const QByteArray& languageId);
	Q_SLOT void closeEditor(const QByteArray& languageId);

protected:
	QListWidget* m_fileListWidget;
	QTreeView* m_stringListWidget;
	ScriptViewWidget* m_scriptViewer;
	QString currentMessageFile() const;
	Q_SLOT void setMessageSetModel(const QString& filename);
	Q_SLOT void onMessageSelect(const QModelIndex& index);
	Q_SLOT void onTextChanged(const QByteArray& languageId, const QString& text);

protected:
	std::auto_ptr<MessageSetModel> m_currentModel;
	QMap<QString,QVector<MessageSet>> m_mainLanguageData;
	QByteArray m_mainLanguage;
	QSet<QByteArray> m_languages;
	QMap<QByteArray,ScriptEditor*> m_openedEditors;
};