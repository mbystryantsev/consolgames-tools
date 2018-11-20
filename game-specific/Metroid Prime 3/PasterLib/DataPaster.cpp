#include "DataPaster.h"
#include "MainDolPatcher.h"
#include <QtPakArchive.h>
#include <QtFileStream.h>
#include <WiiFileStream.h>
#include <Stream.h>
#include <QStringList>
#include <QDir>
#include <QFileInfo>
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
	, m_pakProgressHandler(&g_dummyProgressHandler)
{
	m_image.setProgressHandler(&m_pakToWiiImageProgressHandlerAdapter);
}

bool DataPaster::open()
{
	if (!m_image.open(m_imageFilename.toStdWString(), Stream::modeReadWrite))
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

bool DataPaster::rebuildPaks(const QStringList& pakArchives, const std::vector<std::wstring>& inputDirs, const QString& outDir)
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
		if (!pak.isOpen())
		{
			DLOG << "Unable to parse pak: " << pakName;
			m_errorCode = RebuildPaks_UnableToParsePak;
			m_errorData = pakName;
			return false;
		}

		const std::wstring filename = QDir::toNativeSeparators(QDir(outDir).absoluteFilePath(pakName)).toStdWString();

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

bool DataPaster::patchMainDol(const QString& inputDir, const QString& outDir)
{
	std::auto_ptr<WiiFileStream> imageFile(m_image.openFile("main.dol", Stream::modeRead));
	if(imageFile.get() == NULL)
	{
		DLOG << "Unable to open file in image: main.dol";
		m_errorCode = PatchMainDol_UnableToOpenFileInImage;
		m_errorData = "main.dol";
		return false;
	}

	{
		QtFileStream outFile(outDir + "/main.dol", QIODevice::WriteOnly);
		if (!outFile.isOpen())
		{
			DLOG << "Unable to open temp file: main.dol";
			m_errorCode = PatchMainDol_UnableToOpenTempFile;
			m_errorData = "main.dol";
			return false;
		}

		if (outFile.writeStream(imageFile.get(), imageFile->size()) != imageFile->size())
		{
			DLOG << "Unable to extract file from image: main.dol";
			m_errorCode = PatchMainDol_UnableToExtractFileFromImage;
			m_errorData = "main.dol";
			return false;
		}
	}

	{
		MainDolPatcher patcher;
		if (!patcher.open(outDir + "/main.dol"))
		{
			m_errorCode = PatchMainDol_UnableToOpenFileToPatch;
			m_errorData = "main.dol";
			return false;
		}

		const QString messagesPath = inputDir + "/messages.txt";
		const QString fontPath = inputDir + "/system.FONT";
		const QString fontTexturePath = inputDir + "/system.TXTR";
		if (!patcher.patch(messagesPath, fontPath, fontTexturePath))
		{
			m_errorCode = PatchMainDol_UnableToPatchMainDol;
			m_errorData = "main.dol";
			return false;
		}
	}


	Tree<FileInfo>::Node* fileRecord = m_image.findFile("main.dol");
	if (fileRecord == NULL)
	{
		DLOG << "Unable to find file in image for replace: main.dol";
		m_errorCode = PatchMainDol_UnableToFindMainDolInImage;
		m_errorData = "main.dol";
		return false;
	}

	QtFileStream dolFile(outDir + "/main.dol", QIODevice::ReadOnly);
	if (!dolFile.isOpen())
	{
		DLOG << "Unable to open temp file: main.dol";
		m_errorCode = PatchMainDol_UnableToOpenTempFile;
		m_errorData = "main.dol";
		return false;
	}

	WiiImage::IProgressHandler* handler = &m_image.progressHandler();
	m_image.setProgressHandler(NULL);
	const bool written = m_image.wii_write_data_file(m_image.dataPartition(), fileRecord->data().offset, &dolFile, dolFile.size());
	m_image.setProgressHandler(handler);

	if (!written)
	{
		DLOG << "Unable to write file!";
		m_errorCode = PatchMainDol__UnableToWriteFile;
		m_errorData = "main.dol";
		return false;
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

		FileStream inputFile(filename.toStdWString(), Stream::modeRead);	
		if (!inputFile.isOpen())
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

class TempFileRemover
{
public:
	TempFileRemover(const QString& filename) : m_filename(filename)
	{
	}
	~TempFileRemover()
	{
		if (QFile::exists(m_filename))
		{
			QFile::remove(m_filename);
		}
	}

private:
	const QString m_filename;
};

bool DataPaster::checkData(const QStringList& pakArchives, const QStringList& inputDirs, const QString& outDir, const QString& tempDir)
{
	ProgressHandlerHolder holder(m_actionProgressHandler, pakArchives.size());

	const QString tempFileName = QDir(tempDir).absoluteFilePath("~filefrompak.tmp");
	TempFileRemover tempGuard(tempFileName);

	int paksChecked = 0;

	foreach (const QString& pakName, pakArchives)
	{
		m_actionProgressHandler->progress(paksChecked++, pakName.toLatin1().constData());

		if (m_actionProgressHandler->stopRequested())
		{
			break;
		}

		const QString pakPath = outDir + QDir::separator() + pakName;
		QtPakArchive resultPak;
		if (!resultPak.open(pakPath.toStdWString()))
		{
			DLOG << "CheckData: Unable to parse result pak: " << pakName;
			m_errorCode = CheckData_UnableToParseResultPak;
			m_errorData = pakName;
			return false;
		}

		foreach (const FileRecord& fileRecord, resultPak.files())
		{
			const QString filename = QString::fromStdString(fileRecord.name());
			if ((fileRecord.size & 0x3F) != 0)
			{
				DLOG << "Invalid file size alignment!";
				m_errorCode = CheckData_InvalidFileSizeAlignment;
				m_errorData = filename;
				return false;
			}

			QString resultName;
			foreach (const QString& dir, inputDirs)
			{
				const QString filePath = QDir(dir).absoluteFilePath(filename);
				if (QFileInfo(filePath).exists())
				{
					resultName = filePath;
					break;
				}
			}

			if (!resultName.isNull())
			{
				if (m_actionProgressHandler->stopRequested())
				{
					break;
				}

				QtFileStream file(resultName, QIODevice::ReadOnly);
				if (!file.isOpen())
				{
					DLOG << "Unable to open file!";
					m_errorCode = CheckData_UnableToOpenFile;
					m_errorData = filename;
					return false;
				}

				std::auto_ptr<Stream> fileInPak;
				if (fileRecord.packed != 0)
				{
					fileInPak.reset(new QtFileStream(tempFileName, QIODevice::ReadWrite | QIODevice::Truncate));
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

				const bool ignoreSize = (fileRecord.packed == 0);
				if ((ignoreSize && abs(file.size() - fileInPak->size()) > 0x3F)
					|| !compareStreams(&file, fileInPak.get(), ignoreSize))
				{
					DLOG << "Files are different!";
					m_errorCode = CheckData_FilesAreDifferent;
					m_errorData = pakName + ";" + filename + ";" + QString::number(file.size()) + ";" + QString::number(fileInPak->size()) + ";" + QString::number(fileRecord.packed);
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

		if (m_actionProgressHandler->stopRequested())
		{
			break;
		}

		std::auto_ptr<Stream> imagePakFile(m_image.openFile(pakName.toStdString(), Stream::modeRead));
		if (imagePakFile.get() == NULL)
		{
			DLOG << "CheckData: Opening pak in image failed: " << pakName;
			m_errorCode = CheckPaks_UnableToOpenPak;
			m_errorData = pakName;
			return false;
		}

		QtFileStream resultPakFile(paksDir + QDir::separator() + pakName, QIODevice::ReadOnly);
		if (!resultPakFile.isOpen())
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
	largesize_t size = std::min(stream1->size(), stream2->size());
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

		if (m_pakProgressHandler->stopRequested())
		{
			return false;
		}

		const largesize_t toRead = std::min<largesize_t>(chunk, size);
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
	if (!m_image.checkPartition(m_image.dataPartition()))
	{
		m_errorCode = CheckImage_Failed;
		m_errorData = QString::fromStdString(m_image.lastErrorData());
		return false;
	}
	return true;
}

void DataPaster::setActionProgressHandler(IPakProgressHandler* handler)
{
	m_actionProgressHandler = (handler == NULL ? &g_dummyProgressHandler : handler);
}

bool DataPaster::removeTempFiles(const QString& tempDirectory)
{
	QDir dir(tempDirectory);

	if (!dir.exists())
	{
		return false;
	}

	const QStringList files = dir.entryList(QDir::Files);
	ProgressHandlerHolder holder(m_actionProgressHandler, files.size());

	int processed = 0;
	foreach (const QString& file, files)
	{
		DLOG << "Removing temporary file: " << file;
		m_pakProgressHandler->progress(processed++, file.toLatin1().constData());
		if (!dir.remove(file))
		{
			DLOG << "Removing temporary file failed: " << file;
			return false;
		}
	}

	DLOG << "Removing temporary dir: " << tempDirectory;
	if (!dir.rmdir(tempDirectory))
	{
		DLOG << "Removing temporary dir failed: " << tempDirectory;
		return false;
	}

	return true;
}

void DataPaster::resetProgressHandlers()
{
	m_actionProgressHandler = &g_dummyProgressHandler;
	m_pakProgressHandler = &g_dummyProgressHandler;
}