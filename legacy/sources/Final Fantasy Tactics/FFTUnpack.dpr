program FFTUnpack;

{$APPTYPE CONSOLE}

uses
  SysUtils, FFTPacker;
var F: File; Buf: Pointer; Size: Integer;
begin

  AssignFile(F, 'FFT\TEXT\HELP.LZW');
  Reset(F,1);
  Size:=FileSize(F)-128;
  GetMem(Buf, Size);
  Seek(F,128);
  BlockRead(F, Buf^, Size);
  CloseFile(F);
  AssignFile(F, 'FFT\TEXT\HELP.LZW.UNP');
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F,Buf^,Decompress(Buf, Size));
  CloseFile(F);
  FreeMem(Buf);

  { TODO -oUser -cConsole Main : Insert code here }
end.
