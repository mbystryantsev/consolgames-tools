unit GbaUnit;

interface

Uses SysUtils, Classes;

Type
 DWord = Cardinal;
 PByte = ^Byte;
 PWord = ^Word;
 PDWord = ^DWord;
 PBytes = ^TBytes;
 TBytes = Array[Word] of Byte;
 PWords = ^TWords;
 TWords = Array[Word] of Word;
 PDWords = ^TDWords;
 TDWords = Array[Word] of DWord;
 PPalette = ^TPalette;
 TPalette = Array[Byte] of DWord;
 PFreq = ^TFreq;
 TFreq = Record
  Count: Integer;
  Code: Integer;
  HCode: DWord;
  LRbit: DWord;
  Pos: Integer;
  Left: PFreq;
  Right: PFreq;
  Next: PFreq;
 end;
 TFreqs = Class
  Root: PFreq;
  Count: Integer;
  Constructor Create;
  Function Add: PFreq;
  Function MakeParent: Boolean;
  Destructor Destroy; override;
 end;


//*** HUFFMAN ***//

Function HuffDecompress(Var Source, Dest): Integer;
Function HuffCompress(Var Source, Dest; SrcLen: Integer; Bit8: Boolean): Integer;

Var
 LastHufSize: Integer;

//**** LZ77 *****//

function Lz77Decompress(Var Source, Dest): Integer;
function Lz77Compress(Var Source, Dest; SrcLen: Integer; VRAM_Safe: Boolean): Integer;
procedure Lz77_DecompressNH(Var Source, Dest; UncompSize: Integer);
function Lz77_StreamDecompress(const Source, Dest: TStream): Integer;
procedure Lz77_StreamDecompressNH(Const Source, Dest: TStream; UncompSize: Integer);
function Lz77_StreamCompress(const Source, Dest: TStream;
                             SrcLen: Integer; VRAM_Safe: Boolean): Integer;

//*** PALETTE ***//

Function GetR(V: Word): Byte;
Function GetG(V: Word): Byte;
Function GetB(V: Word): Byte;
Function Color2GBA(Color: DWord): Word;
Function GBA2Color(Color: Word): DWord;
Procedure GetGBApalette(Var Source, Dest; Count: Integer);
Procedure SetGBApalette(Var Source, Dest; Count: Integer);

implementation

{$I LZ77.PAS}

Function GetR(V: Word): Byte;
begin
 Result := (V and $1F) shl 3;
end;

Function GetG(V: Word): Byte;
begin
 Result := ((V and $3FF) shr 5) shl 3;
end;

Function GetB(V: Word): Byte;
begin
 Result := ((V and $7FFF) shr 10) shl 3;
end;

Function Color2GBA(Color: DWord): Word;
Type
 TBGRZ = Packed Record R, G, B, Z: Byte end;
begin
 With TBGRZ(Color) do Result := (B shr 3) shl 10 + (G shr 3) shl 5 + R shr 3;
end;

Function GBA2Color(Color: Word): DWord;
begin
 Result := GetB(Color) shl 16 + GetG(Color) shl 8 + GetR(Color);
end;

Function HuffDecompress(Var Source, Dest): Integer;
Var
 Src, Dst, Header, TreeSize, TreeStart, Mask, Data, RootNode: DWord;
 CurrentNode, WriteValue, HalfLen, Value, Pos, ByteShift: DWord;
 ByteCount: Integer; WriteData: Boolean; Len: Integer;
begin
 LastHufSize := 0;
 Src := DWord(Addr(Source));
 Dst := DWord(Addr(Dest));
 Header := PDWord(Src)^;
 Inc(Src, 4);
 Inc(LastHufSize, 4);
 TreeSize := PByte(Src)^;
 TreeStart := Src + 1;
 Inc(Src, (TreeSize + 1) shl 1);
 Inc(LastHufSize, (TreeSize + 1) shl 1);
 Len := Header shr 8;
 Result := Len;
 Mask := $80000000;
 Data := PDWord(Src)^;
 Inc(Src, 4);
 Inc(LastHufSize, 4);
 Pos := 0;
 RootNode := PByte(TreeStart)^;
 CurrentNode := RootNode;
 WriteData := False;
 ByteShift := 0;
 ByteCount := 0;
 WriteValue := 0;
 if Header and $0F = 8 then
 begin
  While Len > 0 do
  begin
   If Pos = 0 then Inc(Pos) Else Inc(Pos, (((CurrentNode and $3F) + 1) shl 1));
   If Data and Mask <> 0 then
   begin
    If CurrentNode and $40 <> 0 then WriteData := True;
    CurrentNode := PByte(TreeStart + Pos + 1)^;
   end Else
   begin
    If CurrentNode and $80 <> 0 then WriteData := True;
    CurrentNode := PByte(TreeStart + Pos)^;
   end;
   If WriteData then
   begin
    WriteValue := WriteValue or (CurrentNode shl ByteShift);
    Inc(ByteCount);
    Inc(ByteShift, 8);
    Pos := 0;
    CurrentNode := RootNode;
    WriteData := False;
    If ByteCount = 4 then
    begin
     ByteCount := 0;
     ByteShift := 0;
     PDWord(Dst)^ := WriteValue;
     WriteValue := 0;
     Inc(Dst, 4);
     Dec(Len, 4);
    end;
   end;
   Mask := Mask shr 1;
   If Mask = 0 then
   begin
    Mask := $80000000;
    Data := PDWord(Src)^;
    Inc(Src, 4);
    Inc(LastHufSize, 4);
   end;
  end;
 end Else
 begin
  HalfLen := 0;
  Value := 0;
  While Len > 0 do
  begin
   If Pos = 0 then Inc(Pos) Else Inc(Pos, (((CurrentNode and $3F) + 1) shl 1));
   If Data and Mask <> 0 then
   begin
    If CurrentNode and $40 <> 0 then WriteData := True;
    CurrentNode := PByte(TreeStart + Pos + 1)^;
   end Else
   begin
    If CurrentNode and $80 <> 0 then WriteData := True;
    CurrentNode := PByte(TreeStart + Pos)^;
   end;
   If WriteData then
   begin
    If HalfLen = 0 then
     Value := Value or CurrentNode Else
     Value := Value or (CurrentNode shl 4);
    Inc(HalfLen, 4);
    If HalfLen = 8 then
    begin
     WriteValue := WriteValue or (Value shl ByteShift);
     Inc(ByteCount);
     Inc(ByteShift, 8);
     HalfLen := 0;
     Value := 0;
     If ByteCount = 4 then
     begin
      ByteCount := 0;
      ByteShift := 0;
      PDWord(Dst)^ := WriteValue;
      WriteValue := 0;
      Inc(Dst, 4);
      Dec(Len, 4);
     end;
    end;
    Pos := 0;
    CurrentNode := RootNode;
    WriteData := False;
   end;
   Mask := Mask shr 1;
   If Mask = 0 then
   begin
    Mask := $80000000;
    Data := PDWord(Src)^;
    Inc(Src, 4);
    Inc(LastHufSize, 4);
   end;
  end;
 end;
end;

Constructor TFreqs.Create;
begin
 Root := NIL;
 Count := 0;
end;

Function TFreqs.Add: PFreq;
begin
 New(Result);
 FillChar(Result^, SizeOf(TFreq), 0);
 Result^.Code := -1;
 Result^.Next := Root;
 Root := Result;
 Inc(Count);
end;

Destructor TFreqs.Destroy;
Procedure FreeNodes(Node: PFreq);
begin
 If Node <> NIL then
 begin
  FreeNodes(Node^.Left);
  FreeNodes(Node^.Right);
  Dispose(Node^.Left);
  Dispose(Node^.Right);
 end;
end;
Var N: PFreq;
begin
 While Root <> NIL do
 begin
  With Root^ do
  begin
   N := Next;
   FreeNodes(Left);
   Dispose(Left);
   FreeNodes(Right);
   Dispose(Right);
  end;
  Dispose(Root);
  Root := N;
 end;
 Count := 0;
 Inherited Destroy;
end;

Function TFreqs.MakeParent: Boolean;
Function FindMin: PFreq;
Var I: Integer; P, N: PFreq;
begin
 I := $7FFFFFFF;
 N := Root;
 P := NIL;
 While N <> NIL do With N^ do
 begin
  If I > Count then
  begin
   I := Count;
   P := N;
  end;
  N := Next;
 end;
 N := Root;
 If N = P then
 begin
  Root := N^.Next;
  P^.Next := NIL;
  Dec(Count);
  Result := P;
  Exit;
 end;
 While N <> NIL do
 begin
  If P = N^.Next then
  begin
   N^.Next := P^.Next;
   P^.Next := NIL;
   Dec(Count);
   Result := P;
   Exit;
  end;
  N := N^.Next;
 end;
 Result := NIL;
end;
Var A, B, N: PFreq;
begin
 Result := False;
 A := FindMin;
 B := FindMin;
 If B = NIL then
 begin
  Root := A;
  Exit;
 end;
 If Root <> NIL then With Add^ do
 begin
  Left := B;
  Right := A;
  Code := -1;
  Count := A^.Count + B^.Count;
  Result := True;
 end Else
 begin
  New(N);
  FillChar(N^, SizeOf(TFreq), 0);
  With N^ do
  begin
   Left := B;
   Right := A;
   Code := -1;
   Count := A^.Count + B^.Count;
  end;
  Root := N;
  Inc(Count);
  Result := False;
 end;
end;

Var Stopper: Boolean;

Function CreateTree(Var Dest; Root: PFreq): DWord;
Function NodePos(L, R: PFreq; Pos: DWord): DWord;
begin
 If L <> NIL then
 begin
  L^.Pos := Pos;
  R^.Pos := Pos + 1;
  Result := NodePos(R^.Left, R^.Right, NodePos(L^.Left, L^.Right, Pos + 2));
 end Else Result := Pos;
end;
Var B: PBytes;
Procedure PutNode(N: PFreq);
Var I: Integer;
begin
 If Stopper then Exit;
 If N <> NIL then With N^ do
 begin
  If Code = -1 then
  begin
   I := (Left^.Pos - (Pos - Integer(not Odd(Pos)))) shr 1 - 1;
   If I > $3F then
   begin
    Stopper := True;
    Exit;
   end;
   B^[Pos] := I + Byte(Left^.Left = NIL) shl 7 +
                     Byte(Right^.Left = NIL) shl 6;
  end Else
   B^[Pos] := Code;
  PutNode(Left);
  PutNode(Right);
 end;
end;
begin
 Result := 0;
 If Root = NIL then Exit;
 With Root^ do
 begin
  Pos := 0;
  Result := NodePos(Left, Right, 1);
 end;
 B := Addr(Dest);
 Stopper := False;
 PutNode(Root);
 If Stopper then Result := 0;
end;

Function HuffCompress(Var Source, Dest; SrcLen: Integer; Bit8: Boolean): Integer;
Var Codes: Array[Byte] of Packed Record Code: DWord; Size: DWord end;
Procedure AnalizeCodes(Node: PFreq; A, B: Integer);
Var I: Integer;
begin
 I := Node^.Code;
 If I <> -1 then
 begin
  Codes[I].Size := A;
  Codes[I].Code := B;
 end;
 With Node^ do
 begin
  HCode := B;
  If Left = NIL then Exit;
  Left^.LRbit := 1;
  Right^.LRbit := 0;
  AnalizeCodes(Left, A + 1, B + B);
  AnalizeCodes(Right, A + 1, (B + B) or 1);
 end;
end;
Var
 S: PBytes; Dst: DWord; I: Integer; Bit: DWord;
 Frs: TFreqs; Freqs: Array[Byte] of DWord; DataSize, Old: DWord;
 Header: DWord Absolute Dest; TSZ: PByte; NCount: Integer;
 MasX: DWord;
Procedure AddCode(Code: Byte);
Var Mask: DWord;
begin
 With Codes[Code] do
 begin
  Mask := 1 shl (Size - 1);
  While Mask > 0 do
  begin
   If Code and Mask = 0 then
    PDWord(DST)^ := PDWord(DST)^ and not MasX Else
    PDWord(DST)^ := PDWord(DST)^ or MasX;
   Mask := Mask shr 1;
   MasX := MasX shr 1;
   If MasX = 0 then
   begin
    Inc(Dst, 4);
    MasX := $80000000;
   end;
  end;
  Inc(Bit, Size);
  If Bit div 32 > Old then
  begin
   Inc(DataSize, 4);
   Old := Bit div 32;
  end;
 end;
end;
begin
 FillChar(Freqs, SizeOf(Freqs), 0);
 S := Addr(Source);
 Dst := DWord(Addr(Dest));
 Frs := TFreqs.Create;
 If not Bit8 then
 begin
  For I := 0 to SrcLen - 1 do
  begin
   Inc(Freqs[S^[I] and $0F]);
   Inc(Freqs[S^[I] shr 4]);
  end;
 end Else For I := 0 to SrcLen - 1 do Inc(Freqs[S^[I]]);
 With Frs do
 begin
  For I := 0 to 255 do If Freqs[I] <> 0 then With Add^ do
  begin
   Code := I;
   Count := Freqs[I];
  end;
  While MakeParent do;
  FillChar(Codes, SizeOf(Codes), 0);
  AnalizeCodes(Root, 0, 0);
  Header := SrcLen shl 8 + $24;
  If Bit8 then Inc(Header, 4);
  Inc(Dst, 4);
  Tsz := PByte(Dst);
  NCount := CreateTree(Pointer(Dst + 1)^, Root) + 1;
  While NCount mod 4 > 0 do Inc(NCount);
  Inc(Dst, NCount);
  NCount := NCount shr 1 - 1;
  If not Stopper and (NCount <= 255) then
  begin
   Tsz^ := NCount;
   Result := (NCount + 1) shl 1 + 4;
   Bit := 0; DataSize := 4; Old := 0;
   MasX := $80000000;
   If Bit8 then For I := 0 to SrcLen - 1 do AddCode(S^[I]) Else
   For I := 0 to SrcLen - 1 do
   begin
    AddCode(S^[I] and $0F);
    AddCode(S^[I] shr 4);
   end;
   Inc(Result, DataSize);
  end Else Result := 0;
 end;
 Frs.Free;
end;

Procedure GetGBApalette(Var Source, Dest; Count: Integer);
Var SP: PWord; DP: PCardinal;
begin
 SP := Addr(Source);
 DP := Addr(Dest);
 While Count > 0 do
 begin
  DP^ := GBA2Color(SP^);
  Inc(DP); Inc(SP);
  Dec(Count);
 end;
end;

Procedure SetGBApalette(Var Source, Dest; Count: Integer);
Var SP: PCardinal; DP: PWord; 
begin
 SP := Addr(Source);
 DP := Addr(Dest);
 While Count > 0 do
 begin
  DP^ := Color2GBA(SP^);
  Inc(DP); Inc(SP);
  Dec(Count);
 end;
end;

end.
