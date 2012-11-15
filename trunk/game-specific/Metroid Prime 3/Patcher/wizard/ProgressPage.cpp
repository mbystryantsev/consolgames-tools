#include "ProgressPage.h"
#include "PatchWizard.h"
#include <QAbstractButton>

QHash<QString,QString> ProgressPage::s_locInfo;

enum
{
	IndexProgress = 0,
	IndexCompleted = 1,
	IndexFailed = 2,
	IndexCanceled = 3
};

ProgressPage::ProgressPage()
	: Page<Ui_ProgressPage>()
	, m_state(InProgress)
{
	if (s_locInfo.isEmpty())
	{
		s_locInfo["initialize"] = QString::fromLocal8Bit("Инициализация");
		s_locInfo["rebuildPaks"] = QString::fromLocal8Bit("Обработка игровых данных");
		s_locInfo["checkData"] = QString::fromLocal8Bit("Проверка игровых данных");
		s_locInfo["replacePaks"] = QString::fromLocal8Bit("Замена игровых данных в образе");
		s_locInfo["checkPaks"] = QString::fromLocal8Bit("Проверка игровых архивов в образе");
		s_locInfo["checkImage"] = QString::fromLocal8Bit("Проверка образа");
		s_locInfo["finalize"] = QString::fromLocal8Bit("Удаление временных файлов");
	}

	VERIFY(connect(&m_patcherController, SIGNAL(completed()), SLOT(onPatchingCompleted())));
	VERIFY(connect(&m_patcherController, SIGNAL(stepStarted(const QByteArray&)), SLOT(onStepStarted(const QByteArray&))));
	VERIFY(connect(&m_patcherController, SIGNAL(stepCompleted(const QByteArray&)), SLOT(onStepCompleted(const QByteArray&))));
	VERIFY(connect(&m_patcherController, SIGNAL(failed(const QByteArray&, int, const QString&, const QString&, const QString&)),
		SLOT(onPatchingFailed(const QByteArray&, int, const QString&, const QString&, const QString&))));
	VERIFY(connect(&m_patcherController, SIGNAL(canceled(const QByteArray&)), SLOT(onPatchingCanceled(const QByteArray&))));

	VERIFY(connect(m_patcherController.progressHandler(), SIGNAL(progressInit(int)), m_ui.progressBar, SLOT(setMaximum(int))));
	VERIFY(connect(m_patcherController.progressHandler(), SIGNAL(progress(int, const QString&)), m_ui.progressBar, SLOT(setValue(int))));
	VERIFY(connect(m_patcherController.progressHandler(), SIGNAL(progressFinish()), m_ui.progressBar, SLOT(reset())));
	VERIFY(connect(m_patcherController.progressHandler(), SIGNAL(progress(int, const QString&)), SLOT(onProgress(int, const QString&))));
}

int ProgressPage::nextId() const 
{
	if (m_state == Failed)
	{
		return PatchWizard::PageFailed;
	}
	if (m_state == Canceled)
	{
		return PatchWizard::PageCanceled;
	}
	return PatchWizard::PageCompleted;
}

bool ProgressPage::isComplete() const 
{
	return (m_state != InProgress);
}

void ProgressPage::startPatching(const QStringList& actions)
{	
	QList<QByteArray> steps;
	steps.reserve(actions.size());
	foreach (const QString& action, actions)
	{
		m_patcherController.addStep(action.toLatin1());
	}

	m_patcherController.setImagePath(field("imagePath").toString());
	m_patcherController.setTempPath(field("tempPath").toString());
	m_patcherController.start();
}

void ProgressPage::finalizePatching()
{
}

void ProgressPage::initializePage()
{
	m_ui.stackedWidget->setCurrentIndex(IndexProgress);

	const PatchWizard& wiz = dynamic_cast<PatchWizard&>(*wizard());

	const bool isRiivolution = (wiz.patchType() == PatchWizard::RiivolutionPatch);
	const bool checkingEnabled = wiz.checkingEnabled();

	QStringList actions;

	actions << "initialize";
	actions << "rebuildPaks";
	if (checkingEnabled)
	{
		actions << "checkData";
	}
	actions << "replacePaks";
	if (!isRiivolution && checkingEnabled)
	{
		actions << "checkPaks";
#if !defined(_DEBUG)
		actions << "checkImage";
#endif
	}
	actions << "finalize";

	foreach (const QString& action, actions)
	{
		ASSERT(s_locInfo.contains(action));
		m_ui.actionList->addAction(action, s_locInfo[action]);
	}

	startPatching(actions);
}

void ProgressPage::onPatchingCompleted()
{
	m_state = Completed;
	m_ui.stackedWidget->setCurrentIndex(IndexCompleted);
	QApplication::beep();

	emit completeChanged();
}

void ProgressPage::onStepStarted(const QByteArray& step)
{
	m_ui.actionList->setActionState(QString::fromLatin1(step), ActionListWidget::Running);
}

void ProgressPage::onStepCompleted(const QByteArray& step)
{
	m_ui.actionList->setActionState(QString::fromLatin1(step), ActionListWidget::Completed);
	m_ui.progressText->setText(QString());
}

void ProgressPage::onPatchingFailed(const QByteArray& step, int errorCode, const QString& errorData, const QString& errorMessage, const QString& errorDescription)
{
	m_state = Failed;
	m_ui.stackedWidget->setCurrentIndex(IndexFailed);
	MessageBeep(MB_ICONERROR);

	m_ui.actionList->setActionState(QString::fromLatin1(step), ActionListWidget::Failed);
	m_ui.errorMessage->setText(errorMessage);
	m_ui.errorDescription->setText(errorDescription);

	PatchWizard* wiz = reinterpret_cast<PatchWizard*>(wizard());
	ASSERT(wiz != NULL);

	wiz->setErrorCode(errorCode);
	wiz->setErrorData(QString::fromLatin1(QString("%1;%2").arg(errorCode).arg(errorData).toLatin1().toBase64()));

	emit completeChanged();
}

void ProgressPage::onPatchingCanceled(const QByteArray& step)
{
	m_state = Canceled;
	m_ui.stackedWidget->setCurrentIndex(IndexCanceled);
	QApplication::beep();

	m_ui.actionList->setActionState(QString::fromLatin1(step), ActionListWidget::Canceled);

	emit completeChanged();
}

void ProgressPage::onProgress(int, const QString& message)
{
	m_ui.progressText->setText(message);
}