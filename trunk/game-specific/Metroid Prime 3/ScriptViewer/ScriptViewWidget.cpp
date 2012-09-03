#include "ScriptViewWidget.h"
#include <MetroidFont.h>
#include <QImage>
#include <QWheelEvent>

ScriptViewWidget::ScriptViewWidget(QWidget* parent) : QGLWidget(parent), m_renderer(this)
{
}

void ScriptViewWidget::initializeGL()
{
	{
		// Temporary solution
		Font* font = new Font(this, &m_renderer);
		font->loadFromEditorFormat("..\\content\\rus\\fonts\\mtf\\073A875DB4D51CE9.mtf");
		font->setLinespacing(17);
		m_renderer.addFont(0xFC1BE4F13D86CE52ULL, font);
		m_renderer.setTextArea(QImage("../misc/viewer_project/textarea.png"), QRect(30, 16, 382, 51));
		m_renderer.setAlignHorizontally(true);
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

void ScriptViewWidget::wheelEvent(QWheelEvent* event)
{
	if (event->delta() > 0)
	{
		m_renderer.setScale(qMin(10.0, m_renderer.scale() + 0.05));
	}
	else
	{
		m_renderer.setScale(qMax(0.1, m_renderer.scale() - 0.05));	
	}
	updateGL();
}