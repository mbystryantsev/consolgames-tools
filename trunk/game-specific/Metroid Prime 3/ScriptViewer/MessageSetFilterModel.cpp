#include "MessageSetFilterModel.h"
#include "MessageSetModel.h"

void MessageSetFilterModel::setPattern(const QString& pattern)
{
	m_pattern = pattern;
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

	if (text.contains(m_pattern, Qt::CaseInsensitive))
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
				if (messageSet.messages[sourceRow].text.contains(m_pattern, Qt::CaseInsensitive))
				{
					return true;
				}
			}
		}
	}

	return false;
}
