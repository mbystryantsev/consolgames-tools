#pragma once
#include <QString>
#include <QMap>

namespace ShatteredMemories
{

class TextureDatabase
{
public:
	struct TextureInfo
	{
		quint32 fileHash;
		QString textureName;
		int width;
		int height;
		int mipmapCount;
		quint32 rasterOffset;
		quint32 rasterSize;
		quint32 paletteOffset;
		quint32 paletteSize;
	};
	typedef QMap<QString, TextureInfo> FileInfo;

public:
	TextureDatabase();
	static TextureDatabase fromCSV(const QString& filename);

	bool contains(quint32 hash) const;
	bool isNull() const;
	QList<TextureInfo> textures(quint32 hash) const;

private:
	QMap<quint32, FileInfo> m_info;
};

}