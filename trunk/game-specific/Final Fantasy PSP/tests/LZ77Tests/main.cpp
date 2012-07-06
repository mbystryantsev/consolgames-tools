#include "LZ77DecoderTests.h"
#include "LZ77EncoderTests.h"
#include <QtTest>

int main(int argc, char *argv[]) 
{ 
	QCoreApplication app(argc, argv);

	QTest::qExec(&LZ77DecoderTests());
	QTest::qExec(&LZ77EncoderTests());

	return 0;
}
