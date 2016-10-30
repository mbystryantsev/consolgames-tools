program EvPaster;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows,
  FFT;

Type

TStringArray = Array of String;
TText = Packed Record
  BBegin, BEnd, PEnd: DWord;
  Name: String;
  Compr: Boolean;
  Text: TStringArray;
end;

TFlag = Packed Record
  Compress  ,
  NCompress ,
  NPaste    ,
  Paste     ,
  Ignore    : Boolean;
end;

var Table: TTableArray;
mMsg: Array[0..15] of TText = (
(BBegin: $80;     BEnd: $160D4; PEnd: $0;     Name: 'atchelp.lzw';  Compr: False),
(BBegin: $E330;   BEnd: $10116; PEnd: $10116; Name: 'attack.out';   Compr: False),
(BBegin: $10E78;  BEnd: $2445A; PEnd: $2445A; Name: 'bunit.out';    Compr: True ),
(BBegin: $96BC;   BEnd: $A36D;  PEnd: $A36D;  Name: 'card.out';     Compr: False),
(BBegin: $10C58;  BEnd: $1968E; PEnd: $1968E; Name: 'equip.out';    Compr: True ),
(BBegin: $80;     BEnd: $169BF; PEnd: $0;     Name: 'help.lzw';     Compr: True ),
(BBegin: $1BB0;   BEnd: $184EF; PEnd: $18583; Name: 'helpmenu.out'; Compr: True ),
(BBegin: $6588;   BEnd: $10F5E; PEnd: $10F5E; Name: 'jobstts.out';  Compr: True ),
(BBegin: $80;     BEnd: $41F5;  PEnd: $0;     Name: 'join.lzw';     Compr: False),
(BBegin: $80;     BEnd: $5578;  PEnd: $0;     Name: 'open.lzw';     Compr: False),
(BBegin: $CEF0;   BEnd: $11065; PEnd: $11065; Name: 'require.out';  Compr: False),
(BBegin: $80;     BEnd: $4B87;  PEnd: $0;     Name: 'sample.lzw';   Compr: False),
(BBegin: $0;      BEnd: $3704;  PEnd: $0;     Name: 'spell.mes';    Compr: False),
(BBegin: $EC;     BEnd: $1ED2;  PEnd: $0;     Name: 'small.out';    Compr: False),
(BBegin: $80;     BEnd: $1ADE3; PEnd: $0;     Name: 'wldhelp.lzw';  Compr: True ), //!!
(BBegin: $80;     BEnd: $E2DC;  PEnd: $0;     Name: 'world.lzw';    Compr: True));


//EvPaster.exe FFTTest.opt.txt FFTTest.fid FFTTable.tbl EVENT
var n,m,Size, ErCnt: Integer; Msg: TMessageArray; fCompr: Boolean;
Text: String; FDir: String; Buf: Pointer; Flag: TFlag; F: File;
begin
  If (ParamCount<3) or (not FileExists(ParamStr(1)))
  or (not FileExists(ParamStr(2))) or (not FileExists(ParamStr(3))) Then
  begin
    WriteLn('Недостаточно параметров (минимум 3), либо указаны несуществуюшие файлы');
    Exit;
  end;
  ErCnt:=0;
  If (ParamStr(4)<>'') and (ParamStr(4)<>'-c') and (ParamStr(4)<>'-n')
  and (ParamStr(4)<>'-s') and (ParamStr(4)<>'-p') and (ParamStr(4)<>'-i') Then FDir:=ParamStr(4);
  For n:=4 to ParamCount do
  begin
    If ParamStr(n)='-c' Then Flag.Compress:=True;
    If ParamStr(n)='-n' Then Flag.NCompress:=True;
    If ParamStr(n)='-s' Then Flag.NPaste:=True;
    If ParamStr(n)='-i' Then Flag.Ignore:=True;
    If ParamStr(n)='-p' Then Flag.Paste:=True;
  end;
  GetMem(Buf, $80000);
  SetLength(Msg,0);
  LoadOptText(ParamStr(1), ParamStr(2), Msg, False);
  LoadTable(ParamStr(3), Table);
  For n:=0 To Length(Msg)-1 do
  begin
    If mMsg[n].PEnd>0 Then mMsg[n].BEnd:=mMsg[n].PEnd;

    Text:='';
    For m:=0 To Length(Msg[n].R)-1 do
      Text:=Text+Msg[n].R[m].Text;
    If FileExists(FDir+Msg[n].Name) Then
    begin
      Size:=PasteText(Text,Table,Buf);
      fCompr:=False;
      If Flag.Compress or ((mMsg[n].PEnd>0) and (Size>mMsg[n].PEnd-mMsg[n].BBegin+1)
      and not mMsg[n].Compr)
      or mMsg[n].Compr and not Flag.NCompress then
      begin
        Size:=Compress(Buf, Size);
        fCompr:=True;
      end;
      If ((mMsg[n].PEnd>0) and (Size<=mMsg[n].PEnd-mMsg[n].BBegin+1)) or
      (not Flag.NPaste and (mMsg[n].PEnd=0)) or Flag.Ignore or Flag.Paste then
      begin
        If Flag.Paste and (Size>mMsg[n].PEnd-mMsg[n].BBegin+1) then
          Size:=mMsg[n].PEnd-mMsg[n].BBegin+1;
        AssignFile(F, FDir+Msg[n].Name);
        Reset(F,1);
        Seek(F, Msg[n].Adr1);
        BlockWrite(F, Buf^, Size);
        CloseFile(F);
        WriteLn(Format('[%d/%d] Sucesfully pasted %d bytes. Compression: %s (%s)',
        [n+1,Length(Msg),Size,fBoolToStr(fCompr),Msg[n].Name]));
      end else
      begin
          WriteLn(Format('[%d/%d] ERROR! Not enough space [%d bytes] Compression: %s (%s)',
          [n+1,Length(Msg),Size-(mMsg[n].BEnd-mMsg[n].BBegin+1),fBoolToStr(fCompr),Msg[n].Name]));
          Inc(ErCnt);
      end;
    end else
    begin
      WriteLn(Format('[%d/%d] ERROR! File not found (%s)',[n+1,Length(Msg),FDir+Msg[n].Name]));
      Inc(ErCnt);
    end;
  end;
  WriteLn(Format('%d errors in %d files.',[ErCnt,Length(Msg)]));
  FreeMem(Buf);
  //ReadLn;

end.
