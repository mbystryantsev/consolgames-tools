#include "ImageFileChecker.h"
#include <QLineEdit>
#include <QFileInfo>

ImageFileChecker::ImageFileChecker(QLineEdit* pathEdit, QObject* parent) : PathChecker(pathEdit, parent)
{
}

void ImageFileChecker::onPathChanged()
{
	const QString path = m_edit->text();

	QFileInfo info(path);
	if (!info.exists() || !info.isFile())
	{
		setError();
		emit pathError();
		return;
	}

	if (!info.isWritable())
	{
		setError();
		emit accessError();
		return;
	}

	resetError();
}
