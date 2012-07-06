#include "TagCalculator.h"

int TagCalculator::calcTags(const QString& str)
{
	int tagCount = 0;
	bool tagOpened = false;
	foreach (const QChar c, str)
	{
		if (tagOpened)
		{
			if (c == ';')
			{
				tagOpened = false;
				continue;
			}
			if (!(c == '&' || c == '-' || c == '?' || c == '/' || c == '_' || c == '|' || c == '=' || c == ':' || c == '(' || c == ')' || c == '[' || c == ']' || c == '#' || c == ',' || c == '.' || c.isDigit() || (c.toLower() >= 'a' && c.toLower() <= 'z')))
			{
				return -1;
			}
		}
		else if (c == '&')
		{
			tagOpened = true;
			tagCount++;
		}
	}
	return tagOpened ? -1 : tagCount;
}

bool TagCalculator::checkString(const QString& str)
{
	return (calcTags(str) != -1);
}