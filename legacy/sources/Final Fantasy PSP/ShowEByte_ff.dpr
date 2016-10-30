program ShowEByte_ff;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows;

var F: File; Ptr: Dword; Cnt: DWord; S1, S2: Byte;
begin
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  Seek(F,9);
  BlockRead(F, Cnt,3);
  If Cnt>1 then
  begin
    Seek(F, 20);
    BlockRead(F, Ptr, 4);
    Seek(F, Ptr-1);
    BlockRead(F, S1, 1);
  end;
  Seek(F, FileSize(F)-1);
  BlockRead(F, S2, 1);
  Close(F);

  If Cnt>1 then
  begin
    WriteLn(Format('%s  -  %s',[IntToHex(S1, 2),IntToHex(S2,2)]));
  end else
  begin
    WriteLn(Format('%s',[IntToHex(S2,2)]));
  end;
    ReadLn;

end.
