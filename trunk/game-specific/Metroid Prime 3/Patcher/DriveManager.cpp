#include "DriveManager.h"
#include <QDir>

QList<QChar> DriveManager::usbDriveList()
{
	QList<QChar> driveList;
	const quint32 mask = GetLogicalDrives();
	for (int i = 0; i < 24; i++)
	{
		if (mask & (1 << i))
		{
			const QChar letter = QChar('A' + i);
			const QString volumePath = QString("%1:\\").arg(letter);
			const int driveType = GetDriveType(reinterpret_cast<LPCWSTR>(volumePath.constData()));
			if (driveType == DRIVE_REMOVABLE)
			{
				if (QDir(volumePath).isReadable())
				{
					driveList << letter;
				}
			}
		}
	}
	return driveList;
}

QList<QChar> DriveManager::cdDriveList()
{
	QList<QChar> driveList;
	const quint32 mask = GetLogicalDrives();
	for (int i = 0; i < 24; i++)
	{
		if (mask & (1 << i))
		{
			const QChar letter = QChar('A' + i);
			const QString volumePath = QString("%1:\\").arg(letter);
			const int driveType = GetDriveType(reinterpret_cast<LPCWSTR>(volumePath.constData()));
			if (driveType == DRIVE_CDROM)
			{
				driveList << letter;
			}
		}
	}
	return driveList;
}

QString DriveManager::volumeName(QChar letter)
{
	const QString volumePath = QString("%1:\\").arg(letter);
	wchar_t nameBuffer[1024] = {};
	if (GetVolumeInformation(reinterpret_cast<LPCWSTR>(volumePath.constData()), reinterpret_cast<LPWSTR>(nameBuffer), sizeof(nameBuffer), NULL, 0, 0, NULL, 0) != 0)
	{
		return QString::fromWCharArray(nameBuffer);
	}
	return QString();
}