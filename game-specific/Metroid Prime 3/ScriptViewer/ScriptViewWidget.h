#pragma once
#include "StringRenderer.h"
#include "Font.h"
#include <QGLWidget>
#include <QList>
#include <MetroidFont.h>

class ScriptViewWidget : public QGLWidget
{
	Q_OBJECT;

public:
	ScriptViewWidget(QWidget* parent = NULL);

	void drawText(const QString& text);

protected:
	virtual void initializeGL() override;
	virtual void resizeGL(int width, int height) override;
	virtual void paintGL() override;

	Font m_font;
	int m_texture;

	QString m_currentText;
	StringRenderer m_renderer;
};
