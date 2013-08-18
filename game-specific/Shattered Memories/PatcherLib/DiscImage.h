#pragma once
#include <string>
#include <Stream.h>

namespace ShatteredMemories
{

class ProgressNotifier;

class DiscImage
{
public:
	struct FileInfo
	{
		FileInfo()
			: offset(0)
			, size(0)
		{
		}

		bool isNull() const
		{
			return (offset == 0 && size == 0);
		}

		offset_t offset;
		largesize_t size;
	};

public:
	virtual ~DiscImage(){}

	virtual bool open(const std::wstring& filename, Consolgames::Stream::OpenMode mode) = 0;
	virtual bool opened() const = 0;
	virtual void close() = 0;
	virtual Consolgames::Stream* openFile(const std::string& filename, Consolgames::Stream::OpenMode mode) = 0;
	virtual bool writeData(offset_t offset, Consolgames::Stream* stream, largesize_t size) = 0;
	virtual FileInfo findFile(const std::string& filename) = 0;
	virtual std::string discId() const = 0;
	virtual ProgressNotifier* progressNotifier() = 0;
	virtual bool checkImage() = 0;
	virtual std::string lastErrorData() const = 0;
};

}
