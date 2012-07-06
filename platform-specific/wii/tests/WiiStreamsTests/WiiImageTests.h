#pragma once
#include <WiiImage.h>
#include <QObject>

class WiiImageTests : public QObject
{
	Q_OBJECT

private:
	Q_SLOT void initTestCase();
	Q_SLOT void filesTest();
	Q_SLOT void cleanupTestCase();

	Consolgames::WiiImage m_image;
};