library NULL;

uses
  ShareMem,
  Needs in '..\Needs.pas';

{$E .kpl}

resourcestring
 SKPLDescription = 'Плагин для основного текста игры "Sword of Mana" (GBA)';

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
Var R: PTextString; SCount,Pos: Word; W: ^Word;
begin
 Result := '';
 SCount:=0;
 With TextStrings^ do
 begin
  R := Root;
  While R <> NIL do
  begin
    SCount:=SCount+1;
    R := R^.Next;
  end;
 end;
 Pos:=SCount*2+6;
 SetLength(Result,Pos);
 W:=Addr(Result[1]);
 W^:=0; Inc(W);
 W^:=SCount; Inc(W);
 If TextStrings = NIL then Exit;
 With TextStrings^ do
 begin
  R := Root;
  W^:=Pos; Inc(W);
  While R <> NIL do
  begin
   Inc(Pos, Length(R^.Str));
   W^:=Pos; Inc(W);
   Result := Result + R^.Str;
   R := R^.Next;
  end;
 end;
 //Pos:=Length(Result);
end;

{Procedure CopyMem(PDst,PSrc: Pointer; Size: Integer);
var B1,B2: ^Byte; n: Integer;
begin
  B1:=PDst; B2:=PSrc;
  For n:=0 To Size-1 do
  begin
    B1^:=B2^;
    Inc(B1); Inc(B2);
  end;
end;}

Function GetStrings(X, Sz: Integer): PTextStrings; stdcall;
Var I: DWord; Ptr,NPtr,Count: ^Word; Offset,n: Integer; Flag: Boolean;
begin
 Offset:=0;
 Count:=Addr(ROM^[X]);
 Inc(Count);
 Ptr:=Count;
 NPtr:=Count; Inc(Ptr); Inc(NPtr,2);
 Result := NIL;
 If (X >= RomSize) or (X < 0) then Exit;
 New(Result, Init);
 For n:=0 To Count^-1 do
 begin
  If NPtr^<Ptr^ Then Inc(Offset,$10000);
  With Result^.Add^ do
  begin
    I := NPtr^ - Ptr^;
    If Ptr^>NPtr^ Then Inc(I,$10000);
    While (I > 0) and (X + I >= RomSize) do Dec(I);
    If I > 0 Then
    begin
      SetLength(Str, I);
      Move(ROM^[X + Ptr^+Offset], Str[1], I);
      //CopyMem(Addr(ROM^[X + Ptr^]), Addr(Str[1]), I);
    end
    else Str:='';
    Inc(Ptr); Inc(NPtr);
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

