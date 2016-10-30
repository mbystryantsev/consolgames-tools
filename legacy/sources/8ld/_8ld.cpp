#include <cstdlib>
#include <iostream>

using namespace std;

void crypt(void* ptr, int size, int phase){
  const unsigned char code[7] = {0x4F, 0x4E, 0xE2, 0x99, 0xA5, 0x4D, 0x38};
  int cur = 0;
  char* buf = (char*)ptr;
  while(cur < size){
    buf[cur] ^= code[phase];
    cur++;
    phase++;
    if(phase==7)phase=0;
  }
}

int main(int argc, char *argv[])
{

    cout << "8LD decrypter by HoRRoR" << endl;
    cout << "http://consolgames.ru/" << endl;

    if(argc<2)return 1;
    char name[4096] = "";

    int to8ld = 0;
    int i;

    i = strlen(argv[1]) - 3;
    if(strcmp(argv[1] + i, "xml") == 0)
      to8ld = 1;

    if(!argv[2]){
      strcpy(name, argv[1]);
      i = strlen(name) - 3;
      name[i]   = to8ld ? '8' : 'x';
      name[i+1] = to8ld ? 'l' : 'm';
      name[i+2] = to8ld ? 'd' : 'l';
    }
    else
      strcpy(name, argv[2]);


    FILE* src = fopen(argv[1], "rb");

    fseek(src, 0, SEEK_END);
    int size = ftell(src);
    fseek(src, 0, SEEK_SET);

    char *buf;
    if(to8ld){
      buf = (unsigned char*)malloc(size + 5);
      fread(buf + 5, size, 1, src);
      fclose(src);
      memcpy(buf, &("M8LD"), 4);
      buf[4] = rand() % 255;
      i = (unsigned int)(buf[4]) % 7;
      crypt(buf + 5, size, i);

      FILE* dst = fopen(name, "wb");
      fwrite(buf, size + 5, 1, dst);
      fclose(dst);
    }else{
      buf = (unsigned char*)malloc(size);
      fread(buf, size, 1, src);
      fclose(src);

      i = (unsigned int)(buf[4]) % 7;
      crypt(buf + 5, size - 5, i);
      FILE* dst = fopen(name, "wb");
      fwrite(buf + 5, size - 5, 1, dst);
      fclose(dst);
    }

    cout << "Done!" << endl;
    return EXIT_SUCCESS;
}
