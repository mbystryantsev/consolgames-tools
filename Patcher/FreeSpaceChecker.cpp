#include "FreeSpaceChecker.h"
#include <QLineEdit>
#include <QDir>
#include <Windows.h>

static const quint64 g_bytesNeeded = 3221225472ULL;

static quint64 getFreeSpace(const QString& path)
{
	quint64 freeBytes = 0;
	const bool success = GetDiskFreeSpaceEx(reinterpret_cast<LPCWSTR>(path.constData()), reinterpret_cast<PULARGE_INTEGER>(&freeBytes), NULL, NULL);
	return success ? freeBytes : 0;
}

FreeSpaceChecker::FreeSpaceChecker(QLineEdit* pathEdit, QObject* parent)
	: PathChecker(pathEdit, parent)
{
}

void FreeSpaceChecker::onPathChanged()
{
	const QString path = m_edit->text();

	QDir dir(path);
	if (!dir.exists())
	{
		setError();
		emit pathError();
		return;
	}

	const QString nativePath = QDir::toNativeSeparators(dir.absolutePath());
	const quint64 freeSpace = getFreeSpace(nativePath);

	if (freeSpace < g_bytesNeeded)
	{
		setError();
		emit freeSpaceError(freeSpace);
		return;
	}

	resetError();
}
