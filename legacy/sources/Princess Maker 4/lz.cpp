#include "lz.h"
#include <stdlib.h>
#include <mem.h>

static u8 g_lzss_text[4096+32];

u32 decodeLZ(void *in_src, u32 in_size, void *out_ptr)
{
	int i, j, k, r, c, n, f;
	u32 size, out_size;
	unsigned int flags;
	void *ptr;
	u8 *rd, *wr;

	if (!memcmp((s8 *)in_src, (s8 *)"LZ08", 4))
	{
		// 9bit
		n = 512;
		f = 130;
	} else
	if (!memcmp((s8 *)in_src, (s8 *)"LZ12", 4))
	{
		// 12bit
		n = 4096;
		f = 18;
	} else {
		// LZSS
                memcpy(out_ptr, in_src, in_size);
		return in_size;
	}
	size = *(int*)((s8*)in_src + 4);
	out_size = size;
	rd = (u8 *)((int)in_src + 8);
        ptr = out_ptr;
	wr = (u8 *)ptr;
	in_size -= 8;

	for (i=0; i<n-f; i++)
		g_lzss_text[i] = 0;
	r = n - f;
	flags = 0;
	while (size > 0)
	{
		if (((flags >>= 1) & 256) == 0)
		{
			c = *rd;
			rd++;
			flags = (unsigned int)(c | 0xff00);
		}

		if (flags & 1)
		{
			*wr = *rd;
			rd++;
			g_lzss_text[r++] = *wr;
			wr++;
			size--;
			if (size == 0)
				break;
			r &= (n - 1);
		} else {
			i = *rd;
			rd++;
			j = *rd;
			rd++;
			if (n == 4096)
			{
				i |= ((j & 0xf0) << 4);
				j = (j & 0x0f) + 2;
			} else {
				i |= ((j & 0x80) << 1);
				j = (j & 0x7f) + 2;
			}
			for (k=0; k<=j; k++)
			{
				c = g_lzss_text[(i + k) & (n - 1)];
				*wr = (u8)c;
				wr++;
				size--;
				if (size == 0)
					break;
				g_lzss_text[r++] = (u8)c;
				r &= (n - 1);	
			}
		}
	}
	return out_size;
}

struct LZElement{
    //int len;
    //int count;
    u8 *pointer;
    LZElement* ptrs[256], *parent;
};

LZElement lz_table[4096];

inline int in_table(u8 *r){

}

u32 encodeLZ(void *in_src, u32 in_size, void *out_ptr, int lz12){

/*
    u8 *rd = (u8*)in_src, *rr, *wr = (u8*)out_ptr + 8, *r, *r_end;
    int table_len = 256, count, text_pos = 0, n = 4096, el_buf_pos;
    u8* in_end = in_src + in_size;
    int best_count, best_pos, n, f;

    if(lz12){
    } else {
    }


    LZElement *el, *prev, *el_buf[18];
    memset(lz_table, 0, sizeof(lz_table));
    memset(g_lzss_text, 0, sizeof(g_lzss_text));
    while(in_size > 0){
        r = rd;
        r_end = rd + max_c;
        if(r_end > in_end) r_end = in_end;
        el = &lz_table[*r];


        if(count < max_c){
            if(lz_table[table_len].parent){
                lz_table[table_len].parent->ptrs[*(lz_table[table_len].pointer)] = NULL;
            }
            prev->ptrs[*r] = el = &lz_table[table_len++];
            el->len     = r - rd + 1;
            el->pointer = rd;
            if (table_len > n) table_len = 256;
        }
        if(count >= 2){
            if(max_c == 130){
                *wr++ = 0;
                *wr++ = (count - 2) & 0x7F;
            } else {
                *wr++ = 0;
                *wr++ = (count - 2) & 0x0F;;
            }
        } else {
            g_lzss_text[text_pos++] = *rd;
            text_pos &= 4096 - 1;
        }
        //g_lzss_text[text_pos++] = *r++;
        rd = r;
    }

    */
}
