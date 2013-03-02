#pragma once
#include "Hash.h"
#include <Stream.h>
#include <memory>
#include <string>

namespace ShatteredMemories
{

class Archive;

class FileSource
{
public:
	class FileAccessor
	{
	public:
		virtual std::tr1::shared_ptr<Consolgames::Stream> open() = 0;
		virtual ~FileAccessor()
		{
		}
	};

public:
	virtual std::tr1::shared_ptr<Consolgames::Stream> file(u32 hash, FileAccessor& accessor) = 0;
	virtual std::tr1::shared_ptr<Consolgames::Stream> fileByName(const std::string& name, FileAccessor& accessor)
	{
		return file(Hash::calc(name.c_str()), accessor);
	}
	virtual ~FileSource()
	{
	}
};

}
