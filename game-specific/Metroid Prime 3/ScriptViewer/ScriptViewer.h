#pragma once
#include "MessageSetModel.h"
#include "MessageSetFilterModel.h"
#include "MessageFileListModel.h"
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
	void addSourceLanguage(const QByteArray& languageId, const QString& path);

	QByteArray mainLanguage() const;

protected:
	enum Actions
	{
		actOpenProject,
		actSave,
		actExit
	};

protected:
	typedef QMap<QString,QVector<MessageSet>> LanguageData;
	bool loadLanguage(LanguageData& data, const QByteArray& languageId, const QString& path);
	virtual void closeEvent(QCloseEvent *event);

	void openEditor(const QByteArray& languageId);
	Q_SLOT void closeEditor(const QByteArray& languageId);

	void initUI();
	void initMessageList();
	void initScriptViewer();
	void initActions();
	void initToolbar();
	void initMenu();

	void updateFileList();
	void setSaved(bool saved);

protected:
	Ui_CentralWidget m_ui;
	ScriptViewWidget* m_scriptViewer;
	QString currentMessageFile() const;
	Q_SLOT void onFileListIndexChanged(const QModelIndex& index);
	Q_SLOT void setMessageSetModel(const QString& filename);
	Q_SLOT void onMessageSelect(const QModelIndex& index);
	Q_SLOT void onTextChanged(const QString& text, const QByteArray& languageId);
	Q_SLOT void onFilterChanged(const QString& pattern);

protected:
	// Actions
	Q_SLOT void onExit();
	Q_SLOT void onSave();

protected:
	std::auto_ptr<MessageSetModel> m_currentModel;
	std::auto_ptr<MessageSetFilterModel> m_filterModel;
	std::auto_ptr<QItemSelectionModel> m_selectionModel;

	std::auto_ptr<MessageFileListModel> m_scriptFilesModel;
	std::auto_ptr<QItemSelectionModel> m_scriptFilesSelectionModel;

	bool m_saved;
	
	Message* m_currentMessage;
	QModelIndex m_currentMessageIndex;

	typedef QMap<quint64,const MessageSet*> MessageMap;

	LanguageData m_mainLanguageData;
	QList<LanguageData> m_sourceLanguagesData;
	QHash<QByteArray,MessageMap> m_sourceLangMessageMap;

	QByteArray m_mainLanguage;
	QSet<QByteArray> m_languages;
	QMap<QByteArray,ScriptEditor*> m_openedEditors;
	QMap<Actions,QAction*> m_actions;
};