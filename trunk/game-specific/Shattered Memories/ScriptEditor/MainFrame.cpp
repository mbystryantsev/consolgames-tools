#include "MainFrame.h"
#include "MainController.h"
#include "EditorDockWidget.h"
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

LOG_CATEGORY("ScriptEditor.MainFrame");

using namespace ShatteredMemories;

MainFrame::MainFrame(QWidget* parent, QSplashScreen* splash)
	: QMainWindow(parent)
	, m_viewMenu(NULL)
	, m_splash(splash)
	, m_controller(NULL)
{
	if (splash)
	{
		splash->showMessage("Initializing...", Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	}

	m_controller = new MainController(this);
	initUI();
}

void MainFrame::initUI()
{
	QWidget* centralWidget = new QWidget(this);
	m_ui.setupUi(centralWidget);
	setCentralWidget(centralWidget);


	m_ui.categoryList->setModel(m_controller->categoriesModel());
	m_ui.categoryList->setSelectionModel(m_controller->categoriesSelectionModel());
	m_ui.categoryList->expandAll();

 	initMessageList();
 
 	initActions();
 	initMenu();
 	initToolbar();

	openEditor("Russian");
	openEditor("English");
	openEditor("Japan");
}

void MainFrame::initMessageList()
{
	m_ui.messageList->setModel(m_controller->messagesFilterModel());
	m_ui.messageList->setSelectionModel(m_controller->messagesSelectionModel());
	VERIFY(connect(m_controller, SIGNAL(messageSelected(quint32)), SLOT(onMessageSelect(quint32))));
	VERIFY(connect(m_ui.filterPattern, SIGNAL(textChanged(const QString&)), m_controller, SLOT(onFilterChanged(const QString&))));
	VERIFY(connect(m_ui.filterPattern, SIGNAL(textChanged(const QString&)), this, SLOT(onFilterChanged(const QString&))));

	m_ui.messageList->selectionModel()->setCurrentIndex(m_controller->messagesFilterModel()->index(0, 0), QItemSelectionModel::SelectCurrent);
}

#define REG_ACT(name, key, icon) \
{ \
	QAction* action = new QAction(icon, tr(#name), this); \
	action->setShortcut(key); \
	m_actions[act##name] = action; \
	VERIFY(connect(action, SIGNAL(triggered()), SLOT(on##name()))); \
}

void MainFrame::initActions()
{
	REG_ACT(Exit, QKeySequence::Quit, QIcon());
	REG_ACT(Save, QKeySequence::Save, QApplication::style()->standardIcon(QStyle::SP_DialogSaveButton));
}

void MainFrame::initToolbar()
{
	ASSERT(!m_actions.isEmpty());

	{
		QToolBar* bar = addToolBar(tr("&File"));
		bar->setIconSize(QSize(24, 24));
		bar->addAction(m_actions[actSave]);
	}
}

void MainFrame::initMenu()
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

void MainFrame::onLanguageLoading(const QByteArray& language)
{
	if (m_splash)
	{
		m_splash->showMessage("Load main language: " + QString::fromUtf8(language), Qt::AlignLeft | Qt::AlignBottom, Qt::white);
	}
}

void MainFrame::openEditor(const QByteArray& languageId)
{
	if (m_openedEditors.contains(languageId))
	{
		return;
	}
	ASSERT(m_controller->languages().contains(languageId));

	EditorDockWidget* dockWidget = NULL;
	if (!m_editors.contains(languageId))
	{
		dockWidget = new EditorDockWidget(languageId, languageId == m_controller->mainLanguageId(), this);
		VERIFY(connect(dockWidget, SIGNAL(closing(const QByteArray&)), SLOT(closeEditor(const QByteArray&))));
		VERIFY(connect(dockWidget->editor(), SIGNAL(textChanged(const QString&, const QByteArray&, const quint32)), m_controller, SLOT(onTextChanged(const QString&, const QByteArray&, const quint32))));
		addDockWidget(Qt::RightDockWidgetArea, dockWidget, Qt::Vertical);
		
		m_editors[languageId] = dockWidget;
	}
	else
	{
		dockWidget = m_editors[languageId];
	}

	m_openedEditors.insert(languageId, dockWidget->editor());
	dockWidget->setVisible(true);

	dockWidget->editor()->setText(m_controller->languageData(languageId).messages[m_controller->currentHash()]);
}

void MainFrame::closeEditor(const QByteArray& languageId)
{
	ASSERT(m_openedEditors.contains(languageId));
	m_openedEditors.remove(languageId);
	m_editors[languageId]->setVisible(false);
}

void MainFrame::onMessageSelect(quint32 hash)
{
	foreach (ScriptEditor* editor, m_openedEditors)
	{
		const MessageSet& messageSet = m_controller->languageData(editor->languageId());
		if (messageSet.messages.contains(hash))
		{
			editor->setText(messageSet.messages[hash]);
		}
		else
		{
			ASSERT(m_controller->mainLanguageId() != editor->languageId());
			editor->setText("", 0);
		}
	}
}

void MainFrame::onFilterChanged(const QString& pattern)
{
	foreach (ScriptEditor* editor, m_openedEditors)
	{
		editor->setFilterPattern(pattern);
	}

	const QModelIndex currentIndex = m_controller->messagesSelectionModel()->currentIndex();
	if (currentIndex.isValid())
	{
		m_ui.messageList->scrollTo(currentIndex);
	}
}

//////////////////////////////////////////////////////////////////////////

void MainFrame::onExit()
{
	close();
}

void MainFrame::onSave()
{
	m_controller->saveTranslationData();
}

void MainFrame::closeEvent(QCloseEvent *event)
{
	if (m_controller->somethingIsChanged())
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

void MainFrame::buildViewMenu()
{
	ASSERT(m_viewMenu != NULL);
	m_viewMenu->clear();

	foreach (const QByteArray& languageId, m_controller->languages())
	{
		QAction* toggleEditorVisibleAct = m_viewMenu->addAction(languageId);
		toggleEditorVisibleAct->setCheckable(true);
		toggleEditorVisibleAct->setChecked(m_openedEditors.contains(languageId));
		VERIFY(connect(toggleEditorVisibleAct, SIGNAL(toggled(bool)), SLOT(toggleEditorVisible(bool))));
	}
}

void MainFrame::toggleEditorVisible(bool visible)
{
	QAction* action = dynamic_cast<QAction*>(sender());
	ASSERT(action != NULL);

	const QByteArray languageId = action->text().toLatin1();
	ASSERT(m_controller->languages().contains(languageId));

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
