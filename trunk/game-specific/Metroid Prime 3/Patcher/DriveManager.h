#pragma once

class DriveManager
{
public:
	static QList<QChar> usbDriveList();
	static QList<QChar> cdDriveList();
	static QString volumeName(QChar letter);
};
