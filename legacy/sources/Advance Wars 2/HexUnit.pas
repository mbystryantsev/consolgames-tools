unit HexUnit;

interface

Function HexToInt(S: String): Integer;
Function GetLDW(S: String): Integer;
Function IntCheckOut(S: String): Boolean;
Function HexCheckOut(S: String): Boolean;
Function UnsCheckOut(S: String): Boolean;
Function CheckFileName(FileName: String): Boolean;
Function StrToInt(Const S: string): Integer;
Function HexToCardinal(S: String): Cardinal;

Var
 HexError: Boolean = False;
 IntError: Boolean = False;

implementation

Function StrToInt(Const S: String): Integer;
Var E: Integer;
begin
 Val(S, Result, E);
 IntError := E <> 0;
end;

Function GetLDW(S: String): Integer;
var Code, V: Integer;
begin
  Val(S, V, Code);
  If Code <> 0 Then IntError := True
  else Result := V;
{
 IntError := True;
 If S = '' then
 begin
  Result := 0;
  Exit;
 end;
 if s[1] in ['h', 'H'] then
 begin
  Delete(S, 1, 1);
  If S = '' then
  begin
   Result := 0;
   HexError := True;
   IntError := False;
  end Else
  begin
   Result := HexToInt(S);
   IntError := False;
  end;
 end Else Result := StrToInt(S);    }
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

Function HexToCardinal(S: String): Cardinal;
Var
 I, LS: Integer; PS: ^Char; H: Char; J: Cardinal;
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

Function IntCheckOut(S: String): Boolean;
Var I: Integer;
begin
 Result := False;
 if s = '' then exit;
 Result := True;
 If s[1] = '-' then Delete(s, 1, 1);
 If (Length(s) > 10) or (S = '') then
 begin
  Result := false;
  Exit;
 end;
 For i := 1 to Length(s) do If not (s[i] in ['0'..'9']) then
 begin
  Result := False;
  Exit;
 end;
end;

Function HexCheckOut(S: String): Boolean;
Var I, Code: Integer;
begin
 Result := False;
 if s = '' then exit;
 Result := True;
 if s[1] in ['h', 'H'] then
 begin
  Delete(s, 1, 1);
  if (length(s) > 8) or (S = '') then
  begin
   Result := false;
   Exit;
  end;
  For I := 1 to Length(s) do
   If not (s[i] in ['0'..'9', 'A'..'F', 'a'..'f']) then
   begin
    Result := False;
    Exit;
   end;
 end Else
 begin
  If s[1] = '-' then
   Delete(s, 1, 1);
  If (Length(s) > 10) or (S = '') then
  begin
   Result := false;
   Exit;
  end;
  For i := 1 to Length(s) do
   If not (s[i] in ['0'..'9']) then
   begin
    Result := False;
    Exit;
   end;
 end;
end;

Function UnsCheckOut(s: string): Boolean;
Var I, Code: Integer;
begin
 Result := False;
 if s = '' then exit;
 Val(S, I, Code);
 If Code = 0 Then
 Result := True;
 {
 if s[1] in ['h', 'H'] then
 begin
  Delete(s, 1, 1);
  if (length(s) > 8) or (S = '') then
  begin
   Result := false;
   Exit;
  end;
  For i := 1 to Length(s) do
   If not (s[i] in ['0'..'9', 'A'..'F', 'a'..'f']) then
   begin
    Result := False;
    Exit;
   end;
 end Else
 begin
  if (length(s) > 10) or (S = '') then
  begin
   Result := false;
   Exit;
  end;
  For i := 1 to Length(s) do
   If not (s[i] in ['0'..'9']) then
   begin
    Result := False;
    Exit;
   end;
 end;    }
end;

Function CheckFileName(FileName: String): Boolean;
Var I: Integer;
begin
 Result := True;
 For I := 1 to Length(FileName) do
 If FileName[I] in ['\', '/', ':', '*', '?', '"', '<', '>', '|'] then
 begin
  Result := False;
  Exit;
 end;
end;

end.
