#include "ScriptViewWidget.h"
#include <MetroidFont.h>
#include <QImage>

ScriptViewWidget::ScriptViewWidget(QWidget* parent) : QGLWidget(parent), m_font(this)
{
}

void ScriptViewWidget::initializeGL()
{
	m_font.loadFromEditorFormat("D:\\svn\\consolgames\\translations\\mp3c\\content\\rus\\fonts\\mtf\\FC1BE4F13D86CE52.mtf");
	//m_font.load("D:\\rev\\corruption\\paks\\GuiNAND\\FONT_Deface14B.FONT", "D:\\rev\\corruption\\paks\\GuiNAND\\BBF70FA8BF8C7AEE.TXTR");
	m_renderer.setFont(&m_font);

	qglClearColor(Qt::green);
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
	m_renderer.drawString(QString::fromWCharArray(L"Множество!"), 2);
}