#include "MessageSetFilterModel.h"
#include "MessageSetModel.h"
#include "Category.h"

using namespace ShatteredMemories;

MessageSetFilterModel::MessageSetFilterModel(QObject* parent)
	: QSortFilterProxyModel(parent)
	, m_patternAtBegin(false)
	, m_patternAtEnd(false)
	, m_caseSensitivity(Qt::CaseInsensitive)
{
}

void MessageSetFilterModel::setPattern(const QString& pattern)
{
	m_pattern = pattern;
	m_pattern.replace("\\r", "\r");
	m_pattern.replace("\\n", "\n");

	m_caseSensitivity = Qt::CaseInsensitive;
	if (m_pattern.startsWith('!'))
	{
		m_caseSensitivity = Qt::CaseSensitive;
		m_pattern = m_pattern.right(m_pattern.size() - 1);
	}

	m_patternAtBegin = false;
	if (m_pattern.startsWith('^'))
	{
		m_patternAtBegin = true;
		m_pattern = m_pattern.right(m_pattern.size() - 1);
	}

	m_patternAtEnd = false;
	if (m_pattern.endsWith('$'))
	{
		m_patternAtEnd = true;
		m_pattern.truncate(m_pattern.size() - 1);
	}

	m_tags.clear();
	m_hashes.clear();
	if (!m_patternAtBegin && !m_patternAtEnd && pattern.startsWith('[') && pattern.endsWith(']'))
	{
		QString newPattern = m_pattern.right(m_pattern.size() - 1);
		newPattern.truncate(newPattern.size() - 1);
		const QStringList tagData = newPattern.split(',');
		foreach (const QString& tag, tagData)
		{
			const QString trimmed = tag.trimmed();
			m_tags << trimmed;

			const quint32 hash = Strings::strToHash(trimmed);
			if (hash != 0)
			{
				m_hashes.insert(hash);
			}
		}
	}

	invalidateFilter();
}

bool MessageSetFilterModel::hasVisibleRows(int row) const
{
	const QModelIndex index = sourceModel()->index(row, 0);
	const int rows = sourceModel()->rowCount(index);
	for (int i = 0; i < rows; i++)
	{
		if (filterAcceptsRow(i, index))
		{
			return true;
		}
	}
	return false;
}

bool MessageSetFilterModel::filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const 
{
	const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
	const quint32 hash = index.internalId();

	if ((!m_tags.isEmpty() || !m_hashes.isEmpty()) && (m_hashes.contains(hash) || containsAnyTag(hash)))
	{
		return true;
	}
	if (m_pattern.isEmpty())
	{
		return true;
	}

	const MessageSetModel& model = dynamic_cast<const MessageSetModel&>(*sourceModel());
	const MessageSet& messageSet = model.messages();
	const QString& text = messageSet.messages.find(hash)->text;
	const quint32 refHash = Strings::isReference(text) ? Strings::extractReferenceHash(text) : 0;

	if (stringSatisfyFilter(refHash == 0 ? text : messageSet.messages.find(refHash)->text))
	{
		return true;
	}

	if (model.sourceMessages() != NULL && model.sourceMessages()->messages.contains(hash))
	{
		if (stringSatisfyFilter(model.sourceMessages()->messages.find(hash)->text))
		{
			return true;
		}
	}

	return false;
}

bool MessageSetFilterModel::stringSatisfyFilter(const QString& text) const
{
	if (m_patternAtEnd && m_patternAtBegin)
	{
		return (text.compare(text, m_caseSensitivity) == 0);
	}
	if (m_patternAtBegin)
	{
		return text.startsWith(m_pattern, m_caseSensitivity);
	}
	if (m_patternAtEnd)
	{
		return text.endsWith(m_pattern, m_caseSensitivity);
	}
	return text.contains(m_pattern, m_caseSensitivity);
}

bool MessageSetFilterModel::containsAnyTag(quint32 hash) const
{
	const MessageSetModel& model = dynamic_cast<const MessageSetModel&>(*sourceModel());
	const QMap<quint32, QStringList>* tagsCollection = model.tags();
	if (tagsCollection == NULL || !tagsCollection->contains(hash))
	{
		return false;
	}
	
	const QStringList& tags = *(tagsCollection->find(hash));
	foreach (const QString& tag, m_tags)
	{
		if (tags.contains(tag))
		{
			return true;
		}
	}

	return false;
}