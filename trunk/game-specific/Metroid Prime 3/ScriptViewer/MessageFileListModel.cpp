#include "MessageFileListModel.h"
#include <QFileInfo>

MessageFileListModel::MessageFileListModel(const ScriptData& scriptData, QObject* parent)
	: QAbstractListModel(parent)
	, m_scriptData(scriptData)
	, m_filenames(scriptData.keys())
{
}

QVariant MessageFileListModel::data(const QModelIndex& index, int role) const 
{
	if (role == Qt::DisplayRole)
	{
		const QString& fileName = m_filenames[index.row()];
		const QString baseName = QFileInfo(fileName).baseName();
		if (!m_diffInfo.contains(fileName))
		{
			return baseName;
		}
		const DiffFileInfo& info = m_diffInfo[fileName];
		const double percentsBySets = (static_cast<double>(info.messageSetDiffs) / static_cast<double>(info.messageSetCount)) * 100.0;
		//const double percentsByMessages = (static_cast<double>(info.messageDiffs) / static_cast<double>(info.messageCount)) * 100.0;

		return QString("%1   -   %2%").arg(baseName).arg(percentsBySets, 0, 'f', 1);
	}
	return QVariant();
}

QModelIndex MessageFileListModel::index(int row, int column, const QModelIndex& parent) const 
{
	Q_UNUSED(parent);
	return createIndex(row, column);
}

int MessageFileListModel::rowCount(const QModelIndex & parent) const 
{
	Q_UNUSED(parent);
	return m_scriptData.size();
}

const QStringList& MessageFileListModel::filenames() const
{
	return m_filenames;
}

const MessageFileListModel::DiffInfo& MessageFileListModel::diffInfo() const
{
	return m_diffInfo;
}

void MessageFileListModel::setDiffInfo(const QString& file, const DiffFileInfo& info)
{
	m_diffInfo[file] = info;
}