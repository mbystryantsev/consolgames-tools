#include "CompressionTests.h"
#include <QTest>

int main(int argc, char* argv[])
{
	QTest::qExec(&CompressionTests(), argc, argv);
	return 0;
}