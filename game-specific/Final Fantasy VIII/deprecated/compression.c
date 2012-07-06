#define UBYTE unsigned char /* Unsigned     byte (1 byte )        */
#define BYTE unsigned char
#define UWORD unsigned int  /* Unsigned     word (2 bytes)        */
#define ULONG unsigned long /* Unsigned longword (4 bytes)        */
#define FLAG_BYTES    4     /* Number of bytes used by copy flag. */
#define FLAG_COMPRESS 0     /* Signals that compression occurred. */
#define FLAG_COPY     1     /* Signals that a copyover occurred.  */
#define TRUE 1
void fast_copy(UBYTE *p_src, UBYTE*p_dst,ULONG len) /* Fast copy routine.             */
{while (len--) *p_dst++=*p_src++;}


#define PS *p++!=*s++  /* Body of inner unrolled matching loop.         */
#define ITEMMAX 16     /* Maximum number of bytes in an expanded item.  */

int extern lzs_compress(UBYTE *p_src_first,ULONG src_len,UBYTE *p_dst_first,ULONG *p_dst_len)
/* Input  : Specify input block using p_src_first and src_len.          */
/* Input  : Point p_dst_first to the start of the output zone (OZ).     */
/* Input  : Point p_dst_len to a ULONG to receive the output length.    */
/* Input  : Input block and output zone must not overlap.               */
/* Output : Length of output block written to *p_dst_len.               */
/* Output : Output block in Mem[p_dst_first..p_dst_first+*p_dst_len-1]. */
/* Output : May write in OZ=Mem[p_dst_first..p_dst_first+src_len+256-1].*/
/* Output : Upon completion guaranteed *p_dst_len<=src_len+FLAG_BYTES.  */
{
	UBYTE *p_src=p_src_first,*p_dst=p_dst_first;
	UBYTE *p_src_post=p_src_first+src_len/*,*p_dst_post=p_dst_first+src_len*/;
	UBYTE *p_src_max1=p_src_post-ITEMMAX,*p_src_max16=p_src_post-8*ITEMMAX;
	UBYTE *hash[4096], *p_control;
	UWORD control=0,control_bits=0;

	*p_dst=FLAG_COMPRESS; p_dst+=FLAG_BYTES; p_control=p_dst; p_dst++;

	while (TRUE) {
		UBYTE *p,*s;
		UWORD unroll=8,len,index;
		ULONG offset;
//		if (p_dst > p_dst_post) goto overrun;	// NEVER direct copy at this level
		if (p_src > p_src_max16) {
			unroll = 1;
			if (p_src > p_src_max1) {
				if (p_src == p_src_post) break;
				goto literal;
			}
		}

begin_unrolled_loop:

		index = ((40543 * ((((p_src[0] << 4) ^ p_src[1]) << 4) ^ p_src[2])) >> 4) & 0xFFF;
		p = hash[index];
		hash[index] = s = p_src;
		offset = s-p;
		if (offset>4095 || p<p_src_first || offset==0 || PS || PS || PS) {
literal:
			*p_dst++ = *p_src++;
			control >>= 1;
			control_bits++;
		}
		else {
			PS || PS || PS || PS || PS || PS || PS ||
			PS || PS || PS || PS || PS || PS || s++;
			len = s-p_src-1;

			// Change offset here...
			offset = ((p_src - p_src_first) - offset - 18) & 0xFFF;

			*p_dst++ = (BYTE)offset;
			*p_dst++ = (BYTE)(((offset & 0xF00) >> 4) + (len - 3));
			p_src += len;
			control = (control >> 1) | 0x80;
			control_bits++;
		}

//end_unrolled_loop:

		if (--unroll) goto begin_unrolled_loop;

		if (control_bits==8) {
			*p_control = control ^ 0xFF;

			p_control = p_dst;
			p_dst++;
			control = control_bits = 0;
		}
	}
	
	control >>= 8-control_bits;
	*p_control++ = control ^ 0xFF;
	//*p_control++ = control >> 8;

	if (p_control == p_dst) p_dst--;
	*p_dst_len = p_dst - p_dst_first;
	*(int*)p_dst_first = *p_dst_len - 4;
	return 1;

//overrun:
	fast_copy(p_src_first,p_dst_first,src_len);
	*p_dst_first = FLAG_COPY;
	*p_dst_len = src_len;

	return 0;

}

/******************************************************************************/

void extern lzs_decompress(UBYTE *p_src_first,ULONG src_len, UBYTE *p_dst_first,ULONG *p_dst_len)
/* Input  : Specify input block using p_src_first and src_len.          */
/* Input  : Point p_dst_first to the start of the output zone.          */
/* Input  : Point p_dst_len to a ULONG to receive the output length.    */
/* Input  : Input block and output zone must not overlap. User knows    */
/* Input  : upperbound on output block length from earlier compression. */
/* Input  : In any case, maximum expansion possible is eight times.     */
/* Output : Length of output block written to *p_dst_len.               */
/* Output : Output block in Mem[p_dst_first..p_dst_first+*p_dst_len-1]. */
/* Output : Writes only  in Mem[p_dst_first..p_dst_first+*p_dst_len-1]. */
{
	UWORD controlbits = 0, control;
	UBYTE *p_src = p_src_first,
		*p_dst = p_dst_first,
		*p_src_post = p_src_first+src_len;

	while (p_src != p_src_post) {
		if (controlbits == 0) {
			control = *p_src++;
			controlbits = 8;
		}
		if (!(control & 1)) {
			UWORD offset,len; UBYTE *p;
			offset = *p_src++ & 0xFF;
			offset += (*p_src & 0xF0) << 4;
			len = 3 + (*p_src++ & 0xF);

			p = p_dst - (((p_dst - p_dst_first) - (offset + 18)) & 0xFFF);

			while (len--) {
				if (p < p_dst_first) {
					*p_dst++ = 0;
					p++;
				}
				else
					*p_dst++ = *p++;
			}
		}
		else
			*p_dst++ = *p_src++;
		
		control >>= 1;
		controlbits--;
	}

	*p_dst_len = p_dst - p_dst_first;
}