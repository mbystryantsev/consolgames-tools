program TXDPack;

{$APPTYPE CONSOLE}

uses
  SysUtils, MGS;

var F,WF: File; Buf: Pointer; Size, FSize: Integer; NM: String; Sg: Array[0..3] of Char = 'Z2HM';
begin
  If (ParamCount<1) or not FileExists(ParamStr(1)) Then Exit;
  If ParamStr(2)<>'' Then NM:=ParamStr(2) else nm:=ParamStr(1)+'.p';
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  FSize:=FileSize(F);
  GetMem(Buf,FSize);
  BlockRead(F, Buf^, FSize);
  Size:=TXDCompress(Buf,FSize);
  AssignFile(WF, NM);
  Rewrite(WF,1);
  BlockWrite(WF, Sg, 4);
  Seek(WF,4);
  BlockWrite(WF, FSize,4);
  Seek(WF,8);
  BlockWrite(WF, Buf^, Size);
  CloseFile(F);
  CloseFile(WF);
  FreeMem(Buf);
end.
 