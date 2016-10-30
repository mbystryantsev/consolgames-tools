unit SHDec;

interface

uses
SysUtils;

Procedure SHDecrypt(var Buf: Pointer; Size: Integer);
Function SHDecryptFile(sFile: String): Boolean;

implementation

const
  Code1: Integer = $03A452F7;
  Code2: Integer = $01309125;

Procedure SHDecrypt(var Buf: Pointer; Size: Integer);
var Pos,Mn: Integer; I: ^Integer;
begin
  Mn:=0; Pos:=0;
  I:=Addr(Buf^);
  While Pos<Size div 4 do
  begin
    Mn:=(Code2+Mn)*Code1;
    I^:=I^ XOR Mn;
    Inc(I); Inc(Pos);
  end;
end;

Function SHDecryptFile(sFile: String): Boolean;
var F: File; Buf: Pointer;
begin
  If not FileExists(ParamStr(1)) Then
  begin
    Result:=False;
    Exit;
  end;
  AssignFile(F,sFile);
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F, Buf^,FileSize(F));
  SHDecrypt(Buf,FileSize(F));
  Seek(F,$47800);
  BlockWrite(F,Buf^,FileSize(F));
  FreeMem(Buf);
  CloseFile(F);
  Result:=True;
end;
end.
 