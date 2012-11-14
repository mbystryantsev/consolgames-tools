#include "PatchWizard.h"
#include "IntroPage.h"
#include "EulaPage.h"
#include "PatchSelectPage.h"
#include "ImagePatchPage.h"
#include "CompletedPage.h"
#include "FailedPage.h"
#include "ui_SideWidget.h"

#include "ProgressPage.h"

#include <QIcon>

PatchWizard::PatchWizard(QWidget* parent)
	: QWizard(parent)
	, m_checkingEnabled(false)
	, m_patchType(ImagePatch)
	, m_errorCode(0)
{
	setWizardStyle(ModernStyle);

	setButtonText(QWizard::NextButton, QString::fromWCharArray(L"Далее >"));
	setButtonText(QWizard::BackButton, QString::fromWCharArray(L"< Назад"));
	setButtonText(QWizard::CancelButton, QString::fromWCharArray(L"Отмена"));
	setButtonText(QWizard::FinishButton, QString::fromWCharArray(L"Завершить"));
	setButtonText(QWizard::CommitButton, QString::fromWCharArray(L"Применить!"));

	setPixmap(QWizard::WatermarkPixmap, QPixmap(":/watermark.png"));

	QWidget* sideWidget = new QWidget(this);
	Ui_SideWidget().setupUi(sideWidget);
	setSideWidget(sideWidget);

	setPage(PageIntro, new IntroPage());
	setPage(PageEula, new EulaPage());
	setPage(PagePatchType, new PatchSelectPage());
	setPage(PageImagePatch, new ImagePatchPage());
	setPage(PageProgress, new ProgressPage());
	setPage(PageCompleted, new CompletedPage());
	setPage(PageFailed, new FailedPage());

	setStartId(PageIntro);

	setFixedSize(600, 420);
	setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
}

void PatchWizard::setCheckingEnabled(bool enabled)
{
	m_checkingEnabled = enabled;
}

bool PatchWizard::checkingEnabled() const
{
	return m_checkingEnabled;
}

void PatchWizard::setPatchType(PatchType type)
{
	m_patchType = type;
}

PatchWizard::PatchType PatchWizard::patchType() const
{
	return m_patchType;
}

void PatchWizard::setErrorCode(int code)
{
	m_errorCode = code;
}

int PatchWizard::errorCode() const
{
	return m_errorCode;
}

void PatchWizard::setErrorData(const QString& errorData)
{
	m_errorData = errorData;
}

QString PatchWizard::errorData() const
{
	return m_errorData;
}