#pragma once

class DXTCodec
{
public:
	static void decodeDXT1(void* src, void* dest, int width, int height);
	static int encodeDXT1(void* src, void* dest, int width, int height);
	static int encodeDXT1(void* src, void* dest, int width, int height, int mipmaps, int min_width = 32, int min_height = 32);
	static void decodeDXT3(void* src, void* dest, int width, int height);
	static int convert8bppaToGray(const void* inData, void* outData, int width, int height);

protected:
	static void flipImage(void* data, int w, int h);
	static void deswizzleImage(void* src, void* dest, int width, int height);
};

