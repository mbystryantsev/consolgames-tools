#pragma once
#include <QUuid>
#include <QWidget>

class UsbDriveListener : public QWidget
{
	Q_OBJECT

public:
	UsbDriveListener(QWidget* parent = NULL);
	~UsbDriveListener();

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