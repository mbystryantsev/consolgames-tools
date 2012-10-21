#include "MetroidProgressBar.h"
#include <QStylePainter>
#include <QPaintEvent>
#include <QBitmap>

MetroidProgressBar::MetroidProgressBar(QWidget* parent, bool startNow) 
	: QProgressBar(parent)
	, m_background(":/progressbg.png")
	, m_backgroundOffset(0)
	, m_opacity(0.5)
{
	setRange(0, 100);
	connect(&m_timer, SIGNAL(timeout()), SLOT(processFrame()));
	m_timer.setInterval((1000 / 60) / 2);
	if (startNow)
	{
		start();
	}
}

void MetroidProgressBar::start()
{
	m_timer.start();
}

void MetroidProgressBar::stop()
{
	m_timer.stop();
}

void MetroidProgressBar::paintEvent(QPaintEvent* event)
{
	QStylePainter painter(this);

	const double ratio = 1.0 - static_cast<double>(value()) / (maximum() - minimum());
	QRect rect = event->rect();
	rect.adjust(0, 0, -rect.width() * ratio, 0);

	painter.setOpacity(m_opacity);
	painter.setBrush(QBrush(m_background));
	painter.translate(m_backgroundOffset, 0);
	painter.drawRect(rect.adjusted(-m_backgroundOffset, 0, -m_backgroundOffset, -1));
	painter.resetTransform();
	painter.setOpacity(1.0);
	painter.setPen(QPen(QColor(Qt::white)));
	painter.setBrush(Qt::NoBrush);
	painter.drawRect(event->rect().adjusted(0, 0, -1, -1));
	painter.setFont(font());
	painter.drawText(event->rect(), Qt::AlignCenter | Qt::AlignHCenter, text());
}

void MetroidProgressBar::processFrame()
{
	m_backgroundOffset = (m_backgroundOffset + 1) % m_background.width();
	repaint();
}

double MetroidProgressBar::opacity() const
{
	return m_opacity;
}

void MetroidProgressBar::setOpacity(double op)
{
	m_opacity = op;
	emit opacityChanged();
}