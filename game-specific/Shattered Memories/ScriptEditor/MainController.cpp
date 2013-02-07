#include "MainController.h"
#include "MainFrame.h"
#include "CategoriesModel.h"
#include "MessageSetModel.h"
#include "MessageSetFilterModel.h"
#include <QItemSelectionModel>
#include <QTextStream>
#include <QClipboard>
#include <QApplication>

using namespace ShatteredMemories;

LOG_CATEGORY("ScriptEditor.MainController");

MainController::MainController(MainFrame* parent)
	: QObject(parent)
	, m_parent(parent)
	, m_categoriesModel(NULL)
	, m_messagesModel(NULL)
	, m_languageChanged(false)
	, m_categoriesChanged(false)
	, m_commentsChanged(false)
	, m_authorsChanged(false)
{
	VERIFY(connect(this, SIGNAL(loadingLanguage(const QByteArray&)), m_parent, SLOT(onLanguageLoading(const QByteArray&))));

	loadLanguages();

	initCategories();
	initCategoriesModels();
	initMessagesModels();
}

MainController::~MainController()
{
}

void MainController::initCategories()
{
	m_rootCategory = Category::fromFile("../content/common/categories.txt");
}

void MainController::initCategoriesModels()
{
	m_categoriesModel = new CategoriesModel(m_rootCategory, this);
	m_categoriesSelectionModel = new QItemSelectionModel(m_categoriesModel);

	VERIFY(connect(m_categoriesSelectionModel, SIGNAL(currentChanged(const QModelIndex&, const QModelIndex&)), SLOT(onCategoryChanged(const QModelIndex&))));
}

void MainController::initMessagesModels()
{
	m_messagesModel = new MessageSetModel(mainLanguageData(), this);
	m_messagesModel->setSourceMessages(mainSourceLanguageData());

	m_messagesFilterModel = new MessageSetFilterModel(this);
	m_messagesFilterModel->setSourceModel(m_messagesModel);

	m_messagesSelectionModel = new QItemSelectionModel(m_messagesFilterModel, this);

	VERIFY(connect(m_messagesSelectionModel, SIGNAL(currentChanged(const QModelIndex&, const QModelIndex&)), SLOT(onMessageChanged(const QModelIndex&))));
}

QAbstractItemModel* MainController::messagesModel() const
{
	return m_messagesModel;
}

QAbstractItemModel* MainController::messagesFilterModel() const
{
	return m_messagesFilterModel;
}

QItemSelectionModel* MainController::messagesSelectionModel() const
{
	return m_messagesSelectionModel;
}

QAbstractItemModel* MainController::categoriesModel() const
{
	return m_categoriesModel;
}

QItemSelectionModel* MainController::categoriesSelectionModel() const
{
	return m_categoriesSelectionModel;
}

static QString langPath(const QString& shortLangId)
{
	return QString("../content/%1/text/wii").arg(shortLangId);
}

void MainController::loadComments()
{
	const MessageSet comments = Strings::loadMessages("../content/common/comments.txt");
	m_comments.clear();
	foreach (const Message& message, comments.messages)
	{
		m_comments.insert(message.hash, message.text);
	}
}

void MainController::loadAuthors()
{
	//QFile file();
}

void MainController::loadLanguages()
{
	loadMainLanguage("Russian",   langPath("rus"));
	loadSourceLanguage("English", langPath("eng"));
	loadSourceLanguage("Japan",   langPath("jap"));
	loadSourceLanguage("French",  langPath("fre"));
	loadSourceLanguage("Spanish", langPath("spa"));
	loadSourceLanguage("German",  langPath("ger"));
	loadSourceLanguage("Italian", langPath("ita"));
	setMainSourceLanguage("English");
}

void MainController::loadMainLanguage(const QByteArray& languageId, const QString& path)
{
	emit loadingLanguage(languageId);
	m_mainLanguageId = languageId;

	m_scripts[languageId] = Strings::loadMessages(path);

	m_filesInfo.clear();
	m_filesInfo[QDir(path).absoluteFilePath("ShatteredMemories.txt")] = m_scripts[languageId].hashes;
}

void MainController::loadSourceLanguage(const QByteArray& languageId, const QString& path)
{
	emit loadingLanguage(languageId);
	m_scripts[languageId] = Strings::loadMessages(path);
	Strings::expandReferences(m_scripts[languageId]);
}

void MainController::setMainSourceLanguage(const QByteArray& languageId)
{
	m_mainSourceLanguageId = languageId;
}

bool MainController::saveTranslationData()
{
	return saveMainLanguage() && saveCategories() && saveComments() && saveAuthors();	
}

bool MainController::saveMainLanguage()
{
	return true;
}

bool MainController::saveComments()
{
	return true;
}

bool MainController::saveCategories()
{
	return true;
}

bool MainController::saveAuthors()
{
	return true;
}

const MessageSet& MainController::mainLanguageData() const
{
	ASSERT(!m_mainLanguageId.isEmpty());
	return languageData(m_mainLanguageId);
}

const MessageSet& MainController::mainSourceLanguageData() const
{
	ASSERT(!m_mainSourceLanguageId.isEmpty());
	return languageData(m_mainSourceLanguageId);
}

const MessageSet& MainController::languageData(const QByteArray& languageId) const
{
	ASSERT(m_scripts.contains(languageId));
	return *m_scripts.find(languageId);
}

const QList<QByteArray> MainController::languages() const
{
	return m_scripts.keys();
}

void MainController::onCategoryChanged(const QModelIndex& index)
{
	if (index.internalId() == CategoriesModel::All)
	{
		m_messagesModel->resetCategory();
	}
	else if (index.internalId() == CategoriesModel::Uncategorized)
	{
		m_messagesModel->setExceptionCategory(m_rootCategory);
	}
	else
	{
		const Category& category = m_categoriesModel->categoryByIndex(index);
		m_messagesModel->setCategory(category);
	}
}

void MainController::onMessageChanged(const QModelIndex& index)
{
	emit messageSelected(m_messagesFilterModel->mapToSource(index).internalId());
}

void MainController::onTextChanged(const QString& text, const QByteArray& languageId, quint32 hash)
{
	ASSERT(languageId == m_mainLanguageId);
	ASSERT(hash == 0 || mainLanguageData().hashes.contains(hash));

	Q_UNUSED(languageId);

	if (hash != 0 && mainLanguageData().messages[hash].text != text)
	{
		m_scripts[m_mainLanguageId].messages[hash].text = text;
		m_messagesModel->updateString(hash);
		m_languageChanged = false;
	}
}

void MainController::onFilterChanged(const QString& pattern)
{
	const QModelIndex currentIndex = m_messagesFilterModel->mapToSource(m_messagesSelectionModel->currentIndex());
	m_messagesFilterModel->setPattern(pattern);

	if (currentIndex.isValid())
	{
		m_messagesSelectionModel->clearSelection();
		m_messagesSelectionModel->select(m_messagesFilterModel->mapFromSource(currentIndex), QItemSelectionModel::SelectCurrent | QItemSelectionModel::Rows);
	}
}

const QByteArray& MainController::mainLanguageId() const
{
	return m_mainLanguageId;
}

bool MainController::somethingIsChanged() const
{
	return (m_languageChanged || m_commentsChanged || m_categoriesChanged || m_authorsChanged);
}

quint32 MainController::currentHash() const
{
	const QModelIndex index = m_messagesSelectionModel->currentIndex();
	return index.isValid() ? m_messagesFilterModel->mapToSource(index).internalId() : 0;
}

void MainController::copyHashesToClipboard()
{
	QString text;
	QTextStream stream(&text);
	foreach (const QModelIndex& index, m_messagesSelectionModel->selectedRows())
	{
		stream << Strings::hashToStr(m_messagesFilterModel->mapToSource(index).internalId()) << '\n';
	}
	stream.flush();

	QApplication::clipboard()->setText(text);
}
