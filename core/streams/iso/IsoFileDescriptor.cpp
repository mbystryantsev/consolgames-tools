#include "IsoDirectory.h"
#include "IsoFile.h"
#include "PathInfo.h"
#include "core.h"
#include <memory>

namespace Consolgames
{
	
IsoFileDescriptor::IsoFileDescriptor()
	: lba(0)
	, size(0)
	, flags(0)
{
}

IsoFileDescriptor::IsoFileDescriptor(const uint8* data, int length)
{
	*this = fromData(data, length);
}

IsoFileDescriptor IsoFileDescriptor::fromData(const uint8* data, int)
{
	IsoFileDescriptor info;

	info.lba  = *reinterpret_cast<const uint32*>(&data[2]);
	info.size = *reinterpret_cast<const uint32*>(&data[10]);

	info.date.year      = data[18] + 1900;
	info.date.month     = data[19];
	info.date.day       = data[20];
	info.date.hour      = data[21];
	info.date.minute    = data[22];
	info.date.second    = data[23];
	info.date.gmtOffset = data[24];

	info.flags = data[25];

	int fileNameLength = data[32];

	if(fileNameLength == 1)
	{
		uint8 c = data[33];

		switch(c)
		{
			case 0:	
				info.name = "."; 
				break;
			case 1: 
				info.name = ".."; 
				break;
			default: 
				info.name = c;
		}
	}
	else
	{
		// copy string and up-convert from ascii to wxChar
		const uint8* fnsrc = data + 33;
		const uint8* fnend = fnsrc + fileNameLength;

		while (fnsrc != fnend)
		{
			info.name += *fnsrc;
			fnsrc++;
		}
	}

	return info;
}

}
