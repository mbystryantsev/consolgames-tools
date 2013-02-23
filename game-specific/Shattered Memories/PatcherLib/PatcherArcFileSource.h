#pragma once
#include "OnFlyPatchStream.h"
#include "TextureDatabase.h"
#include <FileSource.h>
#include <QList>

namespace ShatteredMemories
{

class PatcherArcFileSource : public FileSource
{
public:
	PatcherArcFileSource(FileSource* primarySource, const QString& texturesPath, const TextureDatabase& texturesDatabase);

	virtual std::tr1::shared_ptr<Consolgames::Stream> file(u32 hash, FileAccessor& accessor) override;

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
		QList<OnFlyPatchStream::PartInfo> m_partInfo;
		QList<TextureDatabase::TextureInfo> m_texturesInfo;
	};

private:
	FileSource* m_primarySource;
	TextureDatabase m_textureDB;
	QString m_texturesPath;
};

}
