#include "lz.h"


static u8 g_lzss_text[4096+32];

u32 decodeLZ(void *in_src, u32 in_size, void **in_ptr)
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
		*in_ptr = in_src;
		return in_size;
	}
	memcpyBDS((s8 *)&size, (s8 *)in_src+4, 4);
	out_size = size;
	rd = (u8 *)((int)in_src + 8);
	ptr = mallocBDS((u32)size);
	wr = (u8 *)ptr;
	in_size -= 8;

	// iGJAIDEa
	for (i=0; i<n-f; i++)
		g_lzss_text[i] = 0;
	// ?«?Y?I??
	r = n - f;
	// ?ÛJEd
	flags = 0;
	while (size > 0/*TRUE*/)
	{
		if (((flags >>= 1) & 256) == 0)
		{
			c = *rd;
			rd++;
			flags = (unsigned int)(c | 0xff00);
		}
		// ?ÛH?G©?
		if (flags & 1)
		{
			*wr = *rd;
			rd++;
			g_lzss_text[r++] = *wr;		// iGJAEH?G??«??
			wr++;
			size--;
			if (size == 0)
				break;
			r &= (n - 1);	// ??Y???³
		} else {
			i = *rd;
			rd++;
			j = *rd;
			rd++;
			if (n == 4096)
			{
				i |= ((j & 0xf0) << 4);		// ????
				j = (j & 0x0f) + 2;			// ??????e
			} else {
				i |= ((j & 0x80) << 1);		// ????
				j = (j & 0x7f) + 2;			// ??????e
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
	free(in_src);
	*in_ptr = ptr;
	//DC_FlushAll();
	return out_size;
}