#ifndef __DXT1_H
#define __DXT1_H

void DecodeDXT1(void* src, void* dest, int width, int height, bool flip = true);
int EncodeDXT1(void* src, void* dest, int width, int height, bool flip = true, bool fast = false);
int EncodeDXT1(void* src, void* dest, int width, int height, int mipmaps, bool flip = true, bool fast = false, int min_width = 8, int min_height = 8);
void DecodeDXT3(void* src, void* dest, int width, int height);
void DeswizzleImage(void* src, void* dest, int width, int height);

#endif /* __DXT1_H */
