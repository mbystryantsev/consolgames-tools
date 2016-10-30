program WinxText;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils,
  TextUnit in 'TextUnit.pas';

Type
  DWord = LongWord;

var
  MText: TText;

const
  cTegOpen =  '<text_data>';
  cTegClose = '</text_data>';
  cMarqueOpen = '<marqueetext>';
  cMarqueClose = '</marqueetext>';

Function ExtractXMLText(P: Pointer; var Msg: TMessageArray; FSize: Integer;
TegOpen: String = cTegOpen; TegClose: String = cTegClose): Integer;
var Count,Pos,NPos,Len: Integer; PC: PChar; S: String; NotNull: Boolean;
begin
  Count := 0;
  Result:=0;
  NPos:=1;
  PC:=P;
  NotNull := False;
  While True do
  begin
    Pos:=PosEx(TegOpen,PC,NPos);
    If Pos=0 Then Break;
    NPos:=PosEx(TegClose,PC,NPos);
    Len:=NPos-Pos-{11}Length(TegOpen);
    S := MidStr(PC,Pos+{11}Length(TegOpen),Len);
    If S <> 'null' Then NotNull := True;
    SetLength(Msg,Count+1);
    Msg[Count].Text := S;
    Inc(Count);
    Inc(NPos,Length(TegClose){12});
  end;
  If not NotNull Then Finalize(Msg);
  Result:=Length(Msg);
end;

Procedure ExtractDialogText(P: Pointer; var Msg: TMessageArray; GameText: Boolean = False);
var n: Integer; Ptr: ^DWord; Count: DWord; S: PChar; NPtr: ^Word;
begin
  Ptr:=P;
  Count:=Ptr^;
  Inc(Ptr);
  If GameText Then SetLength(Msg,Count) else SetLength(Msg,Count div 6);
  For n:=0 To Count-1 do
  begin
    If GameText Then
    begin
      NPtr:=Pointer(DWord(P)+Ptr^+4);
      S:=Pointer(DWord(NPtr)+NPtr^-4);
      Msg[n].Text := S;
      Inc(NPtr);
      S:=Pointer(DWord(NPtr)+NPtr^-6);
      Msg[n].Text:=Format('%s'#13#10'%s',[Msg[n].Text,S]);
    end else
    begin
      If (n div 6)*6 = n Then
      begin
        S:=Pointer(DWord(P)+Ptr^);
        Msg[n div 6].Text := S;
      end;
    end;
    Inc(Ptr);
  end;
end;

Function BuildDialogText(P: Pointer; Text: TText; ID: Integer; GameText: Boolean = False): Integer;
var Pos: Pointer; Ptr: ^DWord; n,m,Len,SLen: Integer; W: ^Word; NStart: Integer;
S: String;
begin
  If GameText Then DWord(P^):=Length(Text[ID].S)
  else DWord(P^):=Length(Text[ID].S)*6;
  Len:=DWord(P^)*4+4;
  Ptr:=P; Inc(Ptr);
  For n:=0 To High(Text[ID].S) do
  begin                    
    If Text[ID].S[n].Retry Then
      S := Text[FindMessage(Text[ID].S[n].RName,Text)].S[Text[ID].S[n].RID].Text
    else
      S := Text[ID].S[n].Text;

    Pos:=Pointer(DWord(P)+Len);
    SLen:=Length(S);
    If not GameText Then
    begin            
      For m:=0 to 5 do
      begin
        Ptr^:=Len;
        Inc(Ptr);
      end;
      Move(S[1],Pos^,SLen);
      Inc(Len,RoundBy(SLen+1,4));
    end else
    begin
      NStart:=PosEx(#13#10,S);
      Ptr^:=Len;  Inc(Ptr);
      DWord(Pos^):=7;
      W:=Pos; Inc(W,2);
      W^:=$14; Inc(W);
      For m:=0 To 5 do
      begin
        W^:=$14+RoundBy(NStart,4); Inc(W);
      end;
      W:=Pos; Inc(DWord(W),$14);
      Move(S[1],W^,NStart-1);
      Inc(DWord(W),RoundBy(NStart,4));
      Move(S[NStart+2],W^,SLen-(NStart+1));
      Inc(Len,DWord(W)-DWord(Pos)+RoundBy(SLen-NStart,4));
    end;
  end;
  Result:=Len;
end;

Procedure ExtractDialogs(Folder: String; var Text: TText);
var SR: TSearchRec; FileCount,Count: Integer; Buf: Pointer;
begin
  If FindFirst(Folder+'\*.loc',  faAnyFile, SR) <> 0 then Exit;
  FileCount:=0;
  Repeat
    SetLength(Text,FileCount+1);
    Text[FileCount].Name := ExtractFileName(SR.Name);
    LoadFile(Format('%s\%s',[Folder,SR.Name]),Buf);
    ExtractDialogText(Buf,Text[FileCount].S,Text[FileCount].Name='gametext.loc');
    Inc(FileCount);
    FreeMem(Buf);
  Until (FindNext(SR) <> 0);
end;

Procedure BuildDialogs();
var n,FSize: Integer; Buf: Pointer;
begin
//      0        1    2        3        4
// winxtext.exe -bd text.txt text.idx OutFolder
  OpenOpt (ParamStr(3), MText);
  OpenText(ParamStr(2), MText);
  GetMem(Buf,$40000);
  For n:=0 To High(MText) do
  begin
    FillChar(Buf^,$40000,0);
    FSize:=BuildDialogText(Buf,MText,n,MText[n].Name = 'gametext.loc');
    SaveFile(Format('%s\%s',[ParamStr(4),MText[n].Name]),Buf,FSize);
  end;
  FreeMem(Buf);
end;

Procedure ExtractXMLs(Folder: String; var Text: TText; TegOpen: String = cTegOpen; TegClose: String = cTegClose);
var SR: TSearchRec; FileCount,Count,FSize,n: Integer; Buf: Pointer; FName: String;
const YES: Array[0..3] of String = ('scene10_5mx.agbm','scene1_3fx.agbm','scene1_4sx.agbm',
'scene2_6bx.agbm');
NO: Array[0..3] of String = ('coming_soon.agbm','story.agbm','dialog.agbm','options_tecna.agbm');
begin
//      0        1    2        3        4
// winxtext.exe -ex InFolder text.txt text.idx

  If FindFirst(Folder+'\*.agbm',  faAnyFile, SR) <> 0 then Exit;
  FileCount:=0;
  Repeat
    FName:=ExtractFileName(SR.Name);
    For n:=0 To High(NO) do If NO[n]=FName Then Break;
    If n<Length(NO) Then Continue;
    If (LeftStr(FName,5)='scene') or (LeftStr(FName,14)='transformation') Then
    begin
      If ParamStr(5) <> '-m' Then
      begin
        For n:=0 To High(YES) do If YES[n]=FName Then break;
        If n=Length(Yes) Then Continue;
      end;
    end;
    SetLength(Text,FileCount+1);
    Text[FileCount].Name := FName;
    LoadFile(Format('%s\%s',[Folder,SR.Name]),Buf);
    If ExtractXMLText(Buf,Text[FileCount].S,FSize, TegOpen, TegClose)>0 Then Inc(FileCount);
    FreeMem(Buf);
  Until (FindNext(SR) <> 0);
  SetLength(Text,FileCount);
end;

Function BuildXMLText(Text: TText; ID: Integer; XMLBuf: Pointer; InSize: Integer; OutBuf: Pointer;
TegOpen: String = cTegOpen; TegClose: String = cTegClose): Integer;
var Count,Pos,NPos,Len,n: Integer; PC: PChar; WPos: ^Byte; S: String;
{const
  TegOpen  = '<text_data>';
  TegClose = '</text_data>';}
begin
  Count := 0;
  Result:=0;
  NPos:=1;
  PC:=XMLBuf;
  WPos:=OutBuf;
  //WriteLn(High(Msg));
  For n:=0 To High(Text[ID].S) do
  begin

    Pos:=PosEx(TegOpen,PC,NPos);
    If Pos=0 Then Break;

    If Text[ID].S[n].Retry Then
      S := Text[FindMessage(Text[ID].S[n].RName,Text)].S[Text[ID].S[n].RID].Text
    else
      S := Text[ID].S[n].Text;
    //WriteLn(S);

    If NPos=1 Then
    begin
      Move(Pointer(DWord(XMLBuf))^,WPos^,Pos-NPos+Length(TegOpen));
      Inc(WPos,Pos-1+Length(TegOpen));
    end else
    begin
      Move(Pointer(DWord(XMLBuf)+NPos-1-Length(TegClose))^,WPos^,Pos-NPos+Length(TegOpen)++Length(TegClose));
      //WriteLn(PChar(WPos));
      Inc(WPos,Pos-NPos+Length(TegOpen)+Length(TegClose));
    end;


    Move(S[1],WPos^,Length(S));
    
    //WriteLn(PChar(WPos));

    Inc(WPos,Length(S));

    NPos:=PosEx(TegClose,PC,NPos);
    Len:=NPos-Pos-Length(TegOpen);

    Inc(NPos,Length(TegClose));
    Inc(Count);
  end;
  Move(Pointer(DWord(XMLBuf)+NPos-1-Length(TegClose))^,WPos^,Length(PC)-NPos+1+Length(TegClose));
  Inc(WPos,Length(PC)-NPos+1+Length(TegClose));
  Result:=DWord(WPos)-DWord(OutBuf);
end;

Procedure BuildXMLs();
var n,FSize: Integer; Buf,XMLBuf: Pointer;
begin
//      0        1    2        3         4         5      6
// winxtext.exe -bx text.txt text.idx InFolder OutFolder [-m]
  OpenOpt (ParamStr(3), MText);
  OpenText(ParamStr(2), MText);
  GetMem(Buf,$40000);
  For n:=0 To High(MText) do
  begin
    FillChar(Buf^,$40000,0);
    FSize := LoadFile(Format('%s\%s',[ParamStr(4),MText[n].Name]), XMLBuf);
    If ParamStr(6) = '-m' Then
      FSize := BuildXMLText(MText, n, XMLBuf, FSize, Buf, cMarqueOpen, cMarqueClose)
    else
      FSize := BuildXMLText(MText, n, XMLBuf, FSize, Buf);
    SaveFile(Format('%s\%s',[ParamStr(5),MText[n].Name]),Buf,FSize);
  end;
  FreeMem(Buf);
end;

begin
 If ParamCount<4 Then
 begin
  WriteLn('Use: WinxText.exe <command> <In> <out>');
  Exit;
 end;
 If ParamStr(1)='-ed' Then
 begin
  ExtractDialogs(ParamStr(2),MText);
  SaveText(ParamStr(3),MText);
  SaveOpt(ParamStr(4),MText)
 end else
 If ParamStr(1)='-bd' Then
  BuildDialogs
 else
 If ParamStr(1)='-ex' Then
 begin
  // -ex files Marque.txt Marque.idx -m
  If ParamStr(5) = '-m' Then
    ExtractXMLs(ParamStr(2),MText, cMarqueOpen, cMarqueClose)
  else
    ExtractXMLs(ParamStr(2),MText);
  OptimizeText(MText);
  SaveText(ParamStr(3),MText);
  SaveOpt(ParamStr(4),MText)
 end else
 If ParamStr(1)='-bx' Then
  // -bx Menus.txt Menus.idx files RUS\XML
  // -bx Marque.txt Marque.idx RUS\XML RUS\XML -m
  BuildXMLs;
  WriteLn('Done!');
  { TODO -oUser -cConsole Main : Insert code here }
end.
