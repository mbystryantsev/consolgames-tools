#include "RunningLabel.h"
#include <QPainter>

const int RunningLabel::s_delta = 64;

RunningLabel::RunningLabel(QWidget* parent) : QLabel(parent), m_textOffset(0)
{
	connect(&m_timer, SIGNAL(timeout()), SLOT(processFrame()));
	m_timer.setInterval((1000 / 60) * 3);
	m_timer.start();
}

void RunningLabel::paintEvent(QPaintEvent* event)
{
	Q_UNUSED(event);

	QPainter painter(this);
	painter.setFont(font());
	painter.setPen(QPen(Qt::white));
	painter.translate(-m_textOffset, 0);
	painter.drawStaticText(0, 0, m_staticText);
	painter.drawStaticText(m_staticText.size().width() + s_delta, 0, m_staticText);
}

void RunningLabel::setText(const QString& text)
{
	m_staticText.setText(text);
	m_staticText.prepare(QTransform(), font());
	QLabel::setText(text);
}

void RunningLabel::processFrame()
{
	m_textOffset++;
	if (m_textOffset > m_staticText.size().width() + s_delta)
	{
		m_textOffset = 0;
	}
	repaint();
}