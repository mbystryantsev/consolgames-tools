unit SH5_PAK;

interface

uses Windows, Dialogs, Classes, SysUtils, StrUtils, SH5_Compression, SH5_Common, AbCabExt;


{const cExestension: Array[0..$2F] of String = (
'000','001','002','cfg','syt','005','cfg','007',
'008','csv','00A','00B','cfg','00D','00E','str',
'ptm','pgp','012','013','014','xml','xml','xml',
'018','019','01A','01B','01C','hka','01E','01F',
'020','021','022','023','024','025','026','ogg',
'028','029','02A','02B','02C','02D','02E','02F');}
const cTempFile = '$TEMP$';

Type
  TNodeType = (ntNone, ntFile, ntFolder, ntPak, ntFileMaket);


  TPakOpenResult = (poOK, poNotPak, poError);
  TCompressionType = (ctNone,ctLZX,ctLZO);
  TPAKFile = Packed Record
    pfName:     Array[0..$3F] of Char;
    Case Byte of
    0:
      (pfFlags:   DWord;
      pfCSize:    DWord;
      pfOffset:   DWord;
      pfPSize:    DWord;
      pfPakID:    Word;
      pfExID:     Word;
      pfSize:     DWord);
    1:
      (pnOffset:  DWord;
       pnSize:    Integer;
       pnFlag:    DWord);
  end;
  PPAKFile = ^TPakFile;

  TPAKHeader = Packed Record
    phSign:     Array[0..3] of Char;
    phVersion:  DWord;
    phFCount:   DWord;
    phReserved: DWord;
  end;
  Type TPakFileArray = Array of TPAKFile;

  TPAKFileInfo = Class;
  TPAK = Class
    Header:     TPAKHeader;
    FFiles:      TPakFileArray;
    Constructor Create;
    Destructor  Destroy;
  private
    FFileName:  String;
    FFile:      File;
    FOpened:    Boolean;
    FBigEndian: Boolean;
    FFileInfo:  TPAKFileInfo;

    Procedure SetInfo(ID: Integer);
    Function GetFileCount: Integer;
    Function GetFileInfo(ID: Integer): TPAKFileInfo;
  public
    Property  FileCount                                         : Integer read GetFileCount;
    Property  Files             [Index: Integer]                : TPAKFileInfo read GetFileInfo;
    Function  FindFile          (Name: String; ExID: Integer)   : Integer;
    Property  BigEndian                                         : Boolean read FBigEndian;
    Function  GetEndianInt      (V: Integer; Sz: Integer = 4)   : Integer;
    Function  GetEndian         (V: DWord)                      : DWord;
    Function  GetEndianW        (V: Word)                       : Word;
    Property  PakFileName                                       : String read FFileName;
    Property  Opened                                            : Boolean Read FOpened;
    Function  Open              (FileName: String)              : TPakOpenResult;
    Procedure Close;
    Procedure ExtractFile       (ID: Integer; FileName: String);
    Function  ExportFileToBuf   (ID:  Integer; var Buf: Pointer): Integer;
    Function  ExtractFileToBuf  (ID: Integer; var Buf: Pointer) : Integer;
    Function  ReplaceFileFromBuf(ID: Integer; var Buf: Pointer; Size: Integer) : Integer;
    Function  ReplaceFile       (ID: Integer; FileName: String) : Integer;
    //Property InPart[Index: Integer]: Boolean read GetAnotherFile;
  end;

                            
  TPAKFileInfo = Class
  private
    FPAK:     TPAK;
    FID:      Integer;
    FPakFile: PPAKFile;
    Procedure SetID(ID: Integer);
    Function  GetCompressed: TCompressionType;
    Function  GetSize:       Integer;
    Function  GetPSize:      Integer;
    Function  GetAnotherPak: Boolean;
    Function  GetPakID:      Integer;
    Function  GetOffset:     DWord;
    Function  GetExID:       Word;
    Function  GetName:       String;
  public
    Property Compressed: TCompressionType read GetCompressed;
    Property Size:       Integer          read GetSize;
    Property PSize:      Integer          read GetPSize;
    Property AnotherPak: Boolean          read GetAnotherPak;
    Property PakID:      Integer          read GetPakID;
    Property Offset:     DWord            read GetOffset;
    Property ExID:       Word             read GetExID;
    Property Ptr:        PPAKFile         read FPakFile;
    Property Name:       String           read GetName;
  end;


  TAssetsHeader = Packed Record
    u1,u2: DWord;
    FoldersCount: Integer;
    FileCount:    Integer;
  end;
  TAssetsFolder = Packed Record
    teg:        DWord;
    Name:       Array[0..$1F] of Char;
    FileCount:  Word;
    RootFolder: Integer;
  end;
  TAssetsFolders = Array of TAssetsFolder;
  TAssetsFileNames = Array of PChar;
  PAssetsFolder = ^TAssetsFolder;

  TAssetsFileNamesHeader = Packed Record
    Teg:  DWord;
    Size: Integer;
  end;

  TAssetsFTypeRecord = Packed Record
    Teg:       Dword;
    Ex:        Array[0..15] of Char;
    Descr:     Array[0..31] of Char;
    AllCount:  Word;
    Count:     Integer;
  end;
  TAssetsFileRecord = Packed Record
    Teg:     DWord;
    NamePos: DWord;
    Teg2:    DWord;
    Folder:  Integer;
  end;
  TAssetsFileRecords = Array of TAssetsFileRecord;
  TAssetsFileList = Packed Record
    Header:      TAssetsFTypeRecord;
    FileRecords: TAssetsFileRecords;
  end;
  TAssetsFileListEx = Array of TAssetsFileList;

  TAssetsFileLink = Record
    PakID:     Integer;
    Num:     Integer;
  end;

  TAssetsFileLinks = Array of TAssetsFileLink;
  TAssetsFileLinkEx = Array of TAssetsFileLinks;

  TAssetsSFProgrProc = Procedure(S: String);

  TPakArray = Array of TPAK;
  TAssets = Class
  destructor destroy;
  private
    FLoaded:        Boolean;
    FFileName:      String;
    FPakCount:      Integer;
    FHeader:        TAssetsHeader;
    FFolders:       TAssetsFolders;
    FFHeader:       TAssetsFileNamesHeader;
    FFileList:      TAssetsFileListEx;
    FFileLinks:     TAssetsFileLinkEx;
    FFolderFlags:   Array of Boolean;
    FBuf:           Pointer;
    FOpened:        Boolean;
    FBigEndian:     Boolean;
    FNamesPos:      Pointer;
    FPaks:          TPakArray;
    Function   GetFolder(ID: Integer): TAssetsFolder;
    Function   GetFolderName(ID: Integer): String;
    Function   GetFoldersCount: Integer;
    Function   GetFolderPointer(ID: Integer): PAssetsFolder;
  public
    FileData   : Array of Pointer;
    FolderData : Array of Pointer;
    Function GetNameFromPos(Pos: DWord): String;
    Procedure LoadFromFile(Name: String);
    Procedure LoadFromBuf(Buf: Pointer);
    Property  Folders      [Index: Integer]: TAssetsFolder read GetFolder;
    Property  FolderNames  [Index: Integer]: String read GetFolderName;
    Property  FileList: TAssetsFileListEx read FFileList;
    Property  FoldersCount: Integer read GetFoldersCount;
    Property  FolderPointers[Index: Integer]: PAssetsFolder read GetFolderPointer;
    Procedure LoadPaks(PakDir: String);
    //Procedure SetFiles(Proc: TAssetsSFProgrProc = nil);
    Property  Loaded: Boolean read FLoaded;
    Property  PakCount: Integer read FPakCount;
    Property  Paks: TPakArray read FPaks;
    Property  FileName: String read FFileName;
    Procedure SetFolder(ID: Integer);
    Function  FindFileInPaks(Name: String; ExID: Integer; var PakID: Integer;
              var FileNum: Integer): Boolean;
    property  FileLink: TAssetsFileLinkEx read FFileLinks;
    Function  GetDirPath(ID: Integer; Level: Integer = 0): String;
    Function  GetFilePath(Ex,ID: Integer): String;
    Function  GetDirLevel(ID: Integer): Integer;
    Procedure ExtractFolder(ID: Integer; Folder: String);
  end;

  TNodeData = Packed Record
    NodeType: TNodeType;
    ID:       Integer;
    ExID:     Integer;
    Case Byte of
      0: ( //Common
        cRoot:         Pointer;
        cData:         Pointer);
      1: ( //ntFile
        fiRoot:       TPAK;
        fiFile:       PPakFile);
      2: ( //ntFolder
        foRoot: TAssets;
        foFolder:     PAssetsFolder);
      3: ( //ntFileMaket
        fmRoot:       TAssets;
        fmList:       ^TAssetsFileList);
      4: ( //ntPak
        pkRoot:       TAssets;
        pkPAK:        TPAK);
    end;

var AbCabExtractor: TAbCabExtractor;
implementation

var CAB: TCAB;

//------------------------------
// A S S E T S
//------------------------------

Destructor TAssets.destroy;
var n: Integer;
begin
  For n:=0 To FPakCount-1 do FPaks[n].Free;
  Finalize(FPaks);
end;

Function TAssets.GetNameFromPos(Pos: DWord): String;
begin
  Try
    Result := PChar(DWord(FNamesPos)+Pos);
  except
    Result := '';
    CreateError(Format('TAssets.GetNameFromPos: Invalid name offset (%.8x)',[Pos]));
  end;
end;

Function   TAssets.GetFolderPointer(ID: Integer): PAssetsFolder;
begin
  If (ID>=0) and (ID<Length(FFolders)) Then
    Result := @FFolders[ID]
  else
    CreateError(Format('TAssets.GetFolderPointer: Folders out of bounds! (%d/%d)',[ID,High(FFolders)]));
end;

Function   TAssets.GetFoldersCount: Integer;
begin
  Result:=Length(FFolders);
end;

Procedure TAssets.LoadPaks(PakDir: String);
var SR: TSearchRec; Created: Boolean; PakList: TStringList; n: Integer;

  Function IsChild(S: String): Boolean;
  var n: Integer;
  begin
    S := RightStr(S,7);
    S := LeftStr(S,3);
    Result := (S[1]='_') and (S[2] in ['0'..'9']) and (S[3] in ['0'..'9']);
  end;

begin
  PakList := TStringList.Create;
  Created := False;
  If FindFirst(PakDir+'\*.PAK',  faAnyFile XOR faDirectory, SR) <> 0 then Exit;
  Repeat
    If not IsChild(SR.Name) Then PakList.Add(SR.Name);
  Until (FindNext(SR) <> 0);

  FPakCount := PakList.Count;
  SetLength(FPaks,FPakCount);
  For n:=0 To PakList.Count -1 do
  begin
    FPaks[n] := TPAK.Create;
    If FPaks[n].Open(Format('%s\%s',[PakDir,PakList.Strings[n]]))<>poOK Then
      CreateError(Format('TAssets.LoadPaks: Pak error! o_O (%s)',[PakList.Strings[n]]));
  end;

  PakList.Free;
end;

Function TAssets.GetFolder(ID: Integer): TAssetsFolder;
begin
  If (ID>=0) and (ID<Length(FFolders)) Then
    Result := FFolders[ID]
  else 
    CreateError(Format('TAssets.GetFolder: Folders out of bounds! (%d/%d)',[ID,High(FFolders)]));

end;

Function TAssets.GetFolderName(ID: Integer): String;
begin
  If (ID>=0) and (ID<Length(FFolders)) Then
    Result:=PChar(@FFolders[ID].Name)
  else
    CreateError(Format('TAssets.GetFolderName: Folders out of bounds! (%d/%d)',[ID,High(FFolders)]));
end;

Procedure TAssets.LoadFromBuf(Buf: Pointer);
var Count: Integer; n: Integer;
begin
  Move(Buf^,FHeader,16);
  SetLength(FFolders,FHeader.FoldersCount);
  SetLength(FFolderFlags,FHeader.FoldersCount);
  Inc(DWord(Buf),16);
  Move(Buf^,FFolders[0],SizeOf(TAssetsFolder)*FHeader.FoldersCount);
  Inc(DWord(Buf),SizeOf(TAssetsFolder)*FHeader.FoldersCount);
  Move(Buf^,FFHeader,SizeOf(TAssetsFileNamesHeader));
  Inc(DWord(Buf),SizeOf(TAssetsFileNamesHeader));
  FNamesPos:=Buf;
  Inc(DWord(Buf),FFHeader.Size);
  Count := 0;
  While True do
  begin
    SetLength(FFileList,Count+1);
    With FFileList[Count] do
    begin
      Move(Buf^,Header, SizeOf(TAssetsFTypeRecord));
      If (Count>0) and (Header.AllCount = 0) Then
      begin
        Header.Count := 0;
        Dec(DWord(Buf),4);
      end;
      If Header.Teg = $A55E1F00 Then
      begin
        SetLength(FFileList,Count);
        break;
      end;

      Inc(DWord(Buf),SizeOf(TAssetsFTypeRecord));
      SetLength(FileRecords,Header.Count);
      Move(Buf^,FileRecords[0],Header.Count*SizeOf(TAssetsFileRecord));
      Inc(DWord(Buf),Header.Count*SizeOf(TAssetsFileRecord));
    end;
    Inc(Count);
  end;
  SetLength(FolderData,Length(FFolders));
  SetLength(FFileLinks,Length(FFileList));
  For n:=0 To High(FFileList) do
  begin
    SetLength(FFileLinks[n],FFileList[n].Header.Count);
    FillChar(FFileLinks[n,0],FFileList[n].Header.Count*SizeOf(TAssetsFileLink),$FF);
  end;
  FFileName := '';
  FLoaded := True;
end;

Procedure TAssets.LoadFromFile(Name: String);
var F: File; Size: Integer;
begin
  AssignFile(F,Name);
  Reset(F,1);
  Size:=FileSize(F);
  ReallocMem(FBuf,Size);
  BlockRead(F,FBuf^,Size);
  CloseFile(F);
  LoadFromBuf(FBuf);
  FFileName:=Name;
end;

Function  TAssets.FindFileInPaks(Name: String; ExID: Integer; var PakID: Integer;
                                 var FileNum: Integer): Boolean;
var n,Num: Integer;
begin
  Result := False;
  If Length(FPAKs)=0 Then Exit;
  If ExID > High(FFileList) Then
  begin
    CreateError(Format('TAssets.FindFileInPaks: Ex. out of bounds! (%d/%d)',[ExID,High(FFileList)]));
    Exit;
  end;
  If PAKID > High(FPAKs) Then
  begin
    CreateError(Format('TAssets.FindFileInPaks: PAKs out of bounds! (%d/%d)',[PAKID,High(FPAKs)]));
    Exit;
  end;
  For n:=0 To FPakCount-1 do
  begin
    Num := FPaks[n].FindFile(Name,ExID);
    If Num>=0 Then
    begin
      PakID   := n;
      FileNum := Num;
      Result  := True;
      Exit;
    end;
  end;
end;

Procedure TAssets.SetFolder(ID: Integer);
var n,m,p,FileNum,PakID: Integer;
begin
  If (ID<0) or (ID>High(FFolderFlags)) Then
  begin
    CreateError(Format('TAssets.SetFolder: FolderFlags out of bounds! (%d/%d)',[ID/High(FFolderFlags)]));
    Exit;
  end;
  If FFolderFlags[ID] Then Exit;
  For m:=0 To High(FFileList) do
  begin
    For n:=0 To FFileList[m].Header.Count-1 do With FFileList[m].FileRecords[n] do
    begin
      If FFileList[m].FileRecords[n].Folder = ID Then
      begin
        If FindFileInPaks(GetNameFromPos(NamePos),m,PakID,FileNum) Then
        begin
          FFileLinks[m,n].PakID := PakID;
          FFileLinks[m,n].Num := FileNum;
          //ShowMessage(Format('ExID: %d; Num: %d; PakID: %d; Num: %d',
          //[m,n,FFileLinks[m,n].PakID,FFileLinks[m,n].Num]));
        end;
      end;
    end;
  end;
  FFolderFlags[ID] := True;
end;

Function TAssets.GetDirLevel(ID: Integer): Integer;
var n: Integer;
begin
  Result := 0;
  If (ID<0) or (ID>High(FFolders)) Then
  begin
    CreateError(Format('TAssets.GetDirLevel: Folders out of bounds! (%d/%d)',[ID/High(FFolders)]));
    Exit;
  end;
  n := ID;
  While n>0 do
  begin
    Inc(Result);
    n      := FFolders[n].RootFolder;
  end;
end;

Function TAssets.GetDirPath(ID: Integer; Level: Integer = 0): String;
var n, Lv: Integer;
begin
  If (ID<0) or (ID>High(FFolders)) Then
  begin
    CreateError(Format('TAssets.GetDirPath: Folders out of bounds! (%d/%d)',[ID/High(FFolders)]));
    Exit;
  end;
  n  := ID;
  Lv := GetDirLevel(ID);
  Result:='';
  While (n>0) and (Lv>=Level) do
  begin
    Dec(Lv);
    Result := Format('%s\%s',[FFolders[n].Name, Result]);
    n      := FFolders[n].RootFolder;
  end;
end;

Function TAssets.GetFilePath(Ex,ID: Integer): String;
begin
  If Ex > High(FFileList) Then
  begin
    CreateError(Format('TAssets.GetFilePath: Ex. out of bounds! (%d/%d)',[Ex,High(FFileList)]));
    Exit;
  end;
  If ID > High(FFileList[Ex].FileRecords) Then
  begin
    CreateError(Format('TAssets.GetFilePath: PAKs out of bounds! (%d/%d)',[ID,High(FFileList[Ex].FileRecords)]));
    Exit;
  end;
  Result := GetDirPath(FFileList[Ex].FileRecords[ID].Folder);
end;

Procedure TAssets.ExtractFolder(ID: Integer; Folder: String);
var n,m: Integer;
begin
  If (ID<0) or (ID>High(FFolders)) Then
  begin
    CreateError(Format('TAssets.ExtractFolder: Folders out of bounds! (%d/%d)',[ID/High(FFolders)]));
    Exit;
  end;
  SetFolder(ID);
  If Folder[Length(Folder)]<>'\' Then Folder := Folder + '\';
  Folder := Folder + FFolders[ID].Name + '\';
  If not DirectoryExists(Folder) Then MakeDirs(Folder);
  For m:=0 To High(FFileLinks) do
  begin
    For n:=0 To High(FFileLinks[m]) do
    begin
      If (FFileList[m].FileRecords[n].Folder = ID) and (FFileLinks[m,n].PakID > -1) Then
      begin
        With FFileLinks[m,n] do With FPAKs[PAKID] do
          ExtractFile(Num,Format('%s\%s%s',
          [Folder,Files[Num].Name,FFileList[Files[Num].ExID].Header.Ex]));
      end;
    end;
  end;
  For n:=0 To High(FFolders) do
    If FFolders[n].RootFolder = ID Then
      ExtractFolder(n,Folder);
end;

//-----------------------------------
//   P A K
//-----------------------------------

Function TPAK.GetFileCount: Integer;
begin
  Result := Length(FFiles);
end;

Constructor TPAK.Create;
begin
  FBigEndian     := True;
  FFileInfo      := TPAKFileInfo.Create;
  FFileInfo.FPAK := Self;
end;

Destructor TPAK.Destroy;
begin
  If FOpened Then CloseFile(FFile);
  FFileInfo.Free;
end;

Function TPAK.Open(FileName: String): TPakOpenResult;
var n: Integer; Buf: Pointer; PFile: ^TPAKFile;
begin
  Result := poError;
  If not FileExists(FileName) Then
  begin
    CreateError(Format('TPAK.Open: File does not exist (%s)',[FileName]));
    Exit;
  end;
  FileMode:=fmOpenRead;
  AssignFile(FFile,FileName);
  FFileName:=FileName;
  FOpened:=True;
  Reset(FFile,1);
  BlockRead(FFile,Header,16);
  If Header.phSign <> 'PAK_' Then
  begin
    Result := poNotPak;
    CreateError(Format('TPAK.Open: File is not PAK (%s)',[FileName]));
    CloseFile(FFile);
    Exit;
  end;
  FBigEndian := Header.phVersion <> 1;
  Seek(FFile,16);

  GetMem(Buf,SizeOf(TPAKFile)*GetEndian(Header.phFCount));
  BlockRead(FFile,Buf^,SizeOf(TPAKFile)*GetEndian(Header.phFCount));
  PFile:=Buf;
  SetLength(FFiles,GetEndian(Header.phFCount));
  //BlockRead(FFile,Files[0],SizeOf(TPAKFile)*GetEndian(Header.phFCount));
  For n:=0 To GetEndian(Header.phFCount)-1 do
  begin
    If (PFile^.pfPakID = $FFFF) or (GetEndianInt(PFile^.pfPakID,2) < $2000) Then
    begin
      Move(PFile^,FFiles[n],SizeOf(TPAKFile));
      Inc(PFile);
    end else
    begin
      Move(PFile^,FFiles[n],$4C);
      Inc(DWord(PFile),$4C);      
    end;
  end;

  //-------------------//
     CloseFile(FFile); //
  //-------------------//
  Result := poOK;
end;

Function TPAK.ReplaceFileFromBuf(ID: Integer; var Buf: Pointer; Size: Integer): Integer;
var WBuf: Pointer; F: File; P: Boolean;
Label bgn;
begin
  Result := -1;
  If (ID<0) or (ID>High(FFiles)) Then
  begin
    CreateError(Format('TPAK.ReplaceFileFromBuf: Files out of bounds! (%d/%d)',[ID,High(FFiles)]));
    Exit;
  end;
  If Size < 0 Then
  begin
    CreateError(Format('TPAK.ReplaceFileFromBuf: Invalid size! (%d)',[Size]));
    Exit;
  end;
  If Size = 0 Then
  begin
    FFiles[ID].pfSize  := 0;
    FFiles[ID].pfPSize := 0;
    FFiles[ID].pfCSize := 0;
    Exit;
  end;
  Case Files[ID].Compressed of
    ctLZX:
    begin
      CreateError('Sorry, but LZX is not yet supported',etNone);
      Exit;
    end;
    ctLZO:  Result := LZO_Compress(Buf,WBuf,Size);
    ctNone:
    begin
      Result := Size;
      WBuf   := Buf;
    end;
  end;

  FFiles[ID].pfSize  := GetEndian(Size);
  FFiles[ID].pfPSize := GetEndian(Result);

  FileMode := fmOpenWrite;
  P := Files[ID].AnotherPak;
  //ShowMessage(Format('%s_%2.2d.PAK',[LeftStr(FFileName,Length(FFileName)-4),FFiles[ID].pfPakID]));
  bgn:
  If P Then
    AssignFile(F, Format('%s_%2.2d.PAK',[LeftStr(FFileName,Length(FFileName)-4),FFiles[ID].pfPakID]))
  else
    AssignFile(F, FFileName);
  Reset(F,1);
  If P and (Files[ID].Offset >= System.FileSize(F)) Then
  begin
    CloseFile(F);
    P := False;
    Goto bgn;
  end;


  //Reset(F,1);
  If Result > RoundBy(Files[ID].PSize, $800) Then
  begin
    Seek(F, RoundBy(FileSize(F), $800));
    FFiles[ID].pfOffset := GetEndian(FilePos(F));
  end else
    Seek(F, Files[ID].Offset);

  BlockWrite(F, WBuf^, Result);
  If P Then
  begin
    CloseFile(F);
    AssignFile(F, FFileName);
    Reset(F,1);
  end;
  Seek(F, 16 + ID * SizeOf(TPAKFile));
  BlockWrite(F, FFiles[ID], SizeOf(TPAKFile));
  CloseFile(F);


  If Files[ID].Compressed <> ctNone Then FreeMem(WBuf);

end;

Function TPAK.ReplaceFile(ID: Integer; FileName: String) : Integer;
var Buf: Pointer;
begin
  If not FileExists(FileName) Then
  begin
    CreateError(Format('TPAK.ReplaceFile: File does not exist (%s)',[FileName]));
    Exit;
  end;
  If (ID<0) or (ID>High(FFiles)) Then
  begin
    CreateError(Format('TPAK.ReplaceFile: Files out of bounds! (%d/%d)',[ID,High(FFiles)]));
    Exit;
  end;
  Result := LoadFile(FileName, Buf);
  Result := ReplaceFileFromBuf(ID, Buf, Result);
  FreeMem(Buf);
end;

Function TPAK.FindFile(Name: String; ExID: Integer): Integer;
var n,m: Integer;
begin                     
  Result:=-1;
  Name := GetUpCase(Name);
  For n:=0 To High(FFiles) do
  begin
    If (ExID = Files[n].ExID) and (GetUpCase(FFiles[n].pfName) = Name) Then
    begin
      Result := n;
      Exit;
    end;
  end;
end;

Function TPAK.ExportFileToBuf(ID:  Integer; var Buf: Pointer): Integer;
var Offset: DWord; F: File; P: Boolean;
Label bgn;
begin
  If (ID<0) or (ID>High(FFiles)) Then
  begin
    CreateError(Format('TPAK.ExportFileToBuf: Files out of bounds! (%d/%d)',[ID,High(FFiles)]));
    Exit;
  end;
  FileMode := fmOpenRead;
  Result:=Files[ID].PSize; //GetEndian(FFiles[ID].pfPSize);
  If Result<0 Then Exit;
  Offset:=Files[ID].Offset; //GetEndian(FFiles[ID].pfOffset);
  GetMem(Buf,Result);
  //-----------------------------//
  Try
    P := Files[ID].AnotherPak;
  bgn:
    If P Then
      AssignFile(F,
        Format('%s_%2.2d.PAK',[LeftStr(FFileName,Length(FFileName)-4),FFiles[ID].pfPakID]))
    else
      AssignFile(F,FFileName); //
      Reset(F,1);              //
    //-----------------------------//
    If P and (Offset >= System.FileSize(F)) Then
    begin
      CloseFile(F);
      P := False;
      Goto bgn;
    end;
    Seek(F,Offset);
    BlockRead(F,Buf^,Result);
    //-----------------------------//
    CloseFile(F);            //
  //-----------------------------//
  except
    Result := -1;
    FreeMem(Buf);
  end;
end;

Function TPAK.ExtractFileToBuf(ID: Integer; var Buf: Pointer): Integer;
var Size: DWord;
begin      
  If (ID<0) or (ID>High(FFiles)) Then
  begin
    CreateError(Format('TPAK.ExtractFileToBuf: Files out of bounds! (%d/%d)',[ID,High(FFiles)]));
    Exit;
  end;
  Size:=ExportFileToBuf(ID,Buf);
  Case Files[ID].Compressed {Compressed[ID]} of
    ctLZX:
    begin
      CAB.ImportFromXCMBuf(Buf,ExtractFileName(cTempFile + '.TMP'),Size);
      CAB.SaveToFile(TempDir + cTempFile);
      AbCabExtractor.OpenArchive(TempDir + cTempFile);
      AbCabExtractor.CabArchive.Load;
      AbCabExtractor.CabArchive.ExtractAt(1,TempDir + cTempFile+'.TMP');
      DeleteFile(TempDir + cTempFile);
      Size := LoadFile(TempDir + cTempFile+'.TMP',Buf);
      DeleteFile(TempDir + cTempFile+'.TMP');
    end;
    ctLZO,ctNone: If Files[ID].Compressed {Compressed[ID]}=ctLZO
                  Then Size:=LZO_Decompress(Buf);
  end;
  Result := Size;
end;

Procedure TPAK.ExtractFile(ID: Integer; FileName: String);
var Buf: Pointer; Size: DWord; F: File;
begin        
  If (ID<0) or (ID>High(FFiles)) Then
  begin
    CreateError(Format('TPAK.ExtractFile: Files out of bounds! (%d/%d)',[ID,High(FFiles)]));
    Exit;
  end;
  If not DirectoryExists(ExtractFilePath(FileName)) Then
  begin
    CreateError(Format('TPAK.ExtractFile: Directory does not exist! (%d)',[ExtractFilePath(FileName)]));
    Exit;
  end;
//  Buf := nil;
  Size:=ExportFileToBuf(ID,Buf);
  If Size<=0 Then Exit;
  Case Files[ID].Compressed {Compressed[ID]} of
    ctLZX:
    begin
      CAB.ImportFromXCMBuf(Buf,ExtractFileName(FileName),Size);
      CAB.SaveToFile(TempDir + cTempFile);
      AbCabExtractor.OpenArchive(TempDir + cTempFile);
      AbCabExtractor.CabArchive.Load;
      AbCabExtractor.CabArchive.ExtractAt(1,FileName);
      DeleteFile(TempDir + cTempFile);
    end;
    ctLZO,ctNone:
    begin
      If Files[ID].Compressed {Compressed[ID]}=ctLZO Then
        Size:=LZO_Decompress(Buf);
      FileMode:=fmOpenWrite;
      AssignFile(F,FileName);
      Rewrite(F,1);
      If Size>0 Then
        BlockWrite(F,Buf^,Size);
      CloseFile(F);
    end;
  end;
  If {Size>0}Buf<>nil Then
    FreeMem(Buf);
end;

Function  TPAK.GetEndian(V: DWord): DWord; //overload;
begin
  Result:=GetEndianInt(V,4);
end;

Function  TPAK.GetEndianW(V: Word): Word; //overload;
begin
  Result:=GetEndianInt(V,2);
end;

Function  TPAK.GetEndianInt(V: Integer; Sz: Integer = 4): Integer;
var B,WB: ^Byte;
begin
  If (Sz>4) or (Sz<1) Then Exit;
  If not FBigEndian Then
  begin
    Result:=V;
    Exit;
  end;
  Result :=0;
  B:=@V; Inc(B,Sz-1);
  WB:=@Result;
  While Sz>0 do
  begin
    WB^:=B^;
    Inc(WB); Dec(B); Dec(Sz);
  end;
end;

Procedure TPAK.Close;
begin
  //If FOpened Then CloseFile(FFile);
  FOpened:=False;
  FillChar(Header,16,0);
  Finalize(FFiles);
  FFileName:='';
end;

Procedure TPAK.SetInfo(ID: Integer);
begin       
  If (ID<0) or (ID>High(FFiles)) Then
  begin
    CreateError(Format('TPAK.SetInfo: Files out of bounds! (%d/%d)',[ID,High(FFiles)]));
    Exit;
  end;
  FFileInfo.FID := ID;
  FFileInfo.FPakFile := @FFiles[ID];
end;

Function TPAK.GetFileInfo(ID: Integer): TPAKFileInfo;
begin    
  If (ID<0) or (ID>High(FFiles)) Then
  begin
    CreateError(Format('TPAK.GetFileInfo: Files out of bounds! (%d/%d)',[ID,High(FFiles)]));
    Exit;
  end;
  FFileInfo.FPakFile := @FFiles[ID];
  FFileInfo.FID      := ID;
  Result := FFileInfo;
end;

//-----------------------------------
//   P A K   F I L E   I N F O
//-----------------------------------

Function TPAKFileInfo.GetPSize: Integer;
begin
  Result := FPAK.GetEndian(FPAKFile.pfPSize);
end;

Function TPAKFileInfo.GetSize: Integer;
begin
  Result := FPAK.GetEndian(FPAKFile.pfSize);
end;

Function TPAKFileInfo.GetCompressed: TCompressionType;
begin
  If Boolean(1 and (FPAK.GetEndian(FPakFile.pfFlags) SHR 14)) Then
    Result:=ctLZX
  else If Boolean(1 and (FPAK.GetEndian(FPakFile.pfFlags) SHR 4)) Then
    Result:=ctLZO
  else
    Result:=ctNone;
end;

Function TPAKFileInfo.GetAnotherPak: Boolean;
begin
  Result := (FPAK.GetEndian(FPAKFile.pfFlags) and $20)>0;
end;

Function TPAKFileInfo.GetPakID: Integer;
begin
  If FPAKFile.pfPakID = $FFFF Then Result := -1
  else Result := FPAK.GetEndianW(FPAKFile.pfPakID);
end;

Function TPAKFileInfo.GetOffset: DWord;
begin
  Result := FPAK.GetEndian(FPAKFile.pfOffset);
end;

Function TPAKFileInfo.GetName: String;
begin
  Result := FPAKFile^.pfName;
end;

Procedure TPAKFileInfo.SetID(ID: Integer);
begin
  //FPAKFile := @FFiles[ID];
end;

Function TPAKFileInfo.GetExID: Word;
begin
  Result := FPAK.GetEndianW(FPAKFile^.pfExID);
end;

Initialization
  CAB:=TCAB.Create;
  AbCabExtractor:=TAbCabExtractor.Create(nil);
Finalization
  CAB.Free;
  AbCabExtractor.Free;
end.
