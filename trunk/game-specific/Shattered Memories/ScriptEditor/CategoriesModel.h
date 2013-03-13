#pragma once
#include "Category.h"
#include <QAbstractItemModel>

class CategoriesModel : public QAbstractItemModel
{
public:
	enum ExtraCategories
	{
		All,
		Uncategorized,
		s_extraCategoriesCount
	};

	enum Columns
	{
		CategoryName,
		ProgressInfo,
		s_columnCount
	};

public:
	CategoriesModel(const Category& rootCategory, QObject* parent = NULL);

	const Category& categoryByIndex(const QModelIndex& index) const;
	QModelIndex indexByCategory(const Category& category) const;
	void setTranslationStatictics(const QMap<const Category*, QPair<int, int>>& stat);
	void updateRange(const QModelIndex& indexFrom, const QModelIndex& indexTo);

	virtual QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
	virtual QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
	virtual int rowCount(const QModelIndex& parent) const override;
	virtual QModelIndex parent(const QModelIndex& index) const override;
	virtual int columnCount(const QModelIndex &parent) const override;
	virtual QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

private:
	const Category& findParentCategory(const Category& category) const;
	const Category* findParentCategory(const Category& category, const Category& current) const;
	
private:
	const Category& m_rootCategory;
	QMap<int, const Category* const> m_categoriesMap;
	const QMap<const Category*, QPair<int, int>>* m_stat;
};
