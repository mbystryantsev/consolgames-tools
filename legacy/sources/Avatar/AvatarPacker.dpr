program AvatarPacker;

{$APPTYPE CONSOLE}

uses
  Windows, SysUtils, Classes, DLZO, Zlib, ZLibEx, LZO;

Type
  TArcHeader = Packed Record
    Signature: Array[0..3] of Char;
    Version:   Integer;
    Offset:    LongWord;
    Null:      Integer;
  end;

  TFileInfo = Packed Record
    Offset:   LongWord;
    Size:     LongWord;
    StrCRC32: LongWord;
  end;
  
  TFileRecord = Record
    DataPtr: ^TFileInfo;
    //LZOSize: LongWord;
    Chunks:  Integer;
    Name:    PChar;
    NameLen: Integer;
    Time:    FILETIME;
  end;

const
  MAX_CHUNK = $10000;

//{$L minilzo.obj}
{$L crc32.obj}
//function adler32; external

// Data_Win32

function crc32(crc: LongWord; Buf: Pointer; Len: LongWord): LongWord; external;


Procedure DumpMem(P: Pointer; Size: Integer; FileName: String);
var F: File;
begin
  AssignFile(F, FileName);
  Rewrite(F, 1);
  BlockWrite(F, P^, Size);
  CloseFile(F);
end;

Procedure ExtractFiles(const F: File; Data: Pointer; OutDir: String; ListFile: String = '');
var
  Count: Integer; P: Pointer; n, m: Integer; Files: Array of TFileRecord;
  C: PChar; Pos: LongWord; S, SS: String; WF: File; Buf, WBuf: Pointer;
  ChunkSize, ZChunkSize, Size: Integer; List: TStringList; Compressed: Boolean;
begin
  If OutDir[Length(OutDir)] <> '\' Then OutDir := OutDir + '\';

  P := Data;
  Inc(LongWord(P), 1);
  Count := Integer(P^);
  Inc(LongWord(P), 4);

  SetLength(Files, Count);
  For n := 0 To Count - 1 do With Files[n] do
  begin
    DataPtr := P;
    Chunks := DataPtr^.Size div $10000;
    If DataPtr^.Size mod $10000 <> 0 Then Inc(Chunks);
    Inc(LongWord(P), 12 + 4 * Chunks);
  end;
  For n := 0 To Count - 1 do With Files[n] do
  begin
    Time := FILETIME(P^);
    Inc(LongWord(P), 8);
    NameLen := Byte(P^);
    Inc(LongWord(P), 1);
    Name := P;
    (*
    C := P;
    For m := 0 To NameLen - 1 do
    begin
      Write(C^);
      Inc(C);
    end;
    *)
    Inc(LongWord(P), NameLen);
    //WriteLn;
  end;
  //WriteLn(LongWord(P) - LongWord(Data));
  //ReadLn;

  GetMem(Buf, $10000);
  GetMem(WBuf, $10000);

  List := TStringList.Create;
  For n := 0 To Count - 1 do With Files[n] do
  begin
    SetLength(SS, NameLen);
    Move(Name^, SS[1], NameLen);
    WriteLn('[', n + 1, '/', Count, '] ', SS);
    S := OutDir + SS;
    ForceDirectories(ExpandFileName(ExtractFilePath(S)));

    AssignFile(WF, S);
    Rewrite(WF, 1);
    P := Pointer(LongWord(DataPtr) + 12);

    Seek(F, Files[n].DataPtr^.Offset);

    Compressed := False;
    For m := 0 To Chunks - 1 do
    begin
      ZChunkSize := Word(P^);
      Inc(LongWord(P), 2);
      ChunkSize := Word(P^);
      Inc(LongWord(P), 2);

      If ChunkSize = $FFFF Then
      begin
        ChunkSize := MAX_CHUNK - ZChunkSize;
        BlockRead(F, Buf^, ChunkSize);
        BlockWrite(WF, Buf^, ChunkSize);
      end else
      begin
        Compressed := True;
        ChunkSize := MAX_CHUNK - ChunkSize;
        //If ZChunkSize = 0 Then ZChunkSize := MAX_CHUNK;
        BlockRead(F, Buf^, ZChunkSize);
        DLZO.decompress(Buf, ZChunkSize, WBuf, ChunkSize);

(*
        If (m < Chunks - 1) Then
        begin
          If (ChunkSize < MAX_CHUNK) Then ReadLn;
        End;
*)
        //If ChunkSize >= MAX_CHUNK Then ReadLn;
        BlockWrite(WF, WBuf^, ChunkSize);
      end;
    end;

    SetLength(S, NameLen + 10);
    S[10] := ' ';
    Move(SS[1], S[11], NameLen);
    If Compressed Then
      S[1] := '+'
    else
      S[1] := '-';
    SS := IntToHex(DataPtr^.StrCRC32, 8);
    Move(SS[1], S[2], 8);
    List.Add(S); 

    SetFileTime(TFileRec(WF).Handle, @Time, nil, nil);
    CloseFile(WF);

  end;
  If ListFile = '' Then
    ListFile := OutDir + '_LIST.LST';
  List.SaveToFile(ListFile);
  List.Free;

  FreeMem(Buf);
  FreeMem(WBuf);

  Finalize(Files);

  //ReadLn;
end;


procedure CompressToUserBuf(const InBuf: Pointer; InBytes: Integer;
                      const OutBuf: Pointer; BufSize: Integer; out OutBytes: Integer);
var
  strm: TZStreamRec;
  P: Pointer;
begin
  FillChar(strm, sizeof(strm), 0);
  strm.zalloc := zlibAllocMem;
  strm.zfree := zlibFreeMem;
  try
    strm.next_in := InBuf;
    strm.avail_in := InBytes;
    strm.next_out := OutBuf;
    strm.avail_out := BufSize;
    deflateInit_(strm, Z_DEFAULT_COMPRESSION, zlib_version, sizeof(strm));
    try
      If deflate(strm, Z_FINISH) <> Z_STREAM_END Then
        raise ECompressionError.Create('ZLib compression error!');
    finally
      deflateEnd(strm);
    end;
    OutBytes := strm.total_out;
  except
    raise
  end;
end;

Function DecompressData(Data, Info: Pointer; out dest: Pointer): Integer;
Type
  TRecord = Packed Record DstOffset, SrcOffset: LongWord; end;
var
  Rec: ^TRecord; Count, n: Integer; SrcOffset, DstOffset: LongWord;
begin
  Count := Integer(Info^);
  Rec := Pointer(LongWord(Info) + 4);
  Result := Integer(Pointer(LongWord(Info) + (Count - 1) * 8 + 4)^);
  GetMem(dest, Result);

  For n := 0 To Count - 2 do
  begin
    SrcOffset := Rec^.SrcOffset xor $80000000;
    DstOffset := Rec^.DstOffset;
    Inc(Rec);
    Zlib.DecompressToUserBuf(
      Pointer(SrcOffset + LongWord(Data)), Rec^.SrcOffset - (SrcOffset xor $80000000),
      Pointer(DstOffset + LongWord(dest)), Rec^.DstOffset - DstOffset
    );
  end;
end;

Function CompressData(Data, Info, OutData: Pointer; BufSize: Integer; var Size: Integer): Integer;
Type
  TRecord = Packed Record DstOffset, SrcOffset: LongWord; end;
var
  Rec: ^TRecord; Count, n, ChunkSize, ZChunkSize: Integer;
  SrcOffset, DstOffset: LongWord; P: Pointer;
begin
  Rec := Pointer(LongWord(Info) + 4);
  LongWord(Info^) := (Size div MAX_CHUNK) + 1;
  If Size mod MAX_CHUNK <> 0 Then Inc(LongWord(Info^));
  Result := LongWord(Info^) * 8 + 4;

  SrcOffset := 4;
  DstOffset := 0;
  While Size > 0 do
  begin
    If Size > MAX_CHUNK Then
      ChunkSize := MAX_CHUNK
    else
      ChunkSize := Size;
    Rec^.DstOffset := DstOffset;
    Rec^.SrcOffset := SrcOffset or $80000000;
    Dec(Size, ChunkSize);
    Inc(Rec);

    CompressToUserBuf(
      Pointer(DstOffset + LongWord(Data)), ChunkSize,
      Pointer(SrcOffset + LongWord(OutData)), BufSize - SrcOffset, ZChunkSize
    );       
    Inc(SrcOffset, ZChunkSize);
    Inc(DstOffset, ChunkSize);
  end;
  Rec^.DstOffset := DstOffset;
  Rec^.SrcOffset := SrcOffset or $80000000;

  Size := SrcOffset;
  LongWord(OutData^) := Size;

end;

Function StoreFile(const F: File; FileName: String; var Data: Pointer; Hash: LongWord;
  Compress: Boolean; const Buffer: Pointer): FILETIME;
var RF: File; Size, n, Chunks: Integer; ZBuf: Pointer; CurPos: LongWord; ZChunkSize, ChunkSize, temp_int: LongInt;
Temp, CurData: Pointer;
label NOT_COMPRESS;
begin
  ZBuf := Pointer(LongWord(Buffer) + MAX_CHUNK);

  FileMode := fmOpenRead;
  AssignFile(RF, FileName);
  Reset(RF, 1);
  Size := FileSize(RF);
  GetFileTime(TFileRec(F).Handle, @Result, nil, nil);

  LongWord(Data^) := FilePos(F);
  Inc(LongWord(Data), 4);
  LongWord(Data^) := Size;
  Inc(LongWord(Data), 4);
  LongWord(Data^) := Hash;
  Inc(LongWord(Data), 4);

  //Chunks := Size div MAX_CHUNK;
  //If Size mod MAX_CHUNKS <> 0 Then
  //  Inc(Chunks);

{
  CurPos := FilePos(F);
  CurData := Data;
NOT_COMPRESS:
}

  While Size > 0 do
  begin
    If Size >= MAX_CHUNK Then
      ChunkSize := MAX_CHUNK
    else
      ChunkSize := Size;
    Dec(Size, ChunkSize);
    ///
    //  If ChunkSize < MAX_CHUNK Then
    //    FillChar(Buffer^, MAX_CHUNK, 0);
    ///
    BlockRead(RF, Buffer^, ChunkSize);
    If Compress Then
    begin
      If (DLZO.compress(Buffer, ChunkSize, ZBuf, ZChunkSize) <> E_OK) or (ZChunkSize >= MAX_CHUNK) Then
      begin

        {
        Compress := False;
        Seek(F, CurPos);
        Seek(RF, 0);
        Data := CurData;
        Size := FileSize(RF);
        }
        
        GoTo NOT_COMPRESS;
      end;
      //DLZO.decompress(ZBuf, ZChunkSize, Buffer, ChunkSize);
      Word(Data^) := ZChunkSize;
      Inc(LongWord(Data), 2);
      Word(Data^) := 0;
      Inc(LongWord(Data), 2);
      BlockWrite(F, ZBuf^, ZChunkSize);
    end else
    begin
NOT_COMPRESS:
      Word(Data^) := MAX_CHUNK - ChunkSize;
      Inc(LongWord(Data), 2);
      Word(Data^) := $FFFF;
      Inc(LongWord(Data), 2);
      BlockWrite(F, Buffer^, ChunkSize);
    end;
  end;
  //Seek(F, (FilePos(F) + 3) and $FFFFFFFC);
end;

Procedure Build(ListFile, InDir, OutFile: String; Compression: Boolean = True; MapFile: String = '');
var
  List: TStringList; n, Code, NameSize, DataSize, Size, InfoSize: Integer;
  Name, S: String; F, WF: File;
  Buffer, DataBuf, Data, NameDataBuf, NameData, Buf, Info: Pointer;
  Hash, DataPos: LongWord;
const
  cSignature: Array[0..7] of Char = 'PAK!'#4#0#0#0;
begin
  If InDir[Length(InDir)] <> '\' Then InDir := InDir + '\';
  List := TStringList.Create;

  AssignFile(F, OutFile);
  Rewrite(F, 1);
  BlockWrite(F, cSignature, 8);
  Seek(F, 16);

  GetMem(Buffer, MAX_CHUNK * 8);
  GetMem(DataBuf, 1024 * 1024 * 4);
  GetMem(NameDataBuf, 1024 * 1024 * 2);
  Data := DataBuf;
  NameData := NameDataBuf;

  Byte(Data^) := 1;
  Inc(LongWord(Data), 1);
  //Data_Win32
  List.LoadFromFile(ListFile);
  LongWord(Data^) := List.Count;
  Inc(LongWord(Data), 4);

  For n := 0 To List.Count - 1 do
  begin
    S := List.Strings[n];
    SetLength(Name, Length(S) - 10);
    Move(S[11], Name[1], Length(Name));

    WriteLn('[', n + 1, '/', List.Count, '] ', Name);

    Hash := crc32(0, PChar(Name), Length(Name));

    FILETIME(NameData^) := StoreFile(F, InDir + Name, Data, Hash, Compression and (S[1] = '+') {and (n < 500)}, Buffer);
    Inc(LongWord(NameData), SizeOf(FILETIME));
    Byte(NameData^) := Length(Name);
    Inc(LongWord(NameData), 1);
    Move(Name[1], NameData^, Length(Name));
    Inc(LongWord(NameData), Length(Name));
  end;
  LongWord(NameData^) := 0;
  NameSize := LongWord(NameData) - LongWord(NameDataBuf) + 4;
  DataSize := LongWord(Data) - LongWord(DataBuf);
  Move(NameDataBuf^, Pointer(LongWord(DataBuf) + DataSize)^, NameSize);

  //******************************
  (*
  AssignFile(WF, 'test.data');
  Rewrite(WF, 1);
  BlockWrite(WF, DataBuf^, NameSize + DataSize);
  CloseFile(WF);
  *)
  //******************************
  //ZLib.CompressBuf(Data, DataSize + NameSize, Buf, Size);
  Size := NameSize + DataSize;

  If MapFile <> '' Then
    DumpMem(DataBuf, Size, MapFile);

  GetMem(Buf, 1024 * 1024 * 2);
  GetMem(Info, MAX_CHUNK);
  InfoSize := CompressData(DataBuf, Info, Buf, 1024 * 1024 * 2, Size);

(*
  AssignFile(WF, 'test.zlib');
  Rewrite(WF, 1);
  BlockWrite(WF, Buf^, Size);
  CloseFile(WF);

  AssignFile(WF, 'test.info');
  Rewrite(WF, 1);
  BlockWrite(WF, Info^, InfoSize);
  CloseFile(WF);
*)

  DataPos := FilePos(F);
  BlockWrite(F, Buf^, Size);
  BlockWrite(F, Info^, InfoSize);
  Seek(F, 8);
  BlockWrite(F, DataPos, 4);

  FreeMem(Buf);
  FreeMem(Info);
  FreeMem(DataBuf);
  FreeMem(NameDataBuf);
  FreeMem(Buffer);
  CloseFile(F);
  List.Free;
end;


Procedure Extract(FileName, OutDir: String; ListFile: String = ''; MapFile: String = '');
var
  F: File; Header: TArcHeader; Buf, Info, WBuf: Pointer;
  Count, Size: Integer;
begin          
  If OutDir[Length(OutDir)] <> '\' Then OutDir := OutDir + '\';
  If ListFile = '' Then
    ListFile := OutDir + ChangeFileExt(ExtractFileName(FileName), '.lst');

  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, Header, SizeOf(Header));

  Seek(F, Header.Offset);
  BlockRead(F, Size, 4);
  Seek(F, Header.Offset);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);

  Seek(F, Header.Offset + Size);
  BlockRead(F, Count, 4);
  Seek(F, Header.Offset + Size);
  GetMem(Info, Count * 8 + 4);
  BlockRead(F, Info^, Count * 8 + 4);

  Size := DecompressData(Buf, Info, WBuf);

  If MapFile <> '' Then
    DumpMem(WBuf, Size, MapFile);


  (*
  AssignFile(F, 'test.myunp');
  Rewrite(F, 1);
  BlockWrite(F, WBuf^, Size);
  CloseFile(F);
  *)


  ExtractFiles(F, WBuf, OutDir, ListFile);
  CloseFile(F);


  FreeMem(Buf);
  FreeMem(WBuf);
  FreeMem(Info);

end;


Procedure PrintUsage();
begin
  WriteLn('James Cameron''s Avatar PAK Extractor by HoRRoR');
  WriteLn('http://consolgames.ru/ :: horror.cg@gmail.com');
  WriteLn('Usage:');
  WriteLn('  AvatarPacker -e [keys] <PAK> <OutDir> [List]');
  WriteLn('  AvatarPacker -b [keys] <List> <InDir> <OutPak>');
  WriteLn('Keys:');
  WriteLn('  -c:       Switch-off comression');
  WriteLn('  -d<file>: Dump filemap data');
end;

var n: Integer; S, MapData: String;
  Compression: Boolean = True;
begin
  //Extract('[mfhs]startup.pak', 'test');
  //Extract('[mfhs]sound_english.pak', 'test');
  //Extract('data.pak', 'data_test');
  //Extract('!data.pak', 'data');
//  Exit;

  //Build('data\data.lst', 'data', 'data.pak');
  //Build('test\_LIST.LST', 'test', 'test.pak');
  //Exit;

  For n := 2 To ParamCount do
  begin
    S := ParamStr(n);
    If S[1] <> '-' Then Break;
    Case S[2] of
      'c', 'C': Compression := not Compression;
      'd', 'D':
      begin
        SetLength(MapData, Length(S) - 2);
        Move(S[3], MapData[1], Length(MapData));
      end;
    end;
  end;

  If ParamStr(1) = '-e' Then
  begin
    WriteLn('Extracting....');
    Extract(ParamStr(n), ParamStr(n + 1), '', MapData);
    WriteLn('Done!');
  end else
  If ParamStr(1) = '-b' Then
  begin
    WriteLn('Building....');
    Build(ParamStr(n), ParamStr(n + 1), ParamStr(n + 2), Compression, MapData);
    WriteLn('Done!');
  end else
    PrintUsage;


end.
