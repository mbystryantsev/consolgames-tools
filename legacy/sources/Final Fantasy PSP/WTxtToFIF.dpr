program WTxtToFIF;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils,
  Classes;

var F: File; Text: TStringList; W: ^Word; Buf: Pointer; n: Byte;
begin
  Text:=TStringList.Create;
  Text.LoadFromFile('FF1PSP\Tools\PNG\SmallFont.txt');
  AssignFile(F, 'FF1PSP\Tools\SmallFont.FIF');
  Reset(F,1);
  Seek(F,$118);
  GetMem(Buf, 256*6);
  BlockRead(F, Buf^, 256*6);
  W:=Addr(Buf^);
  Inc(W, 2);
  For n:=0 to 255 do
  begin
    W^:=1+StrToInt(RightStr(Text.Strings[n], Length(Text.Strings[n])-2));
    Inc(W,3);
  end;
  Seek(F,$118);
  BlockWrite(F, Buf^, 256*6);
  CloseFile(F);
  FreeMem(Buf);
  Text.Free;
end.
 