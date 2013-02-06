#include "MessageSetModel.h"
#include "Category.h"
#include <QColor>
#include <QStringList>

using namespace ShatteredMemories;

LOG_CATEGORY("ScriptEditor.MessageSetModel");

MessageSetModel::MessageSetModel(const MessageSet& messages, QObject* parent)
	: QAbstractItemModel(parent)
	, m_messages(messages)
	, m_sourceMessages(NULL)
	, m_customCategory(false)
{
}

int MessageSetModel::columnCount(const QModelIndex& parent) const 
{
	Q_UNUSED(parent);
	return colCount;
}

const QRegExp referenceExp("\\{REF:([0-9A-Fa-f]{8})\\}");

bool MessageSetModel::isReference(const QString& str)
{
	return referenceExp.exactMatch(str);
}

quint32 MessageSetModel::extractReferenceHash(const QString& str)
{
	QRegExp re(referenceExp);
	if (re.indexIn(str) < 0)
	{
		return 0;
	}
	return Strings::strToHash(re.cap(1));
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
		if (isReference(m_messages.messages[hash].text))
		{
			const quint32 refHash = extractReferenceHash(m_messages.messages[hash].text);
			if (m_messages.messages.contains(refHash))
			{
				return m_messages.messages[refHash].text;
			}
		}
		return m_messages.messages[index.internalId()].text.simplified();
	}
	if (role == Qt::BackgroundColorRole)
	{
		if (isReference(m_messages.messages[hash].text))
		{
			return QColor(220, 220, 220);
		}
		if (m_sourceMessages != NULL)
		{
			if (m_sourceMessages->messages.contains(hash))
			{
				const QString& message = m_messages.messages[hash].text;
				const QString& sourceMessage = m_sourceMessages->messages[hash].text;
				if (sourceMessage == message && !message.trimmed().isEmpty())
				{
					return QColor(QColor(255, 220, 220));
				}
			}
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
	return isReference(m_messages.messages[hash].text);
}

quint32 MessageSetModel::extractReferenceHash(quint32 hash) const
{
	ASSERT(m_messages.messages.contains(hash));
	return extractReferenceHash(m_messages.messages[hash].text);
}

const MessageSet* MessageSetModel::sourceMessages() const
{
	return m_sourceMessages;
}

static QList<quint32> categoryHashes(const Category& category)
{
	QList<quint32> result = category.messages;
	foreach (const Category& child, category.categories)
	{
		result.append(categoryHashes(child));
	}

	return result;
}

static QList<quint32> excludeFromList(const QList<quint32>& hashes, const QList<quint32>& hashesToExclude)
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
	m_categoryHashes = categoryHashes(category);
	endResetModel();
}

void MessageSetModel::setExceptionCategory(const Category& category)
{
	beginResetModel();
	m_customCategory = true;
	m_categoryHashes = excludeFromList(m_messages.hashes, categoryHashes(category));
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
	const QModelIndex index = indexByHash(hash);
	emit dataChanged(index, index);

	if (isReference(hash))
	{
		const QModelIndex index = indexByHash(extractReferenceHash(hash));
		emit dataChanged(index, index);
	}
}

const QList<quint32>& MessageSetModel::hashSource() const
{
	return m_customCategory ? m_categoryHashes : m_messages.hashes;
}