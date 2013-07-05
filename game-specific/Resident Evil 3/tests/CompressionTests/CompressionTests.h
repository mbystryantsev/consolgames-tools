#pragma once
#include <QObject>

class CompressionTests : public QObject
{
	Q_OBJECT

private:
	Q_SLOT void test();
	Q_SLOT void test_data();
};
