#include "QtPakArchive.h"
#include "QtFileStream.h"
#include <QString>
#include <QFileInfo>
#include <QDir>

std::wstring QtPakArchive::findFile(const std::vector<std::wstring>& inputDirs, Hash hash, ResType res) const 
{
	const QString filename = QString::fromStdString(hashToStr(hash)) + QString(".") + QString::fromStdString(res.toString());
	for (size_t i = 0; i < inputDirs.size(); i++)
	{
		QDir dir(QString::fromStdWString(inputDirs[i]));
		const QString path = dir.absoluteFilePath(filename);
		QFileInfo info(path);
		if(info.exists())
		{
			return path.toStdWString();
		}
	}
	return std::wstring();
}

uint32_t QtPakArchive::storeFile(const std::wstring& filename, Consolgames::Stream* stream, bool isPacked, bool isTexture, uint8_t flags)
{
	QtFileStream inputStream(QString::fromStdWString(filename));
	return PakArchive::storeFile(&inputStream, stream, isPacked, isTexture, flags);
}
