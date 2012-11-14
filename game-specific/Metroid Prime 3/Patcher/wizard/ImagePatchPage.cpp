#include "ImagePatchPage.h"
#include "PatchWizard.h"
#include "FreeSpaceChecker.h"
#include <QToolTip>
#include <QFileDialog>

ImagePatchPage::ImagePatchPage() : Page<Ui_ImagePatchPage>()
{
	setCommitPage(true);

	registerField("imagePath", m_ui.imagePath);
	registerField("tempPath", m_ui.tempPath);

	m_freeSpaceChecker = new FreeSpaceChecker(m_ui.tempPath);
	VERIFY(connect(m_freeSpaceChecker, SIGNAL(pathError()), SLOT(onPathError())));
	VERIFY(connect(m_freeSpaceChecker, SIGNAL(freeSpaceError(quint64)), SLOT(onFreeSpaceError(quint64))));
	VERIFY(connect(m_freeSpaceChecker, SIGNAL(errorReset()), SLOT(onResetError())));
	VERIFY(connect(m_ui.selectImageButton, SIGNAL(clicked()), SLOT(onImageSelectPressed())));
	VERIFY(connect(m_ui.selectTempPathButton, SIGNAL(clicked()), SLOT(onTempPathSelectPressed())));
	
	setButtonText(QWizard::NextButton, QString::fromLocal8Bit("Начать!"));
}

int ImagePatchPage::nextId() const 
{
	return PatchWizard::PageProgress;
}

void ImagePatchPage::initializePage()
{
	processEuristic();
}

bool ImagePatchPage::validatePage()
{
	return true;
}

void ImagePatchPage::processEuristic()
{ 
	if (m_ui.tempPath->text().isEmpty())
	{
		m_ui.tempPath->setText(QDir::toNativeSeparators(QDir::tempPath()));
	}

	if (!m_ui.imagePath->text().isEmpty())
	{
		return;
	}

	const QStringList entries = QDir().entryList(QStringList() << "*metroid*.iso" << "*RM3P01*.iso" << "*mp3*.iso" << "*.iso", QDir::Files | QDir::Writable);
	if (!entries.isEmpty())
	{
		m_ui.imagePath->setText(entries.first());
	}
}

void ImagePatchPage::onImageSelectPressed()
{
	const QString filename = QFileDialog::getOpenFileName(this, QString::fromLocal8Bit("Выберите бэкап-образ для применения патча..."), m_ui.imagePath->text(), QString::fromLocal8Bit("Бэкап-образы Wii (*.iso)"));
	if (!filename.isNull())
	{
		m_ui.imagePath->setText(QDir::toNativeSeparators(filename));
	}
}

void ImagePatchPage::onTempPathSelectPressed()
{
	const QString directory = QFileDialog::getExistingDirectory(this, QString::fromLocal8Bit("Укажите путь к директории для временных файлов..."), m_ui.tempPath->text());
	if (!directory.isNull())
	{
		m_ui.tempPath->setText(QDir::toNativeSeparators(directory));
	}
}

void ImagePatchPage::onFreeSpaceError(quint64 space)
{
	const quint64 megabytes = space / (1024 * 1024);
	const double gygabytes = static_cast<double>(megabytes) / 1024.0;
	showToolTip(m_ui.tempPath, QString::fromLocal8Bit("Доступно %1 ГБ из необходимых 3 ГБ!").arg(gygabytes, 0, 'f', 2));
}

void ImagePatchPage::onPathError()
{
	showToolTip(m_ui.tempPath, QString::fromLocal8Bit("Указанный путь неверен!"));
}

void ImagePatchPage::onResetError()
{
	hideToolTip(m_ui.tempPath);
}

void ImagePatchPage::showToolTip(QWidget* widget, const QString& text)
{
	QToolTip::showText(widget->mapToGlobal(QPoint(0, 0)), text, widget);
}

void ImagePatchPage::hideToolTip(QWidget* widget)
{
	QToolTip::showText(QPoint(), QString(), widget);
}