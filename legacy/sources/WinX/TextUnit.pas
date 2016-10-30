unit TextUnit;

interface

uses Classes, SysUtils;

type
  TMessage = Packed Record
    Text: String;
    Retry: Boolean;
    RName: String;
    RID:  Word;
  end;
  TMessageArray = Array of TMessage;
  TMsg = Packed Record
    Name: String;
    S: TMessageArray;
  end;
  TText = Array of TMsg;
  TProc = Function(N: Integer; S: String): Boolean;

Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
Function LoadFile(Name: String; var Pos: Pointer): Integer;
Function GetPart(S: String; C: Char; Num: Integer): String;
Function GetNextMessage(Msg: TMsg; n: Integer): Integer;
Function GetPart2(S: String; C: Char; Num: Integer): String;
Function FindMessage(Name: String; Text: TText): Integer;
Procedure SaveOpt(Name: String; Text: TText);
Procedure OptimizeText(var Text: TText; P: TProc = NIL);
Procedure OpenOpt(Name: String; var Text: TText);
Procedure OpenText(Name: String; var Text: TText);
Procedure SaveText(Name: String; Text: TText);
Function RoundBy(Value, R: Integer): Integer;
implementation

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
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

Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
var F: File;
begin
  FileMode := fmOpenWrite;
  AssignFile(F,Name);
  Rewrite(F,1);
  BlockWrite(F, Pos^, Size);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Function LoadFile(Name: String; var Pos: Pointer): Integer;
var F: File;
begin
  FileMode := fmOpenRead;
  Result:=-1;
  If not FileExists(Name) Then Exit;
  AssignFile(F,Name);
  Reset(F,1);
  Result:=FileSize(F);
  GetMem(Pos, Result+1);
  BlockRead(F, Pos^, Result);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Function GetPart(S: String; C: Char; Num: Integer): String;
var n,m: Integer;
begin
  m:=1;
  Result:='';
  For n:=3 to Length(S)-1 do
  begin
    If (Num=m) and (S[n]=C) Then Inc(m);
    If Num=m then
    Result:=Result+S[n];
    If (Num<>m) and (S[n]=C) Then Inc(m);
  end;
end;

Function GetNextMessage(Msg: TMsg; n: Integer): Integer;
begin
  Result:=n;
  While Msg.S[Result].Retry do Inc(Result);
end;

Function GetPart2(S: String; C: Char; Num: Integer): String;
var n,m: Integer;
begin
  m:=1;
  Result:='';
  For n:=1 to Length(S) do
  begin
    If (Num=m) and (S[n]=C) Then Inc(m);
    If Num=m then
    Result:=Result+S[n];
    If (Num<>m) and (S[n]=C) Then Inc(m);
  end;
end;

Function FindMessage(Name: String; Text: TText): Integer;
begin
  For Result:=0 To High(Text) do If Text[Result].Name=Name Then break;
  If Result=Length(Text) Then Result:=-1;
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

end.
 