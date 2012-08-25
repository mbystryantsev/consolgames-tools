#pragma once
#include <QSortFilterProxyModel>

class MessageSetFilterModel : public QSortFilterProxyModel
{
public:
	void setPattern(const QString& pattern);

protected:
	bool hasVisibleRows(int row) const;
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override;

protected:
	QString m_pattern;
};