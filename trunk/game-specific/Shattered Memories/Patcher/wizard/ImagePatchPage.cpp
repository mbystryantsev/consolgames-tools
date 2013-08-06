#include "ImagePatchPage.h"
#include "PatchWizard.h"
#include "FreeSpaceChecker.h"
#include "ImageFileChecker.h"
#include "Configurator.h"
#include <QToolTip>
#include <QFileDialog>
#include <QMessageBox>

ImagePatchPage::ImagePatchPage() : Page<Ui_ImagePatchPage>()
{
	setCommitPage(true);

	m_freeSpaceChecker = new FreeSpaceChecker(m_ui.tempPath, this);
	m_imageFileChecker = new ImageFileChecker(m_ui.imagePath, this);

	VERIFY(connect(m_freeSpaceChecker, SIGNAL(pathError()), SLOT(onTempPathError())));
	VERIFY(connect(m_freeSpaceChecker, SIGNAL(freeSpaceError(quint64)), SLOT(onTempPathFreeSpaceError(quint64))));
	VERIFY(connect(m_freeSpaceChecker, SIGNAL(errorReset()), SLOT(onTempPathResetError())));
	VERIFY(connect(m_imageFileChecker, SIGNAL(pathError()), SLOT(onImagePathError())));
	VERIFY(connect(m_imageFileChecker, SIGNAL(accessError()), SLOT(onImagePathAccessError())));
	VERIFY(connect(m_imageFileChecker, SIGNAL(errorReset()), SLOT(onImagePathResetError())));
	VERIFY(connect(m_ui.selectImageButton, SIGNAL(clicked()), SLOT(onImageSelectPressed())));
	VERIFY(connect(m_ui.selectTempPathButton, SIGNAL(clicked()), SLOT(onTempPathSelectPressed())));
	
	setButtonText(QWizard::NextButton, tr("Начать!"));
}

int ImagePatchPage::nextId() const 
{
	return PatchWizard::PageProgress;
}

void ImagePatchPage::initializePage()
{
#if defined(_DEBUG)
	m_ui.imagePath->setText(QDir::toNativeSeparators("D:/rev/memories/Silent Hill Shattered Memories.iso"));
	m_ui.tempPath->setText(QDir::toNativeSeparators("D:/Temp"));
#else
	processEuristic();
#endif
}

bool ImagePatchPage::validatePage()
{
	if (m_imageFileChecker->hasError() || m_freeSpaceChecker->hasError())
	{
		const int answer = QMessageBox::question(this,
			tr("Обнаружены ошибки"),
			tr("Вероятно, указан один или несколько ошибочных параметров.") + QString("\r\n") +
				tr("Вы уверены, что хотите продолжить процесс несмотря на возможные ошибки?")
			, QMessageBox::Yes, QMessageBox::No);

		if (answer == QMessageBox::No)
		{
			return false;
		}
	}
	
	Configurator& configurator = Configurator::instanse();
	configurator.setImagePath(m_ui.imagePath->text());
	configurator.setTempPath(m_ui.tempPath->text());

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

	const QStringList entries = QDir().entryList(QStringList()
		<< "*silent*.iso"
		<< "*hill*.iso"
		<< "*shattered*.iso"
		<< "*memories*.iso"
		<< "*SHLPA4*.iso"
		<< "*shsm*.iso"
		<< "*sh*.iso"
		<< "*silent*.iso"
		<< "*.iso",
			QDir::Files | QDir::Writable);
	
	if (!entries.isEmpty())
	{
		m_ui.imagePath->setText(entries.first());
	}
}

void ImagePatchPage::onImageSelectPressed()
{
	const QString filename = QFileDialog::getOpenFileName(this, tr("Выберите бэкап-образ для применения патча..."), m_ui.imagePath->text(), tr("Бэкап-образы Wii (*.iso)"));
	if (!filename.isNull())
	{
		m_ui.imagePath->setText(QDir::toNativeSeparators(filename));
	}
}

void ImagePatchPage::onTempPathSelectPressed()
{
	const QString directory = QFileDialog::getExistingDirectory(this, tr("Укажите путь к директории для временных файлов..."), m_ui.tempPath->text());
	if (!directory.isNull())
	{
		m_ui.tempPath->setText(QDir::toNativeSeparators(directory));
	}
}

void ImagePatchPage::onTempPathFreeSpaceError(quint64 space)
{
	const quint64 megabytes = space / (1024 * 1024);
	const double gygabytes = static_cast<double>(megabytes) / 1024.0;
	showToolTip(m_ui.tempPath, tr("Доступно %1 ГБ из необходимых 3 ГБ!").arg(gygabytes, 0, 'f', 2));
}

void ImagePatchPage::onTempPathError()
{
	showToolTip(m_ui.tempPath, tr("Указанный путь неверен!"));
}

void ImagePatchPage::onTempPathResetError()
{
	hideToolTip(m_ui.tempPath);
}

//////////////////////////////////////////////////////////////////////////

void ImagePatchPage::onImagePathError()
{
	showToolTip(m_ui.imagePath, tr("Указанный путь неверен!"));
}

void ImagePatchPage::onImagePathAccessError()
{
	showToolTip(m_ui.imagePath, tr("Указанный файл недоступен для записи!"));
}

void ImagePatchPage::onImagePathResetError()
{
	hideToolTip(m_ui.imagePath);
}

//////////////////////////////////////////////////////////////////////////

void ImagePatchPage::showToolTip(QWidget* widget, const QString& text)
{
	QToolTip::showText(widget->mapToGlobal(QPoint(0, 0)), text, widget);
}

void ImagePatchPage::hideToolTip(QWidget* widget)
{
	QToolTip::showText(QPoint(), QString(), widget);
}