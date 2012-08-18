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

ScriptViewer::ScriptViewer(QWidget* parent) : QMainWindow(parent)
{
	initUI();

	loadMainLanguage("Russian", "d:/svn/consolgames/translations/mp3c/content/rus/text");
}

void ScriptViewer::initUI()
{
	setCentralWidget(new QWidget());
	
	QHBoxLayout* layout = new QHBoxLayout(centralWidget());
	layout->setStretch(0, 0);
	layout->setStretch(1, 1);

	initFileList();
	initMessageList();
	initScriptViewer();
}

void ScriptViewer::initFileList()
{
	m_fileListWidget = new QListWidget(this);
	VERIFY(connect(m_fileListWidget, SIGNAL(currentTextChanged(const QString&)), SLOT(setMessageSetModel(const QString&))));
	centralWidget()->layout()->addWidget(m_fileListWidget);
}

void ScriptViewer::initMessageList()
{
	m_messageListWidget = new QTreeView(this);
	m_messageListWidget->header()->setDefaultSectionSize(64);
	m_messageListWidget->setHeaderHidden(true);
	VERIFY(connect(m_messageListWidget, SIGNAL(clicked(const QModelIndex&)), SLOT(onMessageSelect(const QModelIndex&))));
	centralWidget()->layout()->addWidget(m_messageListWidget);
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

	m_fileListWidget->clear();
	m_mainLanguageData.clear();

	foreach (const QString& name, dir.entryList(QStringList("*.txt"), QDir::Files))
	{
		const QString filePath = path + "/" + name;
		m_mainLanguageData[name] = ScriptParser::loadFromFile(filePath);
	}

	m_fileListWidget->addItems(m_mainLanguageData.keys());
	m_fileListWidget->setCurrentRow(0);
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
	m_currentModel.reset(new MessageSetModel(m_mainLanguageData[filename]));
	m_messageListWidget->setModel(m_currentModel.get());
}

void ScriptViewer::onMessageSelect(const QModelIndex& index)
{
	const QModelIndex parent = index.parent();
	if (parent.isValid())
	{
		foreach (const QByteArray& languageId, m_openedEditors.keys())
		{
			if (languageId == m_mainLanguage)
			{
				const QVector<MessageSet>& messageSets = m_mainLanguageData[currentMessageFile()];
				m_openedEditors[languageId]->setPlainText(messageSets[parent.row()].messages[index.row()].text);
				continue;
			}
		}
	}
}

QString ScriptViewer::currentMessageFile() const
{
	return m_fileListWidget->currentItem()->text();
}

void ScriptViewer::onTextChanged(const QByteArray& languageId, const QString& text)
{
	m_scriptViewer->drawText(text);
}
