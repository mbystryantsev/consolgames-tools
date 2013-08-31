#include "ProgressPage.h"
#include "PatchWizard.h"
#include "Configurator.h"
#include <QAbstractButton>
#include <QMessageBox>

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
		s_locInfo["initialize"]      = tr("�������������");
		s_locInfo["rebuildArchives"] = tr("��������� ������� ������");
		s_locInfo["checkData"]       = tr("�������� ������� ������");
		s_locInfo["replaceArchives"] = tr("������ ������� ������ � ������");
		s_locInfo["checkArchives"]   = tr("�������� ������� ������� � ������");
		s_locInfo["checkImage"]      = tr("�������� ������");
		s_locInfo["finalize"]        = tr("�������� ��������� ������");
	}

	VERIFY(connect(&m_patcherController, SIGNAL(completed()), SLOT(onPatchingCompleted())));
	VERIFY(connect(&m_patcherController, SIGNAL(stepStarted(const QByteArray&)), SLOT(onStepStarted(const QByteArray&))));
	VERIFY(connect(&m_patcherController, SIGNAL(stepCompleted(const QByteArray&)), SLOT(onStepCompleted(const QByteArray&))));
	VERIFY(connect(&m_patcherController, SIGNAL(failed(const QByteArray&, int, const QString&)),
		SLOT(onPatchingFailed(const QByteArray&, int, const QString&))));
	VERIFY(connect(&m_patcherController, SIGNAL(canceled(const QByteArray&)), SLOT(onPatchingCanceled(const QByteArray&))));

	VERIFY(connect(&m_patcherController, SIGNAL(progressInit(int)), m_ui.progressBar, SLOT(setMaximum(int))));
	VERIFY(connect(&m_patcherController, SIGNAL(progressChanged(int, const QString&)), m_ui.progressBar, SLOT(setValue(int))));
	VERIFY(connect(&m_patcherController, SIGNAL(progressFinish()), m_ui.progressBar, SLOT(reset())));
	VERIFY(connect(&m_patcherController, SIGNAL(progressChanged(int, const QString&)), SLOT(onProgress(int, const QString&))));

	m_ui.progressBar->reset();
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

void ProgressPage::startPatching()
{	
	const Configurator& configurator = Configurator::instanse();
	configurator.configure(m_patcherController);

	m_patcherController.start();

	m_ui.staff->start();
}

void ProgressPage::finalizePatching()
{
	m_ui.staff->stop();
}

void ProgressPage::initializePage()
{
	m_ui.stackedWidget->setCurrentIndex(IndexProgress);

	foreach (const QByteArray& action, m_patcherController.actionList())
	{
		ASSERT(s_locInfo.contains(action));
		m_ui.actionList->addAction(action, s_locInfo[action]);
	}

	VERIFY(disconnect(wizard()->button(QWizard::CancelButton), SIGNAL(clicked()), wizard(), SLOT(reject())));
	VERIFY(connect(wizard()->button(QWizard::CancelButton ), SIGNAL(clicked()), SLOT(onCancelPressed())));

	startPatching();
}

void ProgressPage::onPatchingCompleted()
{
	m_state = Completed;
	m_ui.stackedWidget->setCurrentIndex(IndexCompleted);
	QApplication::beep();

	emit completeChanged();
	wizard()->button(QWizard::CancelButton)->setEnabled(false);
	finalizePatching();
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

void ProgressPage::onPatchingFailed(const QByteArray& step, int errorCode, const QString& errorData)
{
	m_state = Failed;
	m_ui.stackedWidget->setCurrentIndex(IndexFailed);
	MessageBeep(MB_ICONERROR);

	m_ui.actionList->setActionState(QString::fromLatin1(step), ActionListWidget::Failed);
	m_ui.errorMessage->setText(m_patcherController.errorMessage());
	m_ui.errorDescription->setText(m_patcherController.errorDescription());

	Configurator& configurator = Configurator::instanse();
	configurator.setErrorCode(errorCode);
	configurator.setErrorData(QString("%1;%2;%3").arg(errorCode).arg(m_patcherController.errorName(errorCode)).arg(errorData).toLatin1().toBase64());

	emit completeChanged();
	wizard()->button(QWizard::CancelButton)->setEnabled(false);

	finalizePatching();
}

void ProgressPage::onPatchingCanceled(const QByteArray& step)
{
	m_state = Canceled;
	m_ui.stackedWidget->setCurrentIndex(IndexCanceled);
	QApplication::beep();

	m_ui.actionList->setActionState(QString::fromLatin1(step), ActionListWidget::Canceled);

	emit completeChanged();
	finalizePatching();
}

void ProgressPage::onProgress(int, const QString& message)
{
	m_ui.progressText->setText(message);
}

void ProgressPage::onCancelPressed()
{
	const int answer = QMessageBox::question(this,
			tr("������ ������"),
			tr("������ ����� �������� � ����������� �����-������, ���� ��� ����������� �� ����� ������ ������� ������.") +
			QString("\r\n\r\n") +
			tr("�� �������, ��� ������ �������� �������?"),
		QMessageBox::Yes, QMessageBox::No);

	if (answer == QMessageBox::Yes)
	{
		wizard()->button(QWizard::CancelButton)->setEnabled(false);
		m_ui.progressLabel->setText(tr("���������..."));
		m_patcherController.requestStop();
	}
}