unit SH0_Compression;

interface
uses ZlibEx, Zlib, SysUtils, Classes;

Type
DWord = LongWord;

TFileHeader = Packed Record
Case Byte of
    0: (
      NamePos: DWord;
      FilePos: DWord;
      FileSize: DWord;
      FullSize: DWord;
    );
    1: (Hash: DWord);
end;


THeader = Packed Record
  Sign: Array[0..3] of Char;
  Count: DWord;
  HeadSize: DWord;
  NamesPos: DWord;
  NamesSize: DWord;
  FHead: Array of TFileHeader;
end;

procedure CompressToUserBuf(const InBuf: Pointer; InBytes: Integer;
                      const OutBuf: Pointer; BufSize: Integer; out OutBytes: Integer);
Function Z_Compress(var Buf: Pointer; Size: Integer): Integer;
Function Z_Decompress(var Buf: Pointer; Size: Integer): Integer;
Function RoundBy(Value, R: Integer): Integer;
implementation

procedure CompressToUserBuf(const InBuf: Pointer; InBytes: Integer;
                      const OutBuf: Pointer; BufSize: Integer; out OutBytes: Integer);
var
  strm: TZStreamRec;
//  P: Pointer;
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
  Word(OutBuf^) := $DA78;
end;

Function Z_Compress(var Buf: Pointer; Size: Integer): Integer;
var W: ^Word; Buf2: Pointer;
begin
  ZCompress(Buf, Size, Buf2, Result, zcMax);
  ReallocMem(Buf,Result);
  FreeMem(Buf);
  Buf := Buf2;
  W:=Addr(Buf^);
  W^:=$DA78;
end;

Function Z_Decompress(var Buf: Pointer; Size: Integer): Integer;
var Buf2: Pointer; W: ^Word;
begin
  W:=Addr(Buf^);
  W^:=$9C78;
  ZDecompress(Buf, Size, Buf2, Result); 
  FreeMem(Buf);
  Buf := Buf2;
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

end.
