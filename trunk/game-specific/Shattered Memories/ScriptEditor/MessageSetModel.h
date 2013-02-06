#pragma once
#include <Strings.h>
#include <QAbstractItemModel>
#include <QList>

struct Category;

class MessageSetModel : public QAbstractItemModel
{
public:
	MessageSetModel(const ShatteredMemories::MessageSet& messages, QObject* parent = NULL);

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
	static bool isReference(const QString& str);
	static quint32 extractReferenceHash(const QString& str);
	bool isReference(quint32 hash) const;
	quint32 extractReferenceHash(quint32 hash) const;

	Q_SLOT void setCategory(const Category& category);
	Q_SLOT void setExceptionCategory(const Category& category);
	Q_SLOT void resetCategory();
	Q_SLOT void updateString(quint32 hash);

private:
	const QList<quint32>& hashSource() const;

private:
	enum Column
	{
		colHash,
		colText,
		colCount
	};

private:
	const ShatteredMemories::MessageSet& m_messages;
	const ShatteredMemories::MessageSet* m_sourceMessages;
	QList<quint32> m_categoryHashes;
	bool m_customCategory;
};