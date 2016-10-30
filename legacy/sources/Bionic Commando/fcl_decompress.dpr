program fcl_decompress;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, ZlibEx;

Type
  DWord = LongWord;
  TDataRecord = Packed Record
    Offset: DWord;
    Size:   DWord;
  end;
  TDataArray = Array[Word] of TDataRecord;

var
  F: File;
  Count, BlockSize: DWord;
  Size: Integer;
  Data:  ^TDataArray;
  n: Integer; SrcBuf, DestBuf: Pointer;
  Stream, OutStream: TFileStream;

begin
  If ParamCount < 2 Then
    Exit;
  //Assign(F, ParamStr(1));
  //Reset(F);
  Stream := TFileStream.Create(ParamStr(1), fmOpenRead);
  Stream.Read(Count, 4);
  Stream.Read(BlockSize, 4);
  //BlockRead(F, Count, 4);
  //BlockRead(F, Count, 4);
  //BlockRead(F, BlockSize, 4);
  GetMem(Data, Count * 8);
  Stream.Read(Data^, Count * 8);
  GetMem(SrcBuf, BlockSize + BlockSize div 16);
  //GetMem(DestBuf, BlockSize);
  AssignFile(F, ParamStr(2));
  Rewrite(F, 1);
  CloseFile(F);
  OutStream := TFileStream.Create(ParamStr(2), fmOpenWrite);
  For n := 0 To Count -1 do
  begin
    Stream.Seek(Data^[n].Offset, 0);
    Stream.Read(SrcBuf^, Data^[n].Size);
    ZDecompress(SrcBuf, Data^[n].Size, DestBuf, Size, BlockSize);
    OutStream.Write(DestBuf^, BlockSize);
    FreeMem(DestBuf);
  end;


  FreeMem(SrcBuf);
  FreeMem(Data);
  //FreeMem(DestBuf);
  Stream.Free;
  OutStream.Free;
  WriteLn('Done!');
  ReadLn;


  { TODO -oUser -cConsole Main : Insert code here }
end.
