#pragma once
#include "PatcherWorker.h"
#include <QThread>
#include <memory>

namespace ShatteredMemories
{

class PatcherController: public QObject
{
	Q_OBJECT
	Q_ENUMS(PatcherProcessor::ErrorCode);

public:
	PatcherController(QObject* parent = NULL);

	QList<QByteArray> actionList();
	bool isStarted() const;
	bool isStopRequested() const;

	Q_SLOT void reset();

	Q_SLOT void setImagePath(const QString& path);
	Q_SLOT void addResourcesPath(const QString& path);
	Q_SLOT void setTempPath(const QString& path);
	Q_SLOT void requestStop();
	Q_SLOT void start();

	Q_SLOT void setCheckArchives(bool check);
	Q_SLOT void setCheckImage(bool check);

	Q_SIGNAL void completed();
	Q_SIGNAL void stepStarted(const QByteArray&);
	Q_SIGNAL void stepCompleted(const QByteArray&);
	Q_SIGNAL void failed(const QByteArray& step, int errorCode, const QString& errorData);
	Q_SIGNAL void canceled(const QByteArray& step);

	Q_SIGNAL void progressInit(int max);
	Q_SIGNAL void progressChanged(int value, const QString& message);
	Q_SIGNAL void progressFinish();

	int errorCode() const;
	QString errorData() const;
	void waitForWorker();

private:
	void buildActionList();
	bool runStep(const QByteArray& step);
	bool processStep();
	void processCancel();
	void finish();

	Q_SLOT void addStep(const QByteArray& step);
	Q_SLOT void onStepCompleted();
	Q_SLOT void onStepFailed(int errorCode, const QString& errorData);

private:
	bool m_started;

	std::auto_ptr<PatcherWorker> m_workerPtr;
	PatcherWorker* m_worker;
	QThread m_workerThread;
	QList<QByteArray> m_steps;
	QByteArray m_currentStep;
	//CompoundProgressHandler m_progressHandler;
	bool m_stopRequested;

	bool m_checkArchivesData;
	bool m_checkArchivesInImage;
	bool m_checkImage;

	int m_errorCode;
	QString m_errorData;

public:
	static QString errorName(int code);
};

}