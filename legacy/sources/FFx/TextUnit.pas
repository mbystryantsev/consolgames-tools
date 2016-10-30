unit TextUnit;

interface

Uses Classes;

Type
  TTable = Packed Record
    Text: String;
    Value: Word;
    D: Boolean;
  end;
  TTableArray = Array of TTable;

  TMessage = Packed Record
    Text: String;
    Retry: Boolean;
    RName: String;
    RID:  Word;
  end;

  TMsg = Packed Record
    Name: String;
    S: Array of TMessage;
  end;
  TText = Array of String;

var MText: TText;
HexError: Boolean;
const
  cEndLine = '{END}';

Function RoundBy(Value, R: Integer): Integer;
Function HexToInt(S: String): Integer;
Procedure LoadText(Name: String; var Text: TText);
Procedure SaveText(Name: String; Text: TText);
Function InText(S: String; List: TText): Boolean;
Function GetUpCase(S: String): String;
function PosExRev(const SubStr, S: string; Offset: Cardinal = 0): Integer;
Function CharToWideChar(Ch: Char): WideChar;
implementation

Function CharToWideChar(Ch: Char): WideChar;
Var WS: WideString;
begin
 WS := Ch;
 Result := WS[1];
end;

Procedure LoadText(Name: String; var Text: TText);
var List: TStringList; n,m: Integer; S: String; Skip, Read, Per: Boolean;
Label Skp;
begin
  SetLength(Text,1); n:=0;
  Skip:=False; Read:=True;
  List:=TStringList.Create;
  List.LoadFromFile(Name);
  For m:=0 To List.Count-1 do
  begin
    {If Skip Then
    begin
      Skip:=False; GoTo Skp;
    end;}
    S:=List.Strings[m];
    If not Read Then
    begin
      n:=Length(Text);
      If m<List.Count-1 Then SetLength(Text,n+1);
      Read:=True; Per:=False;
    end else
    begin
      If S<>cEndLine Then
      begin
        If not Read Then
        begin
          Per:=False;
          Read:=True;
        end;
        If Per Then Text[n]:=Text[n]+#13#10+S
        else Text[n]:=Text[n]+S;
        Per:=True;
      end else
      begin
        Read:=False; //Skip:=True;
      end;
    end;
    Skp:
  end;
end;

Procedure SaveText(Name: String; Text: TText);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To High(Text) do
  begin
    List.Add(Text[n]);
    List.Add(cEndLine);
    List.Add('');
  end;
  List.SaveToFile(Name);
  List.Free;
end;

Function InText(S: String; List: TText): Boolean;
var n: Integer;
begin
  Result:=True;
  For n:=0 To High(List) do If (Pos(List[n],S)>0) Then Exit;
  Result:=False;
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
      'à'..'ÿ':  Dec(C^, Ord('à') - Ord('À'));
      '¸':       Dec(C^, Ord('¸') - Ord('¨'));
    end;
    Inc(C);
  end;
end;

function PosExRev(const SubStr, S: string; Offset: Cardinal = 0): Integer;
var
  I,X: Integer;
  LenSubStr: Integer;
begin
  I := Offset;
  LenSubStr := Length(SubStr);
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

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char;
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

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;


end.
