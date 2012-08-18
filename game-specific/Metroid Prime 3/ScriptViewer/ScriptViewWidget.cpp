#include "ScriptViewWidget.h"
#include <MetroidFont.h>
#include <QImage>

ScriptViewWidget::ScriptViewWidget(QWidget* parent) : QGLWidget(parent)
{
}

void ScriptViewWidget::initializeGL()
{
	{
		Font* font = new Font(this, &m_renderer);
		font->loadFromEditorFormat("D:\\svn\\consolgames\\translations\\mp3c\\content\\rus\\fonts\\mtf\\FC1BE4F13D86CE52.mtf");
		m_renderer.addFont(0xFC1BE4F13D86CE52ULL, font);
	}

	glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glMatrixMode(GL_MODELVIEW);
	glEnable(GL_TEXTURE_2D);
	glLoadIdentity();

	glColor3d(1, 1, 1);
}

void ScriptViewWidget::resizeGL(int width, int height)
{
	glViewport(0, 0, width, height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, width, height, 0, -1, 1);
}

void ScriptViewWidget::paintGL()
{	
	glClear(GL_COLOR_BUFFER_BIT);
	m_renderer.drawString(m_currentText);
}

void ScriptViewWidget::drawText(const QString& text)
{
	m_currentText = text;
	updateGL();
}