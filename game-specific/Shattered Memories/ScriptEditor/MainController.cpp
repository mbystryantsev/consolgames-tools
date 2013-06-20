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

static QString contentPathFor(const QString& filename)
{
	return QString("../content/common/%1").arg(filename);
}

static QString langPath(const QString& shortLangId)
{
	return QString("../content/%1/text/wii").arg(shortLangId);
}

MainController::MainController(MainFrame* parent)
	: QObject(parent)
	, m_parent(parent)
	, m_categoriesModel(NULL)
	, m_messagesModel(NULL)
	, m_languageChanged(false)
	, m_categoriesChanged(false)
	, m_commentsChanged(false)
	, m_authorsChanged(false)
	, m_tagsChanged(false)
{
	VERIFY(connect(this, SIGNAL(loadingLanguage(const QByteArray&)), m_parent, SLOT(onLanguageLoading(const QByteArray&))));

	loadLanguages();
	loadComments();
	loadAuthors();
	loadTags();

	initCategories();
	initCategoriesModels();
	initMessagesModels();
}

MainController::~MainController()
{
}

void MainController::initCategories()
{
	m_rootCategory = Category::fromFile(contentPathFor("categories.txt"));
	calculateTranslatedCount(m_rootCategory);
}

void MainController::initCategoriesModels()
{
	m_categoriesModel = new CategoriesModel(m_rootCategory, this);
	m_categoriesSelectionModel = new QItemSelectionModel(m_categoriesModel);
	m_categoriesModel->setTranslationStatictics(m_translatedCount);

	VERIFY(connect(m_categoriesSelectionModel, SIGNAL(currentChanged(const QModelIndex&, const QModelIndex&)), SLOT(onCategoryChanged(const QModelIndex&))));
}

void MainController::initMessagesModels()
{
	m_messagesModel = new MessageSetModel(mainLanguageData(), m_authors, this);
	m_messagesModel->setSourceMessages(mainSourceLanguageData());
	m_messagesModel->setRootCategory(m_rootCategory);
	m_messagesModel->setComments(m_comments);
	m_messagesModel->setTags(m_tags);

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

void MainController::loadComments()
{
	const MessageSet comments = Strings::loadMessages(contentPathFor("comments.txt"));
	m_comments.clear();
	foreach (const Message& message, comments.messages)
	{
		m_comments.insert(message.hash, message.text);
	}
}

void MainController::loadAuthors()
{
	QFile file(contentPathFor("authors.txt"));
	VERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
	QTextStream stream(&file);

	while (!stream.atEnd())
	{
		const QString line = stream.readLine().trimmed().simplified();
		if (line.isEmpty())
		{
			continue;
		}

		const QStringList items = line.split(' ');
		if (items.size() != 2)
		{
			DLOG << "Warning: invalid authors line = " << line;
			continue;
		}

		const quint32 hash = Strings::strToHash(items.first());
		if (hash == 0)
		{
			DLOG << "Warning: invalid hash = " << items.first();
			continue;
		}

		if (m_authors.contains(hash))
		{
			DLOG << "Warning: duplicated record detected for hash " << items.first();
			continue;
		}

		m_authors[hash] = items[1];
	}
}

void MainController::loadTags()
{
	QFile file(contentPathFor("tags.txt"));
	VERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
	QTextStream stream(&file);

	while (!stream.atEnd())
	{
		const QString line = stream.readLine().trimmed().simplified();
		if (line.isEmpty())
		{
			continue;
		}

		const int sepIndex = line.indexOf(' ');
		if (sepIndex < 0)
		{
			return;
		}
		const QString tagsString = line.right(line.size() - sepIndex - 1);
		const QString hashString = line.left(sepIndex);

		const quint32 hash = Strings::strToHash(hashString);
		if (hash == 0)
		{
			DLOG << "Warning: invalid hash = " << hashString;
			continue;
		}

		if (m_tags.contains(hash))
		{
			DLOG << "Warning: duplicated record detected for hash " << hashString;
			continue;
		}

		QStringList tags = tagsString.split(',');
		for (int i = 0; i < tags.size(); i++)
		{
			tags[i] = tags[i].trimmed();
		}

		m_tags[hash] = tags;
	}
}

typedef QList<QPair<QString,QString>> LanguageList;

static LanguageList loadLanguageList()
{
	LanguageList list;

	QFile file(contentPathFor("languages.csv"));
	VERIFY(file.open(QIODevice::ReadOnly | QIODevice::Text));
	QTextStream stream(&file);

	while (!stream.atEnd())
	{
		const QString line = stream.readLine().trimmed().simplified();
		if (line.isEmpty())
		{
			continue;
		}

		const QStringList info = line.split(';');
		if (info.size() != 2)
		{
			DLOG << "Invalid language info: " << line;
			continue;
		}

		list.append(QPair<QString, QString>(info.first(), info.last()));
	}

	return list;
}

static QVariantMap loadSettings()
{
	QVariantMap settings;

	QFile file("ScriptEditor.config");

	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		return settings;
	}

	QTextStream stream(&file);

	while (!stream.atEnd())
	{
		const QString line = stream.readLine().trimmed().simplified();
		if (line.isEmpty())
		{
			continue;
		}

		const QStringList pair = line.split('=');
		if (pair.size() != 2)
		{
			DLOG << "Invalid settings line: " << line;
			continue;
		}

		settings[pair.first()] = pair.last();
	}

	return settings;
}

void MainController::loadLanguages()
{
	const LanguageList list = loadLanguageList();
	const QVariantMap settings = loadSettings();

	const QString mainSourceLanguage = settings.value("mainSourceLanguage", "English").toString();
	const QString mainTargetLanguage = settings.value("mainTargetLanguage", "Russian").toString();

	if (list.isEmpty())
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
	else
	{
		for (LanguageList::const_iterator lang = list.begin(); lang != list.end(); lang++)
		{
			if (lang->second == mainTargetLanguage)
			{
				loadMainLanguage(lang->second.toUtf8(), langPath(lang->first));
			}
			else
			{
				loadSourceLanguage(lang->second.toUtf8(), langPath(lang->first));
				if (lang->second == mainSourceLanguage)
				{
					setMainSourceLanguage(mainTargetLanguage.toUtf8());
				}
			}
		}

	}
}

void MainController::loadMainLanguage(const QByteArray& languageId, const QString& path)
{
	emit loadingLanguage(languageId);
	m_mainLanguageId = languageId;

	m_filesInfo.clear();
	m_scripts[languageId] = Strings::loadMessages(path, &m_filesInfo);
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
	return saveMainLanguage() && saveCategories() && saveComments() && saveAuthors() && saveTags();
}

bool MainController::saveMainLanguage()
{
	if (!m_languageChanged)
	{
		return true;
	}

	foreach (const QString& filename, m_filesInfo.keys())
	{
		DLOG << "Saving file: " << filename;
		if (!Strings::saveMessages(filename, mainLanguageData().messages, m_filesInfo[filename]))
		{
			DLOG << "Error ocurred during file saving!";
			return false;
		}
	}

	m_languageChanged = false;
	return true;
}

bool MainController::saveComments()
{
	if (!m_commentsChanged)
	{
		return true;
	}

	DLOG << "Saving comments...";

	QList<quint32> toRemove;
	foreach (quint32 hash, m_comments.keys())
	{
		if (m_comments[hash].isEmpty())
		{
			toRemove << hash;
		}
	}
	foreach (quint32 hash, toRemove)
	{
		m_comments.remove(hash);
	}


	if (!Strings::saveMessages(contentPathFor("comments.txt"), m_comments))
	{
		return false;
	}
	m_commentsChanged = false;
	return true;
}

bool MainController::saveCategories()
{
	return true;
}

bool MainController::saveAuthors()
{
	if (!m_authorsChanged)
	{
		return true;
	}

	DLOG << "Saving authors...";

	QFile file(contentPathFor("authors.txt"));
	VERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));

	QTextStream stream(&file);

	foreach (quint32 hash, m_authors.keys())
	{
		stream << Strings::hashToStr(hash) << ' ' << m_authors[hash] << '\n';
	}
	
	m_authorsChanged = false;
	return true;
}

bool MainController::saveTags()
{
	if (!m_tagsChanged)
	{
		return true;
	}

	DLOG << "Saving tags...";

	QFile file(contentPathFor("tags.txt"));
	VERIFY(file.open(QIODevice::WriteOnly | QIODevice::Text));

	QTextStream stream(&file);

	foreach (quint32 hash, m_tags.keys())
	{
		const QStringList& tags = m_tags[hash];
		if (tags.isEmpty())
		{
			continue;
		}
		
		stream << Strings::hashToStr(hash) << ' ';
		
		bool isFirst = true;
		foreach (const QString& tag, tags)
		{
			if (!isFirst)
			{
				stream << ", ";
			}
			stream << tag;

			isFirst = false;
		}
		stream << '\n';
	}

	m_tagsChanged = false;
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
	if (!index.isValid())
	{
		return;
	}
	emit messageSelected(m_messagesFilterModel->mapToSource(index).internalId());
}

void MainController::updateTranslationStatistics(quint32 hash, const QString& changedText)
{
	if (mainSourceLanguageData().messages.contains(hash))
	{
		const QString& originalText = mainSourceLanguageData().messages[hash].text;
		QString prevText = mainLanguageData().messages[hash].text;
		if (Strings::isReference(prevText))
		{
			quint32 refHash = Strings::extractReferenceHash(prevText);
			if (mainLanguageData().messages.contains(refHash))
			{
				prevText = mainLanguageData().messages[refHash].text;
			}
		}

		QString currText = changedText;
		if (Strings::isReference(currText))
		{
			const quint32 refHash = Strings::extractReferenceHash(currText);
			if (mainLanguageData().messages.contains(refHash))
			{
				currText = mainLanguageData().messages[refHash].text;
			}
		}

		const bool prevStateTranslated = (prevText != originalText);
		const bool currStateTranslated = (currText != originalText);

		if (prevStateTranslated && !currStateTranslated)
		{
			decreaseTranslatedCount(hash);
		}
		else if (!prevStateTranslated && currStateTranslated)
		{
			increaseTranslatedCount(hash);
		}
	}
}

void MainController::onTextChanged(const QString& text, const QByteArray& languageId, quint32 hash)
{
	ASSERT(languageId == m_mainLanguageId);
	ASSERT(hash == 0 || mainLanguageData().hashes.contains(hash));

	Q_UNUSED(languageId);

	if (hash != 0 && mainLanguageData().messages[hash].text != text)
	{
		updateTranslationStatistics(hash, text);

		m_scripts[m_mainLanguageId].messages[hash].text = text;
		m_messagesModel->updateString(hash);
		m_languageChanged = true;
	}
}

void MainController::onFilterChanged(const QString& pattern)
{
	const QModelIndex currentIndex = m_messagesFilterModel->mapToSource(m_messagesSelectionModel->currentIndex());
	m_messagesFilterModel->setPattern(pattern);

	if (currentIndex.isValid())
	{
		m_messagesSelectionModel->clearSelection();
		const int row = m_messagesFilterModel->mapFromSource(currentIndex).row();
		const QItemSelection selection(m_messagesFilterModel->index(row, 0), m_messagesFilterModel->index(row, m_messagesFilterModel->columnCount() - 1));
		m_messagesSelectionModel->select(selection, QItemSelectionModel::SelectCurrent | QItemSelectionModel::Rows);
	}
}

void MainController::onCommentChanged(const QString& text, quint32 hash)
{
	if (!m_comments.contains(hash) && text.isEmpty())
	{
		return;
	}

	m_comments[hash] = text;
	m_commentsChanged = true;
}

void MainController::onTagsChanged(const QStringList& tags, quint32 hash)
{
	if (!m_tags.contains(hash) && tags.isEmpty())
	{
		return;
	}

	m_tags[hash] = tags;
	m_tagsChanged = true;
}

const QByteArray& MainController::mainLanguageId() const
{
	return m_mainLanguageId;
}

bool MainController::somethingIsChanged() const
{
	return (m_languageChanged || m_commentsChanged || m_categoriesChanged || m_authorsChanged || m_tagsChanged);
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

const QMap<quint32,QString>& MainController::comments() const
{
	return m_comments;
}

const QMap<quint32, QStringList>& MainController::tags() const
{
	return m_tags;
}

void MainController::increaseTranslatedCount(quint32 hash, const Category& category, int value)
{
	if (&category == &m_rootCategory)
	{
		const Category* allPtr = reinterpret_cast<const Category*>(CategoriesModel::All);
		m_translatedCount[allPtr].first += value;

		if (!m_rootCategory.contains(hash))
		{
			const Category* uncategorizedPtr = reinterpret_cast<const Category*>(CategoriesModel::Uncategorized);
			m_translatedCount[uncategorizedPtr].first += value;
		}

		m_categoriesModel->updateRange(m_categoriesModel->index(0, 0), m_categoriesModel->index(CategoriesModel::s_extraCategoriesCount - 1, CategoriesModel::s_columnCount - 1));
	}

	if (category.contains(hash))
	{
		m_translatedCount[&category].first += value;

		if (&category != &m_rootCategory)
		{
			const QModelIndex index = m_categoriesModel->indexByCategory(category);
			const QModelIndex updateIndex = m_categoriesModel->index(index.row(), CategoriesModel::ProgressInfo, m_categoriesModel->parent(index));
			m_categoriesModel->updateRange(updateIndex, updateIndex);
		}
	}
	foreach (const Category& childCategory, category.categories)
	{
		increaseTranslatedCount(hash, childCategory, value);
	}
}

void MainController::decreaseTranslatedCount(quint32 hash)
{
	increaseTranslatedCount(hash, m_rootCategory, -1);
}

void MainController::increaseTranslatedCount(quint32 hash)
{
	increaseTranslatedCount(hash, m_rootCategory, 1);
}

int MainController::translatedCount(const QList<quint32>& hashes) const
{
	int count = 0;
	foreach (quint32 hash, hashes)
	{
		QString text = mainLanguageData().messages[hash].text;
		if (Strings::isReference(text))
		{
			const quint32 refHash = Strings::extractReferenceHash(text);
			if (mainLanguageData().messages.contains(refHash))
			{
				text = mainLanguageData().messages[refHash].text;
			}
		}
		if (mainSourceLanguageData().messages.contains(hash) && text != mainSourceLanguageData().messages[hash].text)
		{
			count++;
		}
	}
	return count;
}

void MainController::calculateTranslatedCount(const Category& category)
{
	const QList<quint32> hashes = category.allMessages();
	m_translatedCount[&category].first = translatedCount(hashes);
	m_translatedCount[&category].second = hashes.size();

	foreach (const Category& childCategory, category.categories)
	{
		calculateTranslatedCount(childCategory);
	}

	if (&category == &m_rootCategory)
	{
		const Category* allPtr = reinterpret_cast<const Category*>(CategoriesModel::All);
		m_translatedCount[allPtr].first = translatedCount(mainLanguageData().hashes);
		m_translatedCount[allPtr].second = mainLanguageData().hashes.size();

		const Category* uncategorizedPtr = reinterpret_cast<const Category*>(CategoriesModel::Uncategorized);
		const QList<quint32> uncategorizedHashes = MessageSetModel::excludeFromList(mainLanguageData().hashes, hashes);
		m_translatedCount[uncategorizedPtr].first = translatedCount(uncategorizedHashes);
		m_translatedCount[uncategorizedPtr].second = uncategorizedHashes.size();
	}
}
