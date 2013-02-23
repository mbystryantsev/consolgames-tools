#include "TextureDatabase.h"
#include "CsvReader.h"

namespace ShatteredMemories
{

TextureDatabase::TextureDatabase()
{
}

ShatteredMemories::TextureDatabase TextureDatabase::fromCSV(const QString& filename)
{
	TextureDatabase db;

	CsvReader reader(filename);
	ASSERT(reader.opened());

	ASSERT(reader.header().contains("fileHash"));
	ASSERT(reader.header().contains("textureName"));
	ASSERT(reader.header().contains("width"));
	ASSERT(reader.header().contains("height"));
	ASSERT(reader.header().contains("mipmapCount"));
	ASSERT(reader.header().contains("rasterPosition"));
	ASSERT(reader.header().contains("rasterSize"));

	while (true)
	{
		const QMap<QString, QString> values = reader.readLine();
		if (values.isEmpty())
		{
			break;
		}

		TextureInfo info;

		bool ok = false;
		info.fileHash = values["fileHash"].toUInt(&ok, 16);
		ASSERT(ok);
		
		info.textureName = values["textureName"];

		info.width = values["width"].toInt(&ok);
		ASSERT(ok);

		info.height = values["height"].toInt(&ok);
		ASSERT(ok);

		info.mipmapCount = values["mipmapCount"].toInt(&ok);
		ASSERT(ok);

		info.rasterOffset = values["rasterPosition"].toInt(&ok, 16);
		ASSERT(ok);

		info.rasterSize = values["rasterSize"].toInt(&ok, 16);
		ASSERT(ok);

		db.m_info[info.fileHash][info.textureName] = info;
	}

	return db;
}

bool TextureDatabase::contains(quint32 hash) const
{
	return m_info.contains(hash);
}

QList<TextureDatabase::TextureInfo> TextureDatabase::textures(quint32 hash) const
{
	return m_info[hash].values();
}

bool TextureDatabase::isNull() const
{
	return m_info.isEmpty();
}

}