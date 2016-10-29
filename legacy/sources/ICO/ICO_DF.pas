unit ICO_DF;

interface

uses Classes, SysUtils, Compression;

Type
  TCreateError  = Procedure(S: String);
  TShowProgress = Procedure(Cur,Max: Integer; CurFile: String);

Function DFDATAS_Extract(inFile, OutDir, ListFile: String; Progress: TShowProgress = nil;
CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
Function DFDATAS_Build(InFolder, ArcFile: String; SubFolders: Boolean;
const SavePaths: Boolean = False; Progress: TShowProgress = nil;
CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer; overload;
Function DFDATAS_Build(ListFile, OutFile: String; InFolders: String; const SavePaths: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer; overload;
Function DFDATAS_Build(List: TStringList; OutFile, InFolders: String;
SavePaths: Boolean = False; Progress: TShowProgress = nil;
CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer; overload;

Function DF_Extract(iFile,oFolder: String; Rewrite: Boolean = False; H: Pointer = NIL;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer; 
Procedure DF_ExtractAll(InDir, OutDir: String; HDSFile: String = '';
Progress: TShowProgress = nil; CreateError: TCreateError = nil;
Cancel: PBoolean = nil; FileCount: Integer = -1);
Function DF_Build(HFile, oFile: String; InFolders: String; Compression: Boolean = True;
                   Progress: TShowProgress = nil; CreateError: TCreateError = nil;
                   Cancel: PBoolean = nil): Integer; overload;
Function DF_Build(H: Pointer; oFile: String; InFolders: String; Compression: Boolean = True;
                   Progress: TShowProgress = nil; CreateError: TCreateError = nil;
                   Cancel: PBoolean = nil): Integer; overload;
Function DF_BuildAll(HDSFile, OutDir, InFolders: String; Compression: Boolean = True;
                     Progress: TShowProgress = nil; CreateError: TCreateError = nil;
                     Cancel: PBoolean = nil): Integer;
implementation

Type
  DWord = LongWord;
  TFileHeader = Packed Record
    Name: Array[0..$1F] of Char;
    FilePos: DWord;
    FileSize: DWord;
  end;

  THeader = Packed Record
    Count: DWord;
    FHead: Array of TFileHeader;
  end;
  TStringArray = Array of String;

Procedure SetSlash(var S: String);
begin
  If S='' Then Exit;
  If S[Length(S)] <> '\' Then S := S + '\';
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
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


Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer; CreateError: TCreateError = nil);
var F: File;
begin
  FileMode := fmOpenWrite;
  {Name := ExpandFileName(Name);
  If not DirectoryExists(Name) Then
    ForceDirectories(ExtractFilePath(Name));}

  AssignFile(F,Name); 
  Rewrite(F,1);
  {$I-}
  BlockWrite(F, Pos^, Size);
  {$I+}
  
  If IOResult<>0 Then
  begin
    If @CreateError<>nil Then CreateError(Format('I/O Error! IOResult = %d, File %s',
        [IOResult,Name]));
    CloseFile(F);
    Exit;
  end;
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Function LoadFile(Name: String; var Pos: Pointer): Integer;
var F: File;
begin
  FileMode := fmOpenRead;
  Result:=-1;
  If not FileExists(Name) Then Exit;
  AssignFile(F,Name);
  Reset(F,1);
  Result:=FileSize(F);
  GetMem(Pos, Result);
  BlockRead(F, Pos^, Result);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Function GetFileList(Dir: String; List: TStringList; Sub: Boolean; MaxLen: Integer = 0;
CreateError: TCreateError = nil): Integer;
var SR: TSearchRec;
begin
  Result := 0;
  If (Dir<>'') and not DirectoryExists(Dir) Then
  begin
    If @CreateError <> nil Then CreateError(Format('Directory %s does not exist!', [Dir]));
    Exit;
  end;
  SetSlash(Dir);
  If FindFirst(Dir + '*', faAnyFile, SR) <> 0 then Exit;
  Repeat
    If (SR.Name = '.') or (SR.Name = '..') Then Continue;
    If SR.Attr = faDirectory Then
    begin
      If Sub Then Inc(Result, GetFileList(Dir + SR.Name, List, True, MaxLen, @CreateError));
    end else
    begin
      If (MaxLen>0) and (Length(SR.Name) > MaxLen) Then
      begin
        If @CreateError<>nil Then CreateError(Format('Too long file name (%s)',[SR.Name]));
        Continue;
      end;
      List.Add(Dir + SR.Name);
      Inc(Result);
    end;
  Until (FindNext(SR) <> 0);
  FindClose(SR);
end;

Function DFDATAS_Extract(inFile, OutDir, ListFile: String; Progress: TShowProgress = nil;
CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var Head: THeader; F,WF: File; n: Integer; Buf: Pointer; S: PChar; List: TStringList;
begin
  Result := 0;
  If Not FileExists(InFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exists!',[InFile]));
    Exit;
  end;
  SetSlash(OutDir);
  Buf := nil;
  List:=TStringList.Create;
  FileMode:=fmOpenRead;
  AssignFile(F,inFile);
  Reset(F,1);
  BlockRead(F,Head.Count,4);
  SetLength(Head.FHead,Head.Count);
  Seek(F,4);
  BlockRead(F,Head.FHead[0],Head.Count*$28);
  FileMode:=fmOpenWrite;
  For n:=0 To Head.Count-1 do
  begin
    With Head.FHead[n] do
    begin
      S:=Addr(Name);
      List.Add(S);
      If @Progress<>nil Then Progress(n, Head.Count, S);
      If (Cancel<>nil) and Cancel^ Then
      begin
        CloseFile(F);
        List.Free;
        If Buf<>nil Then FreeMem(Buf);
        Exit;
      end;
      Seek(F,FilePos);
      ReallocMem(Buf,FileSize);
      BlockRead(F,Buf^,FileSize);
      If not DirectoryExists(OutDir + ExtractFilePath(S)) Then
        ForceDirectories(OutDir + ExtractFilePath(S));
      AssignFile(WF,OutDir + S);
      Rewrite(WF,1);
      Seek(WF,0);
      BlockWrite(WF,Buf^,FileSize);
      CloseFile(WF);
    end;
    Inc(Result);
  end;
  If ListFile = ''   Then ListFile := OutDir + 'LIST.LST';
  If ListFile <> '*' Then List.SaveToFile(ListFile);
  CloseFile(F);
  FreeMem(Buf);
end;

Function DFDATAS_Build(InFolder, ArcFile: String; SubFolders: Boolean; 
const SavePaths: Boolean = False; Progress: TShowProgress = nil;
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
  If (InFolder = '.\') Then InFolder := '';
  List := TStringList.Create;
  GetFileList(InFolder, List, SubFolders, $20, @CreateError);
  Result := DFDATAS_Build(List,ArcFile, '.\',SavePaths,Progress,CreateError, Cancel);
  List.Free;
end;

Function DFDATAS_Build(ListFile, OutFile: String; InFolders: String; const SavePaths: Boolean = False;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var List: TStringList;
begin
  If Not FileExists(ListFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exist!',[ListFile]));
    Exit;
  end;
  List:=TStringList.Create;
  List.LoadFromFile(ListFile);
  Result :=
  DFDATAS_Build(List,OutFile,InFolders+';'+ ExtractFilePath(ListFile),
    SavePaths,Progress,CreateError, Cancel);
  List.Free;
end;

Function DFDATAS_Build(List: TStringList; OutFile, InFolders: String;
SavePaths: Boolean = False; Progress: TShowProgress = nil;
CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var Folders: TStringArray; Head: THeader;
F: File; n,m,Pos: Integer; Buf: Pointer; Nm: String; ErrorCount: Integer;
begin
  ErrorCount := 0;
  Result := 1;
  FileMode:=fmOpenReadWrite;
  AssignFile(F,OutFile);
  Rewrite(F,1);
  Head.Count:=List.Count;
  SetLength(Head.FHead,Head.Count);
  GetPaths(InFolders, Folders);
  Pos:=RoundBy(Head.Count*SizeOf(TFileHeader)+4,$800);
  For n:=0 To High(Folders) do
    SetSlash(Folders[n]);

  For n:=0 To Head.Count-1 do
  begin
    With Head.FHead[n] do
    begin
      If SavePaths Then Nm:=List.Strings[n]
      else Nm := ExtractFileName(List.Strings[n]);
      If @Progress<>nil Then Progress(n, Head.Count, Nm);
      If (Cancel<>nil) and Cancel^ Then
      begin
        CloseFile(F);
        Exit;
      end;
      //WriteLn(Format('[%d/%d] %s',[n+1,Head.Count,Nm]));
      FillChar(Name,$20,0);
      If Length(Nm)>32 Then
      begin
        If @CreateError<>nil Then CreateError(Format('Too long file name! (%s)',[Nm]));
        Inc(ErrorCount);
        Continue;
      end;
      Move(Nm[1],Name,Length(Nm));
      For m:=Low(Folders) to High(Folders) do
      begin
        If FileExists(Folders[m] + Nm) Then
        begin
          If Folders[m]='.\' Then Break;
          Nm:=Folders[m]+Nm;
          Break;
        end;
      end;
      If m>=Length(Folders) Then
      begin
        If @CreateError<>nil Then CreateError(Format('File %s not found!',[Nm]));
        Inc(ErrorCount);
        Continue;
      end;
      FilePos:=Pos;
      FileSize:=LoadFile(Nm,Buf);
      Seek(F,Pos);
      BlockWrite(F,Buf^,FileSize);
      FreeMem(Buf);
      Pos:=RoundBy(Pos+FileSize,$800);
    end;
  end;
  Seek(F,0);
  BlockWrite(F,Head.Count,4);
  Seek(F,4);
  BlockWrite(F,Head.FHead[0],SizeOf(TFileHeader)*Head.Count);
  CloseFile(F);
  Result := ErrorCount;
end;


Type
  TDFFileHeader = Packed Record
    u: Array[0..2] of DWord;
    FileSize: Integer;
    Name: Array[0..$1FF] of Char;
    u1:   DWord;
    FilePos:  Integer;
    u2: Array[0..2] of DWord;
  end;

  TDFHeader = Packed Record
    Count:  Integer;
    HSize:  Integer;
    TegD:   Array[0..7] of Byte;
    FHead:  Array of TDFFileHeader;
  end;

Function DF_Extract(iFile,oFolder: String; Rewrite: Boolean = False; H: Pointer = NIL;
Progress: TShowProgress = nil; CreateError: TCreateError = nil; Cancel: PBoolean = nil): Integer;
var Buf,Buf2: Pointer; Size,n: Integer; Head: TDFHeader; Dir,Nm: String; P: PChar;
begin
  If Not FileExists(iFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exists!',[iFile]));
    Exit;
  end;
  SetSlash(oFolder);
  Size:=LoadFile(iFile,Buf2);
  If Size <= 0 Then Exit;
  Size:=GZip_Decompress(Buf2,Buf,Size);
  FreeMem(Buf2);
  Move(Buf^,Head,$10);
  SetLength(Head.FHead,Head.Count);
  Move(Pointer(DWord(Buf)+$10)^,Head.FHead[0],SizeOf(TDFFileHeader)*Head.Count);
  If H<>NIL Then
  begin
    Result:=Head.Count*SizeOf(TDFFileHeader)+$10;
    Move(Buf^,H^,Result);
  end;
  For n:=0 To Head.Count-1 do
  begin
    With Head.FHead[n] do
    begin
      Nm:=ReplaceChar(Name,'/','\'); 
      If @Progress <> nil Then Progress(n, Head.Count, Nm);
      //WriteLn(Nm,'***'#13#10,Dir);
      Dir := ExpandFileName(oFolder + ExtractFilePath(Nm));
      Nm := ExtractFileName(Nm);
      If not DirectoryExists(Dir) Then ForceDirectories(Dir);
      If not (FileExists(Dir + Nm) and not Rewrite) Then
        SaveFile(Dir + Nm,Pointer(DWord(Buf)+FilePos),FileSize, @CreateError);
    end;
  end;
end;

Procedure DF_ExtractAll(InDir, OutDir: String; HDSFile: String = '';
Progress: TShowProgress = nil; CreateError: TCreateError = nil;
Cancel: PBoolean = nil; FileCount: Integer = -1);
var Buf,Buf2: Pointer; Size,n,Pos: Integer; Head: TDFHeader; Dir,Nm: String;
P: PChar; F: File; SR: TSearchRec; Folders: Array of String; H: THeader;
begin
  If Not DirectoryExists(InDir) Then
  begin
    If @CreateError<>nil Then CreateError(Format('Directory "%s" does not exist!',[InDir]));
    Exit;
  end;
  SetSlash(InDir);
  SetSlash(OutDir);
  If HDSFile = '' Then HDSFile := OutDir + 'LIST.HDS';
  n:=0; Pos:=0;
  GetMem(Buf,$1000000);
  If FindFirst(InDir + '*.DF', faAnyFile, SR) = 0 Then
  begin
    repeat
      Nm:={ExtractFileName(}SR.Name{)};
      If @Progress<>nil Then Progress(n, FileCount, Nm);
      If (Cancel<>nil) and Cancel^ Then
      begin
        FreeMem(Buf);
        Exit;
      end;
      SetLength(H.FHead,n+1);
      FillChar(H.FHead[n].Name,$20,0);
      Move(Nm[1],H.FHead[n].Name,Length(Nm));
      //WriteLn(Format('[%.2d] %s',[n+1,Nm]));
      H.FHead[n].FileSize:=DF_Extract(InDir + SR.Name, OutDir, False, Pointer(DWord(Buf)+Pos));
      H.FHead[n].FilePos:=Pos;
      Pos:=RoundBy(Pos+H.FHead[n].FileSize,$10);
      Inc(n);
    until FindNext(SR)<>0;
    H.Count:=n;
    If HDSFile <> '*' Then
    begin
      AssignFile(F, HDSFile);
      Rewrite(F,1);
      Seek(F,0);
      BlockWrite(F,H.Count,4);
      Seek(F,4);
      BlockWrite(F,H.FHead[0],H.Count*SizeOf(TFileHeader));
      Seek(F,H.Count*SizeOf(TFileHeader)+4);
      BlockWrite(F,Buf^,Pos);
      CloseFile(F);
    end;
    FreeMem(Buf);
  end;
  //WriteLn('Done!');
end;

Function DF_Build(HFile, oFile: String; InFolders: String; Compression: Boolean = True;
                   Progress: TShowProgress = nil; CreateError: TCreateError = nil;
                   Cancel: PBoolean = nil): Integer;
var Buf: Pointer;
begin
  If Not FileExists(HFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exists!',[HFile]));
    Exit;
  end;
  LoadFile(HFile, Buf);
  Result := DF_Build(Buf, oFile, InFolders, Compression, @Progress, @CreateError, Cancel);
  FreeMem(Buf);
end;

Function DF_Build(H: Pointer; oFile: String; InFolders: String; Compression: Boolean = True;
                   Progress: TShowProgress = nil; CreateError: TCreateError = nil;
                   Cancel: PBoolean = nil): Integer;
var Buf,Buf2,FBuf: Pointer; Size,Pos,n,m: Integer; Head: TDFHeader;
Folders: TStringArray; Dir,Nm: String;// P: PChar;
begin
  Move(H^,Head,$10);
  SetLength(Head.FHead,Head.Count);
  Move(Pointer(DWord(H)+$10)^,Head.FHead[0],SizeOf(TDFFileHeader)*Head.Count);
  Pos:=Head.Count*SizeOf(TFileHeader)+$10;
  GetMem(Buf,$2000000);
  GetPaths(InFolders, Folders);
  Result := 0;
  For n:=0 To Head.Count-1 do
  begin
    With Head.FHead[n] do
    begin
      Nm:=ReplaceChar(Name,'/','\');
      If @Progress<>nil Then Progress(n, Head.Count, Nm);
      For m:=Low(Folders) to High(Folders) do
      begin
        If FileExists(Folders[m]+Nm) Then
        begin
          Dir := Folders[m];
          Nm  := Dir + Nm;
          break;
        end;
      end;
      If m>=Length(Folders) Then
      begin
        If @CreateError<>nil Then CreateError(Format('File "%s" not found!',[Nm]));
        Inc(Result);
        Continue;
      end;
      FileSize:=LoadFile(Nm,FBuf);
      FilePos:=Pos;
      Move(FBuf^,Pointer(DWord(Buf)+Pos)^,FileSize);
      FreeMem(FBuf);
      Pos:=RoundBy(Pos+FileSize,4);
    end;
  end;
  Move(Head,Buf^,$10);
  Move(Head.FHead[0],Pointer(DWord(Buf)+$10)^,SizeOf(TFileHeader)*Head.Count);
  If Compression Then
  begin
    If @Progress<>nil Then Progress(-1, -1, Format('Compressing %d bytes...',[Pos]));
    Size:=GZip_Compress(Buf,Buf2,Pos);
    FreeMem(Buf);
    SaveFile(oFile,Buf2,Size, @CreateError);
    FreeMem(Buf2);
  end else
  begin                       
    SaveFile(oFile,Buf,Size, @CreateError);
    FreeMem(Buf);
  end;
end;

Function DF_BuildAll(HDSFile, OutDir, InFolders: String; Compression: Boolean = True;
                     Progress: TShowProgress = nil; CreateError: TCreateError = nil;
                     Cancel: PBoolean = nil): Integer;
var Buf: Pointer; Error: Boolean; H: THeader; F: File; n: Integer;
begin 
  If Not FileExists(HDSFile) Then
  begin
    If @CreateError<>nil Then CreateError(Format('File "%s" does not exist!',[HDSFile]));
    Exit;
  end;
  If not DirectoryExists(OutDir) Then
  begin
    If not ForceDirectories(OutDir) Then
    begin
      CreateError('Can''t create out dir!');
      Exit;
    end;
  end;
  Buf := nil;
  SetSlash(OutDir);
  AssignFile(F,HDSFile);
  Reset(F,1);
  BlockRead(F,H.Count,4);
  n := H.Count*SizeOf(TFileHeader)+4; 
  GetMem(Buf,FileSize(F)-n);
  SetLength(H.FHead,H.Count);
  BlockRead(F,H.FHead[0],H.Count*SizeOf(TFileHeader));
  BlockRead(F,Buf^,FileSize(F)-n);
  CloseFile(F);
  Result := 0;
  For n:=0 To H.Count-1 do
  begin
    If @Progress<>nil Then Progress(n, H.Count, H.FHead[n].Name);
    If (Cancel<>nil) and Cancel^ Then break;
    If DF_Build(Pointer(DWord(Buf)+H.FHead[n].FilePos), OutDir + H.FHead[n].Name,
             InFolders + ';' + ExtractFilePath(HDSFile), Compression, nil, @CreateError) > 0 Then
                Inc(Result);
  end;
  FreeMem(Buf);
end;

end.
 