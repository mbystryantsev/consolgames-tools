#pragma once
#include <Stream.h>
#include <memory>

namespace ShatteredMemories
{

class IFileSource
{
public:
	virtual std::tr1::shared_ptr<Consolgames::Stream> file(u32 hash) = 0;
};

}
