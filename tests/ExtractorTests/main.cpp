#include "ExtractorTests.h"
#include <QTest>

int main(int argc, char* argv[])
{
	QTest::qExec(&ExtractorTests(), argc, argv);
	return 0;
}