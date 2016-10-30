unit HexUnit;

interface

//***Numbers convertion utilities***//
Function IntCheckOut(S: String): Boolean;
//Returns TRUE if S contains the valid integer value
Function HexCheckOut(S: String): Boolean;
//Returns TRUE if S contains the valid integer value or hXX style hex value
Function UnsCheckOut(S: String): Boolean;
//Returns TRUE if S contains the valud unsigned value or hXX style hex value
Function StrToInt(Const S: string): Integer;
//Converts decimal string to 32 bit integer value
Function HexToInt(Const S: String): Integer;
//Converts hex-string to 32 bit integer value
Function DecHexToInt(S: String): Integer;
//Converts decimal or hXX style hex-string to 32 bit integer value
Function HexToCardinal(Const S: String): Cardinal;
//Converts hex-string to 32 bit unsigned value
Function GHexToInt(S: String): Integer;
//Converts hex-string of 0XXh style to integer value
Function SwapWord(Value: Word): Word;
//Swaps bytes in 16 bit value
Function SwapInt(Value: Integer): Integer;
//Swaps bytes in 32 bit value
Function SwapInt64(Value: Int64): Int64;
//Swaps bytes in 64 bit value
Function IntToDelphiHex(Value: Int64; Digits: Byte): String;
//Converts decimal to DELPHI format hex-string (ex: $135ABC)

Var
 HexError: Boolean = False;
 IntError: Boolean = False;

implementation

uses SysUtils;

Function IntToDelphiHex(Value: Int64; Digits: Byte): String;
begin
 If Value < 0 then
 begin
  If Value = Low(Int64) then
  begin
   Result := '-$8000000000000000';
   Exit;
  end Else
  begin
   Result := '-$';
   Value := -Value;
  end;
 end Else Result := '$';
 Result := Result + IntToHex(Value, Digits);
end;

Function StrToInt(Const S: String): Integer;
Var E: Integer;
begin
 Val(S, Result, E);
 IntError := E <> 0;
end;

Function DecHexToInt(S: String): Integer;
begin
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
 end Else Result := StrToInt(S);
end;

Function GHexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: PChar; H: Char;
begin
 HexError := True;
 Result := 0;
 LS := Length(S);
 If (LS <= 0) then Exit;
 If Upcase(S[LS]) <> 'H' then
 begin
  HexError := False;
  Result := StrToInt(S);
  Exit;
 end Else
 begin
  Dec(LS);
  SetLength(S, LS);
  If (LS > 8) and (S[1] = '0') then Delete(S, 1, 1);
  LS := Length(S);
 end;
 If LS > 8 then Exit;
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

Function HexToInt(Const S: String): Integer;
Var
 I, LS, J: Integer; PS: PChar; H: Char;
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

Function HexToCardinal(Const S: String): Cardinal;
Var
 I, LS: Integer; PS: PChar; H: Char; J: Cardinal;
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
 If S <> '' then
 begin
  Result := True;
  If S[1] = '-' then Delete(S, 1, 1);
  If (Length(S) > 10) or (S = '') then
  begin
   Result := False;
   Exit;
  end;
  For I := 1 to Length(S) do If not (S[I] in ['0'..'9']) then
  begin
   Result := False;
   Exit;
  end;
 end Else Result := False;
end;

Function HexCheckOut(S: String): Boolean;
Var I: Integer;
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

Function UnsCheckOut(S: string): Boolean;
Var i: integer;
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
 end;
end;

Function SwapInt(Value: Integer): Integer;
asm
 bswap  eax
end;

Function SwapWord(Value: Word): Word;
asm
 xchg   al,ah
end;

Function SwapInt64(Value: Int64): Int64;
Type
 TInt64 = Packed Record
  A: Integer;
  B: Integer;
 end;
Var
 Val: TInt64 absolute Value;
 Res: TInt64 absolute Result;
begin
 Res.A := SwapInt(Val.B);
 Res.B := SwapInt(Val.A);
end;

end.
