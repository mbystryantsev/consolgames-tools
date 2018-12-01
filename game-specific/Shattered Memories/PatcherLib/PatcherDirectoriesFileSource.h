#pragma once
#include <FileSource.h>
#include <QStringList>
#include <QList>
#include <QDir>

namespace ShatteredMemories
{

class PatcherDirectoriesFileSource : public FileSource
{
public:
	PatcherDirectoriesFileSource(const QStringList& directories);

	virtual std::shared_ptr<Consolgames::Stream> file(uint32_t hash, FileAccessor& accessor) override;
	virtual std::shared_ptr<Consolgames::Stream> fileByName(const std::string& name, FileAccessor& accessor) override;

private:
	QList<QDir> m_directories;
};

}
