program Ever17_d;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  PRT;



var F: File; Buf: Pointer; Sz,Size: Integer;
var Nn,Mm: Integer;
Procedure ShowProgress(I: Integer);
begin
  //Clear;
  Nn:=(I*100) Div Size;
  If Nn<>Mm Then WriteLn(Format('%d%%',[Nn]));
  Mm:=Nn;
end;

begin
  WriteLn('Ever17 decompressor by HoRRoR');
  If ParamCount < 2 Then
  begin
    WriteLn('Usage: Ever17 <ArcFile> <DestFile>');
    Exit;
  end;
  //AssignFile(F, 'D:\Крэкинг\RLE\test');
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  BlockRead(F, Size, 4);
  //Size:=FileSize(F);
  GetMem(Buf,Size );
  BlockRead(F, Buf^, FileSize(F) - 4);
  CloseFile(F);

  Decompress(Buf, Size);
  AssignFile(F, ParamStr(2));
  Rewrite(F,1);
  BlockWrite(F, Buf^, Size);
  FreeMem(Buf);
  CloseFile(F);
  { TODO -oUser -cConsole Main : Insert code here }
end.
