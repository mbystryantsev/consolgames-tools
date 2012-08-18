#include "StringRenderer.h"
#include <FlagHolder.h>
#include <qgl.h>

QHash<QString,StringRenderer::TagType> StringRenderer::s_tagsInfo;

StringRenderer::StringRenderer(QObject* parent)
	: QObject(parent)
	, m_currentFont(NULL)
	, m_isDrawing(false)
	, m_stackSize(0)
{
	initTagsInfo();
}

void StringRenderer::initTagsInfo()
{
	if (s_tagsInfo.isEmpty())
	{
		s_tagsInfo["push"] = tagPush;
		s_tagsInfo["pop"] = tagPop;
		s_tagsInfo["main-color"] = tagMainColor;
	}
}

void StringRenderer::drawRawString(const QString& str, double scale)
{
	ASSERT(m_currentFont != NULL);
	ASSERT(!m_isDrawing);
	FlagHolder startDrawing(m_isDrawing, true); 
	
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glScaled(scale, scale, 1.0);

	QChar prevChar = '\0';
	foreach (QChar c, str)
	{
		m_currentFont->drawChar(c);
		m_currentFont->processKerning(prevChar, c);
	}

	glPopMatrix();
}

void StringRenderer::drawString(const QString& str, double scale)
{
	ASSERT(m_currentFont != NULL);
	ASSERT(m_stackSize == 0);
	ASSERT(!m_isDrawing);
	FlagHolder startDrawing(m_isDrawing, true);

	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glScaled(scale, scale, 1.0);
	glPushMatrix();

	pushState();

	QChar prevChar = '\0';
	for (QString::const_iterator c = str.constBegin(); c != str.constEnd(); c++)
	{
		while (*c == '&')
		{
			const TagInfo tag = parseTag(c, str.constEnd());
			processTag(tag);
		}
		if (c == str.constEnd())
		{
			break;
		}

		if (*c == '\n')
		{
			glPopMatrix();
			glTranslated(0, m_currentFont->height(), 0);
			glPushMatrix();
			continue;
		}

		m_currentFont->drawChar(*c);
		m_currentFont->processKerning(prevChar, *c);
	}

	popState();

	clearStack();

	glPopMatrix();
	glPopMatrix();
}

void StringRenderer::addFont(quint64 hash, Font* font)
{
	m_fonts[hash] = font;
	font->setParent(this);
	if (m_currentFont == NULL)
	{
		m_currentFont = font;
	}
}

static bool equalString(const QString::const_iterator& begin, const QString::const_iterator& end, const QString& str)
{
	return (end - begin == str.size() && qEqual(begin, end, str.begin()));
}

StringRenderer::TagType StringRenderer::detectTagType(const QString::const_iterator& begin, const QString::const_iterator& end)
{
	return s_tagsInfo.value(QString(begin, end - begin), tagUnknown);
}

StringRenderer::TagInfo StringRenderer::parseTag(QString::const_iterator& c, const QString::const_iterator& end)
{
	ASSERT(*c == '&');
	ASSERT(c != end);
	c++;
	const QString::const_iterator nameBegin = c;
	QString::const_iterator valueBegin;

	TagInfo info;
	bool typeDetected = false;
	bool valueStarted = false;
	bool tagCompleted = false;

	for (; c != end && !tagCompleted; c++)
	{
		if (*c == '=')
		{
			info.type = detectTagType(nameBegin, c);
			typeDetected = true;
			valueStarted = true;
			valueBegin = c + 1;
		}
		if (*c == ';')
		{
			if (!typeDetected)
			{
				info.type = detectTagType(nameBegin, c);
			}
			if (valueStarted)
			{
				info.value = QString(valueBegin, c - valueBegin);
			}
			tagCompleted = true;
		}
	}
	return info;
} 

void StringRenderer::pushState()
{
	glPushAttrib(GL_CURRENT_BIT);
	m_stackSize++;
}

void StringRenderer::popState()
{
	if (m_stackSize == 0)
	{
		DLOG << "Stack is empty!";
		return;
	}
	glPopAttrib();
	m_stackSize--;
}

void StringRenderer::clearStack()
{
	while (m_stackSize > 0)
	{
		popState();
	}
}

void StringRenderer::processTag(const TagInfo& tagInfo)
{
	if (tagInfo.type == tagMainColor)
	{
		if (tagInfo.value.isNull())
		{
			DLOG << "main-color: invalid color value!";
			return;
		}
		int alpha = 255;
		QString colorStr = tagInfo.value;
		if (tagInfo.value.length() == 9)
		{
			bool ok = false;
			alpha = QString(colorStr.end() - 2, 2).toUInt(&ok, 16);
			colorStr.resize(7);
			if (!ok)
			{
				DLOG << "Cannot process alpha!";
			}
		}
		QColor color(colorStr);
		glColor3d(color.redF(), color.greenF(), color.blueF());
	}
	else if (tagInfo.type == tagPush)
	{
		pushState();
	}
	else if (tagInfo.type == tagPop)
	{
		popState();
	}
}
