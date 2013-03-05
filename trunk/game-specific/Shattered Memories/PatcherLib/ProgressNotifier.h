#pragma once
#include <QObject>
#include <QTime>

namespace ShatteredMemories
{

class ProgressNotifier : public QObject
{
	Q_OBJECT;

public:
	ProgressNotifier();

	Q_SLOT void requestStop();
	bool stopRequested();

protected:
	Q_SIGNAL void progressInit(int size);
	Q_SIGNAL void progressChanged(int value, const QString& message);
	Q_SIGNAL void progressFinish();

private:
	Q_SLOT void onProgressInit();

private:
	bool m_stopRequested;
	QTime m_timer;
};

}
