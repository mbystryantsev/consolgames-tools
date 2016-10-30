#include "rpak.h"

unsigned int little(unsigned int v){
   return (v >> 24) | (v << 24) | ((v >> 8) & 0xFF00) | ((v << 8) & 0xFF0000);
}

typedef unsigned char u8;


/*
void read(u8* &src, u8* &dest, int count){
    while(count-- > 0){
        *dest++ = *src++;
    }
}

*/

#define __b_read_(src, dest, c)     \
    int _count = c;                \
    while(_count-- > 0){       \
        *dest ++ = *src++;     \
    }


#define __b_read(src, dest, c)     \
    while(c-- > 0){       \
        *dest ++ = *src++;     \
    }

int RDecompress(void *in_buf, void *out_buf){
    int input_size = little(*(int*)(in_buf)), data_size;
    u8* in = (u8*)in_buf, *out_end,
    *out = (u8*)out_buf,
    *in_end = (u8*)in_buf + input_size + 4;
    in += 5;
    data_size = little(*(int*)in) & 0xFFFFFF;
    out_end = (u8*)out_buf + data_size;
    in += 4;
    while(in < in_end && out < out_end){
        u8 b = *in++;   
        if(b >= 0xFC){
            __b_read_(in, out, b - 0xFC)
        } else if(b >= 0xE0){
            // 111ccccc
    	    __b_read_(in, out, ((b & 0x1F) + 1) * 4);
        } else {
            u8 *src;
            int copy, back, count;
            /*
              c - count to data copy
              n - count to lz copy
              b - link to back
              f - flags
            */
            if(b & 0x80){
                if(b & 0x40){
                    // 110bnncc bbbbbbbb bbbbbbbb nnnnnnnn
                    // max count = (2^10 - 1) + 5 = 1028
                    // max back  = (2^17 - 1) + 1 = 131072
                    copy  =  b & 0x03;
                    count =  ((b >> 2) & 0x03) * 256;
                    back  =  *in++ * 256 + ((b >> 4) & 1) * 0x10000;
                    back  += *in++ + 1;
                    count += *in++ + 0x05;
                    //in += 3;
                } else {
                    // 10nnnnnn ccbbbbbb bbbbbbbb
                    // max count = (2^6  - 1) + 4 = 67
                    // max back  = (2^14 - 1) + 1 = 16384
                    copy  =  *in >> 6;
                    back  =  (*in++ & 0x3F) * 256;
                    back  += *in++ + 1;
                    count =  (b & 0x3F) + 4;
                }
            } else {
                //0bbnnncc bbbbbbbb
                // max count = (2^3  - 1) + 3 = 10
                // max back  = (2^10 - 1) + 1 = 1024
                back = *in++ + ((b >> 5) & 3) * 256 + 1;
                copy = b & 0x03;
                count = ((b >> 2) & 7) + 3;
            }
            __b_read(in, out, copy);
            src = out - back;
            __b_read(src, out, count);
    	}
    }
    return data_size;
    //return (unsigned int)out - (unsigned int)out_buf;
}
        
#define MAX_COUNT 1028  
int max_counts[3] = {10, 67, MAX_COUNT}; 
int FindChain(u8 *data, u8 *back, u8 *end, int *result){
    int max_count = 3, count, iback, t;
    u8 *cur_back, *b, *d, *best_back = 0;
    for(cur_back = back; cur_back < data; cur_back++){
    /*
        iback = data - cur_back;
        if     (iback > 16384 && iback <= 131072) t =  2;
        else if(iback > 1024  && iback <= 16384)  t =  1;
        else if(iback <= 1024 && iback >= 1)      t =  0;
        else                                      continue;
        if(max_count >= max_counts[t]){
            max_count = 0;
            break;
        }
    */
        b = cur_back;
        d = data;
        count = 0;
        while(d < end && *b++ == *d++){
            if(b == data) b = cur_back;
            count++;
        }
        if(count >= max_count){
            best_back = cur_back;
            max_count = count;
            if(max_count >= MAX_COUNT){
                max_count = MAX_COUNT;
                break;
            }
        }
    }
    if(best_back){
        *result = data - best_back;
    } else {
        *result = -1;
    }
    return max_count;
}

/*
void PackChain(char len, ){

}
*/


int store(u8 *in, u8 **out, u8 **last){
    while(in - *last >= 4){
      int count;
      u8 *u = (*out)++;
      for(count = 0; count < 0x1C && in - *last >= 4; count++){
          *(int*)(*out) = *(int*)(*last);
          (*out) += 4;
          (*last)+= 4;
      }
      if(count > 0){
          count--;
          *u = count | 0xE0;
      }
    }
    return in - *last;
}

#define MAX_BACK 131072
//#define MAX_BACK 16384


#define PROGRESS_STEP 128

int RCompress(void *in_buf, int in_size,
void *out_buf, pProgress progress){
    u8 *last = (u8*)in_buf, *in = (u8*)in_buf, *out = (u8*)out_buf, *end = in + in_size;
    int rem, i, progress_count = PROGRESS_STEP;

    out += 4;
    *out++ = 0x10;
    *out++ = 0xFB;
    *out++ = ((unsigned int)in_size >> 16) & 0xFF;
    *out++ = ((unsigned int)in_size >> 8) & 0xFF;
    *out++ = in_size & 0xFF;

    while(in < end){
        int count, rec_t, back;
        u8* back_ptr = (u8*)in_buf;//, *ub = out++;

        
        if(progress != 0){
            progress_count--;
            if(progress_count <= 0){
                progress_count = PROGRESS_STEP;
                progress((unsigned int)in - (unsigned int)in_buf, (unsigned int)end - (unsigned int)in_buf);
            }
        }

        if(in - back_ptr > MAX_BACK) back_ptr = in - MAX_BACK;
        if(end - in < MAX_BACK){
            count = FindChain(in, back_ptr, end, &back);
        } else {
            count = FindChain(in, back_ptr, in + MAX_BACK, &back);
        }


        if     (back >= 1 && back <= 1024   && count >= 3 && count <= 10  ) rec_t = 0;
        else if(back >= 1 && back <= 16384  && count >= 4 && count <= 67  ) rec_t = 1;
        else if(back >= 1 && back <= 131072 && count >= 5 && count <= 1028) rec_t = 2;
        else                                                                rec_t = -1;

        //if(rec_t >= 0) rec_t = 0;


        if(rec_t >= 0){
            back--;
            if(count < rec_t + 3){
                rec_t = -1;
                goto skip;
            }
            if(count > max_counts[rec_t]) count = max_counts[rec_t];
            in += count;
            rem = store(in - count, &out, &last);
        } else {
skip:
            rem = 0;
        }
        switch(rec_t){
            case 2:
                // 110bnncc bbbbbbbb bbbbbbbb nnnnnnnn
                count -= 5;
                *out++ = ((back >> 12) & 0x10) | ((count >> 6) & 0x0C) | rem | 0xC0;
                *out++ = (back >> 8) & 0xFF;
                *out++ = back & 0xFF;
                *out++ = count & 0xFF;

                break;
            case 1:
                // 10nnnnnn ccbbbbbb bbbbbbbb
                *out++ = ((count - 4) & 0x3F) | 0x80;
                *out++ = (rem << 6) | ((back >> 8) & 0x3F);
                *out++ = back & 0xFF;
                break;
            case 0:
                // 0bbnnncc bbbbbbbb
                *out++ = ((back >> 3) & 0x60) | ((count - 3) << 2) | rem;
                *out++ = back & 0xFF;
                break;
            default:
                in++;
                break;
        }
        if(rec_t >= 0){
            while(rem-- > 0){
                *out++ = *last++;
            }
            last = in;
        }
    }

    rem = store(in, &out, &last);
    *out++ = rem + 0xFC;
    while(rem-- > 0){
        *out++ = *last++;
    }
    
    i = (unsigned int)out - (unsigned int)out_buf;
    *(int*)out_buf = little(i - 4);
    return i;





}
