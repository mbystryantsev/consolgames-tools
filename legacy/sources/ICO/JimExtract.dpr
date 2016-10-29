program JimExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows;

var
F,WF: File; n: Integer; Buf: Pointer; S: PChar;
begin
  FileMode:=fmOpenRead;
  AssignFile(F,ParamStr(1));
  Reset(F,1);
  Seek(F,0);
  FileMode:=fmOpenWrite;
  GetMem(Buf,$8800);
  For n:=0 To (FileSize(F) div $8800)-1 do
  begin
    Seek(F,n*$8800);
    BlockRead(F,Buf^,$8800);
    AssignFile(WF,Format('%s\%s.%.2d.tm2',[ParamStr(2),ExtractFileName(ParamStr(1)),n]));
    Rewrite(WF,1);
    Seek(WF,0);
    BlockWrite(WF,Buf^,$8800);
    CloseFile(WF);
  end;
  FreeMem(Buf);
  CloseFile(F);
end.
