#pragma once
#include "Page.h"
#include "ui_ImagePatchPage.h"

class FreeSpaceChecker;
class ImageFileChecker;

class ImagePatchPage : public Page<Ui_ImagePatchPage>
{
	Q_OBJECT

public:
	ImagePatchPage();

	virtual int nextId() const override;
	virtual void initializePage() override;
	virtual bool validatePage() override;
	void processEuristic();

	Q_SLOT void onImageSelectPressed();
	Q_SLOT void onTempPathSelectPressed();
	Q_SLOT void onTempPathFreeSpaceError(quint64 space);
	Q_SLOT void onTempPathError();
	Q_SLOT void onTempPathResetError();
	Q_SLOT void onImagePathError();
	Q_SLOT void onImagePathAccessError();
	Q_SLOT void onImagePathResetError();

	static void showToolTip(QWidget* widget, const QString& text);
	static void hideToolTip(QWidget* widget);

private:
	FreeSpaceChecker* m_freeSpaceChecker;
	ImageFileChecker* m_imageFileChecker;
};