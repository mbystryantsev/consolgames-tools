program DFExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Compression in 'Compression.pas',
  ICO_GZip in 'ICO_GZip.pas',
  ICO_DF;

Type
  DWord = LongWord;
  TFileHeader = Packed Record
    u: Array[0..2] of DWord;
    FileSize: Integer;
    Name: Array[0..$1FF] of Char;
    u1:   DWord;
    FilePos:  Integer;
    u2: Array[0..2] of DWord;
  end;
  
  THeader = Packed Record
    Count:  Integer;
    HSize:  Integer;
    TegD:   Array[0..7] of Byte;
    FHead:   Array of TFileHeader;
  end;

(*Function Extract(iFile,oFolder: String; Rewrite: Boolean = False; H: Pointer = NIL): Integer;
var Buf,Buf2: Pointer; Size,n: Integer; Head: THeader; Dir,Nm: String; P: PChar;
begin
  If oFolder[Length(oFolder)]<>'\' Then oFolder := oFolder + '\';
  Size:=LoadFile(iFile,Buf2);
  If Size <= 0 Then Exit;
  Size:=GZip_Decompress(Buf2,Buf,Size);
  FreeMem(Buf2);
  Move(Buf^,Head,$10);
  SetLength(Head.FHead,Head.Count);
  Move(Pointer(DWord(Buf)+$10)^,Head.FHead[0],SizeOf(TFileHeader)*Head.Count);
  If H<>NIL Then
  begin
    Result:=Head.Count*SizeOf(TFileHeader)+$10;
    Move(Buf^,H^,Result);
  end;
  For n:=0 To Head.Count-1 do
  begin
    With Head.FHead[n] do
    begin
      P:=Addr(Name);
      WriteLn(P);
      Nm:=ReplaceChar(P,'/','\');
      Dir:=Format('%s%s',[oFolder,ExtractFilePath(Nm)]);
      WriteLn(Nm,'***'#13#10,Dir);
      Nm:=ExtractFileName(Nm);
      If not DirectoryExists(Dir) Then {MakeDirs}ForceDirectories(Dir);
      If not (FileExists(Format('%s%s',[Dir,Nm])) and not Rewrite) Then SaveFile(Format('%s%s',[Dir,Nm]),Pointer(DWord(Buf)+FilePos),FileSize);
    end;
  end;
end;         *)

(*
Procedure Build(H: Pointer; oFile: String; Folders: Array of String);
var Buf,Buf2,FBuf: Pointer; Size,Pos,n,m: Integer; Head: THeader; Dir,Nm: String; P: PChar;
begin
  Move(H^,Head,$10);
  SetLength(Head.FHead,Head.Count);
  Move(Pointer(DWord(H)+$10)^,Head.FHead[0],SizeOf(TFileHeader)*Head.Count);
  Pos:=Head.Count*SizeOf(TFileHeader)+$10;
  GetMem(Buf,$2000000);
  For n:=0 To Head.Count-1 do
  begin
    With Head.FHead[n] do
    begin
      P:=Addr(Name);
//    WriteLn(P);
      //WriteLn(Format('%s  %.8x',[P,Pos]));
      Nm:=ReplaceChar(P,'/','\');
      For m:=Low(Folders) to High(Folders) do
      begin
        If FileExists(Format('%s\%s',[Folders[m],Nm])) Then
        begin
          Dir:=Folders[m];
          Nm:=Format('%s\%s',[Dir,Nm]);
          break;
        end;
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
  WriteLn(Format('Compressing %d bytes...',[Pos]));
  Size:=GZip_Compress(Buf,Buf2,Pos);
  FreeMem(Buf);
  SaveFile(oFile,Buf2,Size);
  WriteLn(Format('File %s builded!',[ExtractFileName(oFile)]));
  //ReallocMem(Buf,Pos);
  //SaveFile('F:\Temp\U\1',Buf,Pos);
end;        *)

Type
  TFH = Packed Record
    Name: Array[0..$1F] of Char;
    FilePos: DWord;
    FileSize: DWord;
  end;

  TH = Packed Record
    Count: DWord;
    FHead: Array of TFH;
  end;

Procedure Progress(Cur,Max: Integer; S: String);
begin
  If Max>0 Then
    WriteLn(Format('[%d/%d] %s',[Cur + 1, Max, S]))
  else If Cur>0 Then
    WriteLn(Format('[%d] %s',[Cur + 1, S]))
  else
    WriteLn(S);
end;

Procedure CreateError(S: String);
begin
  WriteLn(Format('***ERROR: %s', [S]));
end;

var Buf,Buf2: Pointer; Size,n,Pos: Integer; Head: THeader; Dir,Nm: String;
P: PChar; F: File; SR: TSearchRec; S: String; H: TH;
begin
  WriteLn('ICO DF Extractor by HoRRoR');
  WriteLn('E-mail: ho-rr-or@mail.ru horror.cg@gmail.com');
  WriteLn('http://consolgames.ru/');
  WriteLn('');

  If ParamStr(1)='-d' Then
  begin
    Size:=LoadFile(ParamStr(2),Buf);
    Size:=GZip_Decompress(Buf,Buf2,Size);
    SaveFile(ParamStr(3),Buf2,Size);
    FreeMem(Buf); FreeMem(Buf2);
  end else
  If ParamStr(1)='-c' Then
  begin
    Size:=LoadFile(ParamStr(2),Buf);
    Size:=GZip_Compress(Buf,Buf2,Size);
    SaveFile(ParamStr(3),Buf2,Size);
    FreeMem(Buf); FreeMem(Buf2);
  end else
  If ParamStr(1)='-e' Then
  begin
    //Extract(ParamStr(2),ParamStr(3));
    DF_Extract(ParamStr(2), ParamStr(3), True, nil, @Progress, @CreateError);
    WriteLn('Done!');
  end else
  If ParamStr(1)='-ea' Then
  begin
    DF_ExtractAll(ParamStr(2), ParamStr(3), ParamStr(4), @Progress, @CreateError);
    WriteLn('Done!');
{    n:=0; Pos:=0;
    GetMem(Buf,$1000000);
    If FindFirst(Format('%s\*.DF',[ParamStr(2)]),faAnyFile,SR)=0 Then
    begin
      repeat
        Nm:=ExtractFileName(SR.Name);
        SetLength(H.FHead,n+1);
        FillChar(H.FHead[n].Name,$20,0);
        Move(Nm[1],H.FHead[n].Name,Length(Nm));
        WriteLn(Format('[%.2d] %s',[n+1,Nm]));
        H.FHead[n].FileSize:=Extract(Format('%s\%s',[ParamStr(2),SR.Name]),ParamStr(3),False,Pointer(DWord(Buf)+Pos));
        H.FHead[n].FilePos:=Pos;
        Pos:=RoundBy(Pos+H.FHead[n].FileSize,$10);
        Inc(n);
      until FindNext(SR)<>0;
      H.Count:=n;
      AssignFile(F, Format('%s\LIST.HDS',[ParamStr(3)]));
      Rewrite(F,1);
      Seek(F,0);
      BlockWrite(F,H.Count,4);
      Seek(F,4);
      BlockWrite(F,H.FHead[0],H.Count*SizeOf(TFH));
      Seek(F,H.Count*SizeOf(TFH)+4);
      BlockWrite(F,Buf^,Pos);
      FreeMem(Buf);
      CloseFile(F);
    end;
    WriteLn('Done!'); }
  end else
  If ParamStr(1)='-b' Then
  begin
    For n:=4 To ParamCount do
      S := S + ParamStr(n) + ';';
    LoadFile(ParamStr(2),Buf);
    DF_Build(Buf, ParamStr(3), S, True, nil, @Progress, @CreateError);
    //Build(Buf,ParamStr(3),Folders);
    FreeMem(Buf);
  end else
  If ParamStr(1)='-ba' Then
  begin
    For n:=4 To ParamCount do
      S := S + ParamStr(n) + ';';
    DF_BuildAll(ParamStr(2), ParamStr(3), S, True, @Progress, @CreateError);
    WriteLn('Done!');
  {
    AssignFile(F,ParamStr(2));
    Reset(F,1);
    GetMem(Buf,FileSize(F)-H.Count*SizeOf(TFH)-4);
    BlockRead(F,H.Count,4);
    SetLength(H.FHead,H.Count);
    BlockRead(F,H.FHead[0],H.Count*SizeOf(TFH));
    BlockRead(F,Buf^,FileSize(F)-H.Count*SizeOf(TFH)-4);
    CloseFile(F);
    For n:=0 To H.Count-1 do
    begin
      P:=Addr(H.FHead[n].Name);
      WriteLn(Format('[%.2d/%.2d] %s',[n+1,H.Count,P]));
      Build(Pointer(DWord(Buf)+H.FHead[n].FilePos),Format('%s\%s',[ParamStr(3),P]),Folders);
    end;
    FreeMem(Buf);  }
  end;
  { TODO -oUser -cConsole Main : Insert code here }
end.
