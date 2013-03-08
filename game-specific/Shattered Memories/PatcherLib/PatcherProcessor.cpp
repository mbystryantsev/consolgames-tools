#include "PatcherProcessor.h"
#include "PatcherDirectoriesFileSource.h"
#include "PatcherTexturesFileSource.h"
#include "EmbededResourceInfo.h"
#include "ArchiveProgressNotifier.h"
#include "WiiImageProgressNotifier.h"
#include "CheckingProgressNotifier.h"
#include <Archive.h>
#include <PartStream.h>
#include <QtFileStream.h>
#include <WiiFileStream.h>
#include <QStringList>
#include <QDir>

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

PatcherProcessor::PatcherProcessor()
	: m_errorCode(NoError)
{
}

bool PatcherProcessor::openImage(const QString& path)
{
	if (!m_image.open(path.toStdWString(), Stream::modeReadWrite))
	{
		m_errorCode = Open_UnableToOpenImage;
		return false;
	}
	if (m_image.discId() != "SHLPA4")
	{
		m_errorCode = Open_InvalidDiscId;
		m_errorData = QString::fromStdString(m_image.discId());
		return false;
	}
	return true;
}

static Archive::MergeMap loadMergeMap(const QString& path)
{
	Archive::MergeMap map;

	QtFileStream stream(path, QIODevice::ReadOnly);
	if (stream.opened())
	{
		if ((stream.size() % 8) != 0)
		{
			DLOG << "WARNING: Invalid merge map size!";
		}

		while (!stream.atEnd())
		{
			const quint32 sourceHash = stream.readUInt();
			const quint32 destHash = stream.readUInt();
			map[sourceHash] = destHash;
		}

	}

	return map;
}

bool PatcherProcessor::rebuildArchives(const QString& outPath, const QStringList& resourcesPaths, const ExecutableInfo& executableInfo)
{
	const CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	const QDir outDir(outPath);
	const QDir resDir(resourcesPaths.first());

	TextureDatabase textureDB = TextureDatabase::fromCSV(resDir.absoluteFilePath("textures.csv"));
	if (textureDB.isNull())
	{
		m_errorCode = RebuildArchives_UnableToLoadTextureDatabase;
		m_errorData = "textures.csv";
		return false;
	}

	Archive::MergeMap mergeMap;
	const QString mergeMapFilename = "mergemap.bin";
	if (resDir.exists(mergeMapFilename))
	{
		mergeMap = loadMergeMap(resDir.absoluteFilePath(mergeMapFilename));
	}

	PatcherDirectoriesFileSource arcDirectoriesFileSource(resourcesPaths);
	PatcherTexturesFileSource arcTexturesFileSource(&arcDirectoriesFileSource, resourcesPaths.first(), textureDB);

	DLOG << "Rebuilding UI.arc...";
	{
		ArchiveProgressNotifier listener;
		m_progressNotifier.setCurrentNotifier(&listener, 0.04);

		auto_ptr<Stream> pakStream(m_image.openFile("igc.arc", Stream::modeRead));
		if (pakStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInImage;
			m_errorData = "igc.arc";
			return false;
		}

		Archive arc(pakStream.get());
		if (!arc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = "igc.arc";
			return false;
		}

		shared_ptr<Stream> uiArcStream = arc.openFile("ui.arc");
		ASSERT(uiArcStream.unique());
		if (uiArcStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInArchive;
			m_errorData = "igc.arc;UI.arc";
			return false;
		}

		Archive uiArc(uiArcStream.get());
		if (!uiArc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = "ui.arc";
			return false;
		}

		uiArc.addProgressListener(&listener);

		const QString filename = outDir.absoluteFilePath("ui.arc");
		if (!uiArc.rebuild(filename.toStdWString(), arcTexturesFileSource, mergeMap))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = "ui.arc";
			return false;
		}
	}

	DLOG << "Rebuilding boot.arc...";
	{
		ArchiveProgressNotifier listener;
		m_progressNotifier.setCurrentNotifier(&listener, 0.01);

		auto_ptr<Stream> executableStream(m_image.openFile(executableInfo.executablePath.toStdString(), Stream::modeRead));
		if (executableStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInImage;
			m_errorData = executableInfo.executablePath;
			return false;
		}

		if (executableStream->seek(executableInfo.bootArcOffset, Stream::seekSet) != executableInfo.bootArcOffset)
		{
			m_errorCode = RebuildArchives_UnableToSeekInExecutable;
			m_errorData = QString::number(executableInfo.bootArcOffset, 16);
			return false;
		}

		const EmbededResourceInfo bootArcInfo = EmbededResourceInfo::parse(executableStream.get());
		if (bootArcInfo.isNull())
		{
			m_errorCode = RebuildArchives_UnableToParseEmbededResource;
			m_errorData = "boot.arc";
			return false;
		}

		if (bootArcInfo.contentSize > bootArcInfo.streamSizeLeft - EmbededResourceInfo::s_headerSize)
		{
			m_errorCode = RebuildArchives_InvalidBootArcSize;
			m_errorData = QString::number(bootArcInfo.contentSize, 16);
			return false;
		}

		PartStream executableSegmentStream(executableStream.get(), executableStream->position(), bootArcInfo.contentSize);
		Archive bootArc(&executableSegmentStream);
		if (!bootArc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = "boot.arc";
			return false;
		}

		bootArc.addProgressListener(&listener);
		const QString filename = outDir.absoluteFilePath("boot.arc");
		if (!bootArc.rebuild(filename.toStdWString(), arcTexturesFileSource, mergeMap))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = "ui.arc";
			return false;
		}
	}

	DLOG << "Rebuilding data.arc...";
	{
		ArchiveProgressNotifier listener;
		m_progressNotifier.setCurrentNotifier(&listener);

		auto_ptr<Stream> pakStream(m_image.openFile("data.arc", Stream::modeRead));
		if (pakStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInImage;
			m_errorData = "data.arc";
			return false;
		}

		Archive arc(pakStream.get());
		if (!arc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = "data.arc";
			return false;
		}

		arc.addProgressListener(&listener);
		const QString filename = outDir.absoluteFilePath("data.arc");
		if (!arc.rebuild(filename.toStdWString(), arcTexturesFileSource, mergeMap))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = "data.arc";
			return false;
		}
	}
	return true;
}

bool PatcherProcessor::checkImage()
{
	CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	WiiImageProgressNotifier listener;
	m_image.setProgressHandler(&listener);

	if (!m_image.checkPartition(m_image.dataPartition()))
	{
		m_errorCode = CheckImage_Failed;
		m_errorData = QString::fromStdString(m_image.lastErrorData());
		return false;
	}
	return true;
}

bool PatcherProcessor::replaceArchives(const QString& arcPath, const ExecutableInfo& executableInfo)
{
	const CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	const QDir dir(arcPath);

	auto_ptr<Stream> executableStream(m_image.openFile(executableInfo.executablePath.toStdString(), Stream::modeRead));
	if (executableStream.get() == NULL)
	{
		m_errorCode = ReplaceArchives_UnableToOpenExecutable;
		m_errorData = executableInfo.executablePath;
		return false;
	}

	DLOG << "Replacing boot.arc...";
	{
		executableStream->seek(executableInfo.bootArcOffset, Stream::seekSet);
		const EmbededResourceInfo info = EmbededResourceInfo::parse(executableStream.get());
		if (info.isNull())
		{
			m_errorCode = ReplaceArchives_UnableToParseEmbededResource;
			m_errorData = "boot.arc";
			return false;
		}

		QtFileStream stream(dir.absoluteFilePath("boot.arc"), QIODevice::ReadOnly);
		if (!stream.opened())
		{
			m_errorCode = ReplaceArchives_UnableToOpenInputPak;
			m_errorData = "boot.arc";
			return false;
		}

		if (stream.size() > info.streamSizeLeft - EmbededResourceInfo::s_headerSize)
		{
			m_errorCode = ReplaceArchives_InputArcFileTooBig;
			m_errorData = "boot.arc";
			return false;
		}

		if (executableStream->writeStream(&stream, stream.size()) != stream.size())
		{
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = "boot.arc";
			return false;
		}

		executableStream->seek(executableInfo.bootArcOffset + EmbededResourceInfo::s_contentSizeOffset, Stream::seekSet);
		executableStream->write32(stream.size());
	}

	DLOG << "Replacing ui.arc...";
	{
		auto_ptr<Stream> pakStream(m_image.openFile("igc.arc", Stream::modeReadWrite));
		if (pakStream.get() == NULL)
		{
			m_errorCode = ReplaceArchives_UnableToOpenArcForReplace;
			m_errorData = "igc.arc";
			return false;
		}

		Archive arc(pakStream.get());
		if (!arc.open())
		{
			m_errorCode = ReplaceArchives_UnableToParseArc;
			m_errorData = "igc.arc";
			return false;
		}

		shared_ptr<Stream> uiArcStream = arc.openFile("ui.arc");
		if (uiArcStream.get() == NULL)
		{
			m_errorCode = ReplaceArchives_UnableToOpenArcForReplace;
			m_errorData = "ui.arc";
			return false;
		}

		QtFileStream stream(dir.absoluteFilePath("ui.arc"), QIODevice::ReadOnly);
		if (!stream.opened())
		{
			m_errorCode = ReplaceArchives_UnableToOpenInputPak;
			m_errorData = "ui.arc";
			return false;
		}

		if (stream.size() > uiArcStream->size())
		{
			DLOG << "Input ui.arc too big: " << stream.size() << " bytes / " << uiArcStream->size() << " bytes";
			m_errorCode = ReplaceArchives_InputArcFileTooBig;
			m_errorData = QString("data.arc;%2;%3").arg(stream.size()).arg(uiArcStream->size());
			return false;
		}

		if (uiArcStream->writeStream(&stream, stream.size()) != stream.size())
		{
			DLOG << "Unable to write ui.arc!";
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = "ui.arc";
			return false;
		}
	}

	executableStream->seek(executableInfo.headersOffset, Stream::seekSet);

	DLOG << "Replacing data.arc...";
	{
		WiiImageProgressNotifier listener;
		m_image.setProgressHandler(&listener);
		m_progressNotifier.setCurrentNotifier(&listener);

		Tree<FileInfo>::Node* fileRecord = m_image.findFile("data.arc");
		if (fileRecord == NULL)
		{
			m_errorCode = ReplaceArchives_UnableToOpenArcForReplace;
			m_errorData = "data.arc";
			return false;
		}

		QtFileStream stream(dir.absoluteFilePath("data.arc"), QIODevice::ReadOnly);
		if (!stream.opened())
		{
			m_errorCode = ReplaceArchives_UnableToOpenInputPak;
			m_errorData = "data.arc";
			return false;
		}

		if (stream.size() > fileRecord->data().size)
		{
			DLOG << "Input data.arc too big: " << stream.size() << " bytes / " << fileRecord->data().size << " bytes";
			m_errorCode = ReplaceArchives_InputArcFileTooBig;
			m_errorData = QString("data.arc;%2;%3").arg(stream.size()).arg(fileRecord->data().size);
			return false;
		}

		const bool written = m_image.wii_write_data_file(m_image.dataPartition(), fileRecord->data().offset, &stream, stream.size());
		if (!written)
		{
			DLOG << "Unable to write data.arc!";
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = "data.arc";
			return false;
		}

		const EmbededResourceInfo info = EmbededResourceInfo::parse(executableStream.get());
		if (info.isNull())
		{
			m_errorCode = ReplaceArchives_UnableToParseEmbededResource;
			m_errorData = "data.arc";
			return false;
		}

		stream.seek(0, Stream::seekSet);
		if (executableStream->writeStream(&stream, info.contentSize) != info.contentSize)
		{
			m_errorCode = ReplaceArchives_UnableToWriteFile;
			m_errorData = "header:data.arc";
			return false;
		}
	}

	return true;
}

bool PatcherProcessor::checkArchives(const QString& arcPath, const ExecutableInfo& executableInfo)
{
	CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);
	const QDir dir(arcPath);

	DLOG << "Checking boot.arc...";
	{
		auto_ptr<Stream> executableStream(m_image.openFile(executableInfo.executablePath.toStdString(), Stream::modeRead));
		if (executableStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenExecutable;
			m_errorData = executableInfo.executablePath;
			return false;
		}

		VERIFY(executableStream->seek(executableInfo.bootArcOffset, Stream::seekSet) == executableInfo.bootArcOffset);

		const EmbededResourceInfo bootArcInfo = EmbededResourceInfo::parse(executableStream.get());
		if (bootArcInfo.isNull())
		{
			m_errorCode = CheckArchives_UnableToParseEmbededResource;
			m_errorData = "boot.arc";
			return false;
		}

		if (bootArcInfo.contentSize > bootArcInfo.streamSizeLeft - EmbededResourceInfo::s_headerSize)
		{
			m_errorCode = CheckArchives_InvalidBootArcSize;
			m_errorData = QString::number(bootArcInfo.contentSize, 16);
			return false;
		}

		PartStream bootArcStream(executableStream.get(), executableStream->position(), bootArcInfo.contentSize);

		QtFileStream resultArcSream(dir.absoluteFilePath("boot.arc"), QIODevice::ReadOnly);
		if (!resultArcSream.opened())
		{
			m_errorCode = CheckArchives_UnableToOpenResultArchive;
			m_errorData = "boot.arc";
			return false;
		}

		if (!compareStreams(&bootArcStream, &resultArcSream, false, 0.01))
		{
			m_errorCode = CheckArchives_ArcsAreNotEqual;
			m_errorData = "boot.arc";
			return false;
		}
	}

	DLOG << "Checking ui.arc...";
	{
		auto_ptr<Stream> pakStream(m_image.openFile("igc.arc", Stream::modeReadWrite));
		if (pakStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = "igc.arc";
			return false;
		}

		Archive arc(pakStream.get());
		if (!arc.open())
		{
			m_errorCode = CheckArchives_UnableToParseArchive;
			m_errorData = "igc.arc";
			return false;
		}

		shared_ptr<Stream> uiArcStream = arc.openFile("ui.arc");
		if (uiArcStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = "ui.arc";
			return false;
		}

		QtFileStream resultArcSream(dir.absoluteFilePath("ui.arc"), QIODevice::ReadOnly);
		if (!resultArcSream.opened())
		{
			m_errorCode = CheckArchives_UnableToOpenResultArchive;
			m_errorData = "ui.arc";
			return false;
		}

		if (!compareStreams(uiArcStream.get(), &resultArcSream, true, 0.04))
		{
			m_errorCode = CheckArchives_ArcsAreNotEqual;
			m_errorData = "ui.arc";
			return false;
		}
	}

	DLOG << "Checking data.arc...";
	{
		QtFileStream resultArcSream(dir.absoluteFilePath("data.arc"), QIODevice::ReadOnly);
		if (!resultArcSream.opened())
		{
			m_errorCode = CheckArchives_UnableToOpenResultArchive;
			m_errorData = "data.arc";
			return false;
		}

		auto_ptr<Stream> executableStream(m_image.openFile(executableInfo.executablePath.toStdString(), Stream::modeRead));
		if (executableStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenExecutable;
			m_errorData = executableInfo.executablePath;
			return false;
		}

		VERIFY(executableStream->seek(executableInfo.headersOffset, Stream::seekSet) == executableInfo.headersOffset);

		const EmbededResourceInfo info = EmbededResourceInfo::parse(executableStream.get());
		if (info.isNull())
		{
			m_errorCode = CheckArchives_UnableToParseEmbededResource;
			m_errorData = "data.arc";
			return false;
		}

		PartStream header(executableStream.get(), executableStream->position(), info.contentSize);
		if (!compareStreams(&header, &resultArcSream, true, 0.01))
		{
			m_errorCode = CheckData_FilesAreDifferent;
			m_errorData = "header:data.arc";
			return false;
		}

		executableStream.reset();

		auto_ptr<Stream> arcStream(m_image.openFile("data.arc", Stream::modeRead));
		if (arcStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = "data.arc";
			return false;
		}

		if (!compareStreams(arcStream.get(), &resultArcSream, true))
		{
			m_errorCode = CheckData_FilesAreDifferent;
			m_errorData = "data.arc";
			return false;
		}
	}

	return true;
}

static int s2c(int size)
{
	const int cluster = 0x7C00;
	return (size + cluster - 1) / cluster;
}

bool PatcherProcessor::compareStreams(Stream* stream1, Stream* stream2, bool ignoreSize, double progressCoeff)
{
	largesize_t size = min(stream1->size(), stream2->size());
	CheckingProgressNotifier notifier(s2c(size));
	m_progressNotifier.setCurrentNotifier(&notifier, progressCoeff);

	if (!ignoreSize && stream1->size() != stream2->size())
	{
		return false;
	}

	stream1->seek(0, Stream::seekSet);
	stream2->seek(0, Stream::seekSet);

	const int chunk = 0x7C00;
	char data1[chunk];
	char data2[chunk];

	int processed = 0;
	while (size > 0)
	{
		notifier.progress(s2c(processed));

		if (notifier.stopRequested())
		{
			return false;
		}

		const largesize_t toRead = min(chunk, size);
		size -= chunk;

		const largesize_t readed1 = stream1->read(&data1[0], toRead);
		const largesize_t readed2 = stream2->read(&data2[0], toRead);
		if (readed1 != readed2 || readed1 != toRead)
		{
			DLOG << __FUNCTION__ << ": I/O error!";
			return false;
		}
		processed += readed1;

		if (!std::equal(&data1[0], &data1[readed1], &data2[0]))
		{
			return false;
		}
	}
	return true;
}

int PatcherProcessor::errorCode() const
{
	return m_errorCode;
}

QString PatcherProcessor::errorData() const
{
	return m_errorData;
}

QObject* PatcherProcessor::progressNotifier()
{
	return &m_progressNotifier;
}

}