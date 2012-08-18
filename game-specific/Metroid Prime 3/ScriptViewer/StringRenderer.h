#pragma once
#include "Font.h"
#include <QVariantMap>
#include <QHash>

class StringRenderer : public QObject
{
public:
	enum TagType
	{
		tagUnknown = -1,
		tagPush,
		tagPop,
		tagJust,
		tagImage,
		tagLookup,
		tagMainColor,


	};
	enum JustType
	{
		justLeft,
		justCenter,
		justRight,
	};
	struct TagInfo
	{
		TagInfo() : type(tagUnknown){}
		TagType type;
		QString value;
	};

public:
	StringRenderer(QObject* parent = NULL);

	void drawRawString(const QString& str, double scale = 1.0);
	void drawString(const QString& str, double scale = 1.0);

	void addFont(quint64 hash, Font* font);

protected:
	static void initTagsInfo();
	TagInfo parseTag(QString::const_iterator& c, const QString::const_iterator& end);
	static TagType detectTagType(const QString::const_iterator& begin, const QString::const_iterator& end);
	void processTag(const TagInfo& tagInfo);

	void pushState();
	void popState();
	void clearStack();

protected:
	static QHash<QString,TagType> s_tagsInfo;
	QMap<quint64,Font*> m_fonts;
	Font* m_currentFont;
	bool m_isDrawing;
	int m_stackSize;
};