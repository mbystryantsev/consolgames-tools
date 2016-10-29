#ifndef __IMAGE_H
#define __IMAGE_H

#pragma pack(push, 1)

struct SGBAColor{
	unsigned r: 5;
	unsigned g: 5;
	unsigned b: 5;
	unsigned a: 1;
};

struct STrueColor{
	unsigned char r, g, b, a;
};

struct SFloatColor{
	float r, g, b, a;
};

#pragma pack(pop)

void decodeImage(void *in, void* out, int& width, int& height, int _alpha = 0);
int encodeImage(void *in, void* out, int width, int height, int _alpha = -1);

#endif /* __IMAGE_H */
