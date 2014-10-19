#pragma once
#include "Common.h"
#include <fstream>

class CDStream
{
public:
	CDStream(const char* filename);
	bool isOpen() const;
	bool seekToSector(int sector, int positionInSector = 0);
	bool seekInSector(int position);
	bool skip(uint32_t size);
	bool read(void* data, uint32_t size);
	int sector() const;
	int positionInSector() const;
	int sectorCount() const;

private:
	std::ifstream m_cd;
	int m_currentSector;
	int m_currentPos;
	int m_sectorCount;
};
