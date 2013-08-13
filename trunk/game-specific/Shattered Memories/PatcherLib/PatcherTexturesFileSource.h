#pragma once
#include "OnFlyPatchStream.h"
#include "TextureDatabase.h"
#include <FileSource.h>
#include <QtFileStream.h>
#include <QList>
#include <memory>

namespace ShatteredMemories
{

enum PartType
{
	partRaster,
	partPalette
};

struct PartInfoRecord
{
	uint32 offset() const
	{
		return (type == partRaster ? textureInfo.rasterOffset : textureInfo.paletteOffset);
	}

	uint32 size() const
	{
		return (type == partRaster ? textureInfo.rasterSize : textureInfo.paletteSize);
	}

	PartType type;
	TextureDatabase::TextureInfo textureInfo;
};

class PatcherTexturesFileSource : public FileSource
{
public:
	PatcherTexturesFileSource(FileSource* primarySource, const QString& texturesPath, const TextureDatabase& texturesDatabase);

	virtual std::tr1::shared_ptr<Consolgames::Stream> file(uint32 hash, FileAccessor& accessor) override;

private:
	class TextureDataSource : public OnFlyPatchStream::DataSource
	{
	public:
		TextureDataSource(const QString& path, const QList<TextureDatabase::TextureInfo>& textures);

		virtual std::tr1::shared_ptr<Consolgames::Stream> getAt(int index) override;
		virtual int partCount() const override;
		virtual OnFlyPatchStream::PartInfo partInfoAt(int index) const override;

	private:
		const QString m_path;
		QList<PartInfoRecord> m_partInfo;
		std::tr1::shared_ptr<QtFileStream> m_cachedFile;
	};

private:
	FileSource* m_primarySource;
	TextureDatabase m_textureDB;
	QString m_texturesPath;
	static const std::string s_fontFilename;
	static const std::string s_fontFileExt;
	static const quint32 s_fontFilenameHash;
};

}
