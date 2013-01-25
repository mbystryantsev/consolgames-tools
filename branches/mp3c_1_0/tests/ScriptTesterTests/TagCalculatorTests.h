#pragma once
#include <QObject>

class TagCalculatorTests : public QObject
{
	Q_OBJECT;

	Q_SLOT void simpleTest();
	Q_SLOT void charTest();
};