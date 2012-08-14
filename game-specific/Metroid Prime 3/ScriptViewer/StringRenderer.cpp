#include <qgl.h>
#include "StringRenderer.h"

void StringRenderer::drawString(const QString& str, double scale)
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

void StringRenderer::setFont(Font* font)
{
	m_font = font;
}