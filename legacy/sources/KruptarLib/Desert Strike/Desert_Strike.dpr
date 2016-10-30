library Desert_Strike;

uses
  ShareMem, Classes, SysUtils,
  Needs in '..\Needs.pas';

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
Var R: PTextString; W,Ptr: ^Word; Pos: DWord; n: Integer;
F: TMemoryStream;
begin
  F:=TMemoryStream.Create;
  //F.LoadFromFile('Desert\0423 - Desert Strike Advance (U).gba');
 F.LoadFromFile('0423 - Desert Strike Advance (U).gba');
 Pos:=$F138;//$EA96;
 Result := '';
 If TextStrings = NIL then Exit;
 With TextStrings^ do
 begin
  R := Root;
  SetLength(Result,2258{ $8C*4});
  W:=Pointer(DWord(F.Memory)+$30E866);
  Move(W^,Addr(Result[1])^,2258);
  F.Free;
  W:=Addr(Result[1]);
  Ptr:=W; Inc(W,$8C);
  //While R <> NIL do
  For n:=0 To $8C-1 do
  begin
   If R^.Str<>'' Then
   begin
    W^:=Length(R^.Str);
    Ptr^:=Pos;
    Inc(Pos,W^);
   end;
   Inc(Ptr); Inc(W);
   Result := Result + R^.Str;
   R := R^.Next;
  end;
 end;
end;


Function GetStrings(X, Sz: Integer): PTextStrings; stdcall;
Var P: PChar; Pos: Pointer; W,Ptr: ^Word; n: Integer;
begin
 W:=Pointer(DWord(ROM)+$30E97E);
 Ptr:=Pointer(DWord(ROM)+$30E866);
 //Pos:=Pointer(DWord(ROM)+$30EA96);
 Result := NIL;
 If (X >= RomSize) or (X < 0) then Exit;
 New(Result, Init);
 For n:=0 to $8C-1 do
 begin
  With Result^.Add^ do
  begin
    If Ptr^>$E866 Then
    begin
      SetLength(Str,W^);
      Move(Pointer(Ptr^+DWord(ROM)+$300000)^,Str[1],W^);
      //P := Addr(ROM^[X]);
      //Str := P;
    end else
    begin
      Str:='';
    end;
    Inc(Ptr); Inc(W);
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

