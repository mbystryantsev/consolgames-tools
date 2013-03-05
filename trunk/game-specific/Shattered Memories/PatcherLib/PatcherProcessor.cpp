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

bool PatcherProcessor::rebuildArchives(const QString& outPath, const QStringList& resourcesPaths, const ExecutableInfo& executableInfo)
{
	const CompoundProgressNotifier::ProgressGuard guard(m_progressNotifier);

	TextureDatabase textureDB = TextureDatabase::fromCSV(QDir(resourcesPaths.first()).absoluteFilePath("textures.csv"));
	if (textureDB.isNull())
	{
		m_errorCode = RebuildArchives_UnableToLoadTextureDatabase;
		m_errorData = "";
		return false;
	}

	PatcherDirectoriesFileSource arcDirectoriesFileSource(resourcesPaths);
	PatcherTexturesFileSource arcTexturesFileSource(&arcDirectoriesFileSource, resourcesPaths.first(), textureDB);

	Archive::MergeMap mergeMap;
	// Strings.Fre
	mergeMap[0x2C238179] = 0x2C238264;
	// Strings.Ita
	mergeMap[0x2C2352B4] = 0x2C238264;
	// Strings.Ger
	mergeMap[0x2C239BD8] = 0x2C238264;
	// Strings.Spa
	mergeMap[0x2C23CD2A] = 0x2C238264;
	// Strings.Jap
	mergeMap[0x2C234C13] = 0x2C238264;
	
	// BootStrings.Fre
	mergeMap[0x7EFC8F0F] = 0x7EFCA512;
	// BootStrings.Ita
	mergeMap[0x7EFC92C2] = 0x7EFCA512;
	// BootStrings.Ger
	mergeMap[0x7EFC8DEE] = 0x7EFCA512;

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

		const QString filename = QDir(outPath).absoluteFilePath("ui.arc");
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
		const QString filename = QDir(outPath).absoluteFilePath("boot.arc");
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
		const QString filename = QDir(outPath).absoluteFilePath("data.arc");
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

	// Boot.arc
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

	executableStream->seek(executableInfo.headersOffset, Stream::seekSet);

	// data.arc
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
		executableStream->writeStream(&stream, info.contentSize);
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
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = "boot.arc";
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

	DLOG << "Checking data.arc...";
	{
		auto_ptr<Stream> arcStream(m_image.openFile("data.arc", Stream::modeRead));
		if (arcStream.get() == NULL)
		{
			m_errorCode = CheckArchives_UnableToOpenArchive;
			m_errorData = "data.arc";
			return false;
		}

		QtFileStream resultArcSream(dir.absoluteFilePath("data.arc"), QIODevice::ReadOnly);
		if (!resultArcSream.opened())
		{
			m_errorCode = CheckArchives_UnableToOpenResultArchive;
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