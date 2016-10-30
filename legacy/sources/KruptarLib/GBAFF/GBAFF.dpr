library GBAFF;

uses
  ShareMem,
  Needs in '..\Needs.pas';

{$E .kpl}

resourcestring
 SKPLDescription = 'Библиотека для работы со строками, заканчивающимися $0D';

Var
 ROM: PBytes = NIL;
 RomSize: Integer = 0;
 EndsRoot: PTableItem = NIL;
 MaxCodes: Integer = 0;
 Align: Integer = 1;

Function Description: String; stdcall;
begin
 Result := SKPLDescription;
end;

Function NeedEnd: Boolean; stdcall;
begin
 Result := True;
end;

Function GetMethod: TMethod; stdcall;
begin
 Result := tmNormal;
end;

Procedure SetVariables(X: PBytes; Sz: Integer; ER: PTableItem; MC, AL: Integer); stdcall;
begin
 ROM := X;
 RomSize := Sz;
 EndsRoot := ER;
 MaxCodes := MC;
 Align := AL;
end;

Function GetData(TextStrings: PTextStrings): String; stdcall;
Var R: PTextString;
begin
 Result := '';
 If TextStrings = NIL then Exit;
 With TextStrings^ do
 begin
  R := Root;
  While R <> NIL do
  begin
   Result := Result + R^.Str + #$0D;
   R := R^.Next;
  end;
 end;
end;


Function GetStrings(X, Sz: Integer): PTextStrings; stdcall;
Var R: PTableItem; B: ^Byte; I, J: Integer; S: PTextString;
begin
 Result := NIL;
 If (X >= RomSize) or (X < 0) then Exit;
 If Sz > 0 then
 begin
  New(Result, Init);
  With Result^.Add^ do
  begin
   If X + Sz > RomSize then J := RomSize - X Else J := Sz;
   SetLength(Str, J);
   Move(ROM^[X], Str[1], J);
  end;
 end Else
 begin
  If (EndsRoot = NIL) or (MaxCodes <= 0) then Exit;
  New(Result, Init);
  B := Addr(ROM^[X]);
  I := 0;
  With Result^ do
  begin
   S := Add;
   Repeat
    R := GetEnd(B, EndsRoot, MaxCodes);
    If R <> NIL then With S^, R^ do
    begin
     Str := Str;// + tiCodes;
     J := Length(tiCodes);
    end Else With S^ do
    begin
     Str := Str + Char(B^);
     J := 1;
    end;
    While J mod Align > 0 do Inc(J);
    Inc(DWord(B), J);
    Inc(I, J);

    If (I = Sz) or (X + I > RomSize) then Exit;
    If R <> NIL then
    begin
     If Sz <= 0 then
      Exit Else
      S := Add;
    end;
   Until False;
  end;
 end;
end;

exports
 GetMethod,
 SetVariables,
 GetData,
 GetStrings,
 DisposeStrings,
 NeedEnd,
 Description;

end.

