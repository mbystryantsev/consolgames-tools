unit MGS;

interface

Uses ZlibEx, Windows, SysUtils, Classes, StrUtils;


Type
  TDarFile = Packed Record
    FileName: String;
    FileSize: Integer;
    FileData: Pointer;
  end;
  TDar = Array of TDarFile;
  TMGATextString = Packed Record
    S: String;
    Retry: Boolean;
    RetryName: String;
    RetryID: Integer;
    RetryNUM: Integer;
  end;
  TMGAText = Packed Record
    Count: Integer;
    Name: String;
    Text: Array of TMGATextString;
  end;
  TMGATextArray = Array of TMGAText;
  TMGATextHeader = Packed Record
    Size: DWord;
    Unknown: DWord;
    TextPos: DWord;
    TextSize: DWord;
    Blank: DWord;
  end;
  TTextSign = Array[0..7] of Byte;
  TProgrProc = Procedure(S: String);
  TTable = Packed Record
    Text: String;
    Value: Word;
    D: Boolean;
  end;
  TTableArray = Array of TTable;

const
  TextSign: TTextSign = ($D2,$68,$EC,$41,0,0,0,0);

Function  ZARDecompress(var Buf: Pointer; Size: Integer): Integer;
Function  ZARCompress(var Buf: Pointer; Size: Integer): Integer;
Function  GetParam(S: String; Num: Integer): String;
Function  RoundBy(Value, R: Integer): Integer;
Function  AssignDar(Buf: Pointer): TDar;
Function  GetDarFile(var P: Pointer; Dar: TDar; Name: String): Integer;
Procedure ExtractText(P: Pointer; var Text: TMGATextArray; Name: String);
Procedure ExtractAllText(var Text: TMGATextArray; Folder: String; Progr: TProgrProc = NIL);
Procedure SaveText(Text: TMGATextArray; FileName: String);
Procedure SaveList(Text: TMGATextArray; FileName: String);
Procedure LoadList(var Text: TMGATextArray; FileName: String; Progr: TProgrProc = NIL);
Procedure LoadText(var Text: TMGATextArray; ListName,TextName: String; Progr: TProgrProc = NIL);
Procedure LoadTable(S: String; var Table: TTableArray);
Function  PasteText(Text: String; Table: TTableArray; var Buf: Pointer): Integer;
Function  HexToInt(S: String): Integer;
Function TXDCompress(var Buf: Pointer; Size: Integer): Integer;
Function TXDDecompress(var Buf: Pointer; Size: Integer): Integer;
implementation

Function BuildText(Text: TMGAText; P: Pointer; Pos: Integer): Integer;
var I: ^DWord; B: Pointer; Head: ^TMGATextHeader;
begin
  Head:=P; Inc(Integer(Head),Pos);
  I:=P; Inc(Integer(I),20+Pos);
  //Inc(B, Text.Count*4+20+Pos);


end;

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char;
begin
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;

Procedure LoadList(var Text: TMGATextArray; FileName: String; Progr: TProgrProc = NIL);
var List: TStringList; n,m,ID,NUM: Integer; S: String;
Label brk;
begin
  Text:=NIL;
  ID:=-1;
  List:=TStringList.Create;
  List.LoadFromFile(FileName);
  For n:=0 To List.Count-1 do
  begin
    If List.Strings[n]='' Then GoTo brk;
    S:=List.Strings[n];
    If (S[1]='[') and (S[Length(S)]=']') Then
    begin
      If ID>=0 Then Text[ID].Count:=Num;
      Inc(ID);
      SetLength(Text,ID+1);
      Text[ID].Name:=GetParam(S,1);
      Text[ID].Count:=StrToInt(GetParam(S,2));
      SetLength(Text[ID].Text,Text[ID].Count);
      NUM:=0;
      If @Progr<>NIL Then Progr(Text[ID].Name);
    end else
    If (S[1]='{') and (S[Length(S)]='}') Then
    begin
      Text[ID].Text[Num].Retry:=True;
      Text[ID].Text[Num].RetryName:=GetParam(S,1);
      Text[ID].Text[Num].RetryID:=StrToInt(GetParam(S,2));
      Text[ID].Text[Num].RetryNUM:=StrToInt(GetParam(S,3));
      Inc(Num);
    end else If S='0' Then Inc(Num);
  brk:
  end;
  If ID>0 Then Text[ID-1].Count:=Num;
  List.Free;
end;

Procedure LoadText(var Text: TMGATextArray; ListName,TextName: String; Progr: TProgrProc = NIL);
var List: TStringList; n,m,ID,NUM: Integer; S: String; rFlag: Boolean;
Label brk, flg;
begin
  rFlag:=False;
  LoadList(Text,ListName,Progr);
  //Exit;
  ID:=-1;
  List:=TStringList.Create;
  List.LoadFromFile(TextName);
  //If not rFlag and (ID>=0) Then While Text[ID].Text[Num].Retry and (Num<Text[ID].Count) do Inc(Num);
  For n:=0 To List.Count-1 do
  begin
    If Text[ID].Count=0 Then GoTo brk;
    If ID>=Length(Text) Then Exit;
    S:=List.Strings[n];
    {If not rFlag and (S='') Then
    begin
      rFlag:=True;
      GoTo brk;
    end;}
    If (Length(S)>3) and (S[2]='$') and (S[1]='[') and (S[Length(S)]=']') Then
    begin
      //If ID>=0 Then Text[ID].Count:=Num;
      Inc(ID); NUM:=0;
      rFlag:=False;
      //If @Progr<>NIL Then Progr(Text[ID].Name);
    end else
    If not rFlag and (S='') Then
    begin
      rFlag:=True;
      While Text[ID].Text[Num].Retry and (Num<Text[ID].Count) do Inc(Num);
      GoTo brk;
    end else
    If rFlag Then
    begin
    flg:
      If Num<Text[ID].Count then
      begin
        Text[ID].Text[Num].S := Text[ID].Text[Num].S+S;
        If (S='') or (S[Length(S)]<>'\') Then Text[ID].Text[Num].S:=Text[ID].Text[Num].S+#$0A
        else
        begin
          SetLength(Text[ID].Text[Num].S,Length(Text[ID].Text[Num].S)-1);
          rFlag:=False;
          Inc(Num);
        end;
      end;
    end;
  brk:
  end;
  List.Free;
end;

Procedure SaveText(Text: TMGATextArray; FileName: String);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(Text)-1 do
  begin
    List.Add(Format('[$%s,%d]',[Text[n].Name,Text[n].Count]));
    List.Add('');
    For m:=0 To Text[n].Count-1 do
    begin
      If not Text[n].Text[m].Retry Then
      begin
        List.Add(Text[n].Text[m].S+'\');
        List.Add('');
      end;
        // else
        //List.Add(Format('{$%s,%d,%d}',
        //[Text[Text[n].Text[m].RetryID].Name,Text[n].Text[m].RetryID,Text[n].Text[m].RetryNUM]));
    end;
  end;
  List.SaveToFile(FileName);
  List.Free;
end;

Procedure SaveList(Text: TMGATextArray; FileName: String);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(Text)-1 do
  begin
    List.Add(Format('[$%s,%d]',[Text[n].Name,Text[n].Count]));
    For m:=0 To Text[n].Count-1 do
    begin
      If not Text[n].Text[m].Retry Then
        List.Add('0') else
        List.Add(Format('{$%s,%d,%d}',
        [Text[Text[n].Text[m].RetryID].Name,Text[n].Text[m].RetryID,Text[n].Text[m].RetryNUM]));
    end;
  List.Add('');
  end;
  List.SaveToFile(FileName);
  List.Free;
end;

Function AssignDar(Buf: Pointer): TDar;
var I: ^Integer; S: ^String; C: ^Char; n,Pos: Integer;
begin
  Result:=NIL;
  Pos:=4;
  I:=Buf;
  SetLength(Result, I^);
  Inc(I);
  For n:=0 To Length(Result)-1 do
  begin
    C:=Addr(I^);
    Result[n].FileName:='';
    While C^<>#0 Do
    begin
      Result[n].FileName:=Result[n].FileName+C^;
      Inc(C); Inc(Pos);
    end;
    Pos:=RoundBy(Pos+1,4);
    I:=Buf; Inc(Integer(I),Pos);
    Result[n].FileSize:=I^;
    Pos:=RoundBy(Pos+4,16);
    I:=Buf; Inc(Integer(I),Pos);
    Result[n].FileData:=I;
    Inc(Pos,Result[n].FileSize+1);
    I:=Buf; Inc(Integer(I),Pos);
  end;
end;

Function GetDarFile(var P: Pointer; Dar: TDar; Name: String): Integer;
var n: Integer;
begin
  For n:=0 To Length(Dar)-1 do
  begin
    If Dar[n].FileName=Name Then
    begin
      P:=Dar[n].FileData;
      Result:=Dar[n].FileSize;
      Exit;
    end;
  end;
  Result:=-1;
end;

Function GetString(P: Pointer): String;
var C: ^Char;
begin
  Result:=''; C:=P;
  While C^<>#0 do
  begin
    Result:=Result+C^;
    Inc(C);
  end;
end;

Function CheckForRetry(var Text: TMGATextArray; n,m: Integer): Boolean;
var r,l: Integer;
begin
  Result:=False;
  For r:=0 To n do
  For l:=0 To Text[r].Count-1 do
  begin
    If (r=n) and (m=l) Then Exit;
    If Text[n].Text[m].S=Text[r].Text[l].S Then
    begin
      Text[n].Text[m].Retry:=True;
      Text[n].Text[m].RetryName:=Text[r].Name;
      Text[n].Text[m].RetryID:=r;
      Text[n].Text[m].RetryNUM:=l;
      Result:=True;
      Exit;
    end;
  end;
end;

Procedure ExtractText(P: Pointer; var Text: TMGATextArray; Name: String);
var n,m: Integer; I: ^DWord; Head: ^TMGATextHeader; Pos,Count: Integer;
begin
  Pos:=20;
  n:=Length(Text);
  SetLength(Text,n+1);
  Text[n].Name:=Name;
  I:=P;
  While I^<>$FFFFFFFF do begin Inc(I); Inc(Pos); end;
  Inc(I); Head:=Addr(I^);
  Count:=(Head^.TextPos-Pos) div 4;
  Text[n].Count:=Count;
  SetLength(Text[n].Text,Count);
  Inc(I,5);
  For m:=0 To Count-1 do
  begin
    Text[n].Text[m].S:=GetString(Pointer(Integer(Head)+Head^.TextPos+(I^-$80000000)));
    CheckForRetry(Text,n,m);
    Inc(I);
  end;     
end;

Function LoadFile(var Buf: Pointer; FileName: String): Integer;
var F: File; Size: Integer;
begin
  If Not FileExists(FileName) Then Exit;
  AssignFile(F,FileName);
  Reset(F,1);
  Size:=FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F,Buf^,Size);
  CloseFile(F);
  Result:=Size;
end;

Function CompareSign(S1,S2: TTextSign): Boolean;
var n: Integer;
begin
  Result:=True;
  For n:=0 To 7 do begin
    If S1[n]<>S2[n] Then begin Result:=False; Exit; End;
  end;
end;

Procedure ExtractAllText(var Text: TMGATextArray; Folder: String; Progr: TProgrProc = NIL);
var SR: TSearchRec; Size,n: Integer; Buf: Pointer; Dar: TDar; Sign: ^TTextSign;
begin
  If Folder[Length(Folder)]<>'\' Then Folder:=Folder+'\';
  If FindFirst(Folder+'*.*', faAnyFile, SR) <> 0 Then Exit;
  Repeat
    If (SR.Attr and faDirectory = faDirectory) and FileExists(Folder+SR.Name+'\_zar') then
    begin
      If @Progr<>NIL Then Progr(SR.Name);
      Size:=LoadFile(Buf, Folder+SR.Name+'\_zar');
      Size:=ZARDecompress(Buf,Size);
      Dar:=AssignDar(Buf);
      For n:=0 To Length(Dar)-1 do
      begin
        Sign:=Dar[n].FileData;
        If CompareSign(Sign^,TextSign) Then
          ExtractText(Dar[n].FileData,Text,Format('%s\%s',[SR.Name,Dar[n].FileName]));
      end;
      FreeMem(Buf);
    end;
  Until FindNext(SR) <> 0;
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function GetParam(S: String; Num: Integer): String;
var n,m: Integer;
begin
  m:=1;
  Result:='';
  For n:=3 to Length(S)-1 do
  begin
    If (Num=m) and (S[n]=',') Then Inc(m);
    If Num=m then
    Result:=Result+S[n];
    If (Num<>m) and (S[n]=',') Then Inc(m);
  end;
end;



Function ZARDecompress(var Buf: Pointer; Size: Integer): Integer;
var OutSize: Integer; WBuf: Pointer; FileSize: ^Integer;
begin
  FileSize:=Buf;
  Result:=FileSize^;
  //If Assigned(WBuf) Then FreeMem(WBuf);
  GetMem(WBuf,FileSize^);
  ZDecompress(Pointer(Integer(Buf)+4), Size, WBuf, OutSize, FileSize^);
  FreeMem(Buf);
  Buf:=WBuf;
end;

Function TXDDecompress(var Buf: Pointer; Size: Integer): Integer;
var OutSize: Integer; WBuf: Pointer; FileSize: ^Integer;
begin
  FileSize:=Buf;
  Inc(FileSize);
  Result:=FileSize^;
  GetMem(WBuf,FileSize^);
  ZDecompress(Pointer(Integer(Buf)+8), Size, WBuf, OutSize, FileSize^);
  FreeMem(Buf);
  Buf:=WBuf;
end;

Function ZARCompress(var Buf: Pointer; Size: Integer): Integer;
var WBuf,B: Pointer;
begin
  GetMem(WBuf, Size);;
  ZCompress(Buf, Size, WBuf, Result);
  FreeMem(Buf);
  Buf:=WBuf;
  //Inc(Result,4);
end;

Function TXDCompress(var Buf: Pointer; Size: Integer): Integer;
var WBuf,B: Pointer;
begin
  GetMem(WBuf, Size);
  ZCompress(Buf, Size, WBuf, Result, zcMax);
  FreeMem(Buf);
  Buf:=WBuf;
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

end.
