program TXDUnpack;

{$APPTYPE CONSOLE}

uses
  SysUtils, MGS;

var F,WF: File; Buf: Pointer; Size: Integer; NM: String;
begin
  If (ParamCount<1) or not FileExists(ParamStr(1)) Then Exit;
  If ParamStr(2)<>'' Then NM:=ParamStr(2) else nm:=ParamStr(1)+'.u';
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  Size:=TXDDecompress(Buf,FileSize(F));
  AssignFile(WF, NM);
  Rewrite(WF,1);
  BlockWrite(WF, Buf^, Size);
  CloseFile(F);
  CloseFile(WF);
  FreeMem(Buf);
end.
 