#include <core.h>
#include <MainFrame.h>
#include <QString>
#include <QListWidgetItem>
#include <QDir>
#include <QFileDialog>
#include <QSettings>
#include <QMessageBox>

using namespace ShatteredMemories;

MainFrame::MainFrame()
	: QFrame()
	, m_settingsIsActive(false)
{
	m_ui.setupUi(this);
	m_ui.actionList->addItem("Waiting for action...");

	VERIFY(connect(m_ui.startButton, SIGNAL(clicked()), SLOT(onStartPressed())));
	VERIFY(connect(m_ui.selectImageButton, SIGNAL(clicked()), SLOT(onImageSelectPressed())));
	VERIFY(connect(m_ui.selectDataPathButton, SIGNAL(clicked()), SLOT(onDataPathSelectPressed())));
	VERIFY(connect(m_ui.selectTempPathButton, SIGNAL(clicked()), SLOT(onTempPathSelectPressed())));

	VERIFY(connect(&m_patcher, SIGNAL(stepStarted(const QByteArray&)), SLOT(onActionStarted(const QByteArray&))));
	VERIFY(connect(&m_patcher, SIGNAL(stepCompleted(const QByteArray&)), SLOT(onActionCompleted(const QByteArray&))));
	VERIFY(connect(&m_patcher, SIGNAL(failed(const QByteArray&, int, const QString&)), SLOT(onFailed(const QByteArray&, int, const QString&))));
	VERIFY(connect(&m_patcher, SIGNAL(canceled(const QByteArray&)), SLOT(onCanceled(const QByteArray&))));
	VERIFY(connect(&m_patcher, SIGNAL(progressInit(int)), SLOT(onProgressInit(int))));
	VERIFY(connect(&m_patcher, SIGNAL(progressChanged(int, const QString&)), SLOT(onProgressChanged(int, const QString&))));
	VERIFY(connect(&m_patcher, SIGNAL(progressFinish()), SLOT(onProgressFinish())));

	VERIFY(connect(m_ui.imagePath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.dataPath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.tempPath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.checkArchives, SIGNAL(stateChanged(int)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.checkData, SIGNAL(stateChanged(int)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.checkImage, SIGNAL(stateChanged(int)), SLOT(storeSettings())));

	reset();

	loadSettings();
}

void MainFrame::onStartPressed()
{
	if (m_patcher.isStarted())
	{
		m_patcher.requestStop();
		return;
	}

	m_ui.startButton->setText("Cancel");
	
	m_patcher.reset();
	m_patcher.setImagePath(m_ui.imagePath->text());
	m_patcher.setTempPath(m_ui.tempPath->text());
	m_patcher.addResourcesPath(m_ui.dataPath->text());

	m_patcher.setCheckArchives(m_ui.checkArchives->isChecked());
	m_patcher.setCheckImage(m_ui.checkImage->isChecked());

	m_actions = m_patcher.actionList();
	m_ui.actionList->clear();
	foreach (const QByteArray& action, m_actions)
	{
		m_ui.actionList->addItem("[ ] " + QString::fromUtf8(action.constData()));
		m_ui.actionList->item(m_ui.actionList->model()->rowCount() - 1)->setData(Qt::FontRole, QFont("Lucida Console"));
	}

	m_patcher.start();
}

void MainFrame::onImageSelectPressed()
{
	const QString filename = QFileDialog::getOpenFileName(this, tr("Please select image file..."), m_ui.imagePath->text(), "Wii Images (*.iso)");
	if (!filename.isNull())
	{
		m_ui.imagePath->setText(filename);
	}
}

void MainFrame::onDataPathSelectPressed()
{
	const QString directory = QFileDialog::getExistingDirectory(this, tr("Please select data path..."), m_ui.dataPath->text());
	if (!directory.isNull())
	{
		m_ui.dataPath->setText(directory);
	}
}

void MainFrame::onTempPathSelectPressed()
{
	const QString directory = QFileDialog::getExistingDirectory(this, tr("Please select directory for temporary files..."), m_ui.dataPath->text());
	if (!directory.isNull())
	{
		m_ui.tempPath->setText(directory);
	}
}

void MainFrame::setProgressSize(int size)
{
	m_ui.progressBar->setMaximum(size);
	m_ui.progressBar->setValue(0);
}

void MainFrame::setProgressValue(int index, const QString&)
{
	m_ui.progressBar->setValue(index + 1);
}

void MainFrame::setMessage(const QString& message)
{
	m_ui.messageLabel->setText(message);
}

void MainFrame::onActionStarted(const QByteArray& action)
{
	m_ui.statusLabel->setText(QString("Action: %1").arg(QString::fromLatin1(action.constData())));

	const int index = m_actions.indexOf(action);
	ASSERT(index >= 0);
	m_ui.actionList->item(index)->setData(Qt::DisplayRole, QString("[%1] %2").arg(QChar(0x2026)).arg(QString::fromUtf8(action.constData())));
}

void MainFrame::onActionCompleted(const QByteArray& action)
{
	const int index = m_actions.indexOf(action);
	ASSERT(index >= 0);
	m_ui.actionList->item(index)->setData(Qt::DisplayRole, QString("[V] ") + QString::fromUtf8(action.constData()));

	if (index == m_actions.size() - 1)
	{
		m_ui.statusLabel->setText("Done!");
		QApplication::beep();
		reset();
	}
}

void MainFrame::onFailed(const QByteArray& action, int errorCode, const QString& errorData)
{
	const int index = m_actions.indexOf(action);
	ASSERT(index >= 0);
	m_ui.actionList->item(index)->setData(Qt::DisplayRole, QString("[F] ") + QString::fromUtf8(action.constData()));
	const QString errorName = PatcherController::errorName(errorCode);

	DLOG << "Error: " << errorName << " (" << errorCode << "), " << errorData;

	m_ui.statusLabel->setText(QString("Action failed: %1").arg(QString::fromLatin1(action.constData())));

	QMessageBox::critical(this, "Error!", QString("An error occured during patching.\nCode: %1 (%2)\nData: %3").arg(errorName).arg(errorCode).arg(errorData));

	reset();
}

void MainFrame::onCanceled(const QByteArray& action)
{
	const int index = m_actions.indexOf(action);
	ASSERT(index >= 0);
	m_ui.actionList->item(index)->setData(Qt::DisplayRole, QString("[C] ") + QString::fromUtf8(action.constData()));

	m_ui.statusLabel->setText("Cancelled");

	QMessageBox::information(this, "Cancelled", "Process cancelled by user.");

	reset();
}

void MainFrame::storeSettings() const
{
	if (!m_settingsIsActive)
	{
		return;
	}

	QSettings settings;

	settings.setValue("imagePath", m_ui.imagePath->text());
	settings.setValue("dataPath", m_ui.dataPath->text());
	settings.setValue("tempPath", m_ui.tempPath->text());
	settings.setValue("checkArchives", m_ui.checkArchives->isChecked());
	settings.setValue("checkData", m_ui.checkData->isChecked());
	settings.setValue("checkImage", m_ui.checkImage->isChecked());

	DLOG << "Settings stored";
}

void MainFrame::loadSettings()
{
	QSettings settings;

	m_ui.imagePath->setText(settings.value("imagePath", m_ui.imagePath->text()).toString());
	m_ui.dataPath->setText(settings.value("dataPath", m_ui.dataPath->text()).toString());
	m_ui.tempPath->setText(settings.value("tempPath", QDir::toNativeSeparators(QDir::tempPath())).toString());

	m_ui.checkArchives->setChecked(settings.value("checkArchives", m_ui.checkArchives->isChecked()).toBool());
	m_ui.checkData->setChecked(settings.value("checkData", m_ui.checkData->isChecked()).toBool());
	m_ui.checkImage->setChecked(settings.value("checkImage", m_ui.checkImage->isChecked()).toBool());

	m_settingsIsActive = true;
}

void MainFrame::closeEvent(QCloseEvent*)
{
	emit aboutToClosing();
	m_patcher.waitForWorker();
}

void MainFrame::reset()
{
	m_ui.progressBar->reset();
	m_ui.messageLabel->setText("");
	m_ui.startButton->setText("Start");
}

void MainFrame::onActionProgress(int, const QString& message)
{
	setMessage(message);
}

void MainFrame::onProgressInit(int max)
{
	m_ui.progressBar->reset();
	m_ui.progressBar->setMaximum(max);
}

void MainFrame::onProgressChanged(int value, const QString& message)
{
	m_ui.progressBar->setValue(value);
	m_ui.messageLabel->setText(message);
}

void MainFrame::onProgressFinish()
{
	m_ui.progressBar->reset();
}
