#include "MessageSetModel.h"
#include "Category.h"
#include <QColor>
#include <QFont>
#include <QStringList>

using namespace ShatteredMemories;

LOG_CATEGORY("ScriptEditor.MessageSetModel");

MessageSetModel::MessageSetModel(const MessageSet& messages, const QMap<quint32,QString>& authors, QObject* parent)
	: QAbstractItemModel(parent)
	, m_messages(messages)
	, m_sourceMessages(NULL)
	, m_authors(authors)
	, m_customCategory(false)
	, m_comments(NULL)
	, m_tags(NULL)
{
}

int MessageSetModel::columnCount(const QModelIndex& parent) const 
{
	Q_UNUSED(parent);
	return colCount;
}

QVariant MessageSetModel::data(const QModelIndex& index, int role) const 
{
	const quint32 hash = index.internalId();
	if (role == Qt::DisplayRole)
	{
		if (index.column() == colHash)
		{
			return Strings::hashToStr(index.internalId());
		}
		if (index.column() == colText)
		{
			if (Strings::isReference(m_messages.messages[hash].text))
			{
				const quint32 refHash = Strings::extractReferenceHash(m_messages.messages[hash].text);
				if (m_messages.messages.contains(refHash))
				{
					return m_messages.messages[refHash].text;
				}
				return QString("###ERROR### Invalid reference! Related string not found!");
			}
			return m_messages.messages[index.internalId()].text.simplified();
		}
		if (index.column() == colFlags)
		{
			return formatFlags(index.internalId());
		}
		if (index.column() == colAuthor)
		{
			return m_authors.value(hash);
		}
	}
	if (role == Qt::BackgroundColorRole)
	{
		if (Strings::isReference(m_messages.messages[hash].text))
		{
			const quint32 refHash = extractReferenceHash(hash);
			if (!m_messages.messages.contains(refHash))
			{
				return QColor(Qt::red);
			}
			return QColor(220, 220, 220);
		}
		if (m_sourceMessages != NULL)
		{
			const bool noTrTag = (m_tags != NULL && m_tags->contains(hash) && m_tags->value(hash).contains("notr"));

			if (!noTrTag && m_sourceMessages->messages.contains(hash))
			{
				const QString& message = m_messages.messages[hash].text;
				const QString& sourceMessage = m_sourceMessages->messages[hash].text;
				if (sourceMessage == message && !message.trimmed().isEmpty())
				{
					return QColor(255, 220, 220);
				}
			}
		}
	}
	if (role == Qt::FontRole)
	{
		if (index.column() == colHash || index.column() == colFlags)
		{
			static const QFont font("Lucida Console");
			return font;
		}
	}
	return QVariant();
}

QModelIndex MessageSetModel::index(int row, int column, const QModelIndex& parent) const 
{
	Q_UNUSED(parent);

	const quint32 hash = hashSource()[row];
	return createIndex(row, column, hash);
}

QModelIndex MessageSetModel::parent(const QModelIndex& index) const
{
	Q_UNUSED(index);
	return QModelIndex();
}

int MessageSetModel::rowCount(const QModelIndex& parent) const 
{
	if (!parent.isValid())
	{
		return hashSource().size();
	}
	return 0;
}

const MessageSet& MessageSetModel::messages() const
{
	return m_messages;
}

void MessageSetModel::setSourceMessages(const MessageSet& sourceMessages)
{
	m_sourceMessages = &sourceMessages;
}

QModelIndex MessageSetModel::indexByHash(quint32 hash)
{
	ASSERT(hashSource().contains(hash));
	return index(hashSource().indexOf(hash));
}

bool MessageSetModel::isReference(quint32 hash) const
{
	ASSERT(m_messages.messages.contains(hash));
	return Strings::isReference(m_messages.messages[hash].text);
}

quint32 MessageSetModel::extractReferenceHash(quint32 hash) const
{
	ASSERT(m_messages.messages.contains(hash));
	return Strings::extractReferenceHash(m_messages.messages[hash].text);
}

const MessageSet* MessageSetModel::sourceMessages() const
{
	return m_sourceMessages;
}

QList<quint32> MessageSetModel::excludeFromList(const QList<quint32>& hashes, const QList<quint32>& hashesToExclude)
{
	QList<quint32> result;
	result.reserve(hashes.size());

	foreach (quint32 hash, hashes)
	{
		if (!hashesToExclude.contains(hash))
		{
			result << hash;
		}
	}

	return result;
}

void MessageSetModel::setCategory(const Category& category)
{
	beginResetModel();
	m_customCategory = true;
	m_categoryHashes = category.allMessages();
	endResetModel();
}

void MessageSetModel::setRootCategory(const Category& category)
{
	m_categorizedHashes = category.allMessages().toSet();
}

void MessageSetModel::setExceptionCategory(const Category& category)
{
	beginResetModel();
	m_customCategory = true;
	m_categoryHashes = excludeFromList(m_messages.hashes, category.allMessages());
	endResetModel();
}

void MessageSetModel::resetCategory()
{
	beginResetModel();
	m_customCategory = false;
	m_categoryHashes.clear();
	endResetModel();
}

void MessageSetModel::updateString(quint32 hash)
{
	if (!hashSource().contains(hash))
	{
		return;
	}

	const QModelIndex index = indexByHash(hash);
	emit dataChanged(createIndex(index.row(), 0, hash), createIndex(index.row(), colCount - 1, hash));

	if (isReference(hash))
	{
		const quint32 refHash = extractReferenceHash(hash);
		if (hashSource().contains(refHash))
		{
			const QModelIndex index = indexByHash(refHash);
			emit dataChanged(createIndex(index.row(), 0, hash), createIndex(index.row(), colCount - 1, hash));
		}
	}
}

const QList<quint32>& MessageSetModel::hashSource() const
{
	return m_customCategory ? m_categoryHashes : m_messages.hashes;
}

QString MessageSetModel::formatFlags(quint32 hash) const
{
	enum
	{
		indexCategorized,
		indexHasComment,
		flagCount
	};

	QString flags(flagCount, ' ');
	flags[indexCategorized] = m_categorizedHashes.contains(hash) ? 'T' : ' ';
	flags[indexHasComment] = (m_comments != NULL && m_comments->contains(hash)) ? 'C' : ' ';

	return flags;
}

void MessageSetModel::setComments(const QMap<quint32, QString>& comments)
{
	m_comments = &comments;
}

void MessageSetModel::setTags(const QMap<quint32, QStringList>& tags)
{
	m_tags = &tags;
}

const QMap<quint32, QStringList>* MessageSetModel::tags() const
{
	return m_tags;
}

const QMap<quint32, QString>* MessageSetModel::comments() const
{
	return m_comments;
}