#include "ImageFileChecker.h"
#include <QLineEdit>
#include <QFile>
#include <QFileInfo>

ImageFileChecker::ImageFileChecker(QLineEdit* pathEdit, QObject* parent) : PathChecker(pathEdit, parent)
{
}

void ImageFileChecker::onPathChanged()
{
	const QString path = m_edit->text();

	QFile file(path);
	if (!file.exists())
	{
		setError();
		emit pathError();
		return;
	}

	if (!QFileInfo(file).isWritable())
	{
		setError();
		emit accessError();
		return;
	}

	resetError();
}
