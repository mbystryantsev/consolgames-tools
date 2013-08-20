#pragma once
#include <QObject>

class FontStreamRebuilderTests : public QObject
{
	Q_OBJECT;

private:
	Q_SLOT void shatteredMemoriesTest();
	Q_SLOT void shatteredMemoriesTest_data();

};
