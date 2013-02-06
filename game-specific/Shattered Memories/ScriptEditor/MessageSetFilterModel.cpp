#include "MessageSetFilterModel.h"
#include "MessageSetModel.h"
#include "Category.h"
#include <QStringList>

using namespace ShatteredMemories;

MessageSetFilterModel::MessageSetFilterModel(QObject* parent)
	: QSortFilterProxyModel(parent)
	, m_patternAtBegin(false)
	, m_patternAtEnd(false)
	, m_filterHash(0)
	, m_filterIndex(-1)
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

	bool isIdPointer = false;
	m_filterHash = 0;
	m_filterIndex = -1;
	if (!m_patternAtBegin && !m_patternAtEnd && pattern.startsWith('[') && pattern.endsWith(']'))
	{
		QString newPattern = m_pattern.right(m_pattern.size() - 1);
		newPattern.truncate(newPattern.size() - 1);
		const QStringList idData = newPattern.split(':');
		if (idData.size() == 1 || idData.size() == 2)
		{
			m_filterHash = idData[0].toULongLong(&isIdPointer, 16);
			if (isIdPointer && idData.size() == 2)
			{
				m_filterIndex = idData[1].toInt(&isIdPointer);
			}
		}
	}

	if (!isIdPointer)
	{
		m_filterHash = 0;
		m_filterIndex = -1;
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

	if (!m_hashes.isEmpty() && !m_hashes.contains(hash))
	{
		return false;
	}
	if (m_pattern.isEmpty())
	{
		return true;
	}

	const MessageSetModel& model = dynamic_cast<const MessageSetModel&>(*sourceModel());
	const MessageSet& messageSet = model.messages();
	if (m_filterHash != 0)
	{
		if (!messageSet.messages.contains(m_filterHash))
		{
			return false;
		}
		if (m_filterIndex >= 0 && m_filterIndex != sourceRow)
		{
			return false;
		}
		return true;
	}

	const QString& text = messageSet.messages.find(hash)->text;
	if (stringSatisfyFilter(text))
	{
		return true;
	}

	if (model.sourceMessages() != NULL && model.sourceMessages()->messages.contains(hash))
	{
		if (stringSatisfyFilter(model.sourceMessages()->messages[sourceRow].text))
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
