unit SH0_ARC;

interface

uses Classes, SH0_Compression, SysUtils, Zlib;

Type
  TCreateError  = Procedure(S: String);
  TShowProgress = Procedure(Cur,Max: Integer; CurFile: String);

const
  ARC_A20  = 0;
  ARC_SHSM = 1;

Function ARC_Extract(InFile: String; OutDir: String; ListFile: String = ''; ListOnly: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
Function ARC_Build(ListFile,ArcFile: String; InFolders: String; Align: Integer = 2048; Shattered: Boolean = False; const SavePaths: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;  overload;
Function ARC_Build(InFolder: String; SubFolders: Boolean; ArcFile: String;
Compression: Boolean; Align: Integer = 2048; Shattered: Boolean = False; const SavePaths: Boolean = False; Progress: TShowProgress = nil;
CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer; overload;
Function ARC_Build(List: TStringList; ArcFile: String; InFolders: String; Align: Integer = 2048; Shattered: Boolean = False; const SavePaths: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer; overload;
Function ARC_Patch(ListFile, ArcFile, InFolders: String;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
Function CalcHash(S: PChar; Hash: LongWord = 0): LongWord;
implementation

Type
 TStringArray = Array of String;

Procedure SetSlash(var S: String);
begin
  If S = '' Then Exit;
  If S[Length(S)] <> '\' Then S := S + '\';
end;

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

Function GetFileList(Dir: String; List: TStringList; Sub: Boolean; C: Boolean): Integer;
var SR: TSearchRec;
const cCompr: Array[Boolean] of String = (' n', ' p');
begin
  Result := 0;
  If not DirectoryExists(Dir) Then Exit;
  If Dir = '.\' Then Dir := '';
  SetSlash(Dir);
  If FindFirst(Dir + '*', faAnyFile, SR) <> 0 then Exit;
  Repeat
    If (SR.Name = '.') or (SR.Name = '..') Then Continue;
    If SR.Attr = faDirectory Then
    begin
      If Sub Then Inc(Result, GetFileList(Dir + SR.Name, List, True, C));
    end else
    begin
      List.Add(Dir + SR.Name + cCompr[C]);
      Inc(Result);
    end;
  Until (FindNext(SR) <> 0);
  FindClose(SR);
end;

Function OpenArc(const F: File; var Head: THeader; var Name: TStringArray;
CreateError: TCreateError = nil): DWord;
var Buf: Pointer; n: Integer;
begin
  BlockRead(F, Head, 20);
  If Head.Sign = 'A2.0' then
    Result := ARC_A20
  else// If Head.Sign = #$10#$FA#0#0 Then
    Result := ARC_SHSM;
  {
  else
  begin
    If @CreateError<> nil Then CreateError('Invalid ARC header!');
    CloseFile(F);
    Exit;
  end;
  }
  SetLength(Head.FHead, Head.Count);
  Case Result of
    ARC_A20:  Seek(F, 20);
    ARC_SHSM: Seek(F, 16);
  end;
  BlockRead(F, Head.FHead[0], Head.Count * SizeOf(TFileHeader));  
  If Result = ARC_A20 Then
  begin
    GetMem(Buf, Head.NamesSize);
    Seek(F, Head.NamesPos);
    BlockRead(F, Buf^, Head.NamesSize);
  end;
  SetLength(Name, Head.Count);

  For n:=0 to Head.Count-1 do
  begin
    If Result = ARC_A20 Then
    begin
      If Head.FHead[n].NamePos >= Head.NamesSize Then
      begin
        CreateError(Format('SH0_ARC: Access volation on reading name, file #%d',[n]));
        Exit;
      end;
      Name[n] := PChar(DWord(Buf) + Head.FHead[n].NamePos);
    end else
      Name[n] := IntToHex(Head.FHead[n].Hash, 8) + '.BIN';
  end;
  If Result = ARC_A20 Then FreeMem(Buf);
end;

Function ARC_Extract(InFile: String; OutDir: String; ListFile: String = ''; ListOnly: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var F, FW: File; Buf: Pointer; List: TStringList; Fldr: String;
Head: THeader; n: Integer; Name: Array of String;
Size: Integer;
begin
  Result := 0;
  If Not FileExists(InFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exists!',[InFile]));
    Exit;
  end;
  SetSlash(OutDir);
  AssignFile(F, InFile);
  Reset(F,1);

  OpenArc(F, Head, TStringArray(Name), @CreateError);

  List:=TStringList.Create;
  For n:=0 to Head.Count-1 do
  begin
    If @Progress<>nil Then Progress(n, Head.Count, Name[n]);
    If (Cancel<>nil) and Cancel^ Then
    begin
      CloseFile(F);
      List.Free;
      Exit;
    end;
    If Head.FHead[n].FullSize>0 then
      List.Add(Name[n]+' p')
    else
      List.Add(Name[n]+' n');
    If Head.FHead[n].FileSize = 0 Then
    begin
      If @CreateError <> nil Then CreateError('Invalid file size!');
      List.Strings[List.Count - 1] := List.Strings[List.Count - 1] + 'f';
      Continue;
    end;
    If not ListOnly Then
    begin
      Seek(F,Head.FHead[n].FilePos);
      GetMem(Buf, Head.FHead[n].FileSize);
      BlockRead(F, Buf^, Head.FHead[n].FileSize);
      If Head.FHead[n].FullSize>0 then
      begin
        If Word(Buf^) <> $DA78 Then
        begin
          If @CreateError <> nil Then CreateError('Invalid archive header!');
          List.Strings[List.Count - 1] := List.Strings[List.Count - 1] + 'f';
          Continue;
        end;
        Try
          Size:=Z_Decompress(Buf,Head.FHead[n].FileSize)
        except
          If @CreateError<>nil Then CreateError('Can''t decompress file!');
          List.Strings[List.Count - 1] := List.Strings[List.Count - 1] + 'e';
          Continue;
        end;
      end
      else
        Size:=Head.FHead[n].FileSize;

      Fldr := ExtractFilePath(Name[n]);
      If Fldr <> '' Then
        Fldr := OutDir + Fldr
      else
        Fldr := OutDir;

      If not DirectoryExists(Fldr) Then
      begin
        If not ForceDirectories(ExpandFileName(Fldr)) Then
        begin
          If @CreateError<>nil Then CreateError('Can''t create directory: ' + Fldr);
          Continue;
        end;
      end;
      AssignFile(FW, Fldr + ExtractFileName(Name[n]));
      Try
        Rewrite(FW,1);
        BlockWrite(FW,Buf^, Size);
      except
        CreateError(Format('Can''t save file: %s',[Name[n]]));
        CloseFile(FW);
        FreeMem(Buf);
        Exit;
      end;
      CloseFile(FW);
      FreeMem(Buf);
    end;
    Inc(Result);
  end;
  If ListFile = '' Then ListFile := OutDir + 'LIST.LST';
  If ListFile <> '*' Then List.SaveToFile(ListFile);
  CloseFile(F);
  List.Free;
end;

Function ARC_Build(InFolder: String; SubFolders: Boolean; ArcFile: String;
Compression: Boolean; Align: Integer = 2048; Shattered: Boolean = False; const SavePaths: Boolean = False; Progress: TShowProgress = nil;
CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var List: TStringList;
begin
  If Not DirectoryExists(InFolder) Then
  begin
    If @CreateError<>nil Then CreateError(Format('Directory "%s" does not exist!',[InFolder]));
    Result := 1;
    Exit;
  end;
  SetSlash(InFolder);
  List := TStringList.Create;
  GetFileList(InFolder, List, SubFolders, Compression);
  Result := ARC_Build(List, ArcFile, '', Align, Shattered, SavePaths, Progress, CreateError, Cancel);
  List.Free;
end;

Function ARC_Build(ListFile, ArcFile: String; InFolders: String; Align: Integer = 2048; Shattered: Boolean = False; const SavePaths: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var List: TStringList;
begin
  If Not FileExists(ListFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exist!',[ListFile]));
    Result := 1;
    Exit;
  end;
  List:=TStringList.Create;
  List.LoadFromFile(ListFile);
  Result :=
  ARC_Build(List,ArcFile,InFolders+';'+ ExtractFilePath(ListFile), Align, Shattered, SavePaths,Progress,CreateError, Cancel);
  List.Free;
end;


(*
int CalcHash(char *s, int hash = 0){
  int i = 0, v;
  while(v = s[i++]){
    if(v >= 'A' && v <= 'Z') v += 0x20;
    hash = ((hash << 5) + hash) ^ v;
  }
  return hash;
}
}*)
Function CalcHash(S: PChar; Hash: LongWord = 0): LongWord;
var i, v: Integer;
begin
  While True do
  begin
    v := Integer(S^);
    If v = 0 Then break;
    If (v >= Integer('A')) and (v <= Integer('Z')) Then Inc(v, $20);
    Hash := ((Hash SHL 5) + Hash) xor v;
    Inc(S);
  end;
  Result := Hash;
end;

Function GetFileInfo(S: String; out FlagPacked, FlagFake: Boolean): String;
var n: Integer;
begin
  FlagPacked := False;
  FlagFake   := False;
  For n := Length(S) downto 1 do
    If S[n] = ' ' Then
      break;
  If n = 0 Then
  begin
    Result := S;
    Exit;
  end;
  SetLength(Result, n - 1);
  Move(S[1], Result[1], n - 1);
  Inc(n);
  While n <= Length(S) do
  begin
    Case S[n] of
      'p': FlagPacked := True;
      'f','e': FlagFake   := True;
    end;
    Inc(n);
  end;
end;

Function IsHex(S: String; Len: Integer = 0): Boolean;
var n: Integer;
begin
  If Len = 0 Then Len := Length(S);
  For n := 1 To Len do
    If not (S[n] in ['0'..'9', 'a'..'f', 'A'..'F']) Then
      break;
  Result := n > Len;
end;

Function GetNameHash(S: String): LongWord;
var Code: Integer;
begin
  S := ExtractFileName(S);
  If (Length(S) = 12) and (String(PChar(@S[9])) = '.BIN') and IsHex(S, 8) Then
  begin
    SetLength(S, 8);
    Val('$' + S, Result, Code);
  end else
    Result := CalcHash(PChar(S));
end;

Function ARC_Build(List: TStringList; ArcFile: String; InFolders: String; Align: Integer = 2048; Shattered: Boolean = False; const SavePaths: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var Buf: Pointer;
n, m, Size, Pos, NPos: Integer; S: String; F, FW: File; Names: Array of Char;
ErrorCount: Integer; WBuf: Pointer; FSize: Integer; C: Char;
FileName: String; MaxSize: Integer;
Head: THeader; Folders: Array of String;
FlagPacked, FlagFake: Boolean;
Label NN;
begin
  ErrorCount := 0;
  Result := 1;
  MaxSize := 32 * 1024 * 1024;

  AssignFile(FW, ArcFile);
  Rewrite(FW,1);
  If Shattered Then
    Pos := RoundBy(24 + (List.Count * SizeOf(TFileHeader)), Align)
  else
    Pos := RoundBy(20 + (List.Count * SizeOf(TFileHeader)), Align);
  SetLength(Head.FHead, List.Count);
  Head.Count:=List.Count;
  Head.Sign:='A2.0';
  Head.HeadSize:=Pos;
  NPos:=0;

  GetPaths(InFolders, TStringArray(Folders));
  SetLength(Folders,Length(Folders)+1);
  Folders[High(Folders)]:='';
  GetMem(WBuf, MaxSize);
  GetMem(Buf, MaxSize);
  For n:=0 to List.Count-1 do
  begin
    {
    S := List.Strings[n];
    If Length(S) < 3 Then
    begin
      If @CreateError <> nil Then
        CreateError(Format('Invalid input string: "%s"',[S]));
      Inc(ErrorCount);
      Continue;
    end;
    C := S[Length(S)];
    SetLength(S, Length(S) - 2);
    }
    S := GetFileInfo(List.Strings[n], FlagPacked, FlagFake);

    For m:=0 To High(Folders) do
    begin
      If FileExists(Format('%s%s',[Folders[m],S])) Then
      begin
        FileName:=Format('%s%s',[Folders[m],S]);
        break;
      end;
    end;
    If m<=Length(Folders) then
    begin
      If @Progress<>nil Then Progress(n, List.Count, S);
      If (Cancel<>nil) and Cancel^ Then
      begin
        CloseFile(FW);
        Result := 0;
        Exit;
      end;
      Head.FHead[n].FilePos:=Pos;
      If not SavePaths or (ExtractFilePath(S) = '.\') Then
        S:=ExtractFileName(S);
      If Shattered Then
        Head.FHead[n].Hash := GetNameHash(S)
      else
      begin
        Head.FHead[n].NamePos:=NPos;
        Inc(NPos, Length(S)+1);
        SetLength(Names, NPos);
        Move(S[1],Names[NPos - Length(S) - 1], Length(S));
        Names[NPos-1]:=#0;
      end;
      If FlagFake Then Continue;
      Assign(F, FileName);
      Reset(F,1);
      FSize := FileSize(F);
      If FSize > MaxSize Then
      begin
        MaxSize := FSize;
        ReallocMem(WBuf, FSize);
        ReallocMem(Buf, FSize);
      end;
      //GetMem(Buf, FSize);
      BlockRead(F, Buf^, FSize);
      Close(F);   
      Seek(FW, Pos);
      //If n=0 Then GetMem(WBuf,FSize) else ReallocMem(WBuf,FSize);
      Move(Buf^,WBuf^,FSize);
      //If C='p' then
      If FlagPacked Then
      begin
        //Size:=Z_Compress(Buf, FSize);
        CompressToUserBuf(Buf, FSize, WBuf, MaxSize, Size);
        If Size >= FSize Then GoTo NN;
        Head.FHead[n].FileSize := Size;
        Head.FHead[n].FullSize := FSize;
        BlockWrite(FW, WBuf^, Size);
      end else
      begin
        NN:
        BlockWrite(FW, Buf^, FSize);
        Head.FHead[n].FileSize := FSize;
        Head.FHead[n].FullSize:=0;
      end;
      //FreeMem(Buf);
      Pos:=RoundBy(Pos + Size, Align)
    end else
    begin
      If @CreateError <> nil Then
        CreateError(Format('File "%s" not found!',[S]));
      Inc(ErrorCount);
    end;
  end;
  FreeMem(Buf);
  FreeMem(WBuf);

  Seek(FW, 0);
  If Shattered Then
  begin
    Head.Sign := #$10#$FA#0#0;
    Head.NamesPos := 0;
    BlockWrite(FW, Head, 16);
  end else
  begin
    Head.NamesPos:=Pos;
    Head.NamesSize:=Length(Names);
    BlockWrite(FW, Head, 20);
  end;
  //BlockWrite(FW, Head.FHead[0], Head.HeadSize-20);
  BlockWrite(FW, Head.FHead[0], Head.Count * SizeOf(TFileHeader));
  If Shattered Then
  begin
    n := $340178;
    BlockWrite(FW, n, 4);
    BlockWrite(FW, n, 4);
  end else
  begin
    Seek(FW, Pos);
    BlockWrite(FW, Names[0], Length(Names));
  end;
  If FileSize(FW) mod Align <> 0 Then
  begin
    n := 0;
    Seek(FW, RoundBy(FileSize(FW), Align) - 1);
    BlockWrite(FW, n, 1);
  end;
  CloseFile(FW);
  Result := ErrorCount;
  //WriteLn(Format('Completed! Errors: %d',[ErrorCount]));
end;

Function ARC_Patch(ListFile, ArcFile, InFolders: String;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var F, FW: File; Buf: Pointer; List: TStringList;
n,m,Pos: Integer; Name, Folders: Array of String;
Size: Integer; {P: Boolean; }S, FileName: String; Head: THeader; 
begin
  If Not FileExists(ArcFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exist!',[ArcFile]));
    Result := 1;
    Exit;
  end;
  If Not FileExists(ArcFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exist!',[ListFile]));
    Result := 1;
    Exit;
  end;
  Result := 0;
  If GetPaths(InFolders, TStringArray(Folders)) = 0 Then Exit;
  SetLength(Folders,Length(Folders)+1);

  AssignFile(F, ArcFile);
  Reset(F,1);

  OpenArc(F, Head, TStringArray(Name));

  List:=TStringList.Create;
  List.LoadFromFile(ListFile);
  For n:=0 To List.Count-1 do
  begin
    S:=List.Strings[n];
    If (Length(S)>2) and (S[Length(S)-1]=' ') Then
      SetLength(S,Length(S)-2)
    else
    begin
      CreateError(Format('Invalid input line: %s',[S]));
      Continue;
    end;
    For m:=0 To High(Folders) do
    begin
      If FileExists(Format('%s%s',[Folders[m],S])) Then
      begin
        FileName:=Format('%s%s',[Folders[m],S]);
        break;
      end;
    end;
    If m<Length(Folders) Then
    begin
      For m:=0 To Head.Count -1 do If Name[m]=S Then break;
      If m<Head.Count Then
      begin
        If @Progress <> nil Then Progress(n, List.Count, Name[m]);
        If (Cancel<>nil) and Cancel^ Then
        begin 
          CloseFile(F);
          Exit;
        end;
        AssignFile(FW,FileName);
        Reset(FW,1);
        Size:=FileSize(FW);
        GetMem(Buf,Size);
        BlockRead(FW,Buf^,Size);
        CloseFile(FW);
        Size:=Z_Compress(Buf, Size);
        If Size<=RoundBy(Head.FHead[m].FileSize,16) Then
          Pos:=Head.FHead[m].FilePos
        else
          Pos:=RoundBy(FileSize(F),16);
        With Head.FHead[m] do
        begin
          FilePos := Pos;
          FileSize:= Size;
          Seek(F,FilePos);
        end;
        BlockWrite(F,Buf^,Size);
        FreeMem(Buf);
      end;
    end;
  end;
  Seek(F,20);
  BlockWrite(F,Head.FHead[0],Head.Count*SizeOf(TFileHeader));
  CloseFile(F);
end;    

end.
