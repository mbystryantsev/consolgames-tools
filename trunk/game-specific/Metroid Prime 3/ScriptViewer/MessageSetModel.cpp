#include "MessageSetModel.h"
#include <QColor>

MessageSetModel::MessageSetModel(const QVector<MessageSet>& messages, QObject* parent)
	: QAbstractItemModel(parent)
	, m_messages(messages)
{
}

int MessageSetModel::columnCount(const QModelIndex& parent) const 
{
	Q_UNUSED(parent);
	return colCount;
}

QVariant MessageSetModel::data(const QModelIndex& index, int role) const 
{
	QModelIndex parent = index.parent();
	if (role == Qt::DisplayRole)
	{
		if (parent.isValid())
		{
			if (index.column() == colIndex)
			{
				return index.row();
			}
			return m_messages[parent.row()].messages[index.row()].text.left(64).simplified();
		}
		if (index.column() == colText)
		{
			return QString::number(m_messages[index.row()].nameHashes[0]);
		}
	}
	if (role == Qt::BackgroundColorRole)
	{
		return parent.isValid() ? QVariant() : QColor(240, 240, 240);
	}
	return QVariant();
}

QModelIndex MessageSetModel::index(int row, int column, const QModelIndex& parent) const 
{
	return createIndex(row, column, parent.isValid() ? parent.row() : -1);
}

QModelIndex MessageSetModel::parent(const QModelIndex& index) const
{
	return index.internalId() >= 0 ? createIndex(index.internalId(), 0, -1) : QModelIndex();
}

int MessageSetModel::rowCount(const QModelIndex& parent) const 
{
	if (!parent.isValid())
	{
		return m_messages.size();
	}
	if (parent.parent().isValid())
	{
		return 0;
	}
	return m_messages[parent.row()].messages.size();
}

const QVector<MessageSet>& MessageSetModel::messages() const
{
	return m_messages;
}
