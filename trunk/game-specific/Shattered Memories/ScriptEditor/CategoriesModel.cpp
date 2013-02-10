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
	if (role == Qt::FontRole)
	{
		const QModelIndex parent = index.parent();
		if (!parent.isValid() && (index.row() == All || index.row() == Uncategorized))
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

	const void* categoryPtr = reinterpret_cast<const void*>(&parent);
	return createIndex(parent.categories.indexOf(category), 0, const_cast<void*>(categoryPtr));
}

int CategoriesModel::columnCount(const QModelIndex &parent) const 
{
	Q_UNUSED(parent);
	return 1;
}
