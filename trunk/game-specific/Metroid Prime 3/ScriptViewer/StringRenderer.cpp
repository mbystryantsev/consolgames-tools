#include <qgl.h>
#include "StringRenderer.h"

void StringRenderer::drawRawString(const QString& str, double scale)
{
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glScaled(scale, scale, 1.0);

	QChar prevChar = '\0';
	foreach (QChar c, str)
	{
		m_font->drawChar(c);
		m_font->processKerning(prevChar, c);
	}

	glPopMatrix();
}

void StringRenderer::drawString(const QString& str, double scale)
{
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glScaled(scale, scale, 1.0);
	glPushMatrix();

	QChar prevChar = '\0';
	bool tagMode = false;
	foreach (QChar c, str)
	{
		if (tagMode)
		{
			tagMode = (c != ';');
			continue;
		}

		if (c == '\n')
		{
			glPopMatrix();
			glTranslated(0, m_font->height(), 0);
			glPushMatrix();
			continue;
		}

		m_font->drawChar(c);
		m_font->processKerning(prevChar, c);
		tagMode = (c == '&');
	}

	glPopMatrix();
	glPopMatrix();
}

void StringRenderer::setFont(Font* font)
{
	m_font = font;
}