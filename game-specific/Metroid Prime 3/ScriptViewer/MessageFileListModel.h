#pragma once
#include <QAbstractListModel>
#include <ScriptParser.h>
#include <QStringList>

class MessageFileListModel : public QAbstractListModel
{
public:
	struct DiffFileInfo
	{
		DiffFileInfo()
			: messageCount(0)
			, messageDiffs(0)
			, messageSetCount(0)
			, messageSetDiffs(0)
		{
		}

		int messageCount;
		int messageDiffs;
		int messageSetCount;
		int messageSetDiffs;
	};

public:
	typedef QMap<QString,QVector<MessageSet>> ScriptData;
	typedef QMap<QString,DiffFileInfo> DiffInfo;

	MessageFileListModel(const ScriptData& scriptData, QObject* parent = NULL);

	virtual QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
	virtual QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
	virtual int rowCount(const QModelIndex & parent) const override;

	const QStringList& filenames() const;
	const DiffInfo& diffInfo() const;
	void setDiffInfo(const QString& file, const DiffFileInfo& info);

protected:
	const ScriptData& m_scriptData;
	const QStringList m_filenames;
	DiffInfo m_diffInfo;
};
