#include "crypto.h"

unsigned int crypto(void* data, int size, unsigned int state)
{
	const unsigned int key1 = 0x03A452F7; 
	const unsigned int key2 = 0x01309125;
	unsigned int* d = reinterpret_cast<unsigned int*>(data);
	unsigned int v = state;	
	for (int i = 0; i < size / 4; i++)
	{
		v = (v + key2) * key1;
		*d++ ^= v;
	}
	
	return v;
}
