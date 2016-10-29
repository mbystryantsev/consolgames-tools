//---------------------------------------------------------------------------

//#include <vcl.h>
#include <Classes.hpp>
#include <SysUtils.hpp>
#include <iostream>
#pragma hdrstop
#pragma argsused

enum FILETYPE{
  ftCD = 0x03,
  ftFile = 0x50,
  ftCont = 0x23
};

struct FILEINFO{
  short type;
  short flag;
  union{
    unsigned int name;
    unsigned int info;
  };
  unsigned int offset;
  unsigned int size;
};

struct FILELINK{
  unsigned int info;
  char* name;
};

#define EXE_INC 0xFF800
#define LIST_OFFSET 0x2CCB80
#define INFO_OFFSET 0x2D4580

using namespace std;

String names[256];

FILEINFO* GetLastInfo(void* mem, FILEINFO*info){
  while(info->type == ftFile){
    info = (FILEINFO*)((int)(mem) + info->info - EXE_INC);
  }
  return info;
}


void ExtractFromFile(String InPath, String OutPath, String arc_name, String name,
TFileStream** streams, unsigned int offset, unsigned int size, int base_offset, int flag){
  TFileStream *Stream, *NewStream;
  int i;
  Stream = NULL;
  char* buf;
  FILE *f;

  for(i=1; i<=name.Length(); i++) if(name[i] == '/') name[i] = '\\';
  for(i=1; i<=arc_name.Length(); i++) if(arc_name[i] == '/') arc_name[i] = '\\';

  for(i=0; i<256; i++){
    if(!(int)streams[i]){
      streams[i] = new TFileStream(InPath + arc_name, fmOpenRead);
      Stream = streams[i];
      names[i] = arc_name;

      if(base_offset){
        if(!FileExists(ExtractFilePath(OutPath + arc_name))){
          ForceDirectories(ExtractFilePath(OutPath + arc_name));
        }
        char* buf = (char*)malloc(base_offset);
        Stream->Read(buf, base_offset);
        f = fopen((char*)(OutPath + arc_name).data(), "wb");
        fwrite(buf, base_offset, 1, f);
        fclose(f);
      }

      break;
    } else if(names[i] == arc_name) {
      Stream = streams[i];
      break;
    }
  }

  if(flag){
    if(!DirectoryExists(OutPath + "chains\\")){
      ForceDirectories(OutPath + "chains\\");
    }
    buf = (char*)malloc(offset - base_offset);
    Stream->Seek(base_offset, 0);
    Stream->Read(buf, offset - base_offset);
    
    f = fopen((char*)(OutPath + "chains\\" + IntToHex(flag, 6)).data(), "wb");
    fwrite(buf, offset - base_offset, 1, f);
    fclose(f);
    free(buf);
  }



  name = OutPath + name;
  arc_name = InPath + arc_name;

  if(!DirectoryExists(ExtractFilePath(name))){
    ForceDirectories(ExtractFilePath(name));
  }

  buf = (char*)malloc(size);//new char[size];
  Stream->Seek(offset, 0);
  Stream->Read(buf, size);

  f = fopen((char*)name.data(), "wb");
  fwrite(buf, size, 1, f);
  fclose(f);

  free(buf);

//  NewStream = new TFileStream(name, fmOpenWrite);
//  NewStream->Write(buf, size);
//  delete NewStream;

  
}

unsigned int RoundBy(unsigned int V, int N = 2048){
  if(!N) return 0;
  if(V % N) return (V / N) * N + N;
  else return V;
}

unsigned int FileSize(char *name){
  FILE* f = fopen(name, "rb");
  fseek(f, 0, SEEK_END);
  int size = ftell(f);
  fclose(f);
  return size;
}


unsigned int InsertToFile(String InPath, String OutPath, String arc_name,
String name, FILE** files, int &linfo){
  TFileStream *Stream, *NewStream;
  int i;
  unsigned int size;
  Stream = NULL;
  FILE *f, *file;
  char* buf;

  for(i=1; i<=name.Length(); i++) if(name[i] == '/') name[i] = '\\';
  for(i=1; i<=arc_name.Length(); i++) if(arc_name[i] == '/') arc_name[i] = '\\';

  for(i=0; i<256; i++){
    if(!(int)files[i]){
      if(!DirectoryExists(ExtractFilePath(OutPath + arc_name)))
        ForceDirectories(ExtractFilePath(OutPath + arc_name));
      files[i] = fopen((char*)(OutPath + arc_name).data() , "wb");
      file = files[i];
      names[i] = arc_name;

      if(FileExists(InPath + arc_name)){
        f = fopen((char*)(InPath + arc_name).data(), "rb");
        fseek(f, 0, SEEK_END);
        size = ftell(f);
        fseek(f, 0, SEEK_SET);
        buf = (char*)malloc(size);
        fread(buf, size, 1, f);
        fclose(f);
        fwrite(buf, size, 1, file);
        fseek(file, RoundBy(ftell(file)), SEEK_SET);
      }

      break;
    } else if(names[i] == arc_name) {
      file = files[i];
      break;
    }
  }

  name = InPath + name;
  arc_name = OutPath + arc_name;


  unsigned int position = ftell(file);

  if(linfo && FileExists(InPath + "chains\\" +IntToHex(linfo, 6))){
    f = fopen((char*)(InPath + String("chains\\") + IntToHex(linfo, 6)).data(), "rb");
    fseek(f, 0, SEEK_END);
    size = ftell(f);
    fseek(f, 0, 0);
    buf = (char*)malloc(size);//new char[size];
    fread(buf, size, 1, f);
    fclose(f);
    fwrite(buf, size, 1, file);
    fseek(file, RoundBy(ftell(file)), SEEK_SET);
    linfo = size;
  } else linfo = 0;

  f = fopen((char*)name.data(), "rb");
  fseek(f, 0, SEEK_END);
  size = ftell(f);
  fseek(f, 0, 0);
  buf = (char*)malloc(size);//new char[size];
  fread(buf, size, 1, f);
  fclose(f);

  int nnn = 0;
  fwrite(buf, size, 1, file);
  
  size = ftell(file);
  if(size != RoundBy(size)){
    fseek(file, RoundBy(size) - 1, SEEK_SET);
    fwrite(&nnn, 1, 1, file);
  }
  //fseek(file, RoundBy(ftell(file)), SEEK_SET);
  free(buf);
  return position;
}


int main(int argc, char* argv[])
{
  if(argc<3)return 1;
  if(argv[1][0] != '-') return 1;

  TFileStream *(streams[256]);
  FILE *(files[256]);
  FILEINFO* info;
  char *name, *arc_name;
  int size, offset, i;
  TMemoryStream* exe;
  FILELINK *ptr;
  unsigned int base_offset;
  unsigned int common_size = 0;
  unsigned int cmn_size = 0;
  int _size;

  switch(argv[1][1]){
  case 'e':
    // extract.exe -e DVDDir OutDir
    exe = new TMemoryStream;
    exe->LoadFromFile(String(argv[2]) + "SLPM_650.98");
    memset(streams, 0, sizeof(streams));

    ptr = (FILELINK*)((char*)(exe->Memory) + LIST_OFFSET);

    unsigned int *poffset;

    while(ptr->name){
      name = (ptr->name - (char*)EXE_INC + (char*)(exe->Memory));
      cout << name;
      info = (FILEINFO*)((char*)(exe->Memory) + ptr->info - EXE_INC);
      switch(info->type){
        case ftCD:
          cout << " - file on CD, skipped!" << endl;
          break;
        case ftCont:
          cout << " - container, skipped!" << endl;
          break;
        case ftFile:
          int count;
          int flag;
          cout << " - extracting... ";
          size = info->size;
          offset = info->offset;
          base_offset = offset;

          _size = info->size;
          flag = info->info;
          info->flag = true;
          common_size += info->size;
          info = (FILEINFO*)((int)(exe->Memory) + info->info - EXE_INC);

          count = 0;
          if(info->type == ftFile){
            count++;
            flag = info->flag || !offset ? 0 : flag;
            if(!info->flag)cmn_size += info->size;
            info->flag = true;
            offset += info->offset;
            base_offset = info->offset;

            info = (FILEINFO*)((int)(exe->Memory) + info->info - EXE_INC);
          } else {
            cmn_size += _size;
            flag = 0;
          }
          cout << '[' << count << ']' << endl;
          if(count > 1) system("PAUSE");



          arc_name = (char*)((int)(exe->Memory) + info->name - EXE_INC);
          ExtractFromFile(String(argv[2]), String(argv[3]), String(arc_name), String(name), streams, offset, size, base_offset, flag);
          break;
        default:
          cout << " - unknown type, skipped!" << endl;
      }
      ptr++;
    }

    size = 0;

    info = (FILEINFO*)((char*)(exe->Memory) + INFO_OFFSET);
    while(info->info){
      if(info->type == ftFile && !info->flag){
        size += info->size;
      }
      info++;
    }
    cout << size << endl;

    for(i=0; i<256; i++){
      if(!streams[i])break;
      delete streams[i];
    }
    delete exe;
    cout << common_size << endl << cmn_size << endl;
    system("PAUSE");
  break;
  case 'b':
    // extract.exe -b SLPM_650.98 InDir OutDir
    exe = new TMemoryStream;
    exe->LoadFromFile(argv[2]);
    memset(files, 0, sizeof(files));

    ptr = (FILELINK*)((char*)(exe->Memory) + LIST_OFFSET);


    int cnt = 0;
    info = (FILEINFO*)((char*)(exe->Memory) + INFO_OFFSET);
    while(info->info){
      if(info->type == ftFile && (GetLastInfo(exe->Memory, info)->type != ftCD)){
        info->size = 0;
        info->offset = 0;
        cnt ++;
      }
      info++;
    }

    cout << cnt;

    while(ptr->name){
      name = (ptr->name - (char*)EXE_INC + (char*)(exe->Memory));
      cout << name;
      info = (FILEINFO*)((char*)(exe->Memory) + ptr->info - EXE_INC);
      switch(info->type){
        case ftCD:
          cout << " - file on CD, skipped!" << endl;
          break;
        case ftCont:
          cout << " - container, skipped!" << endl;
          break;
        case ftFile:
          cout << " - inserting..." << endl;
          size = FileSize((char*)String(String(argv[3]) + String(name)).data());
          info->size = size;
          int linfo;
          unsigned int *foffset;
          foffset = &info->offset;
          poffset = &info->offset;
          linfo = info->info;
          info = (FILEINFO*)((int)(exe->Memory) + info->info - EXE_INC);
          if(info->type == ftFile){
            *poffset = RoundBy(info->size);
            poffset = info->offset ? 0 : &info->offset;
            if(info->offset)linfo = 0;
            info->size += RoundBy(size);
            info = (FILEINFO*)((int)(exe->Memory) + info->info - EXE_INC);
          } else linfo = 0;
          arc_name = (char*)((int)(exe->Memory) + info->name - EXE_INC);
          offset = InsertToFile(String(argv[3]), String(argv[4]), String(arc_name), String(name), files, linfo);
          if(poffset)*poffset = offset;
          if(foffset && foffset != poffset && linfo) *foffset += linfo; 
          break;
        default:
          cout << " - unknown type, skipped!" << endl;
      }
      ptr++;
    }

    exe->SaveToFile(String(argv[4])+String("SLPM_650.98"));

    for(i=0; i<256; i++){
      if(!files[i])break;
      fclose(files[i]);
    }
    delete exe;
    system("PAUSE");
  break;

  }
  return 0;
}
//---------------------------------------------------------------------------
 