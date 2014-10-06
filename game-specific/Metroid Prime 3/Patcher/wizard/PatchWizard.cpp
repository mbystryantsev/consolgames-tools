#include "version.h"
#include "PatchWizard.h"
#include "IntroPage.h"
#include "EulaPage.h"
#include "PatchSelectPage.h"
#include "ImagePatchPage.h"
#include "RiivolutionPatchPage.h"
#include "CompletedPage.h"
#include "FailedPage.h"
#include "CanceledPage.h"
#include "ui_SideWidget.h"

#include "ProgressPage.h"

#include <QIcon>

PatchWizard::PatchWizard(QWidget* parent)
	: QWizard(parent)
	, m_checkingEnabled(false)
	, m_patchType(ImagePatch)
	, m_errorCode(0)
{
	setWindowTitle(QString::fromLocal8Bit("Патч-перевод Metroid Prime 3: Corruption"));

	setWizardStyle(ModernStyle);
	setOption(NoBackButtonOnLastPage, true);

	setButtonText(QWizard::CommitButton, QString::fromLocal8Bit("Применить!"));

	setPixmap(QWizard::WatermarkPixmap, QPixmap(":/watermark.png"));

	QWidget* sideWidget = new QWidget(this);
	Ui_SideWidget ui;
	ui.setupUi(sideWidget);
	ui.version->setText(QString("v%1").arg(version()));
	
	setSideWidget(sideWidget);

	setPage(PageIntro, new IntroPage());
	setPage(PageEula, new EulaPage());
	setPage(PagePatchType, new PatchSelectPage());
	setPage(PageImagePatch, new ImagePatchPage());
	setPage(PageRiivolutionPatch, new RiivolutionPatchPage());
	setPage(PageProgress, new ProgressPage());
	setPage(PageCompleted, new CompletedPage());
	setPage(PageFailed, new FailedPage());
	setPage(PageCanceled, new CanceledPage());

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

QString PatchWizard::version() const
{
	return VER_PRODUCTVERSION_STR;
}