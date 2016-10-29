#ifndef __LZ_H
#define __LZ_H

typedef unsigned char u8;
typedef unsigned int u32;
typedef unsigned short u16;
typedef char s8;

u32 decodeLZ(void *in_src, u32 in_size, void *out_ptr);
u32 encodeLZ(void *in_src, u32 in_size, void *out_ptr);

#endif /* __LZ_H */

