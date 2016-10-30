program Count;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var Buf: Pointer; B: ^Byte; Cnt,Size,Pos,Adr1,Adr2: Integer;
F: File; S: String;
begin

  Adr1 := $4B1C800 ;
  Adr2 := $4B1CF77 ;

  Size:=Adr2-Adr1+2;
  AssignFile(F, 'D:\_job\SH1\SILENT_OR');
  Reset(F,1);
  Seek(F,Adr1);
  GetMem(Buf,Size);
  BlockRead(F,Buf^,Size);
  B:=Addr(Buf^);
  Pos:=0;

  While (Pos<Size-1) do
  begin
    S:='';
    Inc(Cnt);
    While (B^<>0) and (Pos<Size) do
    begin
      S:=S+Char(B^);
      Inc(B);
      Inc(Pos);
    end;
    While (B^=0) and (Pos<Size) do
    begin
      Inc(B);
      Inc(Pos);
    end;
    WriteLn(S);
  end;
  WriteLn(IntToStr(Cnt));
  ReadLn;

  { TODO -oUser -cConsole Main : Insert code here }
end.
 