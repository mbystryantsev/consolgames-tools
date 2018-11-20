#pragma once
#include <QUuid>
#include <QWidget>
#include <windows.h>

class DriveListener : public QWidget
{
	Q_OBJECT

public:
	DriveListener(QWidget* parent = NULL);
	~DriveListener();

	Q_SIGNAL void drivesInserted(const QList<QChar>& letters);
	Q_SIGNAL void drivesRemoved(const QList<QChar>& letters);

private:
	void registerDeviceNotification();
	void unregisterDeviceNotification();
	virtual bool winEvent(MSG* message, long* result);

private:
	const QUuid m_uid;
	QWidget* m_widget;
	HDEVNOTIFY m_handle;
};