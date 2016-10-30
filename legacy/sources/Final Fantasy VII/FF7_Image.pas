unit FF7_Image;

interface

uses
  Classes, FF7_Text, FF7_Common, StrUtils,SysUtils,Windows,ComCtrls, FF7_Compression;

Type
  TImageFile = Record
    Folder: String;
    Name: String;
    LBA,Size: Integer;
    LBASize: Byte;
    Sector: Boolean;
    IgnoreSize: Boolean;
    NullSize: Boolean;
  end;
  Type TAF = Record F,N: String; end;
  TImageFiles = Array of TImageFile;
  TFileMap = Record
    Folder: String;
    Name: String;
    Pos:  Pointer;
    Offset:DWord;
    Size: Integer;
    Compressed: Boolean;
    CTag: DWord;
  end;
  TTocFileType = (ftNone, ftNormal, ftStatic);
  TFileMapArr = Array of TFileMap;
  TTocFile = Record
    Folder: String;
    Name:   String;
    Key:    Boolean;
    fType:  TTocFileType;
    kCompr: Boolean;
    LBA:    DWord;
    Size:   DWord;
    RSize:  DWord;
    TreeID: Integer;
  end;
  TTocFiles = Array of TTocFile;
  TSToc = Record
    LBA:        ^DWord;
    Size:       ^DWord;
    Offset:     DWord;
    vLBA,vSize: DWord;
    Folder,Name:String;
    pSetOffset: Boolean;
    pWSetOffset:Boolean;
    vOffset:    DWord;
    vWOffset:   DWord;
    pSetStep:   Boolean;
    vStep:      Integer;
    pIgnoreSize:Boolean;
    pNullSize:  Boolean;
    pLBASize:   Boolean;
    pScrLBA:    Boolean;
    pScrSize:   Boolean;
    vScrLBA:    String;
    vScrSize:   String;
  end;
  TSTocList = Array of TSToc;
  TSTocListArr = Array of TSTocList;
  TTocRec = Class
  private
    KeyLoaded:  Boolean;
    FBuf:       Pointer;
    Map:        TFileMapArr;
    Files:      TTocFiles;
    Tocs:       TSTocListArr;
    SList:      Array of Integer;
    AddedFiles: Array of TAF;
    Function GetFileCount: Integer;
  public
    property  FileList: TTocFiles Read Files;
    property  FileCount: Integer Read GetFileCount;
    Procedure LoadFileList(List: TStringList);
    Procedure LoadFileListFromFile(FileName: String);
    Procedure LoadScript(List: TStringList);
    Procedure LoadScriptFromFile(FileName: String);
    Procedure LoadKeyFiles(Dir: String);
    Procedure FillTree(Tree: TTreeView);
    Function  GetFileIndex(Folder,Name: String): Integer;
    Function  GetFileSizes(Dir: String): String;
    Procedure SetKeyPointers;
  end;


const ImageFolders: Array[0..18] of String = ('SOUND','INIT','MINI','WORLD','BATTLE',
    'STAGE1','STAGE2','ENEMY1','ENEMY2','ENEMY3','ENEMY4','ENEMY5','ENEMY6',
    'MAGIC','MENU','FIELD','STARTUP','MINT','MOVIE');

Procedure LoadImageFiles(FileName: String; var Files: TImageFiles);
Function GetLBAFileList(Buf: Pointer; Count: Integer; Files: TImageFiles; Step: Integer = 8): String;
Function FindImageFolder(S: String): Integer;
Procedure CreateFileList(Files: TImageFiles);
implementation

{Function GetFileSize(S: String): Integer;
var F: File;
begin
  If not FileExists(S) Then
  begin
    Result:=-1;
    Exit;
  end;
  FileMode:=fmOpenRead;
  AssignFile(F,S);
  Try
    Reset(F,1);
    Result:=FileSize(F);
  except
    Result:=-1;
  end;
  CloseFile(F);
  FileMode:=fmOpenReadWrite;
end;}

Function GetFileSize(const FileName: String): Integer;
Var SR: TSearchRec;
begin
 If FindFirst(FileName, faArchive or faSysFile or faReadOnly or faHidden, SR) = 0 then
  Result := SR.Size Else
  Result := -1;
end;

Function TTocRec.GetFileSizes(Dir: String): String;
var n: Integer; S: String; C: String; F: File; Size: Integer;
begin
  Result:='';
  If Dir[Length(Dir)]<>'\' Then Dir:=Format('%s\',[Dir]);
  For n:=0 To High(Files) do
  begin
    If Files[n].Folder='' then C:='' Else C:='\';
    S:=Format('%s%s%s%s',[Dir,Files[n].Folder,C,Files[n].Name]);
    Size:=GetFileSize(S);
    If Size>=0 Then
      Files[n].RSize:=Size
    else
      Result:=Format('%s%s'#13#10,[Result,S]);
  end;
end;

Function TTocRec.GetFileIndex(Folder,Name: String): Integer;
begin
  For Result:=0 To High(Files) do
  If (Folder=Files[Result].Folder) and (Name=Files[Result].Name) Then Break;
  If Result=Length(Files) Then Result:=-1;
end;

Procedure TTocRec.FillTree(Tree: TTreeView);
var n,ID: Integer; Node: TTreeNode; CurDir: String;
begin;
  Tree.Items.Clear;
  For n:=0 To High(Files) do
  begin
    If CurDir<>Files[n].Folder Then
    begin
      If Files[n].Folder<>'' Then
      begin
        CurDir:=Files[n].Folder;
        Node:=Tree.Items.AddNode(nil,nil,CurDir,Pointer(ID),naAddFirst);
        Node.ImageIndex:=1;
        Node.SelectedIndex:=2;
      end;
    end;
    If CurDir='' Then Tree.Items.Add(nil,Files[n].Name)
    else Tree.Items.AddChild(Node,Files[n].Name);
  end;
end;

Function TTocRec.GetFileCount: Integer;
begin
  Result:=Length(Files);
end;

Procedure TTocRec.LoadFileList(List: TStringList);
var n,Count: Integer; S,CurDir: String;
begin
  CurDir:='';
  Count:=0;
  Finalize(Files);
  For n:=0 To List.Count-1 do
  begin
    S:=RemS(List.Strings[n]);
    If (S<>'') then
    begin
      If S[1]='\' Then
      begin
        CurDir:=AdvGetPart(S,['\'],2);
      end else
      begin
        SetLength(Files,Count+1);
        Files[Count].Folder := CurDir;
        Files[Count].Name := S;
        Inc(Count);
      end;
    end;
  end;
end;

Procedure TTocRec.LoadFileListFromFile(FileName: String);
var List: TStringList;
begin
  List:=TStringList.Create;
  List.LoadFromFile(FileName);
  LoadFileList(List);
  List.Free;
end;

Procedure TTocRec.LoadScript(List: TStringList);
Type ScrLoadMode = (slNone,slRead,slNormal,slStatic);
var n,m,ID,FID,Count,FileNum,CurID,CurPos,Step: Integer; Mode: ScrLoadMode; S,L,L2: String;
CurDir: String; Compr: Boolean; Temp: String;
Label NS;
  Function CheckForRetry(F,N: String): Integer;
  begin
    Result:=-1;
    For Result:=0 To Length(AddedFiles)-1 do
    begin
      If (AddedFiles[Result].N=N) and (AddedFiles[Result].F=F) Then Break;
    end;
    If Result>=Length(AddedFiles) Then Result:=-1;
  end;
begin
  FileNum:=-1;
  Finalize(AddedFiles);
  Mode:=slNone; Count:=0;
  For n:=0 To List.Count-1 do
  begin
    S:=GetUpCase(RemS(List.Strings[n]));
    If (Length(S)>2) and (S[1]+S[2]<>'//') Then
    begin
      If S[1]='\' Then CurDir:=AdvGetPart(S,['\'],2)
      else If S='{END}' Then break
      else If S='{BEGIN}' Then Mode:=slRead
      else If S='{NORMAL}' Then Mode:=slNormal
      else If S='{STATIC}' Then Mode:=slStatic else
      begin
        Case Byte(Mode) of
          1: // Read
          begin
            If S[1]='[' Then
            begin
              L:=AdvGetPart(S,['[',','],2);
              If L[Length(L)]='/' Then
              begin
                Compr:=True;
                L:=AdvGetPart(S,['/'],1);
              end else Compr:=False;
              L2:=ExtractFileName(L);
              L:=GetPart2(ExtractFilePath(L),'\',1);
              ID:=GetFileIndex(L,L2);
              FID:=CheckForRetry(L,L2);
              If FID=-1 Then
              begin
                SetLength(Tocs,Length(Tocs)+1);
                FileNum:=High(Tocs);
                SetLength(AddedFiles,Length(AddedFiles)+1);
                AddedFiles[High(AddedFiles)].F:=L;
                AddedFiles[High(AddedFiles)].N:=L2;
              end else
                FileNum:=FID;
              Count:=Length(Tocs[FileNum]);
              Files[ID].Key:=True;
              CurPos:=HexToInt(AdvGetPart(S,[','],3));
              Step:=GetVal(AdvGetPart(S,[',',']'],4));
              If Step=0 Then Step:=8;
            end else
            begin
              For m:=1 To PartCount(S,[' ',#9]) do
              begin
                L:=AdvGetPart(S,[' ',#9],m);
                SetLength(Tocs[FileNum],Count+1);
                Tocs[FileNum,Count].Folder:=CurDir;
                Case L[1] of
                  'A'..'Z': Tocs[FileNum,Count].Name:=L; //Read
                  '-':    //Key
                  begin
                    Case L[2] of
                      'S': Tocs[FileNum,Count].pIgnoreSize:=True;
                      'N': Tocs[FileNum,Count].pNullSize:=True;
                      'L': Tocs[FileNum,Count].pLBASize:=True;
                    end;
                  end;
                  '$':    //SetOffset
                  begin
                    If L[2]<>'$' Then
                    begin
                      Tocs[FileNum,Count].pSetOffset:=True;
                      Tocs[FileNum,Count].vOffset:=GetVal(L);
                    end else
                    begin
                      Tocs[FileNum,Count].pWSetOffset:=True;
                      Tocs[FileNum,Count].vWOffset:=GetVal(LeftStr(L,Length(L)-1));
                    end;
                  end;
                  '%':    //SetSteep
                  begin
                    Tocs[FileNum,Count].pSetStep:=True;
                    Tocs[FileNum,Count].vOffset:=GetVal(AdvGetPart(L,['%'],2));
                  end;
                  '?':    //Command
                  begin
                    If L[2]<>'?' Then
                    begin
                      Tocs[FileNum,Count].pScrLBA:=True;
                      Tocs[FileNum,Count].vScrLBA:=AdvGetPart(L,['?'],2);
                    end else
                    begin
                      Tocs[FileNum,Count].pScrSize:=True;
                      Tocs[FileNum,Count].vScrSize:=AdvGetPart(L,['?'],3);
                    end;
                  end;
                end;
                Inc(Count);
              end;
            end;
          end;
          2: // Normal
          begin
            ID:=GetFileIndex(CurDir,S);
            If ID>=0 Then Files[ID].fType:=ftNormal;
          end;
          3: //Static
          begin
            ID:=GetFileIndex(CurDir,AdvGetPart(S,[' ',#9],2));
            If ID>=0 Then
            begin
              Files[ID].fType:=ftStatic;
              Files[ID].LBA:=GetVal(AdvGetPart(S,[' ',#9],1));
            end;
          end;
        end;
        GoTo NS;
      end;
      If S[1]='{' Then CurDir:='';
      NS:
    end;
  end;
end;

Procedure TTocRec.LoadScriptFromFile(FileName: String);
var List: TStringList;
begin
  List:=TStringList.Create;
  List.LoadFromFile(FileName);
  LoadScript(List);
  List.Free;
end;

Procedure TTocRec.LoadKeyFiles(Dir: String);
var B: ^Byte; n,Size,Count: Integer; CurPos: DWord; S: String; Buf,WBuf: Pointer;
I: ^DWord;
begin
  CurPos:=0; Size:=0; Count:=0;
  If Length(Map)>0 Then FreeMem(FBuf);
  Finalize(Map);
  If Dir[Length(Dir)]<>'\' Then Dir:=Dir+'\';
  For n:=0 To High(Files) do
  begin
    If Files[n].Key Then
    begin
      SetLength(Map,Count+1);
      If Files[n].Folder='' Then S:='' else S:='\';
      Map[Count].Name:=Format('%s%s%s',[Files[n].Folder,S,Files[n].Name]);
      If Map[Count].Compressed Then
      begin
        Size:=LoadFile(Dir+Map[Count].Name,WBuf);
        I:=WBuf; Inc(I); Map[Count].CTag:=I^; Dec(I);
        Map[Count].Size:=GZip_Decompress(I,Buf,Size-8);
        FreeMem(WBuf);
      end else
        Map[Count].Size:=LoadFile(Dir+Map[Count].Name,Buf);
      Map[Count].Offset:=CurPos;
      If Count=0 Then GetMem(FBuf,CurPos+Map[Count].Size)
      else ReallocMem(FBuf,CurPos+Map[Count].Size);
      B:=FBuf; Inc(B,CurPos);
      Move(Buf^,B^,Map[Count].Size);
      Inc(CurPos,Map[Count].Size);
      FreeMem(Buf);
      Inc(Count);
    end;
  end;
  For n:=0 To High(Map) do
  begin
    Map[n].Pos:=Pointer(Integer(FBuf)+Map[n].Offset);
  end;
end;

Procedure TTocRec.SetKeyPointers;
var n,m,l: Integer; Offset: DWord;
  Function FindMapFile(F,N: String): Integer;
  begin
    Result:=-1;
    For Result:=0 To High(Map) do
    begin
      If (Map[Result].Name=N) and (Map[Result].Folder=F) Then Break;
    end;
    If Result>=Length(Map) Then Result:=-1;
  end;
begin
  For n:=0 To High(Tocs) do
  begin
    l:=FindMapFile(AddedFiles[n].F,AddedFiles[n].n);
    Offset:=Map[l].Offset+DWord(FBuf);
    For m:=0 To High(Tocs[n]) do
    begin
      If not Tocs[n,m].pScrLBA then
      begin
      end else
      begin
      end;
      //I
    end;
  end;
end;




Function FindImageFolder(S: String): Integer;
var n: Integer;
begin
  Result:=0;
  For n:=0 To High(ImageFolders) do
  begin
    If ImageFolders[n]=S Then break else Inc(Result);
  end;
  If Result=Length(ImageFolders) Then Result:=-1;
end;

Procedure LoadImageFiles(FileName: String; var Files: TImageFiles);
var List: TStringList; n, Count: Integer; S: String;
begin
  Count:=0;
  List:=TStringList.Create;
  List.LoadFromFile(FileName);
  For n:=0 To List.Count-1 do
  begin
    S:=List.Strings[n];
    If Length(S)>11 Then
    begin
      SetLength(Files,Count+1);
      Files[Count].LBA:=StrToInt(GetPart2(S,' ',1));
      S:=RightStr(S,Length(S)-11);
      Files[Count].Folder:=GetPart2(S,'\',1);
      Files[Count].Name:=GetPart2(S,'\',2);
      If Files[Count].Name='' Then
      begin
        Files[Count].Name:=Files[Count].Folder;
        Files[Count].Folder:='';
      end;
      Inc(Count);
    end;
  end;
  List.Free;
end;

Procedure CreateFileList(Files: TImageFiles);
var CurDir,S: String; n,m,Num,LBA: Integer; List: TStringList; B: Array of Boolean;
begin
  CurDir:='?';
  SetLength(B, Length(Files));
  For n:=0 To High(B) do B[n]:=True;
  List:=TStringList.Create;
  For n:=0 To High(Files) do
  begin
    LBA:=$200000;
    For m:=0 To High(Files) do
    begin
      If B[m] and (Files[m].LBA<LBA) Then
      begin
        LBA:=Files[m].LBA;
        Num:=m;
      end;
    end;  
    B[Num]:=False;
    If CurDir<>Files[Num].Folder Then
    begin
      CurDir:=Files[Num].Folder;
      List.Add(Format('\%s',[CurDir]));
    end;
    List.Add(Format(#9'%s',[Files[Num].Name]));
  end;
  List.SaveToFile('_FF7\_LZ\ToC\FileList.txt');
  List.Free;
end;

Function FindFileLBA(LBA: Integer; Files: TImageFiles): Integer;
var n: Integer;
begin
  Result:=-1;
  For n:=0 To High(Files) do If LBA=Files[n].LBA Then break;
  If n<Length(Files) Then Result:=n;
end;

Function GetLBAFileList(Buf: Pointer; Count: Integer; Files: TImageFiles; Step: Integer = 8): String;
var n,ID: Integer; Ptr: ^Integer; List: TStringList; CurFolder: String;
begin
  If Step<=0 Then Step:=8;
  List:=TStringList.Create;
  Ptr:=Buf;
  For n:=0 To Count-1 do
  begin
    ID:=FindFileLBA(Ptr^,Files);
    If ID>0 Then
    begin
      If CurFolder<>Files[ID].Folder Then
      begin
        List.Add(Format('\%s',[Files[ID].Folder])); 
        CurFolder:=Files[ID].Folder;
      end;
      List.Add(Format('%s%s',[#9,Files[ID].Name]));
    end else List.Add(Format('ERROR!!! ID: %d, LBA: %d',[n,Ptr^]));
    Inc(Ptr); If Ptr^=0 Then List.Strings[List.Count-1]:=List.Strings[List.Count-1]+' -n';
    Inc(Integer(Ptr),Step-4);
  end;
  Result:=List.Text;
  List.Free;
end;

end.
