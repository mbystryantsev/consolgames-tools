unit Compression;

interface
uses SysUtils, Classes, ICO_GZip;

Type  DWord = LongWord;

Function  RoundBy(Value, R: Integer): Integer;
Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
Function  LoadFile(Name: String; var Pos: Pointer): Integer;
Function  HexToInt(S: String): Integer;
Function GZip_Decompress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Function GZip_Compress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Function ReplaceChar(S: String; Ch,RCh: Char): String;
implementation


Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
var F: File;
begin
  Try
    FileMode := fmOpenWrite;
    AssignFile(F,Name);
    Rewrite(F,1);
    BlockWrite(F, Pos^, Size);
    CloseFile(F);
    FileMode := fmOpenReadWrite;
  except
    WriteLn(Name);
    readln;
  end;
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

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char;
begin
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;

var CHeader: Array[0..9] of Byte = ($1F,$8B,8,0,0,0,0,0,2,3);
Function GZip_Decompress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Var  GZIP: TICOGZip; InStream,OutStream: TMemoryStream; DW: DWord;
begin
  InStream:=TMemoryStream.Create;
  OutStream:=TMemoryStream.Create;
  InStream.Size:=Size+14;
  Move(inBuf^, Pointer(DWord(InStream.Memory)+10)^, Size);
  Move(CHeader,InStream.Memory^,10);
  GZIP:= TICOGZip.Create;
  GZIP.Decompress(InStream,OutStream,Size - 3{-14});
  Result:=OutStream.Size;
  GetMem(outBuf,Result);
  //ReallocMem(outBuf,Result);
  Move(OutStream.Memory^,outBuf^,Result);
  InStream.Free;
  OutStream.Free;
  GZIP.Free;
end;


Function GZip_Compress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Var  GZIP: TICOGZip; InStream,OutStream: TMemoryStream; Ver: ^Byte;
begin
  InStream:=TMemoryStream.Create;
  OutStream:=TMemoryStream.Create;
  InStream.Size:=Size;
  Move(inBuf^, InStream.Memory^, Size);
  GZIP:= TICOGZip.Create;
  GZIP.CompressionLevel:=9;
  GZIP.Compress(InStream,OutStream);
  Result:=OutStream.Size-10-4;
  GetMem(outBuf,Result);
//  ReallocMem(outBuf,Result);
  Move(Pointer(DWord(OutStream.Memory)+10)^,outBuf^,Result);
  InStream.Free;
  OutStream.Free;
  GZIP.Free;
end;

Function ReplaceChar(S: String; Ch,RCh: Char): String;
var n: Integer;
begin
  Result:=S;
  For n:=1 To Length(S) do If Result[n]=Ch Then Result[n]:=RCh;
end;



end.
