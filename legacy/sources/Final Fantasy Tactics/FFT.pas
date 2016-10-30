unit FFT;

interface

uses
SysUtils, Windows, DIB, Classes, Messages, Dialogs, StrUtils;

Type

TPColor = DWord;

TPallete = Array[0..255] of TPColor;

TTable = Packed Record
  Text: String;
  Value: Word;
  D: Boolean;
end;

TTableArray = Array of TTable;



TColor = Word;

TPal = Array of TColor;

TPalArray = Packed Record
  Pal: TPal;
end;

THeader = Packed Record
  FootSize: DWord;
  FootPos: Word;
  Blank: DWord;
  Data: Word;
  ColorCount: Word;
  PalCount: Word;
  Add: Array[0..15] of Byte;
end;

TFooter = Packed Record
  Data: Word;
  TextFlag: Word;
  LineSize: Word;
  Height: Word;
  Flag: Byte;
end;

TOpenImage = Packed Record
  HeadSize: DWord;
  Head: THeader;
  Pal: Array of TPalArray;
  DataSize: DWord;
  Footer: TFooter;
  Pic: TDIB;
end;

TRead = Packed Record
  Read: Boolean;
  Msg: Word;
  Dlg: Word;
  Text: String;
end;

TMessage = Packed Record
  Name: String;
  Adr1: DWord;
  Adr2: DWord;
  R: Array of TRead;
end;

TMessageArray = Array of TMessage;

Function Compress(var Buf: Pointer; Size: Integer): Integer;
Function Decompress(var Buf: Pointer; Size: Integer): Integer;
Function HexToInt(S: String): Integer;
Function GetB(C: Word):   Byte;
Function GetG(C: Word):   Byte;
Function GetR(C: Word):   Byte;
Function GetPB(C: DWord): Byte;
Function GetPG(C: DWord): Byte;
Function GetPR(C: DWord): Byte;
Function GetPA(C: DWord): Byte;
Procedure RawToDib(var Pic: TDIB; Buf: Pointer);
Procedure DibToRaw(var Pic: TDIB; Buf: Pointer);
Procedure SetPal(Var Pic: TDIB; Pal: TPal);
Function GetBpp(C: Integer): Integer;
Function RoundBy(Value, R: Integer): Integer;
Procedure ExtractText(const Buf: Pointer; Table: TTableArray; Size: Integer; Var Text: String);
Function PasteText(Text: String; Table: TTableArray; var Buf: Pointer): Integer;
Procedure LoadTable(S: String; var Table: TTableArray);
Procedure SetPallete(Var Pic: TDIB; Pal: TPallete);
Procedure CopyMem(const Buf: pointer; var WBuf: Pointer; const Size: Integer);
Procedure OptText(var mMsg: TMessageArray);
Procedure LoadText(S: String; var mMsg: TMessageArray; Adr: Boolean);
Procedure SaveOpt(var mMsg: TMessageArray; const S: String; Adr: Boolean);
Procedure SaveOptText(var Msg: TMessageArray; const SText, SFid: String; Adr: Boolean);
Procedure LoadOpt(S: String; var mMsg: TMessageArray; Adr: Boolean);
Procedure LoadOptText(SText, SFid: String; var Msg: TMessageArray; Adr: Boolean);
Function fBoolToStr(B: Boolean): String;

implementation

Function Compress(var Buf: Pointer; Size: Integer): Integer;
var Pos, WPos,RPos,BestLink,n,m,MaxC,C,Link: Integer; Count,BestRes,Back: Word;
RB, B, WB, RPs, NPs: ^Byte; WBuf: Pointer;
begin
  MaxC:=$1EFF;
  C:=MaxC;
    C:=256;
  Pos:=0;
  WPos:=0;
  GetMem(WBuf, $100000);
  B:=Addr(Buf^);
  WB:=Addr(WBuf^);
  While Pos<=Size do
  begin
    Link:=Pos-C;
    If Link<0 Then Link:=0;
    BestRes:=0;
    For n:=Link to Pos-1 do
    begin
      NPs:=Addr(Buf^);
      RPs:=Addr(WBuf^);
      Inc(Nps,Pos);
      Inc(RPs,n);
      Count:=0;
      RPos:=n;
      While (RPos<Pos) and (RPs^<>$FE) do
      begin
        If NPs^=RPs^ Then Inc(Count)
        else Break;
        Inc(NPs); Inc(RPs);
        Inc(RPos);
      end;
      If Count>=BestRes Then
      begin
        BestRes:=Count;
        BestLink:=n;
      end;
    end;
    If BestRes>3 then
    begin
      WB^:=$F0+((BestRes-4) SHR 3) AND $F;
      Inc(WB);
      Back:=WPos-BestLink;
      Inc(Back,((Back-1) div $100)*2);
      If ((Back AND $00FF)<2){ or ((Back AND $0FF)=1|2|)} Then Inc(Back,2);
      WB^:=(((BestRes-4) AND $7) SHL 5)+((Back SHR 8) AND $1F);
      Inc(WB);
      WB^:=Back AND $FF;
      Inc(WB); Inc(WPos,3);
      Inc(Pos, BestRes);
      Inc(B, BestRes);
    end else
    begin
      WB^:=B^;
      Inc(WB); Inc(B); Inc(WPos); Inc(Pos);
    end;
  end;
  FreeMem(Buf);
  Buf:=WBuf;
  Result:=WPos-1;
end;


//  F    X     X    Y
// 1111 xxxx  xxxy yyyy  yyyy yyyy
//        Count        B a c k


{
(B0 AND 3) SHL 3
B1 SHR 5 + rB0 + 4 // 7
B1 And $F              // 0
((rB1 SHL 7 - rB1) SHL 1 + B2 : Link
}
Function Decompress(var Buf: Pointer; Size: Integer): Integer;
var WBuf: Pointer; WB, B, RB: ^Byte; Pos, WPos, n: Integer;
Back,Count: Word;
begin
  GetMem(WBuf, $40000);
  B:=Addr(Buf^); WB:=Addr(WBuf^);
  Pos:=0; WPos:=0;
  While (Pos<Size) do
  Begin
    If (B^>=$F0) and (B^<$F8) then
    begin
      Count:=(B^ AND 3) SHL 3; Inc(B);
      Count:=(B^ SHR 5) + Count + 4;
      Back:=B^ AND $F; Inc(B);
      Back:=(((Back SHL 7) - Back) SHL 1) + B^;
      Inc(B); Inc(Pos,3);
      RB:=B;
      Dec(RB, Back+3);
	  Move(RB^,WB^,Count);
      //For n:=1 to Count+4 do
      //begin
        //WB^:=RB^; Inc(WB); Inc(RB);
      //end;
	  Inc(WB,Count);
      Inc(WPos, Count);
    end else
    begin
      WB^:=B^;
      Inc(B); Inc(WB); Inc(Pos); Inc(WPos);
    end;
  end;
  FreeMem(Buf);
  Buf:=WBuf;
  Result:=WPos;
end;

Function fBoolToStr(B: Boolean): String;
begin
  If B Then Result:='True' else Result:='False';
end;

Procedure LoadOpt(S: String; var mMsg: TMessageArray; Adr: Boolean);
var n,m: Integer; List: TStringList; Flag: Boolean; //Str: String;
begin
  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 To List.Count-1 do
  begin
    If not adr and (LeftStr(List.Strings[n],1)='[') and (RightStr(List.Strings[n],1)=']') then
    begin
      Flag:=False;
      SetLength(mMsg, Length(mMsg)+1);
      mMsg[Length(mMsg)-1].Name:=MidStr(List.Strings[n],2,Length(List.Strings[n])-2);
    end else
    If adr and (LeftStr(List.Strings[n],2)='@@') then
    begin
      Flag:=False;
      SetLength(mMsg, Length(mMsg)+1);
      mMsg[Length(mMsg)-1].Adr1:=HexToInt(MidStr(List.Strings[n],3,8));
      mMsg[Length(mMsg)-1].Adr2:=HexToInt(MidStr(List.Strings[n],12,8));
    end else
    begin
      If List.Strings[n]<>'' Then
      begin
        SetLength(mMsg[Length(mMsg)-1].R,Length(mMsg[Length(mMsg)-1].R)+1);
        If List.Strings[n]<>'Read' Then
        begin
          mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].Read:=True;
          mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].Msg :=
          HexToInt(LeftStr(List.Strings[n],4));
          mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].Dlg :=
          HexToInt(RightStr(List.Strings[n],4));;
        end;
      end;
    end;
  end;
  List.Free;
end;

Procedure LoadOptText(SText, SFid: String; var Msg: TMessageArray; Adr: Boolean);
var n,m,l: Integer; nMsg: TMessageArray;
begin
  LoadOpt(SFid, Msg, Adr);
  LoadText(SText, nMsg,Adr);
  For n:=0 To Length(Msg)-1 do
  begin
    l:=0;
    For m:=0 To Length(Msg[n].R)-1 do
    begin
      If Msg[n].R[m].Read Then
        Msg[n].R[m].Text:=Msg[Msg[n].R[m].Msg].R[Msg[n].R[m].Dlg].Text
      else
      begin
        Msg[n].R[m].Text:=nMsg[n].R[l].Text;
        Inc(l);
      end;
    end;
  end;
end;


Procedure SaveOpt(var mMsg: TMessageArray; const S: String; Adr: Boolean);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(mMsg)-1 do
  begin
    If Adr Then List.Add(Format('@@%s-%s',[IntToHex(mMsg[n].Adr1,8),IntToHex(mMsg[n].Adr2,8)]))
    else List.Add('['+mMsg[n].Name+']');
    For m:=0 To Length(mMsg[n].R)-1 do
    begin
      If mMsg[n].R[m].Read=False Then List.Add('Read')
      else List.Add(IntToHex(mMsg[n].R[m].Msg,4)+' '+IntToHex(mMsg[n].R[m].Msg,4));
    end;
    List.Add('');
  end;
  List.SaveToFile(S);
  List.Free;
end;

Procedure SaveOptText(var Msg: TMessageArray; const SText, SFid: String; Adr: Boolean);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(Msg)-1 do
  begin
    If Adr Then List.Add(Format('@@%s-%s',[IntToHex(Msg[n].Adr1,8),IntToHex(Msg[n].Adr2,8)]))
    else List.Add('['+Msg[n].Name+']');
    List.Add('');
    For m:=0 To Length(Msg[n].R)-1 do
    begin
      If not Msg[n].R[m].Read then
      begin
        List.Add(Msg[n].R[m].Text);
        List.Add('');
      end;
    end;
  end;
  List.SaveToFile(SText);
  SaveOpt(Msg, SFid, Adr);
end;

Procedure OptText(var mMsg: TMessageArray);
var n,m,l,r: Integer;
Label Brk;
begin
  For n:=0 To Length(mMsg)-1 do
  begin
    For m:=0 To Length(mMsg[n].R)-1 do
    begin
      For l:=0 To n do
      For r:=0 To Length(mMsg[l].R)-1 do
      begin
        If (l=n) and (r>=m) Then Break;
        If mMsg[n].R[m].Text=mMsg[l].R[r].Text Then
        begin
          mMsg[n].R[m].Read:=True;
          mMsg[n].R[m].Msg:=l;
          mMsg[n].R[m].Dlg:=r;
          GoTo Brk;
        end;
      end;
      Brk:
    end;
  end;
end;

Procedure LoadText(S: String; var mMsg: TMessageArray; Adr: Boolean);
var n: Integer; List: TStringList; Flag: Boolean; Str: String;
begin
  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 To List.Count-1 do
  begin
    If Adr and (LeftStr(List.Strings[n],2)='@@') then
    begin
      Flag:=False;
      SetLength(mMsg, Length(mMsg)+1);
      mMsg[Length(mMsg)-1].Adr1:=HexToInt(MidStr(List.Strings[n],3,8));
      mMsg[Length(mMsg)-1].Adr2:=HexToInt(MidStr(List.Strings[n],12,8));
    end else
    If not Adr and (LeftStr(List.Strings[n],1)='[') and (RightStr(List.Strings[n],1)=']') then
    begin
      Flag:=False;
      SetLength(mMsg, Length(mMsg)+1);
      mMsg[Length(mMsg)-1].Name:=MidStr(List.Strings[n],2,Length(List.Strings[n])-2);
    end else
    begin
      If not Flag and {(RightStr(List.Strings[n],1)<>'\')}(List.Strings[n]<>'') Then begin
        Flag:=True;
        SetLength(mMsg[Length(mMsg)-1].R,Length(mMsg[Length(mMsg)-1].R)+1);
      end;
      If Flag Then
      begin
        If mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].Text<>'' Then
        Str:=#13#10 Else Str:='';
        mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].Text:=
        mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].Text+Str+List.Strings[n];
      end;
      If (Flag=True) and (RightStr(List.Strings[n],1)='\'{List.Strings[n]=''}) then Flag:=False;
    end;
  end;
  List.Free;
end;


Procedure CopyMem(const Buf: pointer; var WBuf: Pointer; const Size: Integer);
var n: Integer; B,WB: ^Byte;
begin
  B:=Addr(Buf^);
  WB:=Addr(WBuf^);
  For n:=0 To Size-1 do
  begin
    WB^:=B^;
    Inc(WB); Inc(B);
  end;
end;

Function PasteText(Text: String; Table: TTableArray; var Buf: Pointer): Integer;
var List: TStringList; Flag: Boolean; n,m,l: Integer; B: ^Byte; W: ^Word; S: String;
Ln, LnTbl: Integer;
Label Compl;
begin
  Result:=0;
  List:=TStringList.Create;
  List.Text:=Text;
  B:=Addr(Buf^);
  W:=Addr(B^);
  For n:=0 To List.Count-1 do
  begin
    l:=1;
    If not Flag and (List.Strings[n]<>'') Then Flag:=True;
    If Flag Then
    begin
      S:=List.Strings[n];
      Ln:=Length(List.Strings[n]);
      LnTbl:=Length(Table)-1;
      While l<=Ln do
      begin
        If S[l]='{' Then
        begin
          If (Length(S)-l>2) and (S[l+3]='}') then
          begin
            B^:=HexToInt(MidStr(S,l+1,2));
            Inc(B); Inc(Result);
            Inc(l,4);
            GoTo Compl;
          end;
        end;
        If S[l]='[' Then
        begin
          If (Length(S)-l>2) and (S[l+4]=']') and (S[l+1]='#') then
          begin
            B^:=HexToInt(MidStr(S,l+2,2));
            Inc(B); Inc(Result);
            Inc(l,5);
            GoTo Compl;
          end;
        end;
        W:=Addr(B^);
        For m:=0 To LnTbl do
        begin
          If Table[m].Text[1]=S[l] Then
          begin
            If (Length(Table[m].Text)<=Length(List.Strings[n])-l+1) and
            (MidStr(List.Strings[n],l,Length(Table[m].Text))=Table[m].Text) Then
            begin
              If Table[m].D Then
              Begin
                W^:=Table[m].Value;
                Inc(B); Inc(Result);
              end else
                B^:=Table[m].Value;

              Inc(B); Inc(Result);
              Inc(l, Length(Table[m].Text));
              GoTo Compl;
              //Break;
            end;
          end;
        end;
        B^:=$3E;
        Inc(B); Inc(Result);
        Inc(l);
        Compl:
      end;
    end;
    If (List.Strings[n]<>'') And (RightStr(List.Strings[n],1)='\') Then Flag:=False;
    If Flag Then
    begin
      B^:=$F8;
      Inc(B); Inc(Result);
    end;
  end;
  List.Free;
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function GetBpp(C: Integer): Integer;
begin
  Result:=0;
  While C>1 do
  begin
    C:=C SHR 1;
    Inc(Result);
  end;
end;

Function GetB(C: Word): Byte;
var W: Word;
begin
  W:=C;
  //W:=(C SHR 8) + (C SHL 8);
  Result:=(W SHR 11) AND $1F;
end;

Function GetG(C: Word): Byte;
var W: Word;
begin
  W:=C;
  //W:=(C SHR 8) + ((C SHL 8) AND $FF00);
  //Result:=(C SHR 6) and $1F;
  Result:=(W SHR 6) and $1F;
  //ShowMessage(IntToHex(Result,2));
end;

Function GetR(C: Word): Byte;
var W: Word;
begin
  W:=C;
  //W:=(C SHR 8) + ((C SHL 8) AND $FF00);
  //Result:=(C SHR 1) and $1F;
  Result:=(W SHR 0) and $3F;
end;

Function GetPB(C: DWord): Byte;
var W: Word;
begin
  W:=C;
  Result:=(W SHR 16) AND $FF;
end;

Function GetPG(C: DWord): Byte;
var W: Word;
begin
  W:=C;
  Result:=(W SHR 8) and $FF;
end;

Function GetPR(C: DWord): Byte;
var W: Word;
begin
  W:=C;
  Result:=W and $FF;
end;

Function GetPA(C: DWord): Byte;
var W: Word;
begin
  Result:=(C SHR 24) and $FF;
end;


Procedure RawToDib(var Pic: TDIB; Buf: Pointer);
var B, WB: ^Byte; n,m: Integer;
begin
  B:=Addr(Buf^);
  For m:=0 To Pic.Height-1 do
  begin
  WB:=Addr(Pic.ScanLine[m]^);
    For n:=0 To Pic.Width-1 do
    begin
      If Pic.BitCount=4 then
        WB^:=((B^ SHR 4) AND $0F) + ((B^ SHL 4) AND $F0)
      else
        WB^:=B^;
      Inc(B); Inc(WB);
    end;
  end;
end;

Procedure DibToRaw(var Pic: TDIB; Buf: Pointer);
var B, WB: ^Byte; n,m: Integer;
begin
  WB:=Addr(Buf^);
  For m:=0 To Pic.Height-1 do
  begin
  B:=Addr(Pic.ScanLine[m]^);
    For n:=0 To Pic.WidthBytes-1 do
    begin
      If Pic.BitCount=4 then
        WB^:=((B^ SHR 4) AND $0F) + ((B^ SHL 4) AND $F0)
      else
        WB^:=B^;
      Inc(B); Inc(WB);
    end;
  end;
end;

Procedure LoadTable(S: String; var Table: TTableArray);
var List: TStringList; n: Integer;
begin
  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 To List.Count-1 do
  begin
    If (Pos('=', List.Strings[n])=3) or (Pos('=', List.Strings[n])=5) then
    begin
      If Pos('=', List.Strings[n])=5 Then Table[Length(Table)-1].D:=True;
      SetLength(Table, Length(Table)+1);
      Table[Length(Table)-1].Value:=HexToInt(LeftStr(List.Strings[n],Pos('=', List.Strings[n])-1));
      Table[Length(Table)-1].Text:=RightStr(List.Strings[n],Length(List.Strings[n])-(Pos('=', List.Strings[n])));
      If Table[Length(Table)-1].Value>255 Then Table[Length(Table)-1].Value:=
      (Table[Length(Table)-1].Value SHL 8)+(Table[Length(Table)-1].Value SHR 8);
    end;
  end;
  List.Free;
end;

Procedure SetPal(Var Pic: TDIB; Pal: TPal);
var n: Integer;
begin
  For n:=0 to (1 SHL Pic.BitCount)-1 do
  begin
    Pic.ColorTable[n].rgbBlue:=GetB(Pal[n])*16;
    Pic.ColorTable[n].rgbGreen:=GetG(Pal[n])*16;
    Pic.ColorTable[n].rgbRed:=GetR(Pal[n])*8;
    Pic.ColorTable[n].rgbReserved:=0;
  end;
end;

Procedure SetPallete(Var Pic: TDIB; Pal: TPallete);
var n: Integer;
begin
  For n:=0 to (1 SHL Pic.BitCount)-1 do
  begin
    Pic.ColorTable[n].rgbBlue:=GetPB(Pal[n]);
    Pic.ColorTable[n].rgbGreen:=GetPG(Pal[n]);
    Pic.ColorTable[n].rgbRed:=GetPR(Pal[n]);
    //Pic.ColorTable[n].rgbReserved:=GetPA(Pal[n]);
  end;
end;


Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char; //HexError: Boolean;
begin
 //HexError := True;
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 //HexError := False;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   //HexError := True;
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;

Procedure ExtractText(const Buf: Pointer; Table: TTableArray; Size: Integer; Var Text: String);
var n,m: Integer; B: ^Byte; W: ^Word;
begin
  B:=Addr(Buf^);
  W:=Addr(B^);
  n:=0;
  //N:=6;
  While n<Size do
  begin
    For m:=0 To Length(Table)-1 do
    begin
      If (Table[m].Value>255) and (n<Size) and (W^=Table[m].Value) then
      begin
        Text:=Text+Table[m].Text;
        Inc(n,2); Inc(B,2); Inc(W);
        Break;
      end else
      If B^=Table[m].Value then
      begin
        If Table[m].Text='^' Then Text:=Text+#13#10 else
        Text:=Text+Table[m].Text;
        If Table[m].Text='\' Then Text:=Text+#13#10#13#10;
        Inc(n); Inc(B); W:=Addr(B^);
        Break;
      end;
      If m=Length(Table)-1 Then
      begin
        Text:=Text+'{'+IntToHex(B^,2)+'}';
        Inc(n); Inc(B); W:=Addr(B^);
      end;
    end;
  end;
end;


end.


