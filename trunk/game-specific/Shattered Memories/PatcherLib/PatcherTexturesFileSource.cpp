#include "PatcherTexturesFileSource.h"
#include "FontStreamRebuilder.h"
#include <Hash.h>
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
	bool operator()(const PartInfoRecord& a, const PartInfoRecord& b) const
	{
		return a.offset() < b.offset();
	}
};

PatcherTexturesFileSource::TextureDataSource::TextureDataSource(const QString& path, const QList<TextureDatabase::TextureInfo>& textures)
	: m_path(path)
{
	foreach (const TextureDatabase::TextureInfo& info, textures)
	{
		PartInfoRecord partInfo;
		partInfo.textureInfo = info;
		partInfo.type = partRaster;
		m_partInfo << partInfo;

		if (info.paletteSize != 0)
		{
			partInfo.type = partPalette;
			m_partInfo << partInfo;
		}
	}

	qSort(m_partInfo.begin(), m_partInfo.end(), PartInfoComparator());
}

shared_ptr<Stream> PatcherTexturesFileSource::TextureDataSource::getAt(int index)
{
	const PartInfoRecord& record = m_partInfo[index];

	const QString filename = QDir(m_path).absoluteFilePath(record.textureInfo.textureName + ".TXTR");

	if (m_cachedFile.get() == NULL || m_cachedFile->fileName() != filename)
	{
		m_cachedFile.reset(new QtFileStream(filename, QIODevice::ReadOnly));
	}
	else
	{
		m_cachedFile->seek(0, Stream::seekSet);
	}
	
	shared_ptr<Stream> stream = m_cachedFile;

	ASSERT(stream->opened());

	// TODO: Rewrite converter and remove next line
	stream->setByteOrder(Stream::orderBigEndian);
	
	const int platformSignature = stream->readUInt32();
	const int formatSignature = stream->readUInt32();
	const int width = stream->readUInt32();
	const int height = stream->readUInt32();
	const int mipmapCount = stream->readUInt32();
	const int reserved = stream->readUInt32();
	const int rasterSize = stream->readUInt32();
	const int paletteSize = stream->readUInt32();

	ASSERT(platformSignature != 0);
	ASSERT(formatSignature != 0);
	ASSERT(width == record.textureInfo.width);
	ASSERT(height == record.textureInfo.height);
	ASSERT(mipmapCount >= record.textureInfo.mipmapCount && mipmapCount <= 16);
	ASSERT(stream->size() - stream->position() >= record.textureInfo.rasterSize);
	ASSERT(rasterSize > 0);
	ASSERT(rasterSize + paletteSize + 32 == stream->size());

	Q_UNUSED(platformSignature);
	Q_UNUSED(formatSignature);
	Q_UNUSED(width);
	Q_UNUSED(height);
	Q_UNUSED(mipmapCount);
	Q_UNUSED(reserved);
	Q_UNUSED(rasterSize);
	Q_UNUSED(paletteSize);

	if (m_partInfo[index].type == partPalette)
	{
		ASSERT(paletteSize > 0);
		stream->skip(rasterSize);
	}

	return stream;
}

int PatcherTexturesFileSource::TextureDataSource::partCount() const
{
	return m_partInfo.size();
}

OnFlyPatchStream::PartInfo PatcherTexturesFileSource::TextureDataSource::partInfoAt(int index) const
{
	OnFlyPatchStream::PartInfo info;
	info.offset = m_partInfo[index].offset();
	info.size = m_partInfo[index].size();
	return info;
}

}