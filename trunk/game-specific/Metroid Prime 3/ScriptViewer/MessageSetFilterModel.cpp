#include "MessageSetFilterModel.h"
#include "MessageSetModel.h"

MessageSetFilterModel::MessageSetFilterModel()
	: QSortFilterProxyModel()
	, m_patternAtBegin(false)
	, m_patternAtEnd(false)
{
}

void MessageSetFilterModel::setPattern(const QString& pattern)
{
	m_pattern = pattern;
	m_pattern.replace("\\r", "\r");
	m_pattern.replace("\\n", "\n");

	if (m_pattern.startsWith('^'))
	{
		m_patternAtBegin = true;
		m_pattern = m_pattern.right(m_pattern.size() - 1);
	}
	if (m_pattern.endsWith('$'))
	{
		m_patternAtEnd = true;
		m_pattern.truncate(m_pattern.size() - 1);
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
	if (m_pattern.isEmpty())
	{
		return true;
	}

	if (!sourceParent.isValid())
	{
 		return hasVisibleRows(sourceRow);
	}

	const MessageSetModel& model = dynamic_cast<const MessageSetModel&>(*sourceModel());
	const QString& text = model.messages()[sourceParent.row()].messages[sourceRow].text;

	if (stringSatisfyFilter(text))
	{
		return true;
	}

	if (model.sourceMessages() != NULL)
	{
		const quint64 hash = model.messages()[sourceParent.row()].nameHashes[0];
		if (model.sourceMessages()->contains(hash))
		{
			const MessageSet& messageSet = *(*model.sourceMessages())[hash];
			if (messageSet.messages.size() > sourceRow)
			{
				if (stringSatisfyFilter(messageSet.messages[sourceRow].text))
				{
					return true;
				}
			}
		}
	}

	return false;
}

bool MessageSetFilterModel::stringSatisfyFilter(const QString& text) const
{
	if (m_patternAtEnd && m_patternAtBegin)
	{
		return (text.compare(text, Qt::CaseInsensitive) == 0);
	}
	if (m_patternAtBegin)
	{
		return text.startsWith(m_pattern, Qt::CaseInsensitive);
	}
	if (m_patternAtEnd)
	{
		return text.endsWith(m_pattern, Qt::CaseInsensitive);
	}
	return text.contains(m_pattern, Qt::CaseInsensitive);
}
