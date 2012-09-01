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

ScriptViewer::ScriptViewer(QWidget* parent)
	: QMainWindow(parent)
	, m_currentMessage(NULL)
{
	initUI();

	// Temporary solution
	loadMainLanguage("Russian", "../content/rus/text");
	addSourceLanguage("English", "../content/eng/text");
	addSourceLanguage("Japan", "../content/jpn/text");
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
	VERIFY(connect(action, SIGNAL(triggered()), SLOT(on##name()))); \
}

void ScriptViewer::initActions()
{
	REG_ACT(Exit);
	REG_ACT(Save);
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
		menu->addAction(m_actions[actSave]);
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

	EditorDockWidget* dockWidget = new EditorDockWidget(languageId, languageId == m_mainLanguage, this);
	VERIFY(connect(dockWidget, SIGNAL(closing(const QByteArray&)), SLOT(closeEditor(const QByteArray&))));
	VERIFY(connect(dockWidget->editor(), SIGNAL(textChanged(const QString&, const QByteArray&)), SLOT(onTextChanged(const QString&, const QByteArray&))));

	addDockWidget(Qt::RightDockWidgetArea, dockWidget, Qt::Vertical);
	m_openedEditors.insert(languageId, dockWidget->editor());
}

void ScriptViewer::closeEditor(const QByteArray& languageId)
{
	m_openedEditors.remove(languageId);
}

void ScriptViewer::addSourceLanguage(const QByteArray& languageId, const QString& path)
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
	openEditor(languageId);
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
	setMessageSetModel(m_scriptFilesModel->filenames()[index.row()]);
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
	m_currentMessage = NULL;

	const QModelIndex sourceIndex = m_filterModel->mapToSource(index);
	const QModelIndex parent = sourceIndex.parent();
	if (parent.isValid())
	{
		QVector<MessageSet>& messageSets = m_mainLanguageData[currentMessageFile()];
		MessageSet& currMessageSet = messageSets[parent.row()];
		m_currentMessage = &currMessageSet.messages[sourceIndex.row()];
		m_currentMessageIndex = sourceIndex;

		foreach (const QByteArray& languageId, m_openedEditors.keys())
		{
			if (!m_openedEditors.contains(languageId))
			{
				continue;
			}
			if (languageId == m_mainLanguage)
			{
				m_openedEditors[languageId]->setPlainText(messageSets[parent.row()].messages[sourceIndex.row()].text);
			}
			else
			{
				const quint64 hash = currMessageSet.nameHashes[0];
				if (!m_sourceLangMessageMap[languageId].contains(hash))
				{
					continue;
				}

				const MessageSet* sourceMessageSet = m_sourceLangMessageMap[languageId][hash];
				if (sourceIndex.row() >= sourceMessageSet->messages.size())
				{
					continue;
				}

				m_openedEditors[languageId]->setPlainText(sourceMessageSet->messages[sourceIndex.row()].text);
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
		if (m_currentMessage->text != text)
		{
			ASSERT(m_currentMessageIndex.isValid());
			m_currentMessage->text = text;
			m_ui.messageList->update(m_currentMessageIndex);
			setSaved(false);
		}
	}

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