#ifndef __FONT_H
#define __FONT_H
//#include <wchar.h>

#pragma pack(push, 1)
struct SFontHeader{
   short unk0, unk1;
   int size;
   short count;
   short width, height;
   short unk3;
};

struct SCharData{
   wchar_t code;
   short width;
   char  unk;
   char  y, w, h;
   int pos;
   short size;
   short unk2;
};
#pragma pack(pop)


void DecodeChar(void* dest, int d_width, int char_w, int char_h, int y, void *data, int size, int *pal);

#endif /*  __FONT_H */
