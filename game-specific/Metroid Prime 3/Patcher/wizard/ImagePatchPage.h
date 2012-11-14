#pragma once
#include "Page.h"
#include "ui_ImagePatchPage.h"

class FreeSpaceChecker;

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
	Q_SLOT void onFreeSpaceError(quint64 space);
	Q_SLOT void onPathError();
	Q_SLOT void onResetError();

	void showToolTip(QWidget* widget, const QString& text);
	void hideToolTip(QWidget* widget);

private:
	FreeSpaceChecker* m_freeSpaceChecker;
};