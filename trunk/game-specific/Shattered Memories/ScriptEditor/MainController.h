#pragma once
#include "Category.h"
#include <Strings.h>
#include <QSet>
#include <memory>

class MessageSetModel;
class MessageSetFilterModel;
class QItemSelectionModel;
class QSortFilterProxyModel;
class QAbstractItemModel;
class CategoriesModel;
class MainFrame;

class MainController : public QObject
{
	Q_OBJECT

public:
	MainController(MainFrame* parent);
	~MainController();

	QAbstractItemModel* messagesModel() const;
	QAbstractItemModel* messagesFilterModel() const;
	QItemSelectionModel* messagesSelectionModel() const;
	QAbstractItemModel* categoriesModel() const;
	QItemSelectionModel* categoriesSelectionModel() const;

	const ShatteredMemories::MessageSet& mainLanguageData() const;
	const ShatteredMemories::MessageSet& mainSourceLanguageData() const;
	const ShatteredMemories::MessageSet& languageData(const QByteArray& languageId) const;
	const QList<QByteArray> languages() const;
	const QByteArray& mainLanguageId() const;

	quint32 currentHash() const;
	bool somethingIsChanged() const;
	bool saveTranslationData();
	void copyHashesToClipboard();

private:
	void initCategories();
	void initCategoriesModels();
	void initMessagesModels();
	void loadComments();
	void loadAuthors();
	void loadLanguages();
	void loadMainLanguage(const QByteArray& languageId, const QString& path);
	void loadSourceLanguage(const QByteArray& languageId, const QString& path);
	void setMainSourceLanguage(const QByteArray& languageId);

	bool saveMainLanguage();
	bool saveComments();
	bool saveCategories();
	bool saveAuthors();

	Q_SIGNAL void loadingLanguage(const QByteArray& languageId);
	Q_SIGNAL void messageSelected(quint32 hash);

	Q_SLOT void onCategoryChanged(const QModelIndex& index);
	Q_SLOT void onMessageChanged(const QModelIndex& index);
	Q_SLOT void onTextChanged(const QString& text, const QByteArray& languageId, quint32 hash);
	Q_SLOT void onFilterChanged(const QString& pattern);

private:
	MainFrame* m_parent;

	MessageSetModel* m_messagesModel;
	MessageSetFilterModel* m_messagesFilterModel;
	QItemSelectionModel* m_messagesSelectionModel;
	CategoriesModel* m_categoriesModel;
	QItemSelectionModel* m_categoriesSelectionModel;

	bool m_languageChanged;
	bool m_authorsChanged;
	bool m_commentsChanged;
	bool m_categoriesChanged;
	QByteArray m_mainLanguageId;
	QByteArray m_mainSourceLanguageId;

	QMap<QByteArray, ShatteredMemories::MessageSet> m_scripts;
	QMap<QString, QList<quint32>> m_filesInfo;
	Category m_rootCategory;
	QMap<quint32, QString> m_comments;
	QMap<quint32, QString> m_authors;
	QMap<quint32, QList<QString>> m_tags;
};