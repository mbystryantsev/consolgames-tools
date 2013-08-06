#include "TransparentLabel.h"

TransparentLabel::TransparentLabel(QWidget* parent)
	: QLabel(parent)
	, m_opacity(1.0)
{
}

TransparentLabel::TransparentLabel(const QString& text, QWidget* parent)
	: QLabel(text, parent)
	, m_opacity(1.0)
{
}

double TransparentLabel::opacity() const
{
	return m_opacity;
}

void TransparentLabel::setOpacity(double op)
{
	m_opacity = op;
	emit opacityChanged(op);

	QPalette pal = palette();
	QBrush brush = pal.brush(QPalette::Text);
	QColor color = brush.color();
	color.setAlphaF(op);
	brush.setColor(color);
	pal.setBrush(QPalette::Text, brush);
	setPalette(pal);
}
