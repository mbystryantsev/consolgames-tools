program SHDecoder;

{$APPTYPE CONSOLE}

uses
  SysUtils, PtrSrch, Windows;

var Size, Adr1,Adr2,n: Integer;
F, FW: File; Buf, WBuf: Pointer;
DW1,DW2: ^DWord;
begin

  // SH1\SILENT_OR SH1\Menus.bin $EC800 $47800 1024

  {Adr1:=ParToInt(ParamStr(3));
  Adr2:=ParToInt(ParamStr(4));
  Size:=ParToInt(ParamStr(5));

  AssignFile(F, ParamStr(1));
  Reset(F,1);
  AssignFile(FW, ParamStr(2));
  Rewrite(FW,1);
  GetMem(Buf, Size+4);
  GetMem(WBuf, Size+4);
  Seek(F,Adr1);
  BlockRead(F, Buf^, Size+4);
  Seek(F,Adr2);
  BlockRead(F,WBuf^,Size+4);
  DW1:=Addr(Buf^);
  DW2:=Addr(WBuf^);
  For n:=0 To (Size div 4)-1 do
  begin
    WriteLn(IntToHex(DW1^ XOR DW2^,8));
    DW1^:=DW1^ XOR DW2^;
    Inc(DW1); Inc(DW2);
  end;
  Seek(FW,0);
  BlockWrite(FW, Buf^, Size);
  FreeMem(Buf);
  FreeMem(WBuf);
  CloseFile(F);
  CloseFile(FW);}
  { TODO -oUser -cConsole Main : Insert code here }
  ReadLn;
end.
