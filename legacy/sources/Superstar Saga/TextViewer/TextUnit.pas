unit TextUnit;

interface

Uses Classes, TableText;

Type
  TTable = Packed Record
    Text: WideString;
    Value: Word;
    D: Boolean;
  end;
  TTableArray = Array of TTable;

  TMessage = Packed Record
    Text: WideString;
    Retry: Boolean;
    RName: String;
    RID:  Word;
  end;

  TMsg = Packed Record
    Name: String;
    S: Array of TMessage;
  end;
  TText = Array of WideString;

var MText: TGameTextSet;
HexError: Boolean;
const
  cEndLine = '{END}';

Function RoundBy(Value, R: Integer): Integer;
Function InText(S: String; List: TText): Boolean;
function PosExRev(const SubStr, S: WideString; Offset: Cardinal = 0): Integer;
function PosEx(const SubStr, S: WideString; Offset: Cardinal = 1): Integer;
Function CharToWideChar(Ch: Char): WideChar;
implementation

Function CharToWideChar(Ch: Char): WideChar;
Var WS: WideString;
begin
 WS := Ch;
 Result := WS[1];
end;


Function InText(S: String; List: TText): Boolean;
var n: Integer;
begin
  Result:=True;
  For n:=0 To High(List) do If (Pos(List[n],S)>0) Then Exit;
  Result:=False;
end;

function PosEx(const SubStr, S: WideString; Offset: Cardinal = 1): Integer;
var
  I,X: Integer;
  Len, LenSubStr: Integer;
begin
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if S[I] = SubStr[1] then
      begin
        X := 1;
        while (X < LenSubStr) and (S[I + X] = SubStr[X + 1]) do
          Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;


function PosExRev(const SubStr, S: WideString; Offset: Cardinal = 0): Integer;
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

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;


end.
