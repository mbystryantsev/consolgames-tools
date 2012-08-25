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

ScriptViewer::ScriptViewer(QWidget* parent) : QMainWindow(parent)
{
	initUI();

	loadMainLanguage("Russian", "d:/svn/consolgames/translations/mp3c/content/rus/text");
}

void ScriptViewer::initUI()
{
	QWidget* centralWidget = new QWidget(this);
	m_ui.setupUi(centralWidget);
	setCentralWidget(centralWidget);

	initFileList();
	initMessageList();
	initScriptViewer();

	initActions();
	initMenu();
	initToolbar();
}

void ScriptViewer::initFileList()
{
	VERIFY(connect(m_ui.fileList, SIGNAL(currentTextChanged(const QString&)), SLOT(setMessageSetModel(const QString&))));
}

void ScriptViewer::initMessageList()
{
	VERIFY(connect(m_ui.filterPattern, SIGNAL(textChanged(const QString&)), SLOT(onFilterChanged(const QString&))));
}

void ScriptViewer::initScriptViewer()
{
	m_scriptViewer = new ScriptViewWidget(this);
	QDockWidget* dockWidget = new QDockWidget("Viewer", this);
	dockWidget->setWidget(m_scriptViewer);
	dockWidget->setFeatures(dockWidget->features() ^ QDockWidget::DockWidgetClosable);
	dockWidget->setMinimumSize(200, 80);
	addDockWidget(Qt::BottomDockWidgetArea, dockWidget, Qt::Vertical);
}

#define REG_ACT(name) \
{ \
	QAction* action = new QAction(QIcon(), tr(#name), this); \
	m_actions[act##name] = action; \
	VERIFY(connect(action, SIGNAL(triggered), SLOT(on##name))); \
}

void ScriptViewer::initActions()
{
	m_actions[actExit] = new QAction(QIcon(), tr("Exit"), this);

	VERIFY(connect(m_actions[actExit], SIGNAL(triggered()), SLOT(onExit())));
}

void ScriptViewer::initToolbar()
{
	ASSERT(!m_actions.isEmpty());

	{
		QToolBar* bar = addToolBar(tr("&File"));
		bar->addAction(m_actions[actExit]);
	}
}

void ScriptViewer::initMenu()
{
	ASSERT(!m_actions.isEmpty());

	{
		QMenu* menu = menuBar()->addMenu(tr("&File"));
		menu->addAction(m_actions[actExit]);
	}
}

void ScriptViewer::openEditor(const QByteArray& languageId)
{
	if (m_openedEditors.contains(languageId))
	{
		return;
	}
	ASSERT(m_languages.contains(languageId));

	EditorDockWidget* dockWidget = new EditorDockWidget(languageId, this);
	VERIFY(connect(dockWidget, SIGNAL(closing(const QByteArray&)), SLOT(closeEditor(const QByteArray&))));
	VERIFY(connect(dockWidget->editor(), SIGNAL(textChanged(const QByteArray&, const QString&)), SLOT(onTextChanged(const QByteArray&, const QString&))));

	addDockWidget(Qt::BottomDockWidgetArea, dockWidget, Qt::Horizontal);
	m_openedEditors.insert(languageId, dockWidget->editor());
}

void ScriptViewer::closeEditor(const QByteArray& languageId)
{
	m_openedEditors.remove(languageId);
}

void ScriptViewer::addLanguage(const QByteArray& languageId)
{
	m_languages.insert(languageId);	
}

void ScriptViewer::loadMainLanguage(const QByteArray& languageId, const QString& path)
{
	m_mainLanguage = languageId;
	m_languages.insert(languageId);

	QDir dir(path);
	ASSERT(dir.exists());
	if (!dir.exists())
	{
		return;
	}

	m_ui.fileList->clear();
	m_mainLanguageData.clear();

	foreach (const QString& name, dir.entryList(QStringList("*.txt"), QDir::Files))
	{
		const QString filePath = path + "/" + name;
		m_mainLanguageData[name] = ScriptParser::loadFromFile(filePath);
	}

	m_ui.fileList->addItems(m_mainLanguageData.keys());
	m_ui.fileList->setCurrentRow(0);
	openEditor(languageId);
	//setMessageSetModel(m_mainLanguageData.keys().first());
}

QByteArray ScriptViewer::mainLanguage() const
{
	return m_mainLanguage;
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

void ScriptViewer::onMessageSelect(const QModelIndex& index)
{
	const QModelIndex sourceIndex = m_filterModel->mapToSource(index);
	const QModelIndex parent = sourceIndex.parent();
	if (parent.isValid())
	{
		foreach (const QByteArray& languageId, m_openedEditors.keys())
		{
			if (languageId == m_mainLanguage)
			{
				const QVector<MessageSet>& messageSets = m_mainLanguageData[currentMessageFile()];
				m_openedEditors[languageId]->setPlainText(messageSets[parent.row()].messages[sourceIndex.row()].text);
				continue;
			}
		}
	}
}

QString ScriptViewer::currentMessageFile() const
{
	return m_ui.fileList->currentItem()->text();
}

void ScriptViewer::onTextChanged(const QByteArray& languageId, const QString& text)
{
	Q_UNUSED(languageId);
	m_scriptViewer->drawText(text);
}

void ScriptViewer::onFilterChanged(const QString& pattern)
{
	m_filterModel->setPattern(pattern);
	foreach (ScriptEditor* editor, m_openedEditors)
	{
		editor->setFilterPattern(pattern);
	}
	m_ui.messageList->expandAll();
}

//////////////////////////////////////////////////////////////////////////

void ScriptViewer::onExit()
{
	close();
}
