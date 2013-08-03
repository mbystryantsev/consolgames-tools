#include "PatcherTexturesFileSource.h"
#include "FontStreamRebuilder.h"
#include <Hash.h>
#include <FileStream.h>
#include <QDir>

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

const std::string PatcherTexturesFileSource::s_fontFilename = "FontEUR";
const std::string PatcherTexturesFileSource::s_fontFileExt = ".kft";
const quint32 PatcherTexturesFileSource::s_fontFilenameHash = Hash::calc(s_fontFilename.c_str());

PatcherTexturesFileSource::PatcherTexturesFileSource(FileSource* primarySource, const QString& texturesPath, const TextureDatabase& texturesDatabase)
	: m_primarySource(primarySource)
	, m_textureDB(texturesDatabase)
	, m_texturesPath(texturesPath)
{
}

shared_ptr<Stream> PatcherTexturesFileSource::file(uint32 hash, FileAccessor& accessor)
{
	if (hash == s_fontFilenameHash)
	{
		shared_ptr<Stream> fontStream = m_primarySource->fileByName(s_fontFilename + s_fontFileExt, accessor);
		if (fontStream.get() == NULL)
		{
			return fontStream;
		}

		DLOG << "Replacing font...";
		return shared_ptr<Stream>(new FontStreamRebuilder(accessor.open(), fontStream, Stream::orderBigEndian));
	}

	if (m_textureDB.contains(hash))
	{
		DLOG << "Found textures for file " << Hash::toString(hash);
		shared_ptr<Stream> stream = m_primarySource->file(hash, accessor);
		if (stream.get() == NULL)
		{
			stream = accessor.open();
		}
		ASSERT(stream.get() != NULL);

		return shared_ptr<Stream>(new OnFlyPatchStream(stream, shared_ptr<OnFlyPatchStream::DataSource>(new TextureDataSource(m_texturesPath, m_textureDB.textures(hash)))));
	}

	return m_primarySource->file(hash, accessor);
}

//////////////////////////////////////////////////////////////////////////

struct TextureInfoComparator
{
	bool operator()(const TextureDatabase::TextureInfo& a, const TextureDatabase::TextureInfo& b) const
	{
		return a.rasterOffset < b.rasterOffset;
	}
};

struct PartInfoComparator
{
	bool operator()(const OnFlyPatchStream::PartInfo& a, const OnFlyPatchStream::PartInfo& b) const
	{
		return a.offset < b.offset;
	}
};

PatcherTexturesFileSource::TextureDataSource::TextureDataSource(const QString& path, const QList<TextureDatabase::TextureInfo>& textures)
	: m_path(path)
	, m_texturesInfo(textures)
{
	foreach (const TextureDatabase::TextureInfo& info, textures)
	{
		OnFlyPatchStream::PartInfo partInfo;
		partInfo.offset = info.rasterOffset;
		partInfo.size = info.rasterSize;
		m_partInfo << partInfo;
	}

	qSort(m_partInfo.begin(), m_partInfo.end(), PartInfoComparator());
	qSort(m_texturesInfo.begin(), m_texturesInfo.end(), TextureInfoComparator());
}

shared_ptr<Stream> PatcherTexturesFileSource::TextureDataSource::getAt(int index)
{
	const QString filename = QDir(m_path).absoluteFilePath(m_texturesInfo[index].textureName + ".TXTR");
	shared_ptr<Stream> stream(new FileStream(filename.toStdWString(), Stream::modeRead));

	ASSERT(stream->opened());

	// TODO: Rewrite converter and remove next line
	stream->setByteOrder(Stream::orderBigEndian);
	
	const int type = stream->readUInt32();
	const int width = stream->readUInt16();
	const int height = stream->readUInt16();
	const int mipmapCount = stream->readUInt32();

	ASSERT(type != 0);
	ASSERT(width == m_texturesInfo[index].width);
	ASSERT(height == m_texturesInfo[index].height);
	ASSERT(mipmapCount >= m_texturesInfo[index].mipmapCount);
	ASSERT(stream->size() - stream->position() >= m_texturesInfo[index].rasterSize);

	Q_UNUSED(type);
	Q_UNUSED(width);
	Q_UNUSED(height);
	Q_UNUSED(mipmapCount);

	return stream;
}

int PatcherTexturesFileSource::TextureDataSource::partCount() const
{
	return m_partInfo.size();
}

OnFlyPatchStream::PartInfo PatcherTexturesFileSource::TextureDataSource::partInfoAt(int index) const
{
	return m_partInfo[index];
}

}