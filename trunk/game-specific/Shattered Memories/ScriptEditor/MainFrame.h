#pragma once
#include "ui_CentralWidget.h"
#include <QMainWindow>
#include <QSet>

class MainController;
class QListWidget;
class QListView;
class QTreeView;
class ScriptEditor;
class EditorDockWidget;
class ScriptViewWidget;
class QAction;
class QItemSelectionModel;
class QMenu;
class QSplashScreen;
class QDockWidget;

class MainFrame : public QMainWindow
{
	Q_OBJECT;

public:
	MainFrame(QWidget* parent = NULL, QSplashScreen* splash = NULL);

protected:
	enum Actions
	{
		actOpenProject,
		actSave,
		actCopyHashes,
		actExit
	};

protected:
	Q_SLOT void onLanguageLoading(const QByteArray& language);


	bool loadLanguage(const QByteArray& languageId, const QString& path);
	virtual void closeEvent(QCloseEvent *event);

	void openEditor(const QByteArray& languageId);
	Q_SLOT void closeEditor(const QByteArray& languageId);

	void initUI();
	void initMessageList();
	void initActions();
	void initToolbar();
	void initMenu();

	void updateFileList();

protected:
	Ui_CentralWidget m_ui;
	ScriptViewWidget* m_scriptViewer;
	QDockWidget* m_scriptViewerDockWidget;
	Q_SLOT void onMessageSelect(quint32 hash);
	Q_SLOT void onMessageSelect(const QModelIndex& index);
	Q_SLOT void onFilterChanged(const QString& pattern);
	Q_SLOT void onTagSelected(const QString& tag);

protected:
	// Actions
	Q_SLOT void onExit();
	Q_SLOT void onSave();
	Q_SLOT void onCopyHashes();
	Q_SLOT void buildViewMenu();
	Q_SLOT void toggleEditorVisible(bool visible);
	Q_SLOT void toggleCommentEditorVisible(bool visible);

protected:

	MainController* m_controller;

	QSplashScreen* m_splash;
	QDockWidget* m_commentWidget;
	QMap<QByteArray,EditorDockWidget*> m_editors;
	QMap<QByteArray,ScriptEditor*> m_openedEditors;
	QMap<Actions,QAction*> m_actions;
	QMenu* m_viewMenu;
};