unit SHPacker;

interface
uses ZlibEx, SysUtils, Classes;

Type
DWord = LongWord;

TFileHeader = Packed Record
  NamePos: DWord;
  FilePos: DWord;
  FileSize: DWord;
  FullSize: DWord;
end;


THeader = Packed Record
  Sign: Array[0..3] Of char;
  Count: DWord;
  HeadSize: DWord;
  NamesPos: DWord;
  NamesSize: DWord;
  FHead: Array of TFileHeader;
end;

Function Pack(var Buf: Pointer; Size: Integer): Integer;
Function UnPack(var Buf: Pointer; Size: Integer): Integer;
Function RoundBy(Value, R: Integer): Integer;
implementation

Function Pack(var Buf: Pointer; Size: Integer): Integer;
var {Stream: TMemoryStream; CStream: TZCompressionStream;}  W: ^Word;
Size2: Integer; Buf2: Pointer;
begin
  {Stream := TMemoryStream.Create;
  CStream := TZCompressionStream.Create(Stream, zcDefault); // create the compression stream
  CStream.Write(Buf^, Size);
  CStream.Free;
  FreeMem(Buf);
  Buf:=Stream.Memory;
  W:=Addr(Buf^);
  W^:=$DA78;
  Result:=Stream.Size;}
  ZCompress(Buf, Size, Buf2, Result, zcMax);
  ReallocMem(Buf,Result);
  Move(Buf2^,Buf^,Result);
  FreeMem(Buf2);
  W:=Addr(Buf^);
  W^:=$DA78;
end;

Function UnPack(var Buf: Pointer; Size: Integer): Integer;
var InStream, Stream: TMemoryStream; CStream: TZDecompressionStream; Buf2: Pointer;
{Size2: Integer;} W: ^Word;
begin
  W:=Addr(Buf^);
  W^:=$9C78;
  ZDecompress(Buf, Size, Buf2, Result{Size2});
  ReallocMem(Buf,Result);
  Move(Buf2^,Buf^,Result);
  FreeMem(Buf2);
  //Result:= Size2;
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

end.
