#pragma once
#include <QLabel>
#include <QStaticText>
#include <QTimer>

class RunningLabel : public QLabel
{
	Q_OBJECT

public:
	RunningLabel(QWidget* parent = NULL);
	void setText(const QString& text);

protected:
	virtual void paintEvent(QPaintEvent* event) override;
	Q_SLOT void processFrame();

protected:
	QStaticText m_staticText;
	int m_textOffset;
	QTimer m_timer;
	static const int s_delta;
};
