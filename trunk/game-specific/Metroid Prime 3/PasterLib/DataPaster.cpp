#include "DataPaster.h"
#include <QtPakArchive.h>
#include <QtFileStream.h>
#include <WiiFileStream.h>
#include <Stream.h>
#include <QStringList>
#include <QDir>
#include <memory>

LOG_CATEGORY("DataPaster")

using namespace Consolgames;

class DummyProgressHandler : public IPakProgressHandler
{
	virtual void init(int) override {}
	virtual void progress(int, const char*) override {}
	virtual void finish() override {}
	virtual bool stopRequested()
	{
		return false;
	}
};

class ProgressHandlerHolder
{
public:
	ProgressHandlerHolder(IPakProgressHandler* handler, int size) : m_handler(handler)
	{
		m_handler->init(size);
	}
	~ProgressHandlerHolder()
	{
		m_handler->finish();
	}

private:
	IPakProgressHandler* m_handler;
};

DummyProgressHandler g_dummyProgressHandler;

DataPaster::DataPaster(const QString& wiiImageFile)
	: m_imageFilename(wiiImageFile)
	, m_image()
	, m_errorCode(NoError)
	, m_actionProgressHandler(&g_dummyProgressHandler)
{
	m_image.setProgressHandler(&m_pakToWiiImageProgressHandlerAdapter);
}

bool DataPaster::open()
{
	if (!m_image.open(m_imageFilename.toStdString(), Stream::modeReadWrite))
	{
		m_errorCode = Open_UnableToOpenImage;
		return false;
	}
	if (m_image.discId() != "RM3P01")
	{
		m_errorCode = Open_InvalidDiscId;
		m_errorData = QString::fromStdString(m_image.discId());
		return false;
	}
	return true;
}

bool DataPaster::rebuildPaks(const QStringList& pakArchives, const std::vector<std::string>& inputDirs, const std::string& outDir)
{
	int paksRebuilded = 0;

	ProgressHandlerHolder holder(m_actionProgressHandler, pakArchives.size());

	foreach (const QString& pakName, pakArchives)
	{
		if (m_actionProgressHandler->stopRequested())
		{
			break;
		}

		m_actionProgressHandler->progress(paksRebuilded++, pakName.toLatin1().constData());

		std::auto_ptr<WiiFileStream> file(m_image.openFile(pakName.toStdString(), Stream::modeRead));
 		if(file.get() == NULL)
 		{
			DLOG << "Unable to open file in image: " << pakName;
			m_errorCode = RebuildPaks_UnableToOpenFileInImage;
			m_errorData = pakName;
 			return false;
 		}

		QtPakArchive pak;
		pak.setProgressHandler(m_pakProgressHandler);
		pak.open(file.get());
		if (!pak.opened())
		{
			DLOG << "Unable to parse pak: " << pakName;
			m_errorCode = RebuildPaks_UnableToParsePak;
			m_errorData = pakName;
			return false;
		}

		const std::string filename = outDir + std::string(PATH_SEPARATOR_STR) + pakName.toStdString();

		DLOG << "Rebuilding pak: " << pakName;
		if (!pak.rebuild(filename, inputDirs, std::set<ResType>(), m_mergeMap))
 		{
			DLOG << "Unable to rebuild pak: " << pakName;
			m_errorCode = RebuildPaks_UnableToRebuildPak;
			m_errorData = pakName;
			return false;
 		}
	}

	return true;
}

bool DataPaster::replacePaks(const QStringList& pakArchives, const QString& inputDir)
{
	int paksReplaced = 0;

	ProgressHandlerHolder holder(m_actionProgressHandler, pakArchives.size());

	foreach (const QString& pakName, pakArchives)
	{
		m_actionProgressHandler->progress(paksReplaced++, pakName.toLatin1().constData());

		const QString filename = inputDir + QDir::separator() + pakName;

		Tree<FileInfo>::Node* fileRecord = m_image.findFile(pakName.toStdString());
		if (fileRecord == NULL)
		{
			DLOG << "Unable to open pak for replace: " << pakName;
			m_errorCode = ReplacePaks_UnableToOpenPakForReplace;
			m_errorData = pakName;
			return false;
		}

		FileStream inputFile(filename.toStdString(), Stream::modeRead);	
		if (!inputFile.opened())
		{
			DLOG << "Unable to open input pak: " << pakName;
			m_errorCode = ReplacePaks_UnableToOpenInputPak;
			m_errorData = pakName;
			return false;
		}

		if (inputFile.size() > fileRecord->data().size)
		{
			DLOG << "Input pak file too big: " << pakName << " (" << inputFile.size() << " bytes / " << fileRecord->data().size << " bytes)";
			m_errorCode = ReplacePaks_InputPakFileTooBig;
			m_errorData = QString("%1;%2;%3").arg(pakName).arg(inputFile.size()).arg(fileRecord->data().size);
			return false;
		}

		const bool written = m_image.wii_write_data_file(m_image.dataPartition(), fileRecord->data().offset, &inputFile, inputFile.size());
		if (!written)
		{
			DLOG << "Unable to write file!";
			m_errorCode = ReplacePaks_UnableToWriteFile;
			m_errorData = pakName;
			return false;
		}
	}

	return true;
}

void DataPaster::setProgressHandler(IPakProgressHandler* handler)
{
	m_pakProgressHandler = handler;
	m_pakToWiiImageProgressHandlerAdapter.setHandler(handler);
	m_image.setProgressHandler(&m_pakToWiiImageProgressHandlerAdapter);
}

bool DataPaster::checkData(const QStringList& pakArchives, const QStringList& inputDirs, const QString& outDir, const QString& tempDir)
{
	int paksChecked = 0;

	ProgressHandlerHolder holder(m_actionProgressHandler, pakArchives.size());

	foreach (const QString& pakName, pakArchives)
	{
		m_actionProgressHandler->progress(paksChecked++, pakName.toLatin1().constData());

		const QString pakPath = outDir + QDir::separator() + pakName;
		QtPakArchive resultPak;
		if (!resultPak.open(pakPath.toStdString()))
		{
			DLOG << "CheckData: Unable to parse result pak: " << pakName;
			m_errorCode = CheckData_UnableToParseResultPak;
			m_errorData = pakName;
			return false;
		}

		foreach (const FileRecord& fileRecord, resultPak.files())
		{
			const QString filename = QString::fromStdString(fileRecord.name());
			QString resultName;
			foreach (const QString& dir, inputDirs)
			{
				const QString filePath = dir + QDir::separator() + filename;
				if (QFile::exists(filePath))
				{
					resultName = filePath;
					break;
				}
			}

			if (!resultName.isNull())
			{
				FileStream file(resultName.toStdString(), Stream::modeRead);
				if (!file.opened())
				{
					DLOG << "Unable to open file!";
					m_errorCode = CheckData_UnableToOpenFile;
					m_errorData = filename;
					return false;
				}

				std::auto_ptr<Stream> fileInPak;
				const QString tempFileName = QDir(tempDir).absoluteFilePath("~filefrompak.tmp");
				if (fileRecord.packed != 0)
				{
					if (QFile::exists(tempFileName))
					{
						QFile::remove(tempFileName);
					}

					fileInPak.reset(new FileStream(tempFileName.toStdString(), Stream::modeReadWrite));
					if (!resultPak.extractFile(fileRecord.hash, fileInPak.get()))
					{
						DLOG << "Unable to extract file!";
						m_errorCode = CheckData_UnableToExtractTemporaryFile;
						m_errorData = pakPath + ";" + filename;
						return false;
					}
				}
				else
				{
					fileInPak.reset(resultPak.openFileDirect(fileRecord.hash));
				}
				if (fileInPak.get() == NULL)
				{
					DLOG << "Unable to open file in pak!";
					m_errorCode = CheckData_UnableToOpenFileInPak;
					m_errorData = pakName + ";" + filename;
					return false;
				}

				if (!compareStreams(&file, fileInPak.get()))
				{
					DLOG << "Files are different!";
					m_errorCode = CheckData_FilesAreDifferent;
					m_errorData = pakName + ";" + filename;
					return false;
				}
			}
		}

	}
	return true;
}

bool DataPaster::checkPaks(const QStringList& pakArchives, const QString& paksDir)
{
	int paksChecked = 0;

	ProgressHandlerHolder holder(m_actionProgressHandler, pakArchives.size());

	foreach (const QString& pakName, pakArchives)
	{
		m_actionProgressHandler->progress(paksChecked++, pakName.toLatin1().constData());

		std::auto_ptr<Stream> imagePakFile(m_image.openFile(pakName.toStdString(), Stream::modeRead));
		if (imagePakFile.get() == NULL)
		{
			DLOG << "CheckData: Opening pak in image failed: " << pakName;
			m_errorCode = CheckPaks_UnableToOpenPak;
			m_errorData = pakName;
			return false;
		}

		QtFileStream resultPakFile(paksDir + QDir::separator() + pakName, QIODevice::ReadOnly);
		if (!resultPakFile.opened())
		{
			DLOG << "CheckData: Opening result pak failed: " << pakName;
			m_errorCode = CheckPaks_UnableToOpenResultPak;
			m_errorData = pakName;
			return false;
		}

		if (imagePakFile->size() < resultPakFile.size())
		{
			DLOG << "CheckData: Invalid pak size: " << pakName;
			m_errorCode = CheckPaks_InvalidPakSize;
			m_errorData = pakName + ";" + QString::number(resultPakFile.size()) + ";" + QString::number(imagePakFile->size());
			return false;
		}
		
		if (!compareStreams(&resultPakFile, imagePakFile.get(), true))
		{
			DLOG << "PAKs are not equal: " << pakName;
			m_errorCode = CheckPaks_PaksAreNotEqual;
			m_errorData = pakName;
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

bool DataPaster::compareStreams(Consolgames::Stream* stream1, Consolgames::Stream* stream2, bool ignoreSize) const
{
	largesize_t size = min(stream1->size(), stream2->size());
	ProgressHandlerHolder holder(m_pakProgressHandler, s2c(size));

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
		m_pakProgressHandler->progress(s2c(processed), NULL);

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

void DataPaster::setMergeMap(const std::map<Hash,Hash>& mergeMap)
{
	m_mergeMap = mergeMap;
}

void DataPaster::loadMergeMap(const QString& filename, std::map<Hash,Hash>& mergeMap)
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly))
	{
		return;
	}

	while (!file.atEnd())
	{
		char hash1Data[8];
		char hash2Data[8];

		file.read(hash1Data, 8);
		file.read(hash2Data, 8);

		const Hash hash1 = hashFromData(hash1Data);
		const Hash hash2 = hashFromData(hash2Data);
		mergeMap[hash1] = hash2;
	}
}

DataPaster::ErrorCode DataPaster::errorCode() const
{
	return m_errorCode;
}

QString DataPaster::errorData() const
{
	return m_errorData;
}

bool DataPaster::checkImage()
{
	return m_image.checkPartition(m_image.dataPartition());
}

void DataPaster::setActionProgressHandler(IPakProgressHandler* handler)
{
	m_actionProgressHandler = (handler == NULL ? &g_dummyProgressHandler : handler);
}