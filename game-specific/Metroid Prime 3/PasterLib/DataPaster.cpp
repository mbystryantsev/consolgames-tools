#include "DataPaster.h"
#include <pak.h>
#include <WiiFileStream.h>
#include <Stream.h>
#include <QStringList>
#include <QDir>
#include <memory>

LOG_CATEGORY("DataPaster")

using namespace Consolgames;

DataPaster::DataPaster(const QString& wiiImageFile)
	: m_imageFilename(wiiImageFile)
	, m_image()
{
}

bool DataPaster::open()
{
	return m_image.open(m_imageFilename.toStdString(), Stream::modeReadWrite);
}

bool DataPaster::rebuildPaks(const QStringList& pakArchives, const std::vector<std::string>& inputDirs, const std::string& outDir)
{
	foreach (const QString& pakName, pakArchives)
	{
		std::auto_ptr<WiiFileStream> file(m_image.openFile(pakName.toStdString(), Stream::modeRead));
 		if(file.get() == NULL)
 		{
			DLOG << "Unable to open file in image: " << pakName;
 			return false;
 		}

		PakArchive pak;
		pak.setProgressHandler(m_pakProgressHandler);
		pak.open(file.get());
		if (!pak.opened())
		{
			DLOG << "Unable to parse pak: " << pakName;
			return false;
		}

		const std::string filename = outDir + std::string(PATH_SEPARATOR_STR) + pakName.toStdString();

		DLOG << "Rebuilding pak: " << pakName;
		if (!pak.rebuild(filename, inputDirs, std::set<ResType>(), m_mergeMap))
 		{
			DLOG << "Unable to rebuild pak: " << pakName;
			return false;
 		}
	}

	return true;
}

bool DataPaster::replacePaks(const QStringList& pakArchives, const QString& inputDir)
{
	foreach (const QString& pakName, pakArchives)
	{
		const QString filename = inputDir + QDir::separator() + pakName;


		Tree<FileInfo>::Node* fileRecord = m_image.findFile(pakName.toStdString());
		if (fileRecord == NULL)
		{
			DLOG << "Unable to open pak for replace: " << pakName;
			return false;
		}

		FileStream inputFile(filename.toStdString(), Stream::modeRead);	
		if (!inputFile.opened())
		{
			DLOG << "Unable to open input pak: " << pakName;
			return false;
		}

		if (inputFile.size() > fileRecord->data().size)
		{
			DLOG << "Input pak file too big: " << pakName << " (" << inputFile.size() << " bytes / " << fileRecord->data().size << " bytes)";
			return false;
		}


		const bool written = m_image.wii_write_data_file(m_image.dataPartition(), fileRecord->data().offset, &inputFile, inputFile.size());
		if (!written)
		{
			DLOG << "Unable to write file!";
			return false;
		}
	}

	return true;
}

void DataPaster::setProgressHandler(IPakProgressHandler* handler)
{
	m_pakProgressHandler = handler;
}

bool DataPaster::checkData(const QStringList& pakArchives, const QStringList& inputDirs, const QString& outDir)
{
	foreach (const QString& pakName, pakArchives)
	{
		const QString pakPath = outDir + QDir::separator() + pakName;
		PakArchive resultPak;
		if (!resultPak.open(pakPath.toStdString()))
		{
			DLOG << "CheckData: Unable to parse result pak: " << pakName;
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
					return false;
				}

				std::auto_ptr<Stream> fileInPak;
				if (fileRecord.packed != 0)
				{
					if (QFile::exists("~filefrompak.tmp"))
					{
						QFile::remove("~filefrompak.tmp");
					}

					fileInPak.reset(new FileStream("~filefrompak.tmp", Stream::modeReadWrite));
					if (!resultPak.extractFile(fileRecord.hash, fileInPak.get()))
					{
						DLOG << "Unable to extract file!";
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
					return false;
				}

				if (!compareStreams(&file, fileInPak.get()))
				{
					DLOG << "Files are different!";
					return false;
				}
			}
		}

	}
	return true;
}

bool DataPaster::checkPaks(const QStringList& pakArchives, const QString& paksDir)
{
	foreach (const QString& pakName, pakArchives)
	{
		std::auto_ptr<Stream> imagePakFile(m_image.openFile(pakName.toStdString(), Stream::modeRead));
		if (imagePakFile.get() == NULL)
		{
			DLOG << "CheckData: Opening pak in image failed: " << pakName;
			return false;
		}

		FileStream resultPakFile((paksDir + QDir::separator() + pakName).toStdString(), Stream::modeRead);
		if (!resultPakFile.opened())
		{
			DLOG << "CheckData: Opening result pak failed: " << pakName;
			return false;
		}

		if (imagePakFile->size() < resultPakFile.size())
		{
			DLOG << "CheckData: Invalid pak size: " << pakName;
			return false;
		}
		
		if (!compareStreams(&resultPakFile, imagePakFile.get(), true))
		{
			DLOG << "PAKs are not equal: " << pakName;
			return false;
		}
	}
	return true;
}

bool DataPaster::compareStreams(Consolgames::Stream* stream1, Consolgames::Stream* stream2, bool ignoreSize)
{
	if (!ignoreSize && stream1->size() != stream2->size())
	{
		return false;
	}

	largesize_t size = min(stream1->size(), stream2->size());

	stream1->seek(0, Stream::seekSet);
	stream2->seek(0, Stream::seekSet);

	const int chunk = 4096;

	char data1[chunk];
	char data2[chunk];
	while (size > 0)
	{
		const largesize_t toRead = min(chunk, size);
		size -= chunk;

		const largesize_t readed1 = stream1->read(&data1[0], toRead);
		const largesize_t readed2 = stream2->read(&data2[0], toRead);
		if (readed1 != readed2 || readed1 != toRead)
		{
			DLOG << __FUNCTION__ << ": I/O error!";
			return false;
		}

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