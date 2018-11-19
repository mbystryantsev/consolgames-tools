#include "TextureDatabase.h"
#include <CsvReader.h>
#include <Hash.h>

namespace ShatteredMemories
{

TextureDatabase::TextureDatabase()
{
}

ShatteredMemories::TextureDatabase TextureDatabase::fromCSV(const QString& filename)
{
	TextureDatabase db;

	CsvReader reader(filename);
	ASSERT(reader.isOpen());

	ASSERT(reader.header().contains("fileHash") || reader.header().contains("fileName"));
	ASSERT(reader.header().contains("textureName"));
	ASSERT(reader.header().contains("format"));
	ASSERT(reader.header().contains("width"));
	ASSERT(reader.header().contains("height"));
	ASSERT(reader.header().contains("mipmapCount"));
	ASSERT(reader.header().contains("rasterPosition"));
	ASSERT(reader.header().contains("rasterSize"));
	ASSERT(reader.header().contains("paletteFormat"));

	while (true)
	{
		const QMap<QString, QString> values = reader.readLine();
		if (values.isEmpty())
		{
			break;
		}

		TextureInfo info;

		if (values.contains("fileName"))
		{
			const QString name = values["fileName"];
			info.fileHash = Hash::calc(name.toStdString().c_str());
		}
		else
		{
			bool ok = false;
			info.fileHash = values["fileHash"].toUInt(&ok, 16);
			ASSERT(ok);
		}
		
		info.textureName   = values["textureName"];
		info.format        = values["format"];
		info.paletteFormat = values["paletteFormat"];


		bool ok = false;
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

		if (values.contains("palettePosition"))
		{
			ASSERT(values.contains("paletteSize"));

			info.paletteOffset = values["palettePosition"].toInt(&ok, 16);
			ASSERT(ok);

			info.paletteSize = values["paletteSize"].toInt(&ok, 16);
			ASSERT(ok);
		}
		else
		{
			info.paletteOffset = 0;
			info.paletteSize = 0;
		}

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