unit SH2_ARC;

interface

uses SysUtils, Classes;

Type
  DWord = LongWord;

  TFileType = (
    ftCD = $03,
    ftFile = $50,
    ftCont = $23,
    ftDWord = $FFFF
  );

  TFileInfo = Packed Record
    fType: TFileType;
    fFlag: Word;
    Case TFileType of
      ftCD, ftCont:
      (
        Name: DWord;
      );
    ftFile:
      (
        Next:   DWord;
        Offset: DWord;
        Size:   DWord;
      );
  end;
  PFileInfo = ^TFileInfo;

  TFileLink = Packed Record
    Info: DWord;
    Name: DWord;
  end;
  PFileLink = ^TFileLink;

  TProgFunc = Function(Cur, Max: Integer; S: String): Boolean;

const
  EXE_INC = $FF800;
  EXE_NAME = 'SLPM_650.98';
  LIST_OFFSET = $2CCB80;
  INFO_OFFSET = $2D4580;

Procedure SH2_Build(ExeName, SrcDirs, DestDir: String; Progress: TProgFunc = nil);
implementation

Type
  TStringArray = Array of String;

Function NextInfo(const Memory: Pointer; const Info: PFileInfo): PFileInfo;
begin
  Result := Pointer(DWord(Memory) + Info^.Next - EXE_INC);
end;

Function GetPointer(const Memory: Pointer; const Offset: DWord): Pointer;
begin
  Result := Pointer(DWord(Memory) + Offset - EXE_INC);
end;

Procedure ReplaceTokes(var S: String);
var n: Integer;
begin
  For n := 1 To Length(S) do
    If S[n] = '/' Then
      S[n] := '\';
end;

Procedure SetSlash(var S: String);
begin
  If S='' Then Exit;
  If S[Length(S)] <> '\' Then S := S + '\';
end;

Function RoundBy(V: DWord; N: DWord = 2048): DWord;
begin
  If N = 0 Then
  begin
    Result := 0;
    Exit;
  end;
  if (V mod N) <> 0 Then
    Result :=  (V div N) * N + N
  else
    Result := V;
end;


(*
Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;     *)

Function GetPaths(S: String; var P: TStringArray): Integer;
var i, Count: Integer; Flag: Boolean;
begin
  Count := 0;
  Flag  := False;
  For i := 1 To Length(S) do If S[i] = ';' Then S[i] := #0;
  For i := 1 To Length(S) do
  begin
    If (S[i] <> #0) and not Flag Then
    begin
     Flag := True;
     If not DirectoryExists(PChar(@S[i])) Then Continue;
     Inc(Count);
     SetLength(P, Count);
     P[Count - 1] := PChar(@S[i]);
     SetSlash(P[Count - 1]);
    end else If S[i] = #0 Then
     Flag    := False;
  end;
  Result := Count;
end;


Function GetSrcDir(const Dirs: TStringArray; const FileName: String): String;
var n: Integer;
begin
  For n := Low(Dirs) To High(Dirs) do
    If FileExists(Dirs[n] + FileName) Then
      break;
  Result := Dirs[n];
end;

var
  _FileName: String = '';
  _F: File;
  _Buf: Pointer;
  _Files: Array of String;
const
  cBufSize = 64 * 1024 * 1024;

Procedure AddFile(const S: String);
begin
  SetLength(_Files, Length(_Files) + 1);
  _Files[High(_Files)] := S;
end;
  
Function FileEx(const S: String): Boolean;
var n: Integer;
begin
  Result := True;
  For n := Low(_Files) To High(_Files) do
    If _Files[n] = S Then
      Exit;
  Result := False;
end;


Function Min(const A, B: Integer): DWord;
begin
  If A > B Then
    Result := B
  else
    Result := A;
end;

Procedure FileToFile(var DestFile: File; FileName: String);
var F: File; Size, Readed: Integer;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  Size := FileSize(F);
  //GetMem(Buf, Min(Size, cBufSize));
  while Size > 0 do
  begin
    BlockRead(F, _Buf^, Min(Size, cBufSize), Readed);
    BlockWrite(DestFile, _Buf^, Readed);
    Dec(Size, Readed);
  end;
  //FreeMem(Buf);
  CloseFile(F);
end;


Function InsertFile(Dirs: TStringArray; DestDir, Name, ArcName: String; var Size: DWord): DWord;
var Stream: TMemoryStream; SrcDir: String;
begin
  ReplaceTokes(Name);
  ReplaceTokes(ArcName);
  SrcDir := GetSrcDir(Dirs, Name);
  If ArcName <> _FileName Then
  begin
    If _FileName <> '' Then CloseFile(_F);
    _FileName := ArcName;
    If not DirectoryExists(ExtractFilePath(DestDir + _FileName)) Then
      ForceDirectories(ExtractFilePath(DestDir + _FileName));
    AssignFile(_F, DestDir + _FileName);
    If FileEx(_FileName) Then
    begin
      Reset(_F, 1);
      Seek(_F, RoundBy(FileSize(_F)));
    end else
    begin
      Rewrite(_F, 1);
      AddFile(_FileName);
    end;
  end;

  Result := FilePos(_F);

  FileToFile(_F, SrcDir + Name);

  //Stream := TMemoryStream.Create;
  //Stream.LoadFromFile(SrcDir + Name);
  //Size := Stream.Size;
  //BlockWrite(_F, Stream.Memory^, Size);
  Seek(_F, RoundBy(FilePos(_F)));
  //Stream.Free;                  
end;

Type
  TLinkArray = Array of PFileLink;

Function FindFileLink(const Memory: Pointer; Offset: DWord): PFileLink;
var n: Integer; Data: PFileLink;
begin
  Result := nil;
  Data := Pointer(DWord(Memory) + LIST_OFFSET);
  While DWord(Pointer(Data)^) <> 0 do
  begin
    If Data^.Info = Offset Then
    begin
      Result := Data;
      Exit;
    end;
    Inc(Data);
  end;
end;

Procedure GetSortedList(const Memory: Pointer; var List: TLinkArray);
var Count: Integer; Info: PFileInfo; Data: PFileLink;
begin
  Count := 0;
  SetLength(List, 0);
  
  Info := Pointer(DWord(Memory) + INFO_OFFSET);
  While DWord(Pointer(Info)^) <> 0 do
  begin
    If Info^.fType = ftFile Then
    begin
      Data := FindFileLink(Memory, DWord(Info) - DWord(Memory) + EXE_INC);
      If Data <> nil Then
      begin
        //WriteLn(PChar(GetPointer(Memory, Data^.Name)));
        SetLength(List, Count + 1);
        List[Count] := Data;
        Inc(Count);
      end;
    end;
    Inc(Info);
  end;

  //WriteLn(Count);
  //ReadLn;

end;

Type

  //TFileRecordArray = Array of TFileRecord;
  TBlockRecord = Record
    BlockInfo:   PFileInfo;
    //FileInfo: PFileInfo;
    FileInfo:    Array of PFileInfo;
    Defined:    Boolean;
  end;
  TBlockArray = Array of TBlockRecord;

Function GetFileSize(FileName: String): Integer;
var F: File;
begin
  {
  If not FileExists(FileName) Then
  begin
    Result := -1;
    Exit;
  end;
  }
  Try
    Assign(F, FileName);
    Reset(F, 1);
  except
    WriteLn('*** File not found - ' + FileName);
  end;
  Result := FileSize(F);
  CloseFile(F);
end;

Function GetBlockIndex(const BlockList: TBlockArray; Info: PFileInfo): Integer;
begin
  For Result := 0 To High(BlockList) do
    If BlockList[Result].BlockInfo = Info Then
      Exit;
  Result := -1;
end;

Procedure AddFileToBlockList(var BlockList: TBlockArray; Info, Next: PFileInfo; SrcDir, Name: String);
var Index, Count: Integer;
begin
  Index := GetBlockIndex(BlockList, Next);
  If (Index < 0) Then
  begin
    Index := Length(BlockList);
    SetLength(BlockList, Index + 1);
    BlockList[Index].BlockInfo := Next;
  end;
  Count := Length(BlockList[Index].FileInfo);
  SetLength(BlockList[Index].FileInfo, Count + 1);
  BlockList[Index].FileInfo[Count] := Info;
  //BlockList[Index].Files[Count].Name := Name;
  Info^.Offset := RoundBy(Next^.Size);
  Info^.Size := GetFileSize(SrcDir + Name);
  Inc(Next^.Size, RoundBy(Info^.Size));
end;

Procedure InsertFileFromBlock(var BlockList: TBlockArray; Info, Next: PFileInfo; Dirs: TStringArray; DestDir, Name, ArcName: String);
var Index, Num: Integer; Offset,Size: DWord; BlockInfo: PFileInfo;
begin
  ReplaceTokes(ArcName);
  Index := GetBlockIndex(BlockList, Next);
  For Num := 0 To High(BlockList[Index].FileInfo) do
    If BlockList[Index].FileInfo[Num] = Info Then
      Break;
  //Info^.Offset := BlockList[Index].Files[Num].Info^.Offset;
  //Info^.Size   := BlockList[Index].Files[Num].Info^.Size;

  If _FileName <> ArcName Then
  begin
    If _FileName <> '' Then
      CloseFile(_F);
    _FileName := ArcName;
    AssignFile(_F, DestDir + _FileName);
    If FileEx(_FileName) Then
    begin
      Reset(_F, 1);
      Seek(_F, RoundBy(FileSize(_F)));
    end else
    begin
      Rewrite(_F, 1);
      AddFile(_FileName);
    end;
  end;
  //If Next^.Offset = 0 Then
  If not BlockList[Index].Defined Then
  begin
    BlockList[Index].Defined := True;
    Offset := InsertFile(Dirs, DestDir, Name, ArcName, Size);
    Next^.Offset := Offset;
    //BlockList[Index].Info^.Offset := Offset;
    //BlockList[Index].Info^.Size   := BlockList[Index].Size;
    Seek(_F, RoundBy(Offset + Next^.Size));
  end else
  begin
    Offset := FilePos(_F);
    //Seek(_F, Next^.Offset + Info^.Offset);
    Seek(_F, Next^.Offset + Info^.Offset);
    InsertFile(Dirs, DestDir, Name, ArcName, Size);
    Seek(_F, Offset);
  end;
end;

var
  null: DWord = 0;
Procedure SH2_Build(ExeName, SrcDirs, DestDir: String; Progress: TProgFunc = nil);
var Name: String; Exe: TMemoryStream; Info, Next: PFileInfo; Data: PFileLink;
Size, Offset: DWord; n, Count: Integer;  List: TLinkArray; BlockList: TBlockArray;
SrcDir: String; Dirs: TStringArray;
begin
  _FileName := '';
  Exe := TMemoryStream.Create;
  Exe.LoadFromFile(ExeName);
  //Exe.Seek(0, 0);
  Count := 0;
  GetPaths(SrcDirs, Dirs);

  GetSortedList(Exe.Memory, List);
  Count := Length(List);

  Info := Pointer(DWord(Exe.Memory) + INFO_OFFSET);
  While DWord(Pointer(Info)^) <> 0 do
  begin
    If (Info^.fType = ftFile) and (NextInfo(Exe.Memory, Info)^.fType <> ftCD) Then
    begin
      Info^.Offset := 0;
      Info^.Size   := 0;
    end;
    Inc(Info);
  end;        

  If @Progress <> nil Then
    Progress(0, 0, 'Creating file structure map...');

  GetMem(_Buf, cBufSize);
  For n := 0 To Count - 1 do
  begin
    Data := List[n];
    Name := PChar(GetPointer(exe.Memory, Data^.Name));
    Info := GetPointer(exe.Memory, Data^.Info);
    If Info^.fType = ftFile Then
    begin
      Next := NextInfo(Exe.Memory, Info);
      If Next^.fType = ftFile Then
      begin
        //WriteLn(Name);
        //If String(PChar(GetPointer(Exe.Memory, PFileInfo(GetPointer(Exe.Memory, Next^.Next))^.Name))) = 'data/bg2.mgf' Then ReadLn;
        ReplaceTokes(Name);
        SrcDir := GetSrcDir(Dirs, Name);
        AddFileToBlockList(BlockList, Info, Next, SrcDir, Name);
      end;
    end;
  end;

  //Data := Pointer(DWord(Exe.Memory) + LIST_OFFSET);
  For n := 0 To Count - 1 do
  begin
    Data := List[n];
    Name := PChar(GetPointer(exe.Memory, Data^.Name));
    Info := GetPointer(exe.Memory, Data^.Info);
    If @Progress <> nil Then
    begin
      If Progress(n, Count, Name) Then
        Break;
    end;
    //WriteLn(Name);              
    If Info^.fType = ftFile Then
    begin
      //ReplaceTokes(Name);
      Next := NextInfo(Exe.Memory, Info);
      If Next^.fType = ftCont Then
      begin
        Info^.Offset := InsertFile(Dirs{SrcDir}, DestDir, Name, PChar(GetPointer(exe.Memory, Next^.Name)), Info^.Size);
      end else
      begin
        InsertFileFromBlock(BlockList, Info, Next, Dirs{SrcDir}, DestDir, Name, PChar(GetPointer(exe.Memory, NextInfo(exe.Memory, Next)^.Name)));
        //Info^.Offset := RoundBy(Next^.Size);
        //Offset := InsertFile(SrcDir, DestDir, Name, PChar(GetPointer(exe.Memory, NextInfo(exe.Memory, Next)^.Name)), Size);
        //Info^.Size := Size;
        //If Next^.Offset = 0 Then
        //  Next^.Offset := Offset;
        //Inc(Next^.Size, RoundBy(Size));     
      end;
    end;
  end;
  Exe.SaveToFile(DestDir + EXE_NAME);  
  Exe.Free;
  If FileSize(_F) <> RoundBy(FileSize(_F)) Then
  begin
    Seek(_F, FilePos(_F) - 1);
    BlockWrite(_F, null, 1);
  end;
  CloseFile(_F);
  FreeMem(_Buf);
  _FileName := '';
end;

end.
