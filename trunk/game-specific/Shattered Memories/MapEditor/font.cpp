#include "font.h"
/*

int GREY_PALETTE[] = {
        0x00000000, 0xFF111111, 0xFF222222, 0xFF333333,
        0xFF444444, 0xFF555555, 0xFF666666, 0xFF777777,
        0xFF888888, 0xFF999999, 0xFFAAAAAA, 0xFFBBBBBB,
        0xFFCCCCCC, 0xFFDDDDDD, 0xFFEEEEEE, 0xFFFFFFFF
};
*/

void DecodeChar(void* dest, int d_width, int char_w, int char_h, int y, void *data, int size, int *pal){
  unsigned char *s = (char*)data;
  int *d = (int*)dest + (d_width * y), count, _y = y, x = 0;
  bool block;
  while(s < (char*)data + size && y < _y + char_h){
    count = *s++;
    block = true;
    if(count > 0x80){
      block = false;
      count = 0x100 - count;
    }
    while(count){
      if (x >= char_w){
        y++;
        x = 0;
        if(y >= _y + char_h) return;
        d = (int*)dest + d_width * y;
      }
      *d++ = pal[*s & 0xF];
      *d++ = pal[*s >> 4];
      x+=2;
      if(block) s++;
      count--;
    }
    if(!block) s++;
  }
}
