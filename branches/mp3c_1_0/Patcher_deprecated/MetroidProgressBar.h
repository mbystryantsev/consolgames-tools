#pragma once
#include <QProgressBar>
#include <QTimer>

class MetroidProgressBar : public QProgressBar
{
	Q_OBJECT

	Q_PROPERTY(double opacity READ opacity WRITE setOpacity NOTIFY opacityChanged)

public:
	MetroidProgressBar(QWidget* parent = NULL, bool startNow = false);
	void start();
	void stop();

public:
	double opacity() const;
	void setOpacity(double op);
	Q_SIGNAL void opacityChanged();

private:
	virtual void paintEvent(QPaintEvent* event) override;
	Q_SLOT void processFrame();

private:
	QPixmap m_background;
	QTimer m_timer;
	int m_backgroundOffset;
	bool m_running;
	double m_opacity;
};
