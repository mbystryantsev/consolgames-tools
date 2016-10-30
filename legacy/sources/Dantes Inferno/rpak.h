#ifndef __RPAK_H
#define __RPAK_H


typedef __stdcall void(*pProgress)(int, int);
int RDecompress(void *in_buf, void *out_buf);
int RCompress(void *in_buf, int in_size, void *out_buf, pProgress progress);
               

#ifdef RPAK_DEBUG
int store(unsigned char **in, unsigned char **out, unsigned char **last);
int FindChain(unsigned char *data, unsigned char *back, unsigned char *end, int *result);
#endif

#endif /* __RPAK_H */
