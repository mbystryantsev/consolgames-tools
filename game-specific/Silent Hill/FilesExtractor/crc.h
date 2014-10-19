#pragma once

#ifdef _MSC_VER
typedef unsigned __int8 uint8_t;
typedef unsigned __int16 uint16_t;
typedef unsigned __int32 uint32_t;
typedef unsigned __int64 uint64_t;
#else
#include <inttypes.h>
#endif

uint16_t crc16(const void* buf, size_t len, uint16_t crc = 0);
uint32_t crc32(const void* buf, size_t len, uint32_t crc = 0);
