#pragma once
#include <Strings.h>
#include <QAbstractItemModel>
#include <QList>

struct Category;

class MessageSetModel : public QAbstractItemModel
{
public:
	MessageSetModel(const ShatteredMemories::MessageSet& messages, const QMap<quint32,QString>& authors, QObject* parent = NULL);

	// QAbstractItemModel
	virtual int columnCount(const QModelIndex& parent) const override;
	virtual QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
	virtual QModelIndex index(int row, int column = 0, const QModelIndex& parent = QModelIndex()) const override;
	virtual QModelIndex parent(const QModelIndex & index) const override;
	virtual int rowCount(const QModelIndex & parent) const override;

	const ShatteredMemories::MessageSet& messages() const;
	void setSourceMessages(const ShatteredMemories::MessageSet& sourceMessages);
	const ShatteredMemories::MessageSet* sourceMessages() const;
	QModelIndex indexByHash(quint32 hash);
	bool isReference(quint32 hash) const;
	quint32 extractReferenceHash(quint32 hash) const;
	QString formatFlags(quint32 hash) const;

	Q_SLOT void setCategory(const Category& category);
	Q_SLOT void setRootCategory(const Category& category);
	Q_SLOT void setComments(const QMap<quint32, QString>& comments);
	Q_SLOT void setTags(const QMap<quint32, QStringList>& tags);
	Q_SLOT void setExceptionCategory(const Category& category);
	Q_SLOT void resetCategory();
	Q_SLOT void updateString(quint32 hash);

	const QMap<quint32, QStringList>* tags() const;
	const QMap<quint32, QString>* comments() const;

	static QList<quint32> excludeFromList(const QList<quint32>& hashes, const QList<quint32>& hashesToExclude);

private:
	const QList<quint32>& hashSource() const;

public:
	enum Column
	{
		colHash,
		colFlags,
		colAuthor,
		colText,
		colCount
	};

private:
	const ShatteredMemories::MessageSet& m_messages;
	const ShatteredMemories::MessageSet* m_sourceMessages;
	const QMap<quint32, QString>& m_authors;
	QList<quint32> m_categoryHashes;
	QSet<quint32> m_categorizedHashes;
	const QMap<quint32, QString>* m_comments;
	const QMap<quint32, QStringList>* m_tags;
	bool m_customCategory;
};