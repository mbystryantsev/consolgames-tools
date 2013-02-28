#pragma once

class DXTCodec
{
public:
	static void decodeDXT1(const void* src, void* dest, int width, int height);
	static void decodeDXT1(const void* src, void* dest, int width, int height, int mipmaps);
	static int encodeDXT1(const void* src, void* dest, int width, int height);
	static int encodeDXT1(const void* src, void* dest, int width, int height, int mipmaps);

private:
	static void flipImage(void* data, int w, int h);

private:
	static const int s_minMipmapSide;
};

