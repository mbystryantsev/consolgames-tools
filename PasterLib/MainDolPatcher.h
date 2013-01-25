#pragma once
#include "QtFileStream.h"
#include <memory>


class MainDolPatcher
{
public:
	bool open(const QString& filename);
	bool patch(const QString& messagesFilename, const QString& fontFilename, const QString& fontTextureFilename);

private:
	bool patchStrings(const QString& messagesFilename);
	bool patchCompressedItem(const QString& filename, quint32 offset, quint32 size, quint32 originalSize);


private:
	std::auto_ptr<QtFileStream> m_fileStream;
};