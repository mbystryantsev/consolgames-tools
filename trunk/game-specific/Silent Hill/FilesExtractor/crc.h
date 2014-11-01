#pragma once
#include "Common.h"

uint16_t crc16(const void* buf, uint32_t len, uint16_t crc = 0);
uint32_t crc32(const void* buf, uint32_t len, uint32_t crc = 0);
