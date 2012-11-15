#include "CompoundProgressHandler.h"

QHash<QString, int> CompoundProgressHandler::s_paksFileCount;
QHash<QString, int> CompoundProgressHandler::s_paksClusterCount;

static bool isPaksAction(const QString& action)
{
	return (action == "rebuildPaks" || action == "replacePaks" || action == "checkPaks");
}

static inline int s2c(quint64 size)
{
	const int clusterSize = 0x7C00;
	return static_cast<int>((size + clusterSize - 1) / clusterSize);
}

CompoundProgressHandler::CompoundProgressHandler(QObject* parent)
	: QObject(parent)
	, m_actionMax(0)
	, m_currentActionMax(0)
	, m_currentIterationFloor(0)
	, m_currentIterationMax(0)
{
	if (s_paksFileCount.isEmpty())
	{
#if !defined(_DEBUG)
		s_paksFileCount["Metroid1.pak"]     = 37168;
		s_paksFileCount["Metroid3.pak"]     = 38481;
		s_paksFileCount["Metroid4.pak"]     = 30725;
		s_paksFileCount["Metroid5.pak"]     = 29324;
		s_paksFileCount["Metroid6.pak"]     = 5219;
		s_paksFileCount["Metroid7.pak"]     = 6686;
#endif
		s_paksFileCount["Metroid8.pak"]     = 1031;
		s_paksFileCount["GuiDVD.pak"]       = 245;
		s_paksFileCount["GuiNAND.pak"]      = 351;
		s_paksFileCount["Logbook.pak"]      = 3080;
		s_paksFileCount["FrontEnd.pak"]     = 458;
		s_paksFileCount["NoARAM.pak"]       = 220;
		s_paksFileCount["MiscData.pak"]     = 263;
		s_paksFileCount["Worlds.pak"]       = 606;
		s_paksFileCount["UniverseArea.pak"] = 678;
	}
	if (s_paksClusterCount.isEmpty())
	{
#if !defined(_DEBUG)
		s_paksClusterCount["Metroid1.pak"]     = s2c(773174208);
		s_paksClusterCount["Metroid3.pak"]     = s2c(698251328);
		s_paksClusterCount["Metroid4.pak"]     = s2c(738060992);
		s_paksClusterCount["Metroid5.pak"]     = s2c(577712320);
		s_paksClusterCount["Metroid6.pak"]     = s2c(126914560);
		s_paksClusterCount["Metroid7.pak"]     = s2c(158443456);
#endif
		s_paksClusterCount["Metroid8.pak"]     = s2c(33171776);
		s_paksClusterCount["GuiDVD.pak"]       = s2c(2165696);
		s_paksClusterCount["GuiNAND.pak"]      = s2c(1212416);
		s_paksClusterCount["Logbook.pak"]      = s2c(26651200);
		s_paksClusterCount["FrontEnd.pak"]     = s2c(27923392);
		s_paksClusterCount["NoARAM.pak"]       = s2c(16658752);
		s_paksClusterCount["MiscData.pak"]     = s2c(355904);
		s_paksClusterCount["Worlds.pak"]       = s2c(1221248);
		s_paksClusterCount["UniverseArea.pak"] = s2c(15069440);
	}
}

void CompoundProgressHandler::subscribe(QObject* patcherWorker)
{
	VERIFY(connect(patcherWorker, SIGNAL(actionInit(int)), SLOT(onActionInit(int))));
	VERIFY(connect(patcherWorker, SIGNAL(actionProgress(int, const QString&)), SLOT(onActionProgress(int, const QString&))));
	VERIFY(connect(patcherWorker, SIGNAL(actionFinish()), SLOT(onActionFinish())));
	VERIFY(connect(patcherWorker, SIGNAL(subActionInit(int)), SLOT(onSubActionInit(int))));
	VERIFY(connect(patcherWorker, SIGNAL(subActionProgress(int, const QString&)), SLOT(onSubActionProgress(int, const QString&))));
	VERIFY(connect(patcherWorker, SIGNAL(subActionFinish()), SLOT(onSubActionFinish())));
}

void CompoundProgressHandler::onActionInit(int maximum)
{
	m_actionMax = maximum;

	if (isPaksAction(m_currentAction))
	{
		const QHash<QString, int>& progressMap = (m_currentAction == "rebuildPaks" ? s_paksFileCount : s_paksClusterCount);
		m_processedPaks.clear();
		m_currentActionMax = 0;
		foreach (int size, progressMap)
		{
			m_currentActionMax += size;
		}
		emit progressInit(m_currentActionMax);
	}
	else if (m_currentAction != "checkImage")
	{
		emit progressInit(maximum);
	}
}

void CompoundProgressHandler::onActionProgress(int progressValue, const QString& message)
{
	m_currentMessage = message;
	if (isPaksAction(m_currentAction))
	{
		const QHash<QString, int>& progressMap = (m_currentAction == "rebuildPaks" ? s_paksFileCount : s_paksClusterCount);
		ASSERT(progressMap.contains(message));

		m_currentIterationFloor = 0;		
		foreach (const QString& pak, m_processedPaks)
		{
			m_currentIterationFloor += progressMap[pak];
		}
		m_processedPaks.append(message);
		m_currentIterationMax = m_currentIterationFloor + progressMap[message];
	}
	else if (m_currentAction != "checkImage")
	{
		emit progress(progressValue, message);
	}
}

void CompoundProgressHandler::onActionFinish()
{
	if (m_currentAction != "checkImage")
	{
		emit progressFinish();
	}
}

void CompoundProgressHandler::onSubActionInit(int maximum)
{
	if (m_currentAction == "checkImage")
	{
		emit progressInit(maximum);
	}
}

void CompoundProgressHandler::onSubActionProgress(int value, const QString& message)
{
	Q_UNUSED(message);
	if (isPaksAction(m_currentAction))
	{
		const int progressValue = qMin(m_currentIterationMax, m_currentIterationFloor + value);
		emit progress(progressValue, m_currentMessage);
	}
	else if (m_currentAction == "checkImage")
	{
		emit progress(value, QString());
	}
}

void CompoundProgressHandler::onSubActionFinish()
{
	if (m_currentAction == "checkImage")
	{
		emit progressFinish();
	}
}

void CompoundProgressHandler::setCurrentAction(const QString& action)
{
	m_currentAction = action;
}