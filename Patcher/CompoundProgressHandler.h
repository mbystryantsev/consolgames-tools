#pragma once
#include <QHash>
#include <QStringList>

class CompoundProgressHandler : public QObject
{
	Q_OBJECT

public:
	CompoundProgressHandler(QObject* parent = NULL);
	void subscribe(QObject* patcherWorker);
	Q_SLOT void setCurrentAction(const QString& action);

	Q_SIGNAL void progressInit(int maximum);
	Q_SIGNAL void progress(int value, const QString& message);
	Q_SIGNAL void progressFinish();

private:
	Q_SLOT void onActionInit(int maximum);
	Q_SLOT void onActionProgress(int progress, const QString& message);
	Q_SLOT void onActionFinish();
	Q_SLOT void onSubActionInit(int maximum);
	Q_SLOT void onSubActionProgress(int progress, const QString& message);
	Q_SLOT void onSubActionFinish();

private:
	QString m_currentAction;
	QString m_currentMessage;
	int m_actionMax;
	int m_currentActionMax;
	int m_currentIterationFloor;
	int m_currentIterationMax;

	QStringList m_processedPaks;
	static QHash<QString, int> s_paksFileCount;
	static QHash<QString, int> s_paksClusterCount;
};