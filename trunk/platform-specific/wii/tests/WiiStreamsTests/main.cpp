#include "WiiImageTests.h"
#include <QtTest>

int main(int argc, char *argv[]) 
{ 
	QCoreApplication app(argc, argv);

	QTest::qExec(&WiiImageTests());

	return 0;
}
