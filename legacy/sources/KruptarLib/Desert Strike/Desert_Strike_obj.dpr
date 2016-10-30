library Desert_Strike_obj;

uses
  ShareMem,
  SysUtils,
  Needs in '..\Needs.pas',
  HexUnit in '..\..\Advance Wars 2\HexUnit.pas';

{$E .kpl}

resourcestring
 SKPLDescription = 'NULL';

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
 Result := tmNone;
end;

Type TBPointer = Packed Record
  Null1, Ptr, FF, Null2: DWord;
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
Var R: PTextString; B: ^Byte; n: Integer;
begin
 Result := '';
 If TextStrings = NIL then Exit;
 With TextStrings^ do
 begin
  R := Root;
  While R <> NIL do
  begin
   SetLength(Result,Length(Result)+Length(R^.Str)+10);
   //Move(R^.Str[24],Addr(Result[Length(Result)-Length(R^.Str)+10])^,Length(R^.Str)-24);
   Move(R^.Str[24],Result[11],Length(R^.Str)-24+1);
   B:=Addr(Result[1]);
   For n:=1 To 10 do
   begin
    B^:=HexToInt(R^.Str[n*2]+R^.Str[n*2+1]);
    Inc(B);
   end;
   R := R^.Next;
  end;
 end;
end;

{Function GetData(TextStrings: PTextStrings): String; stdcall;
Var R: PTextString;
begin
 Result := '';
 If TextStrings = NIL then Exit;
 With TextStrings^ do
 begin
  R := Root;
  While R <> NIL do
  begin
   If Length(R^.Str)>24 Then
   Result := Result + R^.Str;
   R := R^.Next;
  end;
 end;
end;}

{Function GetStrings(X, Sz: Integer): PTextStrings; stdcall;
Var P: PChar; S: String; n: Integer; B: ^Byte;
begin
 Result := NIL;
 If (X >= RomSize) or (X < 0) then Exit;
 New(Result, Init);
 With Result^.Add^ do
 begin            
  S:='';
  B:=Pointer(DWord(ROM)+X);
  For n:=0 To 9 do
  begin
    S:=Format('%s%.2x',[S,B^]);
    Inc(B);
  end;
  P := Addr(ROM^[X+10]);
  Str := Format('%s'#0'%s',[S,P]);
 end;
end;}

Function GetStrings(X, Sz: Integer): PTextStrings; stdcall;
Var R: PTableItem; B,BB: ^Byte; I, J: Integer; S: PTextString; SCode: String; n: Byte;
Label CodeAdd;
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
  B := Addr(ROM^[X+10]);
  I := 0;
  With Result^ do
  begin
   SCode:='';
   BB:=Pointer(DWord(ROM)+X);
   For n:=0 To 9 do
   begin
     SCode:=Format('%s%.2x',[SCode,BB^]);
     Inc(BB);
   end;
   S := Add;
   S^.Str:=Format('{%s}'#0,[SCode]);
   Repeat
    R := GetEnd(B, EndsRoot, MaxCodes);
    If R <> NIL then With S^, R^ do
    begin
     Str := Str + tiCodes;
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

