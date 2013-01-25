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

#ifndef __ISOFILEDESCRIPTOR_H
#define __ISOFILEDESCRIPTOR_H

#include <string>

typedef char s8;
typedef short s16;
typedef int s32;
typedef __int64 s64;


//typedef __int64 _int64;
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned __int64 u64;
typedef unsigned char u8;

struct IsoFileDescriptor
{
	struct FileDate // not 1:1 with iso9660 date struct
	{
		s32	year;
		u8	month;
		u8	day;
		u8	hour;
		u8	minute;
		u8	second;
		u8	gmtOffset; // Offset from Greenwich Mean Time in number of 15 min intervals from -48 (West) to + 52 (East)

	} date;

	u32		lba;
	u32		size;
	int		flags;
	std::string     name;

	IsoFileDescriptor();
	IsoFileDescriptor(const u8* data, int length);
	
	void load(const void* data, int length );
	
	bool IsFile() const { return !(flags & 2); }
	bool IsDir() const { return !IsFile(); }
};

#endif /* __ISOFILEDESCRIPTOR_H */
