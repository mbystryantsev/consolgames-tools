#ifndef SILENT_H_INCLUDED
#define SILENT_H_INCLUDED

struct FileRec
{
    unsigned int a; // File size and offset in RAM (encrypted by very very long and boring procedure)
    unsigned int b; // First part of name and directory index
    unsigned int c; // Second part of name and exstention index
};

inline unsigned int decodeSize(unsigned int v)
{
    unsigned int lba = ((v >> 0x13) & 0xFFFF) << 8;
    return lba;
}

int DetectRegion(void* data);
int ExtractFiles(FileRec* rec, int count, const char *in_file, const char *out_dir, int ver = 0); // 0 = EUR, 1 - USA
int ExtractFiles(const char* exe_file, const char *in_file, const char *out_dir);

#endif // SILENT_H_INCLUDED
