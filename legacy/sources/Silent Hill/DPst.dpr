program DPst;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  SHDec;

var F: File; Buf: Pointer; Size: Integer;
begin
  //If not FileExists(ParamStr(1)) Then Exit;
  AssignFile(F,'SH_E_C_EDIT.BIN');
  Reset(F,1);
  Size:=FileSize(F);
  GetMem(Buf,Size);
  BlockRead(F, Buf^,Size);
  SHDecrypt(Buf,Size);
  CloseFile(F);
  AssignFile(F,'SILENT');
  Reset(F,1);
  Seek(F,$47800);
  BlockWrite(F,Buf^,Size);
  FreeMem(Buf);
  CloseFile(F);
end.
