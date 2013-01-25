#include "ScriptParserTests.h"
#include "TagCalculatorTests.h"
#include <QtTest>

int main(int argc, char *argv[]) 
{ 
	QCoreApplication app(argc, argv);

	QTest::qExec(&ScriptParserTests());
	QTest::qExec(&TagCalculatorTests());

	return 0;
}
