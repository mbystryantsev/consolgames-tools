unit FF7_Text;

interface
Uses
  Windows, Classes, StrUtils, SysUtils, FF7_DAT, FF7_Field, FF7_Common, FF7_Compression;

Type
  TProc = Function(N: Integer; S: String): Boolean;
  TByteSet = Set of Byte;

var
  MText: TText;
  OText: TText;
  MTable: TTableArray;

const
  ErrorNames: Array[0..16] of String = ('BLIN66_1.DAT','BLIN66_2.DAT','BLIN66_3.DAT','BLIN66_4.DAT',
'BLIN66_5.DAT','BLIN671B.DAT','BLIN673B.DAT','BLIN67_1.DAT','BLIN67_2.DAT',
'BLIN67_3.DAT','BLIN67_4.DAT','BLIN68_1.DAT','BLIN68_2.DAT','PILLAR_1.DAT',
'SMKIN_1.DAT','PILLAR_2.DAT','PILLAR_3.DAT');

Function FindMessage(Name: String; Text: TText): Integer;
Function ExtractAllText(Folder: String; var Text: TText; Table: TTableArray; var Buf: Pointer; P: TProc = NIL): Integer;
Function InsertText(Text: TText; ID: Integer; Buf: Pointer; Table: TTableArray; SC: Byte = $FF): Integer;
Procedure LoadText(Buf: Pointer; Table: TTableArray; var Msg: TMsg; Kernel: Boolean = False; FF8: Boolean = False; DSet: TByteSet=[]; SC: Byte = $FF);
Procedure LoadTable(S: String; var Table: TTableArray);
Function ExtractText(const Buf: Pointer; Table: TTableArray; Var Text: String;
Kernel: Boolean = False; SC: Byte = $FF; DSet: TByteSet = []): Integer;
Function RoundBy(Value, R: Integer): Integer;
Function PasteText(Text: String; Table: TTableArray; var Buf:Pointer; SC:Byte=$FF;
SCarry: Byte = $E7; SNew: Byte = $E8): Integer;
Procedure SaveText(Name: String; Text: TText);
Procedure OptimizeText(var Text: TText; P: TProc = NIL);
Procedure SaveOpt(Name: String; Text: TText);
Procedure OpenOpt(Name: String; var Text: TText);
Procedure OpenText(Name: String; var Text: TText);
Procedure BDat(Text: TText; n: Integer);
function PosExRev(const SubStr, S: string; Offset: Cardinal = 0): Integer;
Function GetUpCase(S: String): String;
Procedure ExtractKernelText(GZip: TBinFile; Table: TTableArray; var Text: TText);
implementation

Function CFTFE(S: String): Boolean;
var n: Integer;
begin
  Result:=True;
  For n:=0 To High(ErrorNames) do
  begin
    If S=ErrorNames[n] Then Exit;
  end;
  Result:=False;
end;

Procedure BDat(Text: TText; n: Integer);
//var DAT: TDAT; BSize,TSize,DSize,m,CSize: Integer; WBuf: Pointer;
var Field: TFieldRec;
begin
  Field:=TFieldRec.Create;
  Field.LoadFromFile(Settings.Path.FieldIn+Text[n].Name);
  Field.ReplaceText(Text,n,MLField,MTable);
  Field.SaveToFile(Settings.Path.FieldOut+Text[n].Name,True,level,LZNull);
  Field.Free;
end;


Procedure ExtractKernelText(GZip: TBinFile; Table: TTableArray; var Text: TText);
var n: Integer; Buf,WBuf: Pointer; BSize,Size: Integer; Ptr: ^Word; PtSz: Integer;
begin
  GetMem(Buf,4096);
  SetLength(Text,26-9+1);
  For n:=9 To 26 do
  begin
    Size:=GZip.ExtractFileToBuf(n,Buf);
    LoadText(Buf,Table,Text[n-9],True);
    Text[n-9].Name:=Format('KERNEL.BIN/%d',[n]);
  end;
  FreeMem(Buf);
end;

Function GetLineSize(Buf: Pointer; SC: Byte = $FF): Integer;
var B: ^Byte;
begin
  B:=Buf; Result:=0;
  While B^<>SC do begin Inc(B); Inc(Result); end;
end;

Procedure LoadText(Buf: Pointer; Table: TTableArray; var Msg: TMsg; Kernel: Boolean = False; FF8: Boolean = False; DSet: TByteSet=[]; SC: Byte = $FF);
Type TT = Array[0..1023] of Byte;
var n,m,Size: Integer; PPtr: ^DWord; T: TT; P: Pointer; Ptr: DWord;
begin
  If FF8 Then SC:=0;// else SC:=$FF;
  P:=Addr(T);
  PPtr:=Buf;
  If FF8 Then Ptr:=PPtr^ else Ptr:=PPtr^ and $FFFF;
  If Kernel Then m:=(Ptr+1) div (2+(2*Byte(FF8))) else
  begin
    m:=Ptr;
    If m=0 Then m:=256;
    Inc(DWord(PPtr),2+Byte(FF8)*2);
    If FF8 Then Ptr:=PPtr^ else Ptr:=PPtr^ and $FFFF;
  end;
  //If CFTFE(Msg.Name) Then m:=(Ptr^ div 2)-1;
  SetLength(Msg.S,m);
  For n:=0 To m-1 do
  begin
    If not Kernel or FF8 Then
      ExtractText(Pointer(DWord(Buf)+Ptr), Table, Msg.S[n].Text, Kernel, SC, DSet)
    else
    begin
      {Size:=}TZ_Decompress(Pointer(DWord(Buf)+Ptr),P,GetLineSize(Pointer(DWord(Buf)+Ptr),SC));
      ExtractText(P, Table, Msg.S[n].Text, Kernel, SC, DSet);
    end;
    Inc(DWord(PPtr),2+Byte(FF8)*2); 
    If FF8 Then Ptr:=PPtr^ else Ptr:=PPtr^ and $FFFF;
  end;
end;

Function PasteText(Text: String; Table: TTableArray; var Buf:Pointer; SC:Byte=$FF;
SCarry: Byte = $E7; SNew: Byte = $E8): Integer;
var List: TStringList; Flag: Boolean; n,m,l: Integer; B: ^Byte; W: ^Word; S: String;
Ln, LnTbl: Integer;
Label Compl, Nxt;
begin
  Result:=0;
  List:=TStringList.Create;
  List.Text:=Text;
  B:=Addr(Buf^);
  W:=Addr(B^);
  For n:=0 To List.Count-1 do
  begin
    If List.Strings[n]='' Then
    begin
      B^:=$E7; Inc(B); Inc(Result);
      GoTo Nxt;
    end;
      l:=1;
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
          end else
          If (Length(S)-l>5) and (S[l+6]='}') then
          begin
            B^:=HexToInt(MidStr(S,l+1,2));
            Inc(B);
            B^:=HexToInt(MidStr(S,l+1+3,2));
            Inc(Result,2);
            Inc(l,7);
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
        If (S[l]='~') And (l=Length(S)) Then
        begin
          Inc(l);
          GoTo Compl;
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
        B^:=$1F; // Неизвестный символ
        Inc(B); Inc(Result);
        Inc(l);
        Compl:
      end;
    If n<List.Count-1 Then
    begin
      If S[Length(S)]='~' Then B^:=SNew else B^:=SCarry;
      Inc(B); Inc(Result);
    end;
    Nxt:
  end;
  B^:=SC; Inc(B); Inc(Result);
  List.Free;
end;

Function InsertText(Text: TText; ID: Integer; Buf: Pointer; Table: TTableArray; SC: Byte = $FF): Integer;
var n,m: Integer; Ptr: ^Word; Pos, Size: Word; B: ^Byte; Txt: String;
begin
  Ptr:=Buf; Ptr^:=Length(Text[ID].S);
  If Ptr^>255 Then Ptr^:=0;
  Pos:=Ptr^*2+2; Inc(Ptr);
  B:=Buf; Inc(B,Pos);
  For n:=0 To Length(Text[ID].S)-1 do
  begin
    If Text[ID].S[n].Retry Then
    begin
      m:=FindMessage(Text[ID].S[n].RName,Text);
      Txt:=Text[m].S[Text[ID].S[n].RID].Text;
    end else
      Txt:=Text[ID].S[n].Text;
    Ptr^:=Pos; Inc(Ptr);
    Size:=PasteText(Txt,Table,Pointer(B));
    Inc(Pos,Size); Inc(B,Size);
  end;
  Result:=Pos;
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function ExtractText(const Buf: Pointer; Table: TTableArray; Var Text: String;
Kernel: Boolean = False; SC: Byte = $FF; DSet: TByteSet = []): Integer;
var n,m: Integer; B: ^Byte; W: ^Word;
begin
  If Length(Table)<=0 Then Exit;
  B:=Addr(Buf^);
  W:=Addr(B^);
  n:=0;
  //N:=6;
  While B^<>SC{n<Size} do
  begin
    If B^{=$FE} in DSet Then
    begin
      Text:=Format('%s{%.2x:',[Text,B^]);
      Inc(B);
      Text:=Format('%s%.2x}',[Text,B^]);
      //Text:=Text+Format('<Color:%s>',[IntToHex(B^,2)]);
      Inc(n,2); Inc(B); Inc(W);
    end else
    If Kernel and (B^=$F9) Then
    begin
      Inc(B);
      Text:=Text+Format('<U:%s>',[IntToHex(B^,2)]);
      Inc(n,2); Inc(B); Inc(W);
    end else
    begin
      For m:=0 To Length(Table)-1 do
      begin
        If Table[m].D {(Table[m].Value>255)} and (W^ SHL 8<>$FF) and (W^=Table[m].Value) then
        begin
          Text:=Text+Table[m].Text;
          Inc(n,2); Inc(B,2); Inc(W);
          Break;
        end else
        If (B^=Table[m].Value) and not Table[m].D then
        begin
          If Table[m].Text='^' Then Text:=Text+#13#10 else
          Text:=Text+Table[m].Text;
          If Table[m].Text='\' Then Text:=Text+#13#10#13#10;
          If Table[m].Text='~' Then Text:=Text+#13#10;
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
  Result:=DWord(B)-DWord(Buf)+1;
end;

Procedure LoadTable(S: String; var Table: TTableArray);
var List: TStringList; n: Integer;
begin
  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 To List.Count-1 do
  begin
    If ((Pos('=', List.Strings[n])=3) and (Length(List.Strings[n])>3))
    or ((Pos('=', List.Strings[n])=5) and (Length(List.Strings[n])>5)) then
    begin
      SetLength(Table, Length(Table)+1);
      If Pos('=', List.Strings[n])=5 Then Table[Length(Table)-1].D:=True;
      Table[Length(Table)-1].Value:=HexToInt(LeftStr(List.Strings[n],Pos('=', List.Strings[n])-1));
      Table[Length(Table)-1].Text:=RightStr(List.Strings[n],Length(List.Strings[n])-(Pos('=', List.Strings[n])));
      If Table[Length(Table)-1].Value>255 Then Table[Length(Table)-1].Value:=
      (Table[Length(Table)-1].Value SHL 8)+(Table[Length(Table)-1].Value SHR 8);
    end;
  end;
  List.Free;
end;

Function StrToChr(S: String): TFName;
var n: Integer;
begin
  For n:=1 To 24 do
  begin
    If n<=Length(S) Then Result[n-1]:=S[n] else Result[n-1]:=#0;
  end;
end;

Function ExtractAllText(Folder: String; var Text: TText; Table: TTableArray; var Buf: Pointer; P: TProc = NIL): Integer;
var SR: TSearchRec; Size: Integer; DAT: TDAT; n: Integer; NBuf, FBuf: Pointer;
Scr: ^TFScript; SHead: ^TFHeader; Pos: Integer; WB: ^Byte;  Cancel: Boolean;
Label Stop;
begin
  Cancel:=False;
  n:=0;
  Pos:=0;
  GetMem(NBuf,$20000);
  GetMem(FBuf,$800000);
  SHead:=NBuf;
  SHead^.Sign:=0;
  SHead^.Count:=0;
  SHead^.HSize:=0;
  SHead^.SSize:=0;
  Scr:=NBuf; Inc(DWord(Scr),16);
  WB:=FBuf;
  SHead^.HSize:=16;
  If FindFirst(Folder+'\*.DAT',  faAnyFile, SR) = 0 then
  begin
    Repeat
    If @P<>NIL Then Cancel:=P(n, SR.Name);
    If Cancel Then GoTo Stop;
    Size:=LoadDat(Format('%s\%s',[Folder,SR.Name]), Buf);
      If Size>0 Then
      begin
        DAT:=AssignDat(Buf, Size);
        If DAT.TextPtr.Size>3 Then
        begin
          SetLength(Text,Length(Text)+1);
          Text[n].Name:=SR.Name;
          LoadText(Dat.TextPtr.Pos, Table, Text[n]);
          Scr^.Name:=StrToChr(SR.Name);
          Scr^.Pos:=Pos;
          Scr^.Size:=DAT.IdxPtr.Size;
          WB:=FBuf; Inc(WB,Pos);
          Inc(Pos,DAT.IdxPtr.Size);
          Move(DAT.IdxPtr.Pos^,WB^,DAT.IdxPtr.Size);
          Inc(SHead^.Count);
          Inc(SHead^.HSize,32);
          Inc(SHead^.SSize,DAT.IdxPtr.Size);
          Inc(n);
          Inc(Scr);
          //////////////
        end;
      end;
      //Size:=FindNext(SR);
    Until (FindNext(SR) <> 0);
  end;
  Stop:
  Result:=SHead^.HSize+SHead^.SSize;
  If Assigned(Buf) Then FreeMem(Buf);
  GetMem(Buf,Result);
  Move(NBuf^,Buf^,SHead^.HSize);
  WB:=Buf; Inc(WB, SHead^.HSize);
  Move(FBuf^,WB^,SHead^.SSize);
  FreeMem(NBuf); FreeMem(FBuf);
end;

Procedure SaveText(Name: String; Text: TText);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(Text)-1 do
  begin
    List.Add(Format('[@%s,%d]',[Text[n].Name,Length(Text[n].S)]));
    List.Add('');
    For m:=0 To Length(Text[n].S)-1 do
    begin
      If not Text[n].S[m].Retry Then
      begin
        List.Add(Text[n].S[m].Text);
        List.Add('{E}');
        List.Add('');
      end;
    end;
    //List.Add('{END}');
    //List.Add(''); 
  end;
  List.SaveToFile(Name);
  List.Free; 
end;

Procedure SaveOpt(Name: String; Text: TText);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(Text)-1 do
  begin
    List.Add(Format('[@%s,%d]',[Text[n].Name,Length(Text[n].S)]));
    For m:=0 To Length(Text[n].S)-1 do
    begin
      If Text[n].S[m].Retry Then
      begin
        List.Add(Format('%d,%s,%d',[m,Text[n].S[m].RName,Text[n].S[m].RID]));
      end;
    end;
    List.Add('');
  end;
  List.SaveToFile(Name);
  List.Free; 
end;

Procedure OptimizeText(var Text: TText; P: TProc = NIL);
var n,m,l,r: Integer; Cancel: Boolean;
Label BRK;
begin
  Cancel:=False;
  For n:=0 To Length(Text)-1 do
  begin
    If @P<>NIL Then
    begin
      If P(n,Format('%d%% - %s',[n*100 div (Length(Text)-1),Text[n].Name])) Then Break;
    end;
    For m:=0 To Length(Text[n].S)-1 do
    begin
      For l:=0 To n do
      For r:=0 To Length(Text[l].S)-1 do
      begin
        If (n=l) and (r>=m) Then GoTo BRK;
        If Text[n].S[m].Text=Text[l].S[r].Text Then
        begin
          Text[n].S[m].Retry:=True;
          Text[n].S[m].RName:=Text[l].Name;
          Text[n].S[m].RID:=r;
          GoTo BRK;
        end;
      end;
    BRK:
    end;
  end;
end;

Function FindMessage(Name: String; Text: TText): Integer;
begin
  For Result:=0 To High(Text) do If Text[Result].Name=Name Then break;
  If Result=Length(Text) Then Result:=-1;
end;

Procedure OpenOpt(Name: String; var Text: TText);
var List: TStringList; n,m,i: Integer; S: String;
begin
  n:=-1;
  List:=TStringList.Create;
  List.LoadFromFile(Name);
  For m:=0 To List.Count-1 do
  begin
    S:=List.Strings[m];
    If (Length(S)>0) and (S[1]='[') Then
    begin
      Inc(n); SetLength(Text,n+1); Text[n].Name:=GetPart(S,',',1);
      SetLength(Text[n].S,StrToInt(GetPart(S,',',2)));
    end else
    If S<>'' Then
    begin
      i:=StrToInt(GetPart2(S,',',1));
      Text[n].S[i].Retry:=True;
      Text[n].S[i].RName:=GetPart2(S,',',2);
      Text[n].S[i].RID:=StrToInt(GetPart2(S,',',3));
    end;
  end;
end;

Function GetNextMessage(Msg: TMsg; n: Integer): Integer;
begin
  Result:=n;
  While Msg.S[Result].Retry do Inc(Result);
end;

Procedure OpenText(Name: String; var Text: TText);
var List: TStringList; n,m,i: Integer; S: String; Skip, Read, Per: Boolean;
Label Skp;
begin
  Skip:=False; Read:=False;
  List:=TStringList.Create;
  List.LoadFromFile(Name);
  For m:=0 To List.Count-1 do
  begin
    If Skip Then
    begin
      Skip:=False; GoTo Skp;
    end;
    S:=List.Strings[m];
    If not Read and (Length(S)>3) and (S[1]='[') and (S[2]='@') Then
    begin
      n:=FindMessage(GetPart(S,',',1), Text);
      Skip:=True;
      i:=0;
    end else
    begin
      If S<>'{E}' Then
      begin
        If not Read Then
        begin
          Per:=False;
          Read:=True;
          i:=GetNextMessage(Text[n],i);
        end;
        If Per Then Text[n].S[i].Text:=Text[n].S[i].Text+#13#10+S
        else Text[n].S[i].Text:=Text[n].S[i].Text+S;
        Per:=True;
      end else
      begin
        Read:=False; Skip:=True; Inc(i);
      end;
    end;
    Skp:
  end;
end;

function PosExRev(const SubStr, S: string; Offset: Cardinal = 0): Integer;
var
  I,X: Integer;
  LenSubStr: Integer;
begin
  I := Offset;
  LenSubStr := Length(SubStr);
  //Len := Length(S) - LenSubStr + 1;
  If I = 0 Then I := Length(S);
  while I > 0 do
  begin
    if S[I] = SubStr[LenSubStr] then
    begin
      X := 0;
      while (X < LenSubStr) and (S[I - X] = SubStr[LenSubStr - X]) do
        Inc(X);
      if (X = LenSubStr) then
      begin
        Result := I - LenSubStr + 1;
        exit;
      end;
    end;
    Dec(I);
  end;
  Result := 0;
end;

Function GetUpCase(S: String): String;
var n: Integer; C: ^Char;
begin
  C:=Addr(S[1]);
  Result:=S;
  For n:=1 To Length(S) do
  begin
    Case Result[n] of
      'a'..'z':  Dec(C^, Ord('a') - Ord('A'));
      'а'..'я':  Dec(C^, Ord('а') - Ord('А'));
      'ё':       Dec(C^, Ord('ё') - Ord('Ё'));
    end;
    Inc(C);
  end;
end;

end.
