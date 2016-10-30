program FFTTextExtractor;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils, Windows, Classes, FFT;

Type
TStringArray = Array of String;

TText = Packed Record
  BBegin, BEnd, PEnd: DWord;
  Name: String;
  Compr: Boolean;
  Text: TStringArray;
end;





var Table: TTableArray;
Msg: Array[0..15] of TText = (
(BBegin: $80;     BEnd: $160D4; PEnd: $0;     Name: 'atchelp.lzw';  Compr: False), // 1A3A
(BBegin: $E330;   BEnd: $10116; PEnd: $10116; Name: 'attack.out';   Compr: False), // 990
(BBegin: $10E78;  BEnd: $2445A; PEnd: $2445A; Name: 'bunit.out';    Compr: True ), // B10
(BBegin: $96BC;   BEnd: $A36D;  PEnd: $A36D;  Name: 'card.out';     Compr: False), // AD0
(BBegin: $10C58;  BEnd: $1968E; PEnd: $1968E; Name: 'equip.out';    Compr: True ), // 
(BBegin: $80;     BEnd: $169BF; PEnd: $0;     Name: 'help.lzw';     Compr: True ), // 
(BBegin: $1BB0;   BEnd: $184EF; PEnd: $18583; Name: 'helpmenu.out'; Compr: True ), // 
(BBegin: $6588;   BEnd: $10F5E; PEnd: $10F5E; Name: 'jobstts.out';  Compr: True ), // 
(BBegin: $80;     BEnd: $41F5;  PEnd: $0;     Name: 'join.lzw';     Compr: False), // 
(BBegin: $80;     BEnd: $5578;  PEnd: $0;     Name: 'open.lzw';     Compr: False), // 
(BBegin: $CEF0;   BEnd: $11065; PEnd: $11065; Name: 'require.out';  Compr: False), // 
(BBegin: $80;     BEnd: $4B87;  PEnd: $0;     Name: 'sample.lzw';   Compr: False), // 
(BBegin: $0;      BEnd: $3704;  PEnd: $0;     Name: 'spell.mes';    Compr: False), // 
(BBegin: $EC;     BEnd: $1ED2;  PEnd: $0;     Name: 'small.out';    Compr: False), // 
(BBegin: $80;     BEnd: $1ADE3; PEnd: $0;     Name: 'wldhelp.lzw';  Compr: True ), //!!
(BBegin: $80;     BEnd: $E2DC;  PEnd: $0;     Name: 'world.lzw';    Compr: True)); //

var SBuf: Pointer; F: File; SText: String; List: TStringList;
n,Size: Integer;
begin
  N:=14;
  //S:='FFT\FFTTable.tbl';
  LoadTable('FFT\FFTTable.tbl', Table);
  List:=TStringList.Create;
  For n:=0 To Length(Msg)-1 do
  begin
    WriteLn(Msg[n].Name);
    List.Add('['+Msg[n].Name+']');
    List.Add('');  
    AssignFile(F,'FFT\TEXT\'+Msg[n].Name);
    Reset(F,1);
    GetMem(SBuf, Msg[n].BEnd-Msg[n].BBegin+1);
    Seek(F, Msg[n].BBegin);
    BlockRead(F, SBuf^, Msg[n].BEnd-Msg[n].BBegin+1);
    CloseFile(F);
    If Msg[n].Compr Then
    begin
      Size:=Msg[n].BEnd-Msg[n].BBegin+1;
      Size:=Decompress(SBuf,Msg[n].BEnd-Msg[n].BBegin+1);
      //Size:=Decompress(SBuf,Size);
      //Size:=Decompress(SBuf,Size);
      ExtractText(SBuf, Table,Decompress(SBuf,Size),SText);
      //ExtractText(SBuf, Table,Decompress(SBuf,Size),SText);
    end
    else ExtractText(SBuf, Table, Msg[n].BEnd-Msg[n].BBegin+1, SText);
    FreeMem(SBuf);
    List.Text:=List.Text+SText;
    //List.Add(SText);
    SText:='';
    //List.SaveToFile('FFT\TEXT\'+Msg[n].Name+'.txt');
    //List.Clear;
  end;
  List.SaveToFile('FFT\TEXT\FFTTest1.txt');
  List.Free;

  { TODO -oUser -cConsole Main : Insert code here }
end.
