#include "CategoriesModel.h"
#include <QFont>

namespace
{

static bool operator==(const Category& a, const Category& b)
{
	return (&a == &b);
}

}

CategoriesModel::CategoriesModel(const Category& rootCategory, QObject* parent)
	: QAbstractItemModel(parent)
	, m_rootCategory(rootCategory)
	, m_stat(NULL)
{
}

const Category& CategoriesModel::categoryByIndex(const QModelIndex& index) const
{
	const void* categoryPtr = index.internalPointer();
	if (categoryPtr == NULL)
	{
		return m_rootCategory;
	}
	return *static_cast<const Category*>(categoryPtr);
}

QModelIndex CategoriesModel::indexByCategory(const Category& category) const
{
	const Category& parent = findParentCategory(category);
	return createIndex(parent.categories.indexOf(category) + (parent == m_rootCategory ? s_extraCategoriesCount : 0), 0, const_cast<Category*>(&category));
}

void CategoriesModel::setTranslationStatictics(const QMap<const Category*, QPair<int, int>>& stat)
{
	m_stat = &stat;
}

const Category& CategoriesModel::findParentCategory(const Category& category) const
{
	const Category* parent = findParentCategory(category, m_rootCategory);
	ASSERT(parent != NULL);
	return *parent;
}

const Category* CategoriesModel::findParentCategory(const Category& category, const Category& current) const
{
	if (current.categories.contains(category))
	{
		return &current;
	}
	foreach (const Category& next, current.categories)
	{
		const Category* parent = findParentCategory(category, next);
		if (parent != NULL)
		{
			return parent;
		}
	}
	return NULL;
}

QVariant CategoriesModel::data(const QModelIndex& index, int role) const 
{
	if (role == Qt::DisplayRole)
	{
		const QModelIndex parent = index.parent();
		if (index.column() == CategoryName)
		{
			if (!parent.isValid())
			{
				if (index.row() == All)
				{
					return QString("All");
				}
				if (index.row() == Uncategorized)
				{
					return QString("Uncategorized");
				}
				const int row = index.row() - s_extraCategoriesCount;
				ASSERT(row < m_rootCategory.categories.size());
				return m_rootCategory.categories[row].name;
			}
			const Category& category = categoryByIndex(parent);
			const int row = index.row();
			ASSERT(row <= category.categories.size());
			return category.categories[row].name;
		}
		if (index.column() == ProgressInfo && m_stat != NULL)
		{
			const QPair<int, int> progress = m_stat->value(static_cast<const Category*>(index.internalPointer()));
			const double percent = (progress.second == 0 ? 0 : (static_cast<double>(progress.first) * 100.0) / progress.second);
			return QString("%1%").arg(percent, 0, 'f', 1);
		}
	}
	if (role == Qt::FontRole)
	{
		const QModelIndex parent = index.parent();
		if (!parent.isValid() && index.column() == CategoryName && (index.row() == All || index.row() == Uncategorized))
		{
			QFont font;
			font.setItalic(true);
			return font;
		}
	}
	return QVariant();
}

QModelIndex CategoriesModel::index(int row, int column, const QModelIndex& parent) const 
{
	if (!parent.isValid())
	{
		if (row == All || row == Uncategorized)
		{
			return createIndex(row, column, row);
		}
		const void* categoryPtr = reinterpret_cast<const void*>(&m_rootCategory.categories[row - s_extraCategoriesCount]);
		return createIndex(row, column, const_cast<void*>(categoryPtr));
	}
	
	const Category& category = categoryByIndex(parent);
	const void* categoryPtr = reinterpret_cast<const void*>(&category.categories[row]);
	return createIndex(row, column, const_cast<void*>(categoryPtr));
}

int CategoriesModel::rowCount(const QModelIndex& parent) const 
{
	if (!parent.isValid())
	{
		return m_rootCategory.categories.size() + s_extraCategoriesCount;
	}
	if (parent.internalId() == All || parent.internalId() == Uncategorized)
	{
		return 0;
	}

	const Category& category = categoryByIndex(parent);
	return category.categories.size();
}

QModelIndex CategoriesModel::parent(const QModelIndex& index) const 
{
	if (index.internalPointer() == NULL || index.internalId() == All || index.internalId() == Uncategorized)
	{
		return QModelIndex();
	}

	const Category& category = categoryByIndex(index);
	const Category& parent = findParentCategory(category);
	if (parent == m_rootCategory)
	{
		return QModelIndex();
	}

	return indexByCategory(parent);
}

int CategoriesModel::columnCount(const QModelIndex &parent) const 
{
	Q_UNUSED(parent);
	return s_columnCount;
}

QVariant CategoriesModel::headerData(int section, Qt::Orientation orientation, int role) const
{
	Q_UNUSED(orientation);

	if (role == Qt::DisplayRole)
	{
		if (section == CategoryName)
		{
			return "Category";
		}
		if (section == ProgressInfo)
		{
			return "Progress";
		}
	}

	return QVariant();
}

void CategoriesModel::updateRange(const QModelIndex& indexFrom, const QModelIndex& indexTo)
{
	emit dataChanged(indexFrom, indexTo);
}
