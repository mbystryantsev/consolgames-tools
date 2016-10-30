library FFTA;

uses
  ShareMem,
  Needs in '..\Needs.pas',
  FFTALib in '..\..\FFTA\FFTALib.pas';

{$E .kpl}

resourcestring
 SKPLDescription = 'FFTA';


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
Var P: PChar; Ptr,DW: ^Word; S: String;
begin
 Result := NIL;
 If (X >= RomSize) or (X < 0) then Exit;
 New(Result, Init);
 Ptr:=Addr(Rom^[X]);
 With Result^.Add^ do
 begin
  {Str:='';
  Exit;}
  While Ptr^<>$FFFF do
  begin
    DW:=Addr(ROM^[X+Ptr^]);
    If DW^=$32 Then
    begin
      {SetLength(S, FFTAGetDataSize(Addr(ROM^[X+Ptr^+2])));
      FFTADecompress(Addr(ROM^[X+Ptr^+2]),Addr(S[1]));
      Str:=S;}
      Str:='!';
    end else
    begin
      P := Addr(ROM^[X+Ptr^+2]);
      Str := P;
    end;
    Inc(Ptr);
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

