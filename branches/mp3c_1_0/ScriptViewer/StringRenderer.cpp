#include "StringRenderer.h"
#include <core.h>
#include <ValueHolder.h>
#include <qgl.h>

QHash<QString,StringRenderer::TagType> StringRenderer::s_tagsInfo;

StringRenderer::StringRenderer(QGLWidget* parent)
	: QObject(parent)
	, m_context(parent)
	, m_currentFont(NULL)
	, m_isDrawing(false)
	, m_stackSize(0)
	, m_scale(1.0)
	, m_texture(0)
	, m_alignHorizontally(false)
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
		s_tagsInfo["lookup"] = tagLookup;
		s_tagsInfo["just"] = tagJust;
		s_tagsInfo["space"] = tagSpace;
	}
}

void StringRenderer::drawChar(QChar c)
{
	ASSERT(m_isDrawing);
	m_currentFont->drawChar(c);
}

int StringRenderer::charWidth(QChar c, QChar prevChar) const
{
	return m_currentFont->charWidth(c) + m_currentFont->kerning(prevChar, c);
}

int StringRenderer::wordWidth(const QString::const_iterator& begin, const QString::const_iterator& end) const
{
	int width = 0;
	QChar prevChar = '\0';
	for (QString::const_iterator c = begin; c != end; c++)
	{
		if (c->isSpace())
		{
			break;
		}
		width += charWidth(*c, prevChar);
		prevChar = *c;
	}
	return width;
}

void StringRenderer::drawBackground()
{
	ASSERT(m_isDrawing);
	if (m_texture == 0)
	{
		return;
	}

	glBindTexture(GL_TEXTURE_2D, m_texture);
	glBegin(GL_QUADS);
	{
		glTexCoord2d(0, 0);
		glVertex2f(0, 0);

		glTexCoord2d(1, 0);
		glVertex2f(m_textureSize.width(), 0);

		glTexCoord2d(1, 1);
		glVertex2f(m_textureSize.width(), m_textureSize.height());

		glTexCoord2d(0, 1);
		glVertex2f(0, m_textureSize.height());
	}
	glEnd();
}

void StringRenderer::drawRawString(const QString& str)
{
	ASSERT(m_isDrawing);

	QChar prevChar = '\0';
	foreach (QChar c, str)
	{
		m_currentFont->drawChar(c);
		m_currentFont->processKerning(prevChar, c);
	}
}

int StringRenderer::lineWidth(const QChar* begin, const QChar* end, int areaWidth)
{
	int lineWidth = 0;
	bool wordEndReached = false;
	QChar prevChar = '\0';
	for (const QChar* c = begin; c != end; c++)
	{
		while (*c == '&')
		{
			parseTag(c, end);
		}
		if (c == end || *c == '\n' || (wordEndReached && lineWidth + wordWidth(c, end) > areaWidth))
		{
			break;
		}
		if (c->isSpace())
		{
			wordEndReached = true;
		}

		lineWidth += charWidth(*c, prevChar);
		prevChar = *c;
	}
	return lineWidth;
}

void StringRenderer::drawString(const QString& str)
{
	ASSERT(m_currentFont != NULL);
	ASSERT(m_stackSize == 0);
	ASSERT(!m_isDrawing);
	FlagHolder startDrawing(m_isDrawing, true);
	FlagHolder horAlignRestorer(m_alignHorizontally);

	int initialStackDepth = 0;
	glGetIntegerv(GL_MODELVIEW_STACK_DEPTH, &initialStackDepth);

	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glScaled(m_scale, m_scale, 1.0);
	
	const QRect currentRect = m_textArea.isNull()
		? QRect(0, 0, m_context->geometry().width() / m_scale, m_context->geometry().height() / m_scale) : m_textArea;

	drawBackground();

	glTranslated(currentRect.left(), currentRect.top(), 0.0);	
	glPushMatrix();
	pushState();

	int currLineWidth = 0;
	bool wordEndReached = false;
	bool isFirstChar = true;
	QChar prevChar = '\0';
	bool wrapLine = false;
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
			wrapLine = true;
			continue;
		}
		if (c->isSpace())
		{
  			wordEndReached = true;
		}
		else if (wordEndReached && currLineWidth + wordWidth(c, str.end()) > currentRect.width())
		{
			wrapLine = true;
		}

		if (wrapLine)
		{
			glPopMatrix();
			glTranslated(0, m_currentFont->linespacing() > 0 ? m_currentFont->linespacing() : m_currentFont->height(), 0);
			glPushMatrix();
			currLineWidth = 0;
			wordEndReached = false;
		}
		if (m_alignHorizontally && (wrapLine || isFirstChar))
		{
			const int width = lineWidth(c, str.constEnd(), currentRect.width());
			const int offset = (currentRect.width() - width) / 2;
			glTranslated(offset, 0, 0);
		}
		wrapLine = false;

		if (*c != '\n')
		{
			currLineWidth += charWidth(*c, prevChar);
			m_currentFont->drawChar(*c);
			m_currentFont->processKerning(prevChar, *c);
		}
		isFirstChar = false;
	}

	popState();

	clearStack();

	glPopMatrix();
	glPopMatrix();

	int newStackDepth = 0;
	glGetIntegerv(GL_MODELVIEW_STACK_DEPTH, &newStackDepth);
	ASSERT(initialStackDepth = newStackDepth);
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

void StringRenderer::setTextArea(const QImage& texture, const QRect& area)
{
	freeTextures();
	m_texture = m_context->bindTexture(texture, GL_TEXTURE_2D, GL_RGBA, QGLContext::NoBindOption);
	m_textureSize = texture.size();
	m_textArea = area;
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
	ASSERT(m_isDrawing);

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
	else if (tagInfo.type == tagLookup)
	{
		drawRawString("%" + tagInfo.value + "%");
	}
	else if (tagInfo.type == tagSpace)
	{
		drawChar(' ');
	}
	else if (tagInfo.type == tagJust)
	{
		if (tagInfo.value == "left")
		{
			m_alignHorizontally = false;
		}
		else if (tagInfo.value == "center")
		{
			m_alignHorizontally = true;
		}
	}
}

void StringRenderer::setScale(double scale)
{
	m_scale = scale;
}

double StringRenderer::scale() const
{
	return m_scale;
}

void StringRenderer::freeTextures()
{
	if (m_texture != 0)
	{
		glDeleteTextures(1, &m_texture);
		m_texture = 0;
	}
}

void StringRenderer::setAlignHorizontally(bool align)
{
	m_alignHorizontally = align;
}

bool StringRenderer::alignHorizontally() const
{
	return m_alignHorizontally;
}