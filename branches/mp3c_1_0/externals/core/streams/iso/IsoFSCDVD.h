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

#include <stdio.h>

#include "SectorSource.h"


// CDVDreadTrack mode values:
#define CDVD_MODE_2352	0	// full 2352 bytes
#define CDVD_MODE_2340	1	// skip sync (12) bytes
#define CDVD_MODE_2328	2	// skip sync+head+sub (24) bytes
#define CDVD_MODE_2048	3	// skip sync+head+sub (24) bytes
#define CDVD_MODE_2368	4	// full 2352 bytes + 16 subq

// CDVDgetDiskType returns:
#define CDVD_TYPE_ILLEGAL	0xff	// Illegal Disc
#define CDVD_TYPE_DVDV		0xfe	// DVD Video
#define CDVD_TYPE_CDDA		0xfd	// Audio CD
#define CDVD_TYPE_PS2DVD	0x14	// PS2 DVD
#define CDVD_TYPE_PS2CDDA	0x13	// PS2 CD (with audio)
#define CDVD_TYPE_PS2CD		0x12	// PS2 CD
#define CDVD_TYPE_PSCDDA 	0x11	// PS CD (with audio)
#define CDVD_TYPE_PSCD		0x10	// PS CD
#define CDVD_TYPE_UNKNOWN	0x05	// Unknown
#define CDVD_TYPE_DETCTDVDD	0x04	// Detecting Dvd Dual Sided
#define CDVD_TYPE_DETCTDVDS	0x03	// Detecting Dvd Single Sided
#define CDVD_TYPE_DETCTCD	0x02	// Detecting Cd
#define CDVD_TYPE_DETCT		0x01	// Detecting
#define CDVD_TYPE_NODISC 	0x00	// No Disc

// CDVDgetTrayStatus returns:
#define CDVD_TRAY_CLOSE		0x00
#define CDVD_TRAY_OPEN		0x01

// cdvdTD.type (track types for cds)
#define CDVD_AUDIO_TRACK	0x01
#define CDVD_MODE1_TRACK	0x41
#define CDVD_MODE2_TRACK	0x61

#define CDVD_AUDIO_MASK		0x00
#define CDVD_DATA_MASK		0x40
//	CDROM_DATA_TRACK	0x04	//do not enable this! (from linux kernel)

class IsoFSCDVD: public SectorSource
{
public:
	IsoFSCDVD();
	virtual ~IsoFSCDVD() throw();

	virtual bool readSector(unsigned char* buffer, int lba);

	virtual int  sectorCount();
};
