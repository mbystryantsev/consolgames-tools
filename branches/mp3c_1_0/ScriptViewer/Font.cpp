#include "Font.h"
#include <QImage>

using namespace Consolgames;

Font::Font(QGLWidget* context, QObject* parent)
	: QObject(parent)
	, m_context(context)
	, m_linespacing(0)
{
}

Font::~Font()
{
	freeRenderLists();
	deleteTextures();
}

bool Font::load(const QString& fontFilename, const QString& textureFilename)
{
	if (!m_font.load(fontFilename, textureFilename))
	{
		return false;
	}
	return init();
}

bool Font::loadFromEditorFormat(const QString& filename)
{
	if (!m_font.loadFromEditorFormat(filename))
	{
		return false;
	}
	return init();
}

void Font::setLinespacing(int spacing)
{
	m_linespacing = spacing;
}

int Font::linespacing() const
{
	return m_linespacing;
}

bool Font::init()
{
	initTextures();
	prepareRenderLists();

	return true;
}

void Font::initTextures()
{
	deleteTextures();
	for (int i = 0; i < m_font.layerCount(); i++)
	{
		const SimpleImage& texture = m_font.layerTexture(i);
		QImage image(texture.data(), texture.width(), texture.height(), texture.width(), QImage::Format_Indexed8);
		image.setColorCount(256);
		image.setColor(0, qRgba(0, 0, 0, 0));
		image.setColor(1, qRgb(255, 255, 255));
		image.setColor(2, qRgba(127, 127, 127, 127));
		const GLuint textureId = m_context->bindTexture(image, GL_TEXTURE_2D, GL_RGBA, QGLContext::NoBindOption);
		m_textures.append(textureId);
	}
}

void Font::prepareRenderLists()
{
	freeRenderLists();
	
	const QList<QChar> charList = m_font.charList();
	m_listsBegin = glGenLists(charList.size());
	GLuint currList = m_listsBegin;
	foreach (QChar c, charList)
	{
		m_charLists[c] = currList;
		glNewList(currList, GL_COMPILE);
		drawCharDirectly(c);
		glEndList();
		currList++;
	}
}

void Font::deleteTextures()
{
	foreach (GLuint textureId, m_textures)
	{
		m_context->deleteTexture(textureId);
	}
	m_textures.clear();
}

void Font::freeRenderLists()
{
	glDeleteLists(m_listsBegin, m_charLists.size());
	m_charLists.clear();
	m_listsBegin = 0;
}

void Font::drawCharDirectly(QChar c) const
{
	MetroidFont::CharMetrics metrics = m_font.charMetrics(c);
	if (metrics.isNull())
	{
		return;
	}

	const MetroidFont::Rect& r = metrics.glyphRect;
	const int baselineOffset = m_font.height() - metrics.baselineOffset;

	glBindTexture(GL_TEXTURE_2D, m_textures[metrics.layer]);
	glTranslated(metrics.leftIdent, baselineOffset, 0);
	glBegin(GL_QUADS);
	{
		glTexCoord2d(r.left, r.top);
		glVertex2i(0, 0);

		glTexCoord2d(r.right, r.top);
		glVertex2i(metrics.glyphWidth, 0);

		glTexCoord2d(r.right, r.bottom);
		glVertex2i(metrics.glyphWidth, metrics.glyphHeight);

		glTexCoord2d(r.left, r.bottom);
		glVertex2i(0, metrics.glyphHeight);
	}
	glEnd();
	glTranslated(metrics.bodyWidth + metrics.rightIdent, -baselineOffset, 0);
}

void Font::drawChar(QChar c) const
{
 	if (m_charLists.contains(c))
 	{
 		glCallList(m_charLists[c]);
 	}
}

void Font::processKerning(QChar a, QChar b) const
{
	const int kerning = m_font.kerning(a, b);
	if (kerning != 0)
	{
		glTranslated(kerning, 0, 0);
	}
}

int Font::height() const
{
	return m_font.height();
}

int Font::kerning(QChar a, QChar b) const
{
	return m_font.kerning(a, b);
}

int Font::charWidth(QChar c) const
{
	const MetroidFont::CharMetrics metrics = m_font.charMetrics(c);
	return metrics.leftIdent + metrics.bodyWidth + metrics.rightIdent;
}