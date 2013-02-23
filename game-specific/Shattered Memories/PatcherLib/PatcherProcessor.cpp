#include "PatcherProcessor.h"
#include <Archive.h>
#include <PartStream.h>
#include <WiiFileStream.h>
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

bool PatcherProcessor::rebuildArchives(const QString& outPath, const BootArcInfo& bootArcInfo)
{
	DLOG << "Rebuilding UI.arc...";
	{
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

		const QString filename = QDir(outPath).absoluteFilePath("ui.arc");
		if (!uiArc.rebuild(filename.toStdWString(), std::vector<std::wstring>()))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = "ui.arc";
			return false;
		}
	}

	DLOG << "Rebuilding boot.arc...";
	{
		auto_ptr<Stream> executableStream(m_image.openFile(bootArcInfo.executableName.toStdString(), Stream::modeRead));
		if (executableStream.get() == NULL)
		{
			m_errorCode = RebuildArchives_UnableToOpenFileInImage;
			m_errorData = bootArcInfo.executableName;
			return false;
		}

		if (executableStream->seek(bootArcInfo.sizeOffset, Stream::seekSet) != bootArcInfo.sizeOffset)
		{
			m_errorCode = RebuildArchives_UnableToSeekInExecutable;
			m_errorData = QString::number(bootArcInfo.offset, 16);
			return false;
		}

		const quint32 bootArcSize = executableStream->read32();
		if (bootArcSize > bootArcInfo.size)
		{
			m_errorCode = RebuildArchives_InvalidBootArcSize;
			m_errorData = QString::number(bootArcSize, 16) + ";" + QString::number(bootArcInfo.offset, 16);
		}

		if (executableStream->seek(bootArcInfo.offset, Stream::seekSet) != bootArcInfo.offset)
		{
			m_errorCode = RebuildArchives_UnableToSeekInExecutable;
			m_errorData = QString::number(bootArcInfo.offset, 16);
			return false;
		}

		PartStream executableSegmentStream(executableStream.get(), bootArcInfo.offset, bootArcSize);
		Archive bootArc(&executableSegmentStream);
		if (!bootArc.open())
		{
			m_errorCode = RebuildArchives_UnableToOpenArchive;
			m_errorData = "boot.arc";
			return false;
		}

		const QString filename = QDir(outPath).absoluteFilePath("boot.arc");
		if (!bootArc.rebuild(filename.toStdWString(), std::vector<std::wstring>()))
		{
			m_errorCode = RebuildArchives_UnableToRebuildArchive;
			m_errorData = "ui.arc";
			return false;
		}
	}

	return true;
}

bool PatcherProcessor::rebuildArchive(Consolgames::Stream* pak, const QString& outPath, const QString& arcName)
{
// 	if (m_actionProgressHandler->stopRequested())
// 	{
// 		break;
// 	}
// 
// 	m_actionProgressHandler->progress(paksRebuilded++, arcName.toLatin1().constData());

	std::auto_ptr<WiiFileStream> file(m_image.openFile(arcName.toStdString(), Stream::modeRead));
	if(file.get() == NULL)
	{
		DLOG << "Unable to open file in image: " << arcName;
		m_errorCode = RebuildArchives_UnableToOpenFileInImage;
		m_errorData = arcName;
		return false;
	}

	Archive arc(file.get());
	//arc.addProgressListeners(m_progressListeners);
	if (!arc.open())
	{
		DLOG << "Unable to open archive: " << arcName;
		m_errorCode = RebuildArchives_UnableToOpenArchive;
		m_errorData = arcName;
		return false;
	}

	//const std::wstring filename = QDir::toNativeSeparators(QDir(outDir).absoluteFilePath(arcName)).toStdWString();

	DLOG << "Rebuilding archive: " << arcName;
	//if (!arc.rebuild(filename, inputDirs, std::set<ResType>(), m_mergeMap))
	{
		DLOG << "Unable to rebuild archive: " << arcName;
		m_errorCode = RebuildArchives_UnableToRebuildArchive;
		m_errorData = arcName;
		return false;
	}
}

int PatcherProcessor::errorCode() const
{
	return m_errorCode;
}

QString PatcherProcessor::errorData() const
{
	return m_errorData;
}

}