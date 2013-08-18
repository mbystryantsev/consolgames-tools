#pragma once
#include "ProgressNotifier.h"

namespace ShatteredMemories
{

class CompoundProgressNotifier : public ProgressNotifier
{
	Q_OBJECT;

public:
	class ProgressGuard
	{
	public:
		ProgressGuard(CompoundProgressNotifier& notifier);
		~ProgressGuard();

	private:
		CompoundProgressNotifier& m_notifier;
	};

	friend class ProgressGuard;

public:
	CompoundProgressNotifier();
	~CompoundProgressNotifier();

	Q_SLOT void reset();
	Q_SLOT void requestStop();
	Q_SLOT void setCurrentNotifier(QObject* notifier, double coeff = 0);
	Q_SLOT void unbindCurrentNotifier();

private:
	Q_SLOT void onProgressInit(int maxValue);
	Q_SLOT void onProgressChanged(int value, const QString& message);
	Q_SLOT void onProgressFinished();
	Q_SLOT void checkForForceEnd();

private:
	double m_processedCoeffSum;
	double m_currentCoeff;
	int m_currentMax;
	bool m_progressFinished;
	QObject* m_currentNotifier;

private:
	static const int s_progressSize;
};

}
