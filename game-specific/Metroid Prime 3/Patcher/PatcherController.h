#pragma once
#include "CompoundProgressHandler.h"
#include "PatcherWorker.h"
#include <memory>
#include <QThread>

class PatcherWorker;

class PatcherController : public QObject
{
	Q_OBJECT

public:
	PatcherController(QObject* parent = NULL);

	Q_SLOT void addStep(const QByteArray& step);
	Q_SLOT void setImagePath(const QString& path);
	Q_SLOT void addResourcesPath(const QString& path);
	Q_SLOT void setTempPath(const QString& path);
	Q_SLOT void requestStop();
	Q_SLOT void start();

	Q_SIGNAL void completed();
	Q_SIGNAL void stepStarted(const QByteArray&);
	Q_SIGNAL void stepCompleted(const QByteArray&);
	Q_SIGNAL void failed(const QByteArray& step, int errorCode, const QString& errorData, const QString& errorMessage, const QString& errorDescription);
	Q_SIGNAL void canceled(const QByteArray& step);

	QObject* progressHandler();

	int errorCode() const;
	QString errorData() const;
	QString errorMessage() const;
	QString errorDescription() const;
	void waitForWorker();

private:
	bool runStep(const QByteArray& step);
	bool processStep();
	void finish();
	Q_SLOT void onStepCompleted();
	Q_SLOT void onStepFailed(int errorCode, const QString& errorData, const QString& errorMessage, const QString& errorDescription);

private:
	std::auto_ptr<PatcherWorker> m_workerPtr;
	PatcherWorker* m_worker;
	QThread m_workerThread;
	QList<QByteArray> m_steps;
	QByteArray m_currentStep;
	CompoundProgressHandler m_progressHandler;

	int m_errorCode;
	QString m_errorData;
	QString m_errorMessage;
	QString m_errorDescription;
};