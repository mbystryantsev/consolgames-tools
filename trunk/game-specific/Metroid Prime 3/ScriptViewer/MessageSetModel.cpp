#include "MessageSetModel.h"
#include <QColor>

MessageSetModel::MessageSetModel(const QVector<MessageSet>& messages, QObject* parent)
	: QAbstractItemModel(parent)
	, m_messages(messages)
	, m_sourceMessages(NULL)
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
			return QString::number(m_messages[index.row()].nameHashes[0], 16).toUpper().rightJustified(16, '0');
		}
	}
	if (role == Qt::BackgroundColorRole)
	{
		if (!parent.isValid())
		{
			return QColor(240, 240, 240);
		}
		if (m_sourceMessages != NULL)
		{
			const quint64 hash = m_messages.at(parent.row()).nameHashes[0];
			if (m_sourceMessages->contains(hash))
			{
				const QString& message = m_messages.at(parent.row()).messages[index.row()].text;
				const QString& sourceMessage = (*m_sourceMessages)[hash]->messages[index.row()].text;
				if (sourceMessage == message && !message.trimmed().isEmpty())
				{
					return QColor(QColor(255, 220, 220));
				}
			}
		}
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

void MessageSetModel::setSourceMessages(const MessageMap& sourceMessages)
{
	m_sourceMessages = &sourceMessages;
}
