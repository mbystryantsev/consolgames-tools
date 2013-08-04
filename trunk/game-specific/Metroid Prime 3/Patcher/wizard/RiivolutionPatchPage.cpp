#include "RiivolutionPatchPage.h"
#include "PatchWizard.h"
#include "DriveManager.h"
#include "ImageFileChecker.h"
#include "FreeSpaceChecker.h"
#include <QSortFilterProxyModel>
#include <QMessageBox>
#include <QTimer>

RiivolutionPatchPage::RiivolutionPatchPage() : Page<Ui_RiivolutionPatchPage>()
{
	setCommitPage(true);

	QSortFilterProxyModel* cdProxyModel = new QSortFilterProxyModel(m_ui.cdList);
	cdProxyModel->setSourceModel(m_ui.cdList->model());    

	QSortFilterProxyModel* usbProxyModel = new QSortFilterProxyModel(m_ui.usbList);
	usbProxyModel->setSourceModel(m_ui.usbList->model());    

	m_ui.sourceGroup->setId(m_ui.useDisc, 0);
	m_ui.sourceGroup->setId(m_ui.useImage, 1);
	m_ui.destGroup->setId(m_ui.generateToDrive, 0);
	m_ui.destGroup->setId(m_ui.generateToDirectory, 1);
	
	m_ui.sourceTypes->setCurrentIndex(0);
	m_ui.destTypes->setCurrentIndex(0);

	VERIFY(connect(m_ui.sourceGroup, SIGNAL(buttonClicked(int)), m_ui.sourceTypes, SLOT(setCurrentIndex(int))));
	VERIFY(connect(m_ui.destGroup, SIGNAL(buttonClicked(int)), m_ui.destTypes, SLOT(setCurrentIndex(int))));
	VERIFY(connect(&m_driveListener, SIGNAL(drivesRemoved(const QList<QChar>&)), SLOT(fillCdDriveList())));
	VERIFY(connect(&m_driveListener, SIGNAL(drivesInserted(const QList<QChar>&)), SLOT(fillCdDriveList())));
	VERIFY(connect(&m_driveListener, SIGNAL(drivesRemoved(const QList<QChar>&)), SLOT(fillUsbDriveList())));
	VERIFY(connect(&m_driveListener, SIGNAL(drivesInserted(const QList<QChar>&)), SLOT(fillUsbDriveList())));
	VERIFY(connect(&m_timer, SIGNAL(timeout()), SLOT(fillUsbDriveList())));

	m_timer.setInterval(5000);
	m_timer.start();

	m_freeSpaceChecker = new FreeSpaceChecker(m_ui.destPath, this);
	m_imageFileChecker = new ImageFileChecker(m_ui.imagePath, this);
}

int RiivolutionPatchPage::nextId() const 
{
	return PatchWizard::PageProgress;
}

void RiivolutionPatchPage::initializePage()
{
	fillUsbDriveList();
	fillCdDriveList();
}

bool RiivolutionPatchPage::validatePage()
{
	if (m_imageFileChecker->hasError() || m_freeSpaceChecker->hasError())
	{
		const int answer = QMessageBox::question(this,
			QString::fromLocal8Bit("Обнаружены ошибки"),
			QString::fromLocal8Bit("Вероятно, указан один или несколько ошибочных параметров.\r\n"
			"Вы уверены, что хотите продолжить процесс несмотря на возможные ошибки?")
			, QMessageBox::Yes, QMessageBox::No);

		if (answer == QMessageBox::No)
		{
			return false;
		}
	}
	return true;
}

void RiivolutionPatchPage::fillDriveList(QComboBox* list, const QList<QChar>& drives)
{
	foreach (QChar letter, drives)
	{
		if (list->findData(letter) == -1)
		{
			QString line = QString::fromLocal8Bit("Диск %1").arg(letter);
			const QString name = DriveManager::volumeName(letter);
			if (!name.isEmpty())
			{
				line = QString("%1 - %2").arg(line).arg(name);
			}
			list->addItem(line, letter);
		}
	}
	for (int i = 0; i < list->count(); i++)
	{
		if (!drives.contains(list->itemData(i).toChar()))
		{
			list->removeItem(i);
			i--;
		}
	}
}

void RiivolutionPatchPage::fillUsbDriveList()
{
	if (wizard()->currentPage() != this)
	{
		return;
	}
	const QList<QChar> drives = DriveManager::usbDriveList();
	fillDriveList(m_ui.usbList, drives);
}

void RiivolutionPatchPage::fillCdDriveList()
{
	if (wizard()->currentPage() != this)
	{
		return;
	}
	const QList<QChar> drives = DriveManager::cdDriveList();
	fillDriveList(m_ui.cdList, drives);
}
