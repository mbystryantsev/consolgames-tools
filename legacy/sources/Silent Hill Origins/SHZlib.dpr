program SHZlib;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  SH0_Compression;

var Dest: String; F: File; Buf: Pointer; Size: Integer;
begin
  If ParamStr(1) = '' Then Exit;
  AssignFile(F, ParamStr(1));
  Reset(F, 1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);
  Size := Z_Compress(Buf, Size);

  Dest := ParamStr(2);
  If Dest = '' Then Dest := ParamStr(1) + '.zlib';
  AssignFile(F, Dest);
  Rewrite(F, 1);
  BlockWrite(F, Buf^, Size);
  CloseFile(F);
  FreeMem(Buf);
  { TODO -oUser -cConsole Main : Insert code here }
end.
 