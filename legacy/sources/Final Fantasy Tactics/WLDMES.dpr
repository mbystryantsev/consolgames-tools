program WLDMES;

{$APPTYPE CONSOLE}

uses
  SysUtils, FFT, Windows, Classes;

var F: File; Buf, WBuf: Pointer; WB,B: ^Byte; Table: TTableArray;
n, Pos, FSize, Size: Integer; DW: ^DWord; S, Text: String;
List: TStringList;
begin
  List:=TStringList.Create;
  Pos:=0;
  LoadTable('FFT\FFTTable.tbl', Table);
  AssignFile(F,'FFT\TEXT\WLDMES.BIN');
  Reset(F,1);
  FSize:=FileSize(F);
  GetMem(Buf, FSize);
  BlockRead(F,Buf^,FSize);
  CloseFile(F);
  GetMem(WBuf, $40000);
  While Pos<FSize do
  begin
    B:=Addr(Buf^);
    Inc(B, Pos);
    DW:=Addr(B^);
    Size:=0;
    WB:=Addr(WBuf^);
    S:='@@'+IntToHex(Pos,8)+'-';
    While DW^>0 do
    begin
      WB^:=B^; Inc(WB); Inc(B);
      DW:=Addr(B^);
      Inc(Size);
    end;
    Inc(Pos, RoundBy(Size,$B000));
    S:=S+IntToHex(Pos-1,8);
    Text:='';
    ExtractText(WBuf, Table, Size, Text);
    WriteLn(S);
    List.Add(S);
    List.Add('');
    List.Add(Text);
    List.Add('');
  end;
  List.SaveToFile('FTTTST.txt');
  List.Free;
end.
