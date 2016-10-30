Unit Needs;

interface

Type
 TMethod = (tmNormal, tmL1T, tmL1Te, tmL1TL1T, tmC2S1eSne, tmHat, tmBkp, tmP2P, tmNone);
 DWord = LongWord;
 PByte = ^Byte;
 PWord = ^Word;
 PDWord = ^DWord;
 PBytes = ^TBytes;
 TBytes = Array[Word] of Byte;
 PWords = ^TWords;
 TWords = Array[Word] of Word;
 PDWords = ^TDWords;
 TDWords = Array[Word] of DWord;
 TItemState = (isCode, isBreak, isTerminate);
 PTableItem = ^TTableItem;
 TTableItem = Record
  tiCodes: String;
  tiString: WideString;
  tiState: TItemState;
  Next: PTableItem;
 end;
 PTextString = ^TTextString;
 TTextString = Record
  Str: String;
  Next: PTextString;
 end;
 PTextStrings = ^TTextStrings;
 TTextStrings = Object
  Root, Cur: PTextString;
  Count: Integer;
  Constructor Init;
  Function Add: PTextString;
  Function Get(I: Integer): PTextString;
  Destructor Done;
 end;

Function CompareData(P1, P2: Pointer; Length: Integer): Boolean;
Procedure DisposeStrings(TextStrings: PTextStrings); stdcall;
Function GetEnd(Data: Pointer; Root: PTableItem; Max: Integer): PTableItem;

implementation

Procedure DisposeStrings(TextStrings: PTextStrings); stdcall;
begin
 Dispose(TextStrings, Done);
end;

Function CompareData(P1, P2: Pointer; Length: Integer): Boolean; Assembler;
Asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,P1
        MOV     EDI,P2
        MOV     EDX,ECX
        XOR     EAX,EAX
        AND     EDX,3
        SHR     ECX,1
        SHR     ECX,1
        REPE    CMPSD
        JNE     @@2
        MOV     ECX,EDX
        REPE    CMPSB
        JNE     @@2
        INC     EAX
@@2:    POP     EDI
        POP     ESI
end;

Function TTextStrings.Get(I: Integer): PTextString;
Var N: PTextString; J: Integer;
begin
 N := Root;
 J := 0;
 While N <> NIL do
 begin
  If J = I then
  begin
   Result := N;
   Exit;
  end;
  Inc(J);
  N := N^.Next;
 end;
 Result := NIL;
end;

Constructor TTextStrings.Init;
begin
 Root := NIL;
 Cur := NIL;
 Count := 0;
end;

Function TTextStrings.Add: PTextString;
begin
 New(Result);
 If Root = NIL then Root := Result Else Cur^.Next := Result;
 Cur := Result;
 Inc(Count);
 Result^.Str := '';
 Result^.Next := NIL;
end;

Destructor TTextStrings.Done;
Var N: PTextString;
begin
 While Root <> NIL do
 begin
  N := Root^.Next;
  Root^.Str := '';
  Dispose(Root);
  Root := N;
 end;
 Count := 0;
 Cur := NIL;
end;

Function GetEnd(Data: Pointer; Root: PTableItem; Max: Integer): PTableItem;
Var EF: Boolean; J: Integer;
begin
 EF := False;
 J := Max;
 Repeat
  Result := Root;
  While Result <> NIL do With Result^ do
  begin
   If (Length(tiCodes) = J) and CompareData(Data, Addr(tiCodes[1]), J) then
   begin
    EF := True;
    Break;
   end;
   Result := Next;
  end;
  Dec(J);
 Until EF or (J = 0);
end;

end.
