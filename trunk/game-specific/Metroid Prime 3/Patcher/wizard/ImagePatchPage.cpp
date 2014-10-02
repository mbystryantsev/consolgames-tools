#include "ImagePatchPage.h"
#include "PatchWizard.h"
#include "FreeSpaceChecker.h"
#include "ImageFileChecker.h"
#include <core.h>
#include <QToolTip>
#include <QFileDialog>
#include <QMessageBox>

ImagePatchPage::ImagePatchPage() : Page<Ui_ImagePatchPage>()
{
	setCommitPage(true);

	registerField("imagePath", m_ui.imagePath);
	registerField("tempPath", m_ui.tempPath);

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
	
	setButtonText(QWizard::NextButton, QString::fromLocal8Bit("������!"));
}

int ImagePatchPage::nextId() const 
{
	return PatchWizard::PageProgress;
}

void ImagePatchPage::initializePage()
{
#if defined(_DEBUG)
	m_ui.imagePath->setText(QDir::toNativeSeparators("D:/rev/Corruption/Metroid_3_forPatch.iso"));
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
			QString::fromLocal8Bit("���������� ������"),
			QString::fromLocal8Bit("��������, ������ ���� ��� ��������� ��������� ����������.\r\n"
				"�� �������, ��� ������ ���������� ������� �������� �� ��������� ������?")
			, QMessageBox::Yes, QMessageBox::No);

		if (answer == QMessageBox::No)
		{
			return false;
		}
	}
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
	const QString filename = QFileDialog::getOpenFileName(this, QString::fromLocal8Bit("�������� �����-����� ��� ���������� �����..."), m_ui.imagePath->text(), QString::fromLocal8Bit("�����-������ Wii (*.iso)"));
	if (!filename.isNull())
	{
		m_ui.imagePath->setText(QDir::toNativeSeparators(filename));
	}
}

void ImagePatchPage::onTempPathSelectPressed()
{
	const QString directory = QFileDialog::getExistingDirectory(this, QString::fromLocal8Bit("������� ���� � ���������� ��� ��������� ������..."), m_ui.tempPath->text());
	if (!directory.isNull())
	{
		m_ui.tempPath->setText(QDir::toNativeSeparators(directory));
	}
}

void ImagePatchPage::onTempPathFreeSpaceError(quint64 space)
{
	const quint64 megabytes = space / (1024 * 1024);
	const double gygabytes = static_cast<double>(megabytes) / 1024.0;
	showToolTip(m_ui.tempPath, QString::fromLocal8Bit("�������� %1 �� �� ����������� 3 ��!").arg(gygabytes, 0, 'f', 2));
}

void ImagePatchPage::onTempPathError()
{
	showToolTip(m_ui.tempPath, QString::fromLocal8Bit("��������� ���� �������!"));
}

void ImagePatchPage::onTempPathResetError()
{
	hideToolTip(m_ui.tempPath);
}

//////////////////////////////////////////////////////////////////////////

void ImagePatchPage::onImagePathError()
{
	showToolTip(m_ui.imagePath, QString::fromLocal8Bit("��������� ���� �������!"));
}

void ImagePatchPage::onImagePathAccessError()
{
	showToolTip(m_ui.imagePath, QString::fromLocal8Bit("��������� ���� ���������� ��� ������!"));
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