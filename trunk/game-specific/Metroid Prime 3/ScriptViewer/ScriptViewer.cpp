#include "ScriptViewer.h"
#include "EditorDockWidget.h"
#include "ScriptViewWidget.h"
#include "ScriptEditor.h"
#include <QHBoxLayout>
#include <QDir>
#include <QListWidget>
#include <QTreeView>
#include <QHeaderView>
#include <QDockWidget>
#include <QAction>
#include <QToolBar>
#include <QMenuBar>
#include <QItemSelectionModel>
#include <QMessageBox>
#include <QSplashScreen>

ScriptViewer::ScriptViewer(QWidget* parent, QSplashScreen* splash)
	: QMainWindow(parent)
	, m_currentMessage(NULL)
	, m_currentMessageSet(NULL)
	, m_viewMenu(NULL)
	, m_scriptViewer(NULL)
	, m_scriptViewerDockWidget(NULL)
{
	if (splash) splash->showMessage("Initializing...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);

	initUI();


	// Temporary solution
	if (splash) splash->showMessage("Load main language: Russian...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	loadMainLanguage("Russian", "../content/rus/text");

	if (splash) splash->showMessage("Load language: English...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	addSourceLanguage("English", "../content/eng/text", true);

	if (splash) splash->showMessage("Load language: Japan...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	addSourceLanguage("Japan", "../content/jpn/text", true);

	if (splash) splash->showMessage("Load language: French...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	addSourceLanguage("French", "../content/fre/text");

	if (splash) splash->showMessage("Load language: Spanish...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	addSourceLanguage("Spanish", "../content/spa/text");

	if (splash) splash->showMessage("Load language: German...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	addSourceLanguage("German", "../content/ger/text");
	
	if (splash) splash->showMessage("Load language: Italian...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	addSourceLanguage("Italian", "../content/ita/text");
}

void ScriptViewer::initUI()
{
	QWidget* centralWidget = new QWidget(this);
	m_ui.setupUi(centralWidget);
	setCentralWidget(centralWidget);

	initMessageList();
	initScriptViewer();

	initActions();
	initMenu();
	initToolbar();
}

void ScriptViewer::initMessageList()
{
	VERIFY(connect(m_ui.filterPattern, SIGNAL(textChanged(const QString&)), SLOT(onFilterChanged(const QString&))));
}

void ScriptViewer::initScriptViewer()
{
	m_scriptViewer = new ScriptViewWidget(this);
	m_scriptViewerDockWidget = new QDockWidget("Viewer", this);
	m_scriptViewerDockWidget->setWidget(m_scriptViewer);
	m_scriptViewerDockWidget->setMinimumSize(200, 80);
	addDockWidget(Qt::BottomDockWidgetArea, m_scriptViewerDockWidget, Qt::Vertical);
}

#define REG_ACT(name, key, icon) \
{ \
	QAction* action = new QAction(icon, tr(#name), this); \
	action->setShortcut(key); \
	m_actions[act##name] = action; \
	VERIFY(connect(action, SIGNAL(triggered()), SLOT(on##name()))); \
}

void ScriptViewer::initActions()
{
	REG_ACT(Exit, QKeySequence::Quit, QIcon());
	REG_ACT(Save, QKeySequence::Save, QApplication::style()->standardIcon(QStyle::SP_DialogSaveButton));
}

void ScriptViewer::initToolbar()
{
	ASSERT(!m_actions.isEmpty());

	{
		QToolBar* bar = addToolBar(tr("&File"));
		bar->setIconSize(QSize(24, 24));
		bar->addAction(m_actions[actSave]);
	}
}

void ScriptViewer::initMenu()
{
	ASSERT(!m_actions.isEmpty());
	{
		QMenu* menu = menuBar()->addMenu(tr("&File"));

		menu->addAction(m_actions[actSave]);
		menu->addSeparator();
		menu->addAction(m_actions[actExit]);

		m_viewMenu = menuBar()->addMenu(tr("&View"));
		VERIFY(connect(m_viewMenu, SIGNAL(aboutToShow()), SLOT(buildViewMenu())));
	}
}

void ScriptViewer::updateFileList()
{
	m_scriptFilesSelectionModel.reset();
	m_scriptFilesModel.reset(new MessageFileListModel(m_mainLanguageData));
	m_scriptFilesSelectionModel.reset(new QItemSelectionModel(m_scriptFilesModel.get()));
	m_ui.fileList->setModel(m_scriptFilesModel.get());
	m_ui.fileList->setSelectionModel(m_scriptFilesSelectionModel.get());

	VERIFY(connect(m_scriptFilesSelectionModel.get(), SIGNAL(currentRowChanged(const QModelIndex&, const QModelIndex&)), SLOT(onFileListIndexChanged(const QModelIndex&))));
	m_scriptFilesSelectionModel->setCurrentIndex(m_scriptFilesModel->index(0, 0), QItemSelectionModel::Current);
}

void ScriptViewer::setSaved(bool saved)
{
	m_saved = saved;
}

void ScriptViewer::openEditor(const QByteArray& languageId)
{
	if (m_openedEditors.contains(languageId))
	{
		return;
	}
	ASSERT(m_languages.contains(languageId));

	EditorDockWidget* dockWidget = NULL;
	if (!m_editors.contains(languageId))
	{
		dockWidget = new EditorDockWidget(languageId, languageId == m_mainLanguage, this);
		VERIFY(connect(dockWidget, SIGNAL(closing(const QByteArray&)), SLOT(closeEditor(const QByteArray&))));
		VERIFY(connect(dockWidget->editor(), SIGNAL(textChanged(const QString&, const QByteArray&)), SLOT(onTextChanged(const QString&, const QByteArray&))));
		addDockWidget(Qt::RightDockWidgetArea, dockWidget, Qt::Vertical);
		
		m_editors[languageId] = dockWidget;
	}
	else
	{
		dockWidget = m_editors[languageId];
	}

	m_openedEditors.insert(languageId, dockWidget->editor());
	dockWidget->setVisible(true);

	setSourceLanguageText(languageId);
}

void ScriptViewer::closeEditor(const QByteArray& languageId)
{
	ASSERT(m_openedEditors.contains(languageId));
	m_openedEditors.remove(languageId);
	m_editors[languageId]->setVisible(false);
}

void ScriptViewer::addSourceLanguage(const QByteArray& languageId, const QString& path, bool editorOpen)
{
	m_sourceLanguagesData.append(LanguageData());
	LanguageData& langData = m_sourceLanguagesData.last();

	if (!loadLanguage(langData, languageId, path))
	{
		m_sourceLanguagesData.removeLast();
		return;
	}

	MessageMap& messageMap = m_sourceLangMessageMap[languageId];

	foreach (const QVector<MessageSet>& messages, langData)
	{
		foreach (const MessageSet& messageSet, messages)
		{
			foreach (const quint64 hash, messageSet.nameHashes)
			{
				messageMap[hash] = &messageSet;
			}
		}
	}
	DLOG << "Loaded additional language: " << languageId;
	if (editorOpen)
	{
		openEditor(languageId);
	}
}

void ScriptViewer::loadMainLanguage(const QByteArray& languageId, const QString& path)
{
	if (!loadLanguage(m_mainLanguageData, languageId, path))
	{
		return;
	}
	DLOG << "Loaded main language: " << languageId;

	m_mainLanguage = languageId;
	openEditor(languageId);
	updateFileList();
	setSaved(true);

}

bool ScriptViewer::loadLanguage(LanguageData& data, const QByteArray& languageId, const QString& path)
{
	QDir dir(path);
	ASSERT(dir.exists());
	if (!dir.exists())
	{
		return false;
	}

	m_languages.insert(languageId);
	data.clear();

	foreach (const QString& name, dir.entryList(QStringList("*.txt"), QDir::Files))
	{
		const QString filePath = dir.absoluteFilePath(name);
		data[filePath] = ScriptParser::loadFromFile(filePath);
	}

	return true;
}

QByteArray ScriptViewer::mainLanguage() const
{
	return m_mainLanguage;
}

void ScriptViewer::onFileListIndexChanged(const QModelIndex& index)
{
	m_currentMessageIndex = QModelIndex();
	setMessageSetModel(m_scriptFilesModel->filenames()[index.row()]);
	onFilterChanged(m_ui.filterPattern->text());
}

void ScriptViewer::setMessageSetModel(const QString& filename)
{
	ASSERT(m_mainLanguageData.contains(filename));
	m_selectionModel.reset();
	m_filterModel.reset();

	m_currentModel.reset(new MessageSetModel(m_mainLanguageData[filename]));

	m_filterModel.reset(new MessageSetFilterModel());
	m_filterModel->setSourceModel(m_currentModel.get());

	m_ui.messageList->setModel(m_filterModel.get());
	m_ui.messageList->expandAll();

	m_selectionModel.reset(new QItemSelectionModel(m_filterModel.get()));
	m_ui.messageList->setSelectionModel(m_selectionModel.get());

	VERIFY(connect(m_ui.messageList->selectionModel(), SIGNAL(currentChanged(const QModelIndex&, const QModelIndex&)), SLOT(onMessageSelect(const QModelIndex&))));
}

void ScriptViewer::setSourceLanguageText(const QByteArray& languageId)
{
	if (m_currentMessageSet == NULL || !m_openedEditors.contains(languageId))
	{
		return;
	}
	const quint64 hash = m_currentMessageSet->nameHashes[0];
	if (!m_sourceLangMessageMap[languageId].contains(hash))
	{
		m_openedEditors[languageId]->setPlainText("");
		return;
	}

	const MessageSet* sourceMessageSet = m_sourceLangMessageMap[languageId][hash];
	if (m_currentMessageIndex.row() >= sourceMessageSet->messages.size())
	{
		m_openedEditors[languageId]->setPlainText("");
		return;
	}

	m_openedEditors[languageId]->setPlainText(sourceMessageSet->messages[m_currentMessageIndex.row()].text);
}

void ScriptViewer::onMessageSelect(const QModelIndex& index)
{
	m_currentMessage = NULL;
	m_currentMessageSet = NULL;

	const QModelIndex sourceIndex = m_filterModel->mapToSource(index);
	const QModelIndex parent = sourceIndex.parent();
	if (parent.isValid())
	{
		QVector<MessageSet>& messageSets = m_mainLanguageData[currentMessageFile()];
		MessageSet& currMessageSet = messageSets[parent.row()];
		m_currentMessage = &currMessageSet.messages[sourceIndex.row()];
		m_currentMessageIndex = sourceIndex;
		m_currentMessageSet = &currMessageSet;

		foreach (const QByteArray& languageId, m_openedEditors.keys())
		{
			if (languageId == m_mainLanguage)
			{
				m_openedEditors[languageId]->setPlainText(messageSets[parent.row()].messages[m_currentMessageIndex.row()].text);
			}
			else
			{
				setSourceLanguageText(languageId);
			}
		}
	}
}

QString ScriptViewer::currentMessageFile() const
{
	const int index = m_scriptFilesSelectionModel->currentIndex().row();
	return m_scriptFilesModel->filenames()[index];
}

void ScriptViewer::onTextChanged(const QString& text, const QByteArray& languageId)
{
	if (languageId == m_mainLanguage && m_currentMessage != NULL)
	{
		m_scriptViewer->drawText(text);
		if (m_currentMessage->text != text)
		{
			ASSERT(m_currentMessageIndex.isValid());

			m_currentMessage->text = text;
			m_ui.messageList->update(m_currentMessageIndex);
			setSaved(false);
		}
	}
}

void ScriptViewer::onFilterChanged(const QString& pattern)
{
	m_filterModel->setPattern(pattern);
	foreach (ScriptEditor* editor, m_openedEditors)
	{
		editor->setFilterPattern(pattern);
	}
	m_ui.messageList->expandAll();

	if (m_currentMessageIndex.isValid())
	{
		QModelIndex index = m_filterModel->mapFromSource(m_currentMessageIndex);
		if (index.isValid())
		{
			m_ui.messageList->selectionModel()->select(index, QItemSelectionModel::SelectCurrent);
		}
	}
}

//////////////////////////////////////////////////////////////////////////

void ScriptViewer::onExit()
{
	close();
}

void ScriptViewer::onSave()
{
	foreach (const QString& filename, m_mainLanguageData.keys())
	{
		DLOG << "Saving " << filename << "...";
		ScriptParser::saveToFile(filename, m_mainLanguageData[filename]);
	}

	setSaved(true);
}

void ScriptViewer::closeEvent(QCloseEvent *event)
{
	if (!m_saved)
	{
		const int result = QMessageBox::question(this, tr("Save changes?"),
			tr("Some text has been modified. Do you want to save changes?"),
			QMessageBox::Save, QMessageBox::Discard, QMessageBox::Cancel);

		if (result == QMessageBox::Cancel)
		{
			event->ignore();
			return;
		}
		if (result == QMessageBox::Save)
		{
			onSave();
		}
	}
	QMainWindow::closeEvent(event);
}

void ScriptViewer::buildViewMenu()
{
	ASSERT(m_viewMenu != NULL);
	m_viewMenu->clear();
	QAction* toggleViewerAct = m_viewMenu->addAction(tr("Text &Viewer"));
	toggleViewerAct->setCheckable(true);
	toggleViewerAct->setChecked(m_scriptViewerDockWidget->isVisible());
	VERIFY(connect(toggleViewerAct, SIGNAL(toggled(bool)), SLOT(toggleViewerVisible(bool))));

	m_viewMenu->addSeparator();

	foreach (const QByteArray& languageId, m_languages)
	{
		QAction* toggleEditorVisibleAct = m_viewMenu->addAction(languageId);
		toggleEditorVisibleAct->setCheckable(true);
		toggleEditorVisibleAct->setChecked(m_openedEditors.contains(languageId));
		VERIFY(connect(toggleEditorVisibleAct, SIGNAL(toggled(bool)), SLOT(toggleEditorVisible(bool))));
	}
}

void ScriptViewer::toggleViewerVisible(bool visible)
{
	m_scriptViewerDockWidget->setVisible(visible);
}

void ScriptViewer::toggleEditorVisible(bool visible)
{
	QAction* action = dynamic_cast<QAction*>(sender());
	ASSERT(action != NULL);

	const QByteArray languageId = action->text().toLatin1();
	ASSERT(m_languages.contains(languageId));

	ASSERT(!visible == m_openedEditors.contains(languageId));

	if (visible)
	{
		openEditor(languageId);
	}
	else
	{
		closeEditor(languageId);
	}
}