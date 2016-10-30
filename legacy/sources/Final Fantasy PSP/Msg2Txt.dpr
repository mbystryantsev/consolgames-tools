program Msg2Txt;

{$APPTYPE CONSOLE}



uses
  SysUtils, Classes, Windows, StrUtils;


Type
  TFontHead = Packed Record
  Sign: Array[0..7] of byte;
  Byte1: Byte;
  Count: Word;
  Byte2: Byte;
  Size: DWord;
end;


TLines = Packed Record
  Table: String;
  Line: Array of String;
end;


TMsg = Packed Record
  Sign: Array[0..7] of Char;
  Count: DWord;
  Size: DWord;
  Name: String;
  Text: Array of String;
end;


Type
  TTable = Record
  Value: Word;
  Text: String;
end;

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char; HexError: Boolean;
begin
 HexError := True;
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 HexError := False;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   HexError := True;
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;

var Msg: Array of TMsg; Codes: Array[0..136] of Word;
Procedure SaveMsg(S: String);
var n,m: Integer; MsgList: TStringList;
begin
  MsgList:=TStringList.Create;
  For n:=0 to Length(Msg)-1 do
  begin
    MsgList.Add(Format('[%s,%d]',[Msg[n].Name,Msg[n].Count SHR 8]));
    MsgList.Add('');
    For m:=0 to Length(Msg[n].Text)-1 do
    begin
      MsgList.Add(Msg[n].Text[m]);
      MsgList.Add('');
    end;
  end;
  MsgList.SaveToFile(S);
end;

var Table: Array of TTable;
Procedure LoadTable(S: String);
var F: File; List: TStringList; n: Integer;
begin
  SetLength(Table,0);
  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 to List.Count-1 do
  begin
    If ((Length(List.Strings[n])=4) or (Length(List.Strings[n])=7)) and
    (MidStr(List.Strings[n],3,1)='=') then
    begin
      SetLength(Table, Length(Table)+1);
      Table[Length(Table)-1].Value :=
      HexToInt(LeftStr(List.Strings[n], Pos('=',List.Strings[n])-1));
      Table[Length(Table)-1].Text:=RightStr(List.Strings[n],
      Length(List.Strings[n])-Pos('=',List.Strings[n]));
      //WriteLn(IntToHex(Table[Length(Table)-1].Value, (Table[Length(Table)-1].Value
      //div 256+1)*2)+'='+Table[Length(Table)-1].Text);
    end;
  end;
end;


//44 - Stop Byte
//CE - New Lint
var FontCount: Integer;
Procedure AddMsg(S: String; FontCount: Word);
var F: File; Buf: Pointer;  n,m,l: Integer; Ptr: Array of DWord;
B: ^Byte; W: ^Word; MMsg: TMsg; V: Byte; Flag: Boolean;
begin
  SetLength(Msg, Length(Msg)+1);
  mMsg.Name:=S;
  AssignFile(F, ParamStr(1)+'\'+S);
  Reset(F,1);
  BlockRead(F, mMsg, 16);
  SetLength(Ptr, mMsg.Count SHR 8);
  SetLength(mMsg.Text, mMsg.Count SHR 8);
  Seek(F, 16);
  BlockRead(F,Ptr[0],(mMsg.Count SHR 8)*4);
  GetMem(Buf, FileSize(F));
  Seek(F,0);
  BlockRead(F, Buf^, FileSize(F));
  CloseFile(F);
  For n:=0 to (mMsg.Count SHR 8)-1 do
  begin
    B:=Addr(Buf^);
    Inc(B, Ptr[n]);
    W:=Addr(B^);
    //V:=B^;
    While (Length(mMsg.Text[n])=0) or ((Length(mMsg.Text[n])>0) and (RightStr(mMsg.Text[n],1)<>'/'))  do
    begin
      For m:=0 To Length(Table)-1 do
      begin
        If (Table[m].Value=W^) or (Table[m].Value=B^) then
        begin
          If Table[m].Text<>'^' Then mMsg.Text[n]:=mMsg.Text[n]+Table[m].Text;
          If Table[m].Value<=255 Then Inc(B) else Inc(B,2);
          If Table[m].Text='^' then
          begin
            If mMsg.Text[n]='' then mMsg.Text[n]:=mMsg.Text[n]+'^'+#13#10
            else mMsg.Text[n]:=mMsg.Text[n]+#13#10;
          end;
          W:=Addr(B^);
          Break;
        end;
        If m=Length(Table)-1 then
        begin
          Flag:=False;
          //For l:=0 to length(Codes)-1 do
          //begin
            //If (Codes[l]<>$FFFF) and ((W^=Codes[l]) or (B^=Codes[l])) then
            If B^>FontCount then
            begin
              mMsg.Text[n]:=mMsg.Text[n]+'<'+IntToHex(B^-FontCount,2){+','+IntToHex(Codes[l],4)}+'>';
              //If Codes[l]>255 then Inc(B);
              Flag:=True;
              //Break;
            end;
          //end;
          If Flag=False Then
          mMsg.Text[n]:=mMsg.Text[n]+'{'+IntToHex(B^,2)+'}';
          Inc(B); W:=Addr(B^);
        end;
      end;

    end;
    //WriteLn(mMsg.Text[n]);
  end;
Freemem(Buf);
Msg[Length(Msg)-1]:=mMsg;
end;

//var FntCount: Word;
Procedure LoadCodes(S: String);
var F: File; Count: Word; n: Integer; Cds: Array[0..136] of Word;
begin
  AssignFile(F,S);
  Reset(F,1);
  Seek(F, 2);
  BlockRead(F, Count, 2);
  FontCount:=Count;
  Seek(F,6);
  BlockRead(F, Codes, 137*2);
  CloseFile(F);
  For n:=0 To Length(Codes)-1 do
  begin
    If Codes[n]<>$FFFF then Codes[n]:=Count+Codes[n]+1;
  end;
end;

var S: String; Buf: Pointer; SR, SF, ST: TSearchRec;
begin
  If FindFirst(ParamStr(1)+'\*.*',  faAnyFile, SR) = 0 then
  begin
    Repeat
      If SR.Attr and faDirectory = faDirectory then
      begin
        Writeln(SR.Name+':');
        If FindFirst(ParamStr(1)+'\'+SR.Name+'\*.FIF',  faAnyFile, SF) = 0 then
        begin
          If (SR.Name <> '.') and (SR.Name <> '..') then
          begin
            If SF.Attr and faDirectory <> faDirectory then
            begin
              Writeln('    '+SF.Name);
              S:=ParamStr(1)+'\'+SR.Name+'\'+SF.Name;
              LoadTable(LeftStr(S,Length(S)-3)+'TBL');
              LoadCodes(S);
              SysUtils.FindClose(SF);
                If FindFirst(ParamStr(1)+'\'+SR.Name+'\*.MSG',  faAnyFile, SF) = 0 then
                begin
                  repeat
                    If (SF.Name <> '.') and (SF.Name <> '..') and
                    (SF.Attr and faDirectory <> faDirectory) then
                    begin
                      Writeln('    '+SF.Name);
                      AddMsg(SR.Name+'\'+SF.Name, FontCount);
                    end;
                  Until FindNext(SF) <> 0;
                end;
            end;
            SysUtils.FindClose(SF);
          end;
        end;
      end;
    Until FindNext(SR) <> 0;
      SysUtils.FindClose(SR);
    end;
    SaveMsg('FF1.txt');
end.
