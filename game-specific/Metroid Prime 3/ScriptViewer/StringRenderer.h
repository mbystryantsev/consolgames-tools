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
		tagSpace
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
	StringRenderer(QGLWidget* parent);

	void drawString(const QString& str);
	void addFont(quint64 hash, Font* font);
	void setTextArea(const QImage& texture, const QRect& area);
	void setScale(double scale);
	double scale() const;

protected:
	void drawChar(QChar c);
	void drawRawString(const QString& str);
	int charWidth(QChar c, QChar prevChar = '\0') const;
	int wordWidth(const QString::const_iterator& begin, const QString::const_iterator& end) const;
	void drawBackground();

	static void initTagsInfo();
	TagInfo parseTag(QString::const_iterator& c, const QString::const_iterator& end);
	static TagType detectTagType(const QString::const_iterator& begin, const QString::const_iterator& end);
	void processTag(const TagInfo& tagInfo);

	void pushState();
	void popState();
	void clearStack();
	void freeTextures();

protected:
	QGLWidget* m_context;
	static QHash<QString,TagType> s_tagsInfo;
	QMap<quint64,Font*> m_fonts;
	Font* m_currentFont;
	bool m_isDrawing;
	double m_scale;
	int m_stackSize;
	QRect m_textArea;
	QSize m_textureSize;
	GLuint m_texture;
};