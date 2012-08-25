#pragma once
#include <ScriptParser.h>
#include <QAbstractItemModel>

class MessageSetModel : public QAbstractItemModel
{
public:
	MessageSetModel(const QVector<MessageSet>& m_messages, QObject* parent = NULL);

	// QAbstractItemModel
	virtual int columnCount(const QModelIndex& parent) const override;
	virtual QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
	virtual QModelIndex index(int row, int column, const QModelIndex& parent) const override;
	virtual QModelIndex parent(const QModelIndex & index) const override;
	virtual int rowCount(const QModelIndex & parent) const override;

	const QVector<MessageSet>& messages() const;

protected:
	enum Column
	{
		colIndex,
		colText,
		colCount
	};

protected:
	const QVector<MessageSet>& m_messages;

};