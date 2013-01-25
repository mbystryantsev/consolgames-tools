#include <core.h>
#include <MainFrame.h>
#include <QString>
#include <QListWidgetItem>
#include <QDir>
#include <QFileDialog>
#include <QSettings>

MainFrame::MainFrame()
	: QFrame()
	, m_currentAction(-1)
	, m_settingsIsActive(false)
	, m_isPatching(false)
	, m_stopRequested(false)
{
	ASSERT(QThread::currentThread() != m_paster.thread());

	m_ui.setupUi(this);

	VERIFY(connect(this, SIGNAL(aboutToClosing()), &m_paster, SLOT(quit())));

	VERIFY(connect(m_ui.startButton, SIGNAL(clicked()), SLOT(onStartPressed())));
	VERIFY(connect(m_ui.selectImageButton, SIGNAL(clicked()), SLOT(onImageSelectPressed())));
	VERIFY(connect(m_ui.selectDataPathButton, SIGNAL(clicked()), SLOT(onDataPathSelectPressed())));
	VERIFY(connect(m_ui.selectTempPathButton, SIGNAL(clicked()), SLOT(onTempPathSelectPressed())));
	//VERIFY(connect(&m_paster, SIGNAL(actionCompleted(bool)), SLOT(processStep(bool))));

	VERIFY(connect(&m_paster, SIGNAL(initProgress(int)), SLOT(setProgressSize(int))));
	VERIFY(connect(&m_paster, SIGNAL(changeProgress(int, const QString&)), SLOT(setProgressValue(int, const QString&))));
	VERIFY(connect(&m_paster, SIGNAL(actionStarted(int)), SLOT(onActionStarted(int))));
	VERIFY(connect(&m_paster, SIGNAL(actionCompleted(bool)), SLOT(onActionCompleted(bool))));
	VERIFY(connect(&m_paster, SIGNAL(changeActionProgress(int, const QString&)), SLOT(onActionProgress(int, const QString&))));

	VERIFY(connect(m_ui.pakList, SIGNAL(itemChanged(QListWidgetItem*)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.imagePath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.dataPath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.tempPath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.checkPaks, SIGNAL(stateChanged(int)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.checkData, SIGNAL(stateChanged(int)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.checkImage, SIGNAL(stateChanged(int)), SLOT(storeSettings())));

	reset();

	loadSettings();
}

void MainFrame::addPak(const QString& name, const QString& description, bool checked)
{
	m_settingsIsActive = false;

	const QString str = name + (description.isEmpty() ? "" : (" - " + description));
	QListWidgetItem* item = new QListWidgetItem(str, m_ui.pakList, QListWidgetItem::UserType);
	item->setFlags(Qt::ItemIsSelectable | Qt::ItemIsUserCheckable | Qt::ItemIsEnabled);
	item->setCheckState(checked ? Qt::Checked : Qt::Unchecked);
	item->setData(Qt::UserRole, name);

	m_settingsIsActive = true;
}


void MainFrame::onStartPressed()
{
	if (m_isPatching)
	{
		m_stopRequested = true;
		QMetaObject::invokeMethod(&m_paster, "requestStop");
		return;
	}

	VERIFY(QMetaObject::invokeMethod(&m_paster, "setPakList", Q_ARG(const QStringList&, selectedPaks())));
	VERIFY(QMetaObject::invokeMethod(&m_paster, "setImageFile", Q_ARG(const QString&, QDir::toNativeSeparators(m_ui.imagePath->text()))));
	VERIFY(QMetaObject::invokeMethod(&m_paster, "setDataDirectories", Q_ARG(const QStringList&, QStringList(QDir::toNativeSeparators(m_ui.dataPath->text())))));
	VERIFY(QMetaObject::invokeMethod(&m_paster, "setTempDirectory", Q_ARG(const QString&, QString(QDir::toNativeSeparators(m_ui.tempPath->text())))));
	VERIFY(QMetaObject::invokeMethod(&m_paster, "setCheckData", Q_ARG(bool, m_ui.checkData->isChecked())));
	VERIFY(QMetaObject::invokeMethod(&m_paster, "setCheckPaks", Q_ARG(bool, m_ui.checkPaks->isChecked())));
	VERIFY(QMetaObject::invokeMethod(&m_paster, "setCheckImage", Q_ARG(bool, m_ui.checkImage->isChecked())));

	m_isPatching = true;
	m_ui.startButton->setText("Cancel");


	int actionCount = 3;
	if (m_ui.checkData->isChecked())
	{
		actionCount++;
	}
	if (m_ui.checkPaks->isChecked())
	{
		actionCount++;
	}
	if (m_ui.checkImage->isChecked())
	{
		actionCount++;
	}
	
	m_ui.totalProgressBar->setMaximum(actionCount);
	m_ui.totalProgressBar->setFormat(QString("%v/%1").arg(actionCount));

	m_paster.startPatching();
}

QStringList MainFrame::selectedPaks() const
{
	QStringList paks;
	for (int i = 0; i < m_ui.pakList->model()->rowCount(); i++)
	{
		if (m_ui.pakList->item(i)->checkState() == Qt::Checked)
		{
			paks << m_ui.pakList->item(i)->data(Qt::UserRole).toString();
		}
	}
	return paks;
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
	m_ui.itemProgressBar->setMaximum(size);
	m_ui.itemProgressBar->setValue(0);
}

void MainFrame::setProgressValue(int index, const QString&)
{
	m_ui.itemProgressBar->setValue(index + 1);
}

void MainFrame::setMessage(const QString& message)
{
	m_ui.messageLabel->setText(message);
}

void MainFrame::onActionStarted(int action)
{
	m_currentAction = action;
	switch (action)
	{
		case PasterThread::Init:
			m_ui.totalProgressBar->setValue(0);
			m_ui.statusLabel->setText("Initialazing...");
			break;
		case PasterThread::RebuildPaks:
			m_ui.statusLabel->setText("Rebuilding paks...");
			break;
		case PasterThread::CheckData:
			m_ui.statusLabel->setText("Checking data...");
			break;
		case PasterThread::ReplacePaks:
			m_ui.statusLabel->setText("Replacing paks in image...");
			break;
		case PasterThread::CheckPaks:
			m_ui.statusLabel->setText("Checking paks in image...");
			break;
		case PasterThread::CheckImage:
			m_ui.statusLabel->setText("Checking image...");
			break;
		case PasterThread::Done:
			m_ui.statusLabel->setText("All actions completed!");
			break;
	}
	m_ui.itemProgressBar->reset();
}

void MainFrame::onActionCompleted(bool success)
{
	setMessage(QString());

	if (m_stopRequested)
	{
		m_ui.statusLabel->setText("Aborted by user!");
		QApplication::beep();
		reset();
		return;
	}

	if (success)
	{
		if (m_currentAction == PasterThread::Done)
		{
			QApplication::beep();
			reset();
		}
		else
		{
			m_ui.totalProgressBar->setValue(m_ui.totalProgressBar->value() + 1);
		}
		return;
	}

	switch (m_currentAction)
	{
	case PasterThread::Init:
		m_ui.statusLabel->setText("Initialazing failed!");
		break;
	case PasterThread::RebuildPaks:
		m_ui.statusLabel->setText("Rebuilding paks failed!");
		break;
	case PasterThread::CheckData:
		m_ui.statusLabel->setText("Checking data failed!");
		break;
	case PasterThread::ReplacePaks:
		m_ui.statusLabel->setText("Replacing paks in image failed!");
		break;
	case PasterThread::CheckPaks:
		m_ui.statusLabel->setText("Checking paks in image failed!");
		break;
	case PasterThread::CheckImage:
		m_ui.statusLabel->setText("Checking image failed!");
		break;
	case PasterThread::Done:
		m_ui.statusLabel->setText("Finalizing failed!");
		break;
	}

}

void MainFrame::storeSettings() const
{
	if (!m_settingsIsActive)
	{
		return;
	}

	QSettings settings;

	const QString selectedPaksKey = "selectedPaks";
	settings.setValue(selectedPaksKey, selectedPaks());
	settings.setValue("imagePath", m_ui.imagePath->text());
	settings.setValue("dataPath", m_ui.dataPath->text());
	settings.setValue("tempPath", m_ui.tempPath->text());
	settings.setValue("checkPaks", m_ui.checkPaks->isChecked());
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

	m_ui.checkPaks->setChecked(settings.value("checkPaks", m_ui.checkPaks->isChecked()).toBool());
	m_ui.checkData->setChecked(settings.value("checkData", m_ui.checkData->isChecked()).toBool());
	m_ui.checkImage->setChecked(settings.value("checkImage", m_ui.checkImage->isChecked()).toBool());

	m_settingsIsActive = true;
}

void MainFrame::closeEvent(QCloseEvent*)
{
	emit aboutToClosing();
	m_paster.wait(5000);
}

void MainFrame::reset()
{
	m_ui.itemProgressBar->reset();
	m_ui.totalProgressBar->reset();
	m_ui.messageLabel->setText("");
	m_ui.startButton->setText("Start");
	m_isPatching = false;
	m_stopRequested = false;
}

void MainFrame::onActionProgress(int, const QString& message)
{
	setMessage(message);
}