/*  PCSX2 - PS2 Emulator for PCs
 *  Copyright (C) 2002-2009  PCSX2 Dev Team
 *
 *  PCSX2 is free software: you can redistribute it and/or modify it under the terms
 *  of the GNU Lesser General Public License as published by the Free Software Found-
 *  ation, either version 3 of the License, or (at your option) any later version.
 *
 *  PCSX2 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 *  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 *  PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with PCSX2.
 *  If not, see <http://www.gnu.org/licenses/>.
 */

#pragma once
#include <core.h>
#include <string>

namespace Consolgames
{
	
struct IsoFileDescriptor
{
	IsoFileDescriptor();
	IsoFileDescriptor(const uint8* data, int length = 0);

	static IsoFileDescriptor fromData(const uint8* data, int length = 0);
	bool isFile() const { return !(flags & 2); }
	bool isDir() const { return !isFile(); }
	bool isNull() const {return name.empty();};

	struct FileDate // not 1:1 with iso9660 date struct
	{
		FileDate()
			: year(0)
			, month(0)
			, day(0)
			, hour(0)
			, minute(0)
			, second(0)
			, gmtOffset(0)
		{
		}

		int   year;
		uint8 month;
		uint8 day;
		uint8 hour;
		uint8 minute;
		uint8 second;
		uint8 gmtOffset; // Offset from Greenwich Mean Time in number of 15 min intervals from -48 (West) to + 52 (East)

	} date;

	uint32	lba;
	uint32  size;
	int		flags;
	std::string name;
};

}
