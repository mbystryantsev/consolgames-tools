#pragma once
#include <Stream.h>

namespace ShatteredMemories
{

class DataStreamParser
{
public:
	struct MetaInfo
	{
		bool isNull();
		void clear();

		std::string unknown;
		std::string typeId;
		std::string sourcePath;
		std::string targetPath;
	};

public:

	virtual bool fetch(){return true;}
	virtual bool atEnd() const{return false;}
	virtual const MetaInfo& metaInfo() const = 0;

	static const int s_dataStreamId;
};

}

