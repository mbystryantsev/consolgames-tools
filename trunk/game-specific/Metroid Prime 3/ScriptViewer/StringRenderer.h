#pragma once
#include "Font.h"

class StringRenderer
{
public:
	void drawRawString(const QString& str, double scale = 1.0);
	void drawString(const QString& str, double scale = 1.0);

	void setFont(Font* font);

protected:
	Font* m_font;
};