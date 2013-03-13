#pragma once

struct Category
{
	Category(const QString& name = "");

	static Category fromFile(const QString& filename);
	
	bool contains(quint32 hash) const;
	QList<quint32> allMessages() const;

	QString name;
	QList<Category> categories;
	QList<quint32> messages;
};
