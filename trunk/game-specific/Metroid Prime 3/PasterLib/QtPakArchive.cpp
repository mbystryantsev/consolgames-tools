#include "QtPakArchive.h"
#include "QtFileStream.h"
#include <QString>
#include <QFile>
#include <QDir>

std::string QtPakArchive::findFile(const std::vector<std::string>& inputDirs, Hash hash, ResType res) const 
{
	const QString filename = QString::fromStdString(hashToStr(hash)) + QString(".") + QString::fromStdString(res.toString());
	for (size_t i = 0; i < inputDirs.size(); i++)
	{
		QDir dir(QString::fromStdString(inputDirs[i]));
		const QString path = dir.absoluteFilePath(filename);
		QFile file(path);
		if(file.exists())
		{
			return path.toStdString();
		}
	}
	return std::string();
}

u32 QtPakArchive::storeFile(const std::string& filename, Consolgames::Stream* stream, bool isPacked, bool isTexture, u8 flags)
{
	QtFileStream inputStream(QString::fromStdString(filename));
	return PakArchive::storeFile(&inputStream, stream, isPacked, isTexture, flags);
}
