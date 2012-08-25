#pragma once
#include "MessageSetModel.h"
#include "MessageSetFilterModel.h"
#include "ui_CentralWidget.h"
#include <ScriptParser.h>
#include <QMainWindow>
#include <QSet>

class QListWidget;
class QListView;
class QTreeView;
class ScriptEditor;
class ScriptViewWidget;
class QAction;
class QItemSelectionModel;

class ScriptViewer : public QMainWindow
{
	Q_OBJECT;

public:
	ScriptViewer(QWidget* parent = NULL);

	void loadMainLanguage(const QByteArray& languageId, const QString& path);
	void addLanguage(const QByteArray& languageId);

	QByteArray mainLanguage() const;

protected:
	enum Actions
	{
		actOpenProject,
		actSave,
		actExit
	};

protected:
	void openEditor(const QByteArray& languageId);
	Q_SLOT void closeEditor(const QByteArray& languageId);

	void initUI();
	void initMessageList();
	void initFileList();
	void initScriptViewer();
	void initActions();
	void initToolbar();
	void initMenu();

protected:
	Ui_CentralWidget m_ui;
	ScriptViewWidget* m_scriptViewer;
	QString currentMessageFile() const;
	Q_SLOT void setMessageSetModel(const QString& filename);
	Q_SLOT void onMessageSelect(const QModelIndex& index);
	Q_SLOT void onTextChanged(const QByteArray& languageId, const QString& text);
	Q_SLOT void onFilterChanged(const QString& pattern);

protected:
	// Actions
	Q_SLOT void onExit();

protected:
	std::auto_ptr<MessageSetModel> m_currentModel;
	std::auto_ptr<MessageSetFilterModel> m_filterModel;
	std::auto_ptr<QItemSelectionModel> m_selectionModel;
	
	QMap<QString,QVector<MessageSet>> m_mainLanguageData;
	QByteArray m_mainLanguage;
	QSet<QByteArray> m_languages;
	QMap<QByteArray,ScriptEditor*> m_openedEditors;
	QMap<Actions,QAction*> m_actions;
};