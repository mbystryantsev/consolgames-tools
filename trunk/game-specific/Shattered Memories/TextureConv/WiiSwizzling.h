#pragma once

void wiiUnswizzle32(const void* src, void* dst, int width, int height);
void wiiSwizzle32(const void* src, void* dst, int width, int height);
void wiiUnswizzle16(const void* src, void* dst, int width, int height);
void wiiSwizzle16(const void* src, void* dst, int width, int height);
void wiiUnswizzle8(const void* src, void* dst, int width, int height);
void wiiSwizzle8(const void* src, void* dst, int width, int height);
void wiiUnswizzle4(const void* src, void* dst, int width, int height);
void wiiSwizzle4(const void* src, void* dst, int width, int height);
