#include "Category.h"
#include "Strings.h"
#include <QFile>
#include <QTextStream>

namespace
{

struct CategoryInfo
{
	CategoryInfo()
		: level(-1)
		, category(NULL)
	{
	}

	CategoryInfo(int level, Category& category)
		: level(level)
		, category(&category)
	{
	}

	int level;
	Category* category;
};

}

Category::Category(const QString& name)
	: name(name)
{

}

static int calcLevel(const QString& line)
{
	int level = 0;
	foreach (const QChar& c, line)
	{
		if (!c.isSpace())
		{
			break;
		}
		level++;
	}
	return level;
}

Category Category::fromFile(const QString& filename)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		DLOG << "Unable to open categories file: " << filename;
		return Category();
	}
	
	Category result;
	QStack<CategoryInfo> categoryStack;
	categoryStack.push(CategoryInfo(-1, result));

	QTextStream stream(&file);
	while (!stream.atEnd())
	{
		const QString line = stream.readLine();
		const QString trimmed = line.trimmed();
		if (trimmed.isEmpty() || trimmed.startsWith('#'))
		{
			continue;
		}

		Category& lastCategory = *categoryStack.last().category;
		const quint32 hash = ShatteredMemories::Strings::strToHash(trimmed);
		if (hash != 0)
		{
			lastCategory.messages.append(hash);
			continue;
		}

		const int level = calcLevel(line);
		if (level > categoryStack.last().level)
		{
			lastCategory.categories << Category(trimmed);
			categoryStack.push(CategoryInfo(level, lastCategory.categories.last()));
		}
		else
		{
			while (level <= categoryStack.last().level)
			{
				categoryStack.pop();
			}
			Category& lastCategory = *categoryStack.last().category;
			lastCategory.categories << Category(trimmed);
			categoryStack.push(CategoryInfo(level, lastCategory.categories.last()));
		}
	}

	return result;
}

bool Category::contains(quint32 hash) const
{
	if (messages.contains(hash))
	{
		return true;
	}
	foreach (const Category& category, categories)
	{
		if (category.contains(hash))
		{
			return true;
		}
	}
	return false;
}

QList<quint32> Category::allMessages() const
{
	QList<quint32> result = messages;
	foreach (const Category& child, categories)
	{
		result.append(child.allMessages());
	}

	return result;
}
