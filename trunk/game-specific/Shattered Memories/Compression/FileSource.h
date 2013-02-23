#pragma once
#include <Stream.h>
#include <memory>

namespace ShatteredMemories
{

class FileSource
{
public:
	class FileAccessor
	{
	public:
		virtual std::tr1::shared_ptr<Consolgames::Stream> open() = 0;
	};

public:
	virtual std::tr1::shared_ptr<Consolgames::Stream> file(u32 hash, FileAccessor& accessor) = 0;
};

}
