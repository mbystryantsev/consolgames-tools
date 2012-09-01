#pragma once
#include <MetroidFont.h>
#include <QGLWidget>
#include <QList>

class Font : public QObject
{
public:
	Font(QGLWidget* context, QObject* parent = NULL);
	~Font();

	bool load(const QString& fontFilename, const QString& textureFilename);
	bool loadFromEditorFormat(const QString& filename);

	void drawChar(QChar c) const;
	void processKerning(QChar a, QChar b) const;
	int height() const;

protected:
	bool init();
	void initTextures();
	void prepareRenderLists();

	void deleteTextures();
	void freeRenderLists();

	void drawCharDirectly(QChar c) const;

protected:
	Consolgames::MetroidFont m_font;
	QList<GLuint> m_textures;
	QMap<QChar, GLuint> m_charLists;
	QGLWidget* m_context;

	GLuint m_listsBegin;

};