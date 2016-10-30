program compress_test;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FF8_compression in '..\FF8_compression.pas',
  FF8_Dat in '..\FF8_Dat.pas';

var
  F: File;
  Buf: Pointer;
  WBuf: Array[0..1024*1024*16-1] of Byte;
  Len: Integer;

  Dat: TFF8Dat;
begin
  Dat := TFF8Dat.Create;
  Dat.LoadFromFile('_job\FF8\Dat\bghoke_2.dat');
  //Dat.ExportFileToFile(dfMSD, 'bghoke_2.msd');
  //Dat.ImportFile(TDatFileType(0), nil, 0);
  Dat.SaveToFile('Cutted.dat');
                                           
  Dat.Free;

  Exit;
  AssignFile(F, 'BOOT.BIN'{'compress_test.dpr'});
  Reset(F, 1);
  Len := FileSize(F);
  GetMem(Buf, Len);
  BlockRead(F, Buf^, Len);
  CloseFile(F);
  If not lzs_compress(Buf, Len, @WBuf, Len) Then
    Exit;

  //AssignFile(F, 'compr.lzs');
  //Rewrite(F, 1);
  //BlockWrite(F, WBuf, Len

  lzs_decompress(@WBuf[4], Len - 4, Buf, Len);
  AssignFile(F, 'compr.bin');
  Rewrite(F, 1);
  BlockWrite(F, Buf^, Len);
  CloseFile(F);
  FreeMem(Buf);
  WriteLn('Done!');
  { TODO -oUser -cConsole Main : Insert code here }
end.
