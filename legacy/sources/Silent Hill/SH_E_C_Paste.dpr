program SH_E_C_Paste;

{$APPTYPE CONSOLE}

uses
  SysUtils, SHDec;

var F: File; Buf: Pointer;
begin
  If not (FileExists(ParamStr(1)) and FileExists(ParamStr(2))) Then Exit;
  end;
  AssignFile(F,sFile);
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F, Buf^,FileSize(F));
  SHDecrypt(Buf,FileSize(F));
  Seek(F,0);
  BlockWrite(F,Buf^,FileSize(F));
  FreeMem(Buf);
  CloseFile(F);
  Result:=True;

end.
