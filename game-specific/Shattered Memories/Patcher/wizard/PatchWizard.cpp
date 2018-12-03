#include "PatchSpec.h"
#include "PatchWizard.h"
#include "IntroPage.h"
#include "EulaPage.h"
#include "ImagePatchPage.h"
#include "CompletedPage.h"
#include "FailedPage.h"
#include "CanceledPage.h"
#include "ui_SideWidget.h"
#include "ProgressPage.h"
#include "Configurator.h"
#include <QIcon>

PatchWizard::PatchWizard(QWidget* parent)
	: QWizard(parent)
	, m_checkingEnabled(false)
	, m_patchType(ImagePatch)
	, m_errorCode(0)
{
	const Configurator& configurator = Configurator::instance();

	const QString platformsStr = configurator.availablePlatforms().size() == 1
		? QString(" (%1)").arg(Configurator::platformAbbr(*configurator.availablePlatforms().begin()))
		: QString();

	setWindowTitle(tr("Патч-перевод " GAME_TITLE) + platformsStr);

	setWizardStyle(ModernStyle);
	setOption(NoBackButtonOnLastPage, true);

	setButtonText(QWizard::CommitButton, tr("Применить!"));

	setPixmap(QWizard::WatermarkPixmap, QPixmap(":/watermark.png"));

	QWidget* sideWidget = new QWidget(this);
	Ui_SideWidget ui;
	ui.setupUi(sideWidget);
	ui.version->setText(QString("v%1").arg(Configurator::version()));
	
	setSideWidget(sideWidget);

	setPage(PageIntro, new IntroPage());
	setPage(PageEula, new EulaPage());
	setPage(PageImagePatch, new ImagePatchPage());
	setPage(PageProgress, new ProgressPage());
	setPage(PageCompleted, new CompletedPage());
	setPage(PageFailed, new FailedPage());
	setPage(PageCanceled, new CanceledPage());

	setStartId(PageIntro);

	setFixedSize(600, 420);
	setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
}
