#include "TagCalculatorTests.h"
#include <TagCalculator.h>
#include <QtTest>

void TagCalculatorTests::simpleTest()
{
	int tags = TagCalculator::calcTags("&tag;text&tag2;text2&tag=0xABCD;&tag=-10;");
	QCOMPARE(tags, 4);
}

void TagCalculatorTests::charTest()
{
	int tags = TagCalculator::calcTags("&tag=$;");
	QCOMPARE(tags, -1);
}