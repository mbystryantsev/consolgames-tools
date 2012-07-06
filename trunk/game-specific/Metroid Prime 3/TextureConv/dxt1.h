#ifndef __DXT1_H
#define __DXT1_H

void DecodeDXT1(void* src, void* dest, int width, int height);
int EncodeDXT1(void* src, void* dest, int width, int height);
int EncodeDXT1(void* src, void* dest, int width, int height, int mipmaps, int min_width = 32, int min_height = 32);
void DecodeDXT3(void* src, void* dest, int width, int height);
void DeswizzleImage(void* src, void* dest, int width, int height);

#endif /* __DXT1_H */
