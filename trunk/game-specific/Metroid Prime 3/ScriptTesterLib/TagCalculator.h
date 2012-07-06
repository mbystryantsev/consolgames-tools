#pragma once
#include <QString>

class TagCalculator
{
public:
	static int calcTags(const QString& str);
	static bool checkString(const QString& str);
};