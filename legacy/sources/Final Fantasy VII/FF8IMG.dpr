program FF8IMG;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, Classes, FF7_Common;

Type
  TFF8IMGHeader = Record
    LBA:   DWord;
    Size:  DWord;
  end;

var WF,F: File; Size: Integer; Head: Array[0..132] of TFF8ImgHeader;
n: Integer; Buf: Pointer; List: TStringList; PrevLBA: DWord;
begin
  PrevLBA:=826;
  AssignFile(F,ParamStr(1));
  Reset(F,1);
  BlockRead(F,Head[0],133*8);
  List:=TStringList.Create;
  For n:=0 To High(Head) do
  begin
    Seek(F, (Head[n].LBA-826)*$800);
    GetMem(Buf,Head[n].Size);
    BlockRead(F,Buf^,Head[n].Size);
    WriteLn(Format('File #%d',[n]));
    AssignFile(WF, Format('%s\File%d',[ParamStr(2),n]));
    Rewrite(WF,1);
    BlockWrite(WF,Buf^,Head[n].Size);
    CloseFile(WF);
    FreeMem(Buf);
    List.Add(Format('File%d'#9'Def: %d',[n, Head[n].LBA-PrevLBA]));
    PrevLBA:=Head[n].LBA + (RoundBy(Head[n].Size,$800) div 800);
  end;
  List.SaveToFile(Format('%s\List.txt',[ParamStr(2)]));
  CloseFile(F);

  { TODO -oUser -cConsole Main : Insert code here }
end.
