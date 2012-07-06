#ifndef WIITEX_H_INCLUDED
#define WIITEX_H_INCLUDED

enum
{
	ERROR_NONE,
	ERROR_IO_IMAGE,
	ERROR_UNKNOWN_FILTER
};

enum
{
	FILTER_BOX,
	FILTER_QUADRATIC,
	FILTER_TRIANGLE,
	FILTER_CUBIC
};


int WiiTexSavePNG(char* filename, void* pixels, int width, int height);


#endif // WIITEX_H_INCLUDED
