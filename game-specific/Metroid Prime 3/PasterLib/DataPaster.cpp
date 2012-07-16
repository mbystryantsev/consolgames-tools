#include "DataPaster.h"
#include <pak.h>
#include <Stream.h>
#include <QStringList>
#include <QDir>
#include <memory>

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
		std::auto_ptr<Stream> file(m_image.openFile(pakName.toStdString(), Stream::modeRead));
 		if(file.get() == NULL)
 		{
			DLOG << "Unable to open file in image!";
 			continue;
 		}

		PakArchive pak;
		pak.open(file.get());
		if (!pak.opened())
		{
			DLOG << "Unable to parse pak!";
			continue;
		}

		const std::string filename = outDir + std::string(PATH_SEPARATOR_STR) + pakName.toStdString();

 		if (!pak.rebuild(filename, inputDirs))
 		{
			DLOG << "Unable to rebuild pak!";
 		}
	}

	return true;
}

bool DataPaster::replacePaks(const QStringList& pakArchives, const QString& inputDir)
{
	foreach (const QString& pakName, pakArchives)
	{
		const QString filename = inputDir + QDir::separator() + pakName;

		std::auto_ptr<Stream> file(m_image.openFile(pakName.toStdString(), Stream::modeWrite));
		if (file.get() == NULL)
		{
			DLOG << "Unable to open pak for replace: " << pakName.toStdString().c_str();
			return false;
		}

		FileStream inputFile(filename.toStdString(), Stream::modeRead);	
		if (!inputFile.opened())
		{
			DLOG << "Unable to open input pak: " << pakName.toStdString().c_str();
			return false;
		}

		if (inputFile.size() > file->size())
		{
			DLOG << "Input pak file too big: " << pakName.toStdString().c_str();
			return false;
		}

		largesize_t writed = file->writeStream(&inputFile, inputFile.size());
		if (writed != inputFile.size())
		{
			DLOG << "Unable to write file!";
			return false;
		}
	}

	return true;
}