program FFTExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, Classes, StrUtils;

Type
  THead = Packed Record
  FileCount: DWord;
  AdrPos: DWord;
  SizePos: DWord;
  DataPos: DWord;
  Pos: Array of DWord;
  Size: Array of DWord;
end;
  
var List: TStringList; Buf: Pointer; F,FW: File; Head: THead;
n: Integer; Name: String;
begin
  AssignFile(F,'_FFT\fftpack.bin');
  Reset(F,1);
  BlockRead(F, Head, 16);
  SetLength(Head.Pos, Head.FileCount);
  SetLength(Head.Size, Head.FileCount);
  Seek(F, Head.AdrPos);
  BlockRead(F, Head.Pos[0], Head.FileCount*4);
  Seek(F, Head.SizePos);
  BlockRead(F, Head.Size[0], Head.FileCount*4);
  List:=TStringList.Create;
  For n:=0 To Head.FileCount-1 do
  begin
    //Name:=IntToHex(Head.Pos[n],8)+'.BIN';
    Name:='File'+RightStr('000'+IntToStr(n),4);
    List.Add(Name);
    WriteLn(List.Strings[n]);
    AssignFile(FW, '_FFT\FFTDATA\'+Name);
    Rewrite(FW,1);
    GetMem(Buf, Head.Size[n]);
    Seek(F, Head.Pos[n]);
    BlockRead(F, Buf^, Head.Size[n]);
    BlockWrite(FW, Buf^, Head.Size[n]);
    CloseFile(FW);
    FreeMem(Buf);
  end;
  CloseFile(F);
  List.SaveToFile('FFTDATA\LIST.LST');
  List.Free;
  { TODO -oUser -cConsole Main : Insert code here }
end.
