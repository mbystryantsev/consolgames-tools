unit SH5_Compression;

interface

uses Windows, SysUtils, DLZO, SH5_Common;

Const
  cCABSignature: Array[0..3] of Char = ('M','S','C','F');
  EXTRACT_FILLFILELIST = $00000001;
  EXTRACT_EXTRACTFILES = $00000002;
  MAX_PATH = 256;

Type

  TLZOHeader = Packed Record
    Signature:  Array[0..3] of Char;
    FSize:      DWord;
    PSize:      DWord;
  end;

  {PExtractFileList = ^TExtractFileList;
  TExtractFileList = Packed Record
    filename: PChar;
    next:     PExtractFileList;
    unknown:  Boolean;  // always 1L
  end;
  PFILELIST = ^TFILELIST;
  TFILELIST = Packed Record
    FileName: PChar;
    FILELIST: PFILELIST;
    Extracted:Boolean;
  end;
  TSESSION = Packed Record
     FileSize: Integer;
     ErrorL  : Integer;
     FileList: PFILELIST;
     FileCount: Integer;
     Operation: Integer;
     Destination: Array[0..MAX_PATH-1] of Char;
     CurrentFile: Array[0..MAX_PATH-1] of Char;
     Reserved: Array[0..MAX_PATH-1] of Char;
     FilterList: PFILELIST;
  end;       }



  TCFHEADER = Packed Record
    signature:       Array[0..3] of Char;	// 0x00 cabinet file signature MSCF
    reserved1:       DWord;	              // 0x04 reserved
    cbCabinet:       DWord;	              // 0x08 size of this cabinet file in bytes
    reserved2:       DWord;	              // 0x0C reserved
    coffFiles:       DWord;	              // 0x10 offset of the first CFFILE entry
    reserved3:       DWord;	              // 0x14 reserved
    versionMinor:    Byte;	              // 0x18 cabinet file format version, minor
    versionMajor:    Byte;	              // 0x19 cabinet file format version, major
    cFolders:        Word;	              // 0x1A number of CFFOLDER entries in this cabinet
    cFiles:          Word;	              // 0x1C number of CFFILE entries in this cabinet
    flags:           Word;	              // 0x1E cabinet file option indicators
    setID:           Word;	              // 0x20 must be the same for all cabinets in a set
    iCabinet:        Word;	              // 0x22 number of this cabinet file in a set
    cbCFHeader:      Word; 	              // (optional) size of per-cabinet reserved area
    cbCFFolder:      Byte; 	              // (optional) size of per-folder reserved area
    cbCFData:        Byte; 	              // (optional) size of per-datablock reserved area
    abReserve:       Array of Byte;	      // (optional) per-cabinet reserved area
    szCabinetPrev:   Array of Char;	      // (optional) name of previous cabinet file
    szDiskPrev:      Array of Char;	      // (optional) name of previous disk
    szCabinetNext:   Array of Char;	      // (optional) name of next cabinet file
    szDiskNext:      Array of Char;	      // (optional) name of next disk
  end;
  TCFFOLDER = Packed Record
    coffCabStart:    DWord;	              // 0x24 offset of the first CFDATA block in this folder
    cCFData:         Word;	              // 0x28 number of CFDATA blocks in this folder
    typeCompress:    Word;	              // 0x2A compression type indicator
    abReserve:       Array of Byte;	      // (optional) per-folder reserved area
  end;
  TCFFILE = Packed Record
    cbFile:          DWord;	              // 0x2C uncompressed size of this file in bytes
    uoffFolderStart: DWord;	              // 0x30 uncompressed offset of this file in the folder
    iFolder:         Word;	              // 0x34 index into the CFFOLDER area
    date:            Word;	              // 0x36 date stamp for this file
    time:            Word;	              // 0x38 time stamp for this file
    attribs:         Word;	              // 0x3A attribute flags for this file
    szName:          Array of Char;	      // 0x3C name of this file
  end;
  TCFDATA = Packed Record
    csum:            DWord;	              // checksum of this CFDATA entry
    cbData:          Word;	              // number of compressed bytes in this block
    cbUncomp:        Word;	              // number of uncompressed bytes in this block
    abReserve:       Array of Byte;	      // (optional) per-datablock reserved area
    ab:              Array of Byte;	      // compressed data bytes (ab[cbData])
  end;

  TDLLExtract = Function(dest,szCabName: PChar): DWord; cdecl;
  TCab = Class
    CFHEADER:       TCFHEADER;
    CFFOLDER:       Array of TCFFOLDER;
    CFFILE:         Array of TCFFILE;
    CFDATA:         Array of TCFDATA;
    Destructor      Destroy;
  public
    Function Extract(destFolder,CabFile: String): DWord;
    Procedure ImportFromXCMBuf(P: Pointer; Name: String; Size: Integer);
    Procedure SaveToFile(FileName: String);
    Procedure Init;
  private
   //CabDLLLoaded        : Boolean;
   //CabDLLHandle        : THandle;
   //DLLExtract          : TDLLExtract;
   //Procedure LoadCabinetDLL;
  end;


Function LZO_Decompress(InBuf: Pointer; var OutBuf: Pointer): Integer; overload;
Function LZO_Decompress(var Buf: Pointer): Integer; overload;
Function LZO_Compress(InBuf: Pointer; var OutBuf: Pointer; Size: Integer): Integer; overload;
Function LZO_Compress(var Buf: Pointer; Size: Integer): Integer; overload;
implementation

{procedure TCab.LoadCabinetDLL;
begin
  If CabDLLLoaded Then Exit;
  CabDllHandle := LoadLibrary('cabinet.dll');
  @DLLExtract  := GetProcAddress(CabDllHandle, 'Extract');
  CabDLLLoaded := True;
end;   }

Function LZO_Decompress(InBuf: Pointer; var OutBuf: Pointer): Integer;
var Header: ^TLZOHeader; FSize,PSize: Integer;
begin
  Header:=InBuf;
  FSize:=BigToLittle(Header^.FSize);
  PSize:=BigToLittle(Header^.PSize);
  GetMem(OutBuf,FSize);
  Inc(DWord(InBuf),12);
  Result:=FSize;
  decompress{_safe}(InBuf,PSize,OutBuf,Result);
end;

Function LZO_Decompress(var Buf: Pointer): Integer;
var WBuf: Pointer; FSize: Integer;
begin
  Result:=LZO_Decompress(Buf,WBuf);
  {ReallocMem(Buf,Result);
  Move(WBuf^,Buf^,Result);
  FreeMem(WBuf);          }
  FreeMem(Buf);
  Buf:=WBuf;

end;

Function LZO_Compress(InBuf: Pointer; var OutBuf: Pointer; Size: Integer): Integer; overload;
var Header: ^TLZOHeader;
begin
  Header := OutBuf;
  Header^.Signature := 'LZO';
  Header^.FSize:=BigToLittle(Size);

  GetMem(OutBuf,Size);
  Result:=Size;
  compress{_safe}(InBuf,Size,Pointer(DWord(OutBuf) + 12),Result);
  Header^.PSize:=BigToLittle(Result);
  ReallocMem(OutBuf,Result+12);
end;

Function LZO_Compress(var Buf: Pointer; Size: Integer): Integer; overload;
var WBuf: Pointer;
begin
  Result:=LZO_Compress(Buf,WBuf,Size);
  FreeMem(Buf);
  Buf := WBuf;
end;

Procedure StringToPChar(S: String; var P: PChar);
begin   
  GetMem(P,Length(S)+1);
  FillChar(P^,Length(S)+1,0);
  Move(S[1],P^,Length(S));
end;


Function TCAB.Extract(destFolder,CabFile: String): DWord;
var Name, Folder: String;
begin
  //Init;
  //Folder:=ExtractFilePath(CabFile);
  //Name:=ExtractFileName(CabFile);

end;

Procedure TCAB.SaveToFile(FileName: String);
var F: File; n: Integer;
begin
  FileMode:=fmOpenWrite;
  AssignFile(F,FileName);
  Rewrite(F,1);
  BlockWrite(F,CFHEADER,$24);
  BlockWrite(F,CFFOLDER[0],8);
  BlockWrite(F,CFFILE[0],16);
  BlockWrite(F,CFFILE[0].szName[0],Length(CFFILE[0].szName));
  For n:=0 To High(CFDATA) do With CFDATA[n] do
  begin
    BlockWrite(F,csum,8);
    BlockWrite(F,ab[0],cbData);
  end;
  CloseFile(F);
end;

Procedure TCAB.ImportFromXCMBuf(P: Pointer; Name: String; Size: Integer);
var uSize,pSize,fSize,sSize,sCount: Integer; B: ^Byte; exFlag: Boolean;
begin
  Init;
  sCount:=0;
  sSize:=0;
  exFlag:=False;
  With CFFILE[0] do
  begin
    SetLength(szName,Length(Name)+1);
    szName[High(szName)]:=#0;
    Move(Name[1],szName[0],Length(Name));
  end;
  CFFOLDER[0].coffCabStart := $3D+Length(Name);
  B:=P;
  fSize:=0;
  repeat
    If B^=$FF Then
    begin
      Inc(B);
      uSize:=B^ SHL 8; Inc(B);
      Inc(uSize,B^); Inc(B);
      exFlag:=True;
    end else
      uSize:=$8000;
    pSize:=B^ SHL 8; Inc(B);
    Inc(pSize,B^); Inc(B);


    SetLength(CFDATA,sCount+1);
    With CFDATA[sCount] do
    begin
      csum :=0;
      cbData := pSize;
      cbUncomp := uSize;
      SetLength(ab,pSize);
      Move(B^,ab[0],pSize);
    end;
    Inc(B,pSize);
    Inc(sCount);
    Inc(fSize,uSize);
    Inc(sSize,pSize);
  Until exFlag or (Size<(DWord(B)-DWord(P)+1));
  CFFILE[0].cbFile:=fSize;
  CFFOLDER[0].cCFData := sCount;
  CFHEADER.cbCabinet := sSize+Length(CFDATA)*8+CFFOLDER[0].coffCabStart;
end;

Procedure TCAB.Init;
var DW: ^DWord;
begin
  FillChar(CFHEADER,40,0);
  With CFHEADER do
  begin
    signature := 'MSCF';
    coffFiles :=$2C;
    versionMinor:=3;
    versionMajor:=1;
    cFolders:=1;
    cFiles:=1;
    //SetLength(abReserve,4);
    //DW:=@abReserve[0];
    //DW^:=$10009;
  end;
  SetLength(CFFOLDER,1);
  CFFOLDER[0].cCFData :=1;
  CFFOLDER[0].typeCompress :={1}$1203;
  SetLength(CFFILE,1);
  FillChar(CFFILE[0],16,0);
  With CFFILE[0] do
    attribs:=$20;
end;

Destructor TCAB.Destroy;
var n: Integer;
begin
  For n:=0 To High(CFDATA) do Finalize(CFDATA[n].ab);
  Finalize(CFDATA);
  Finalize(CFFILE);
  Finalize(CFFOLDER);
end;

end.
 