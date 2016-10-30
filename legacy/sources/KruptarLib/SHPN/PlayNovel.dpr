library NULL;

uses
  ShareMem,
  Needs in '..\Needs.pas',
  SHPL in 'SHPL.pas';

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
Var R: PTextString;
begin
 Result := '';
 If TextStrings = NIL then Exit;
 With TextStrings^ do
 begin
  R := Root;
  While R <> NIL do
  begin
   Result := Result + R^.Str + #0;
   R := R^.Next;
  end;
 end;
end;

Function GetStrings(X, Sz: Integer): PTextStrings; stdcall;
Var P: PChar;  I: Integer;
begin
 Result := NIL;
 If (X >= RomSize) or (X < 0) then Exit;
 New(Result, Init);
 //I:=ROM[X]^;
 Result^.Add^.Str:=UnHuf(ROM,$53E918,X);

 //With Result^ do For I := 0 to 4 - 1 do Add^.Str := 'Û';
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

