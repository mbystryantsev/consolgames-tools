#pragma once
#include "Page.h"
#include "ui_RiivolutionPatchPage.h"
#include "DriveListener.h"
#include <QTimer>

class FreeSpaceChecker;
class ImageFileChecker;

class RiivolutionPatchPage : public Page<Ui_RiivolutionPatchPage>
{
	Q_OBJECT

public:
	RiivolutionPatchPage();

	virtual int nextId() const override;
	virtual void initializePage() override;
	virtual bool validatePage() override;

private:
	static void fillDriveList(QComboBox* list, const QList<QChar>& drives);
	Q_SLOT void fillUsbDriveList();
	Q_SLOT void fillCdDriveList();

private:
	DriveListener m_driveListener;
	QTimer m_timer;
	FreeSpaceChecker* m_freeSpaceChecker;
	ImageFileChecker* m_imageFileChecker;
};