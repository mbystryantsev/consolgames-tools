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
	VERIFY(connect(&m_paster, SIGNAL(changeProgress(int, const char*)), SLOT(setProgressValue(int, const char*))));
	VERIFY(connect(&m_paster, SIGNAL(actionStarted(int)), SLOT(onActionStarted(int))));
	VERIFY(connect(&m_paster, SIGNAL(actionCompleted(bool)), SLOT(onActionCompleted(bool))));

	VERIFY(connect(m_ui.pakList, SIGNAL(itemChanged(QListWidgetItem*)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.imagePath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.dataPath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));
	VERIFY(connect(m_ui.tempPath, SIGNAL(textChanged(const QString&)), SLOT(storeSettings())));

	m_ui.itemProgressBar->reset();
	m_ui.totalProgressBar->reset();

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
	m_paster.setPakList(selectedPaks());
	m_paster.setImageFile(QDir::toNativeSeparators(m_ui.imagePath->text()));
	m_paster.setDataDirectories(QStringList(QDir::toNativeSeparators(m_ui.dataPath->text())));
	m_paster.setTempDirectory(QString(QDir::toNativeSeparators(m_ui.tempPath->text())));
	//m_paster.setTempDirectory(QDir::toNativeSeparators("D:/Temp"));

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

void MainFrame::setProgressValue(int index, const char*)
{
	m_ui.itemProgressBar->setValue(index + 1);
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
		case PasterThread::Done:
			m_ui.statusLabel->setText("All actions completed!");
			break;
	}
	m_ui.itemProgressBar->reset();
}

void MainFrame::onActionCompleted(bool success)
{
	if (success)
	{
		if (m_currentAction == PasterThread::Done)
		{
			m_ui.itemProgressBar->reset();
			m_ui.totalProgressBar->reset();
			QApplication::beep();
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

	DLOG << "Settings stored";
}

void MainFrame::loadSettings()
{
	QSettings settings;

	m_ui.imagePath->setText(settings.value("imagePath", m_ui.imagePath->text()).toString());
	m_ui.dataPath->setText(settings.value("dataPath", m_ui.dataPath->text()).toString());
	m_ui.tempPath->setText(settings.value("tempPath", QDir::toNativeSeparators(QDir::tempPath())).toString());

	m_settingsIsActive = true;
}

void MainFrame::closeEvent(QCloseEvent*)
{
	emit aboutToClosing();
	m_paster.wait(5000);
}