#pragma once
#include <QLabel>

class TransparentLabel : public QLabel
{
	Q_OBJECT

	Q_PROPERTY(double opacity READ opacity WRITE setOpacity NOTIFY opacityChanged)

public:
	TransparentLabel(QWidget* parent = NULL);
	TransparentLabel(const QString& text, QWidget* parent = NULL);

	double opacity() const;
	Q_SLOT void setOpacity(double op);
	Q_SIGNAL void opacityChanged(double op);

private:
	double m_opacity;
};
