Type
 ui32 = Cardinal;
 ui16 = Word;
 pui8 = ^ui8;
 ui8 = Byte;
 si32 = Integer;
 si16 = SmallInt;
 si8 = ShortInt;

Const
 RING_SIZE = 4096;
 MATCH_LIMIT = 18;
 THRESHOLD = 2;
 NIL_ = RING_SIZE;

Var
 match_position: Integer;
 match_length: Integer;
 lson: Array[0..RING_SIZE] of si16;
 rson: Array[0..RING_SIZE + 256] of si16;
 dad: Array[0..RING_SIZE] of si16;
 vsafe: Integer;
 text_buf: Array[0..RING_SIZE + MATCH_LIMIT - 2] of Byte;

Procedure InitTree;
Var I: Integer; W: ^si16;
begin
 I := RING_SIZE + 1;
 W := Addr(rson[I]);
 While I <= RING_SIZE + 256 do
 begin
  W^ := NIL_;
  Inc(W);
  Inc(I);
 end;
 I := 0;
 W := Addr(dad[0]);
 While I < RING_SIZE do
 begin
  W^ := NIL_;
  Inc(W);
  Inc(I);
 end;
end;

Procedure InsertNode(R: Integer);
Type
 ByteArray = Array[Byte] of Byte;
Var I, P, CMP: Integer; Key: ^ByteArray;
begin
 CMP := 1;
 Key := Addr(text_buf[R]);
 P := RING_SIZE + 1 + Key^[0];
 rson[R] := NIL_;
 lson[R] := NIL_;
 match_length := 0;
 While True do
 begin
  If CMP >= 0 then
  begin
   If rson[P] <> NIL_ then P := rson[P] Else
   begin
    rson[P] := R;
    dad[R] := P;
    Exit;
   end;
  end Else
  begin
   If lson[P] <> NIL_ then P := lson[P] Else
   begin
    lson[P] := R;
    dad[R] := P;
    Exit;
   end;
  end;
  For I := 1 to MATCH_LIMIT - 1 do
  begin
   CMP := Key^[I] - text_buf[P + I];
   If CMP <> 0 then Break;
  end;
  If (I > match_length) and not ((vsafe <> 0) and
     ((R - P) and (RING_SIZE - 1) <= 1)) then
  begin
   match_position := P;
   match_length := I;
   If match_length >= MATCH_LIMIT then Break;
  end;
 end;
 dad[r] := dad[p];
 lson[r] := lson[p];
 rson[r] := rson[p];
 dad[lson[p]] := r;
 dad[rson[p]] := r;
 If rson[dad[P]] = P then
  rson[dad[P]] := R Else
  lson[dad[P]] := R;
 dad[P] := NIL_;
end;

Procedure DeleteNode(P: Integer);
Var Q: Integer;
begin
 If dad[P] = NIL_ then Exit;
 If rson[P] = NIL_ then Q := lson[P] Else
 If lson[P] = NIL_ then Q := rson[P] Else
 begin
  Q := lson[P];
  If rson[Q] <> NIL_ then
  begin
   Repeat Q := rson[Q] Until rson[Q] = NIL_;
   rson[dad[Q]] := lson[Q];
   dad[lson[Q]] := dad[Q];
   lson[Q] := lson[P];
   dad[lson[P]] := Q;
  end;
  rson[Q] := rson[P];
  dad[rson[P]] := Q;
 end;
 dad[Q] := dad[P];
 if rson[dad[P]] = P then
  rson[dad[P]] := Q Else
  lson[dad[P]] := Q;
 dad[P] := NIL_;
end;

Procedure PutByte(Var Dest: pui8; Value: Byte);
begin
 Dest^ := Value;
 Inc(Dest);
end;

Procedure PutUi16(Var Dest: pui8; Value: ui16);
begin
 ui16(Addr(Dest^)^) := Value;
 Inc(Dest, 2);
end;

Procedure PutUi32(Var Dest: pui8; Value: ui32);
begin
 ui32(Addr(Dest^)^) := Value;
 Inc(Dest, 4);
end;

Function GetByte(Var Source: pui8): Byte;
begin
 Result := Source^;
 Inc(Source);
end;

Function GetUi16(Var Source: pui8): ui16;
begin
 Result := ui16(Addr(Source^)^);
 Inc(Source, 2);
end;

Function GetUi32(Var Source: pui8): ui32;
begin
 Result := ui32(Addr(Source^)^);
 Inc(Source, 4);
end;

Function Lz77Compress(Var Source, Dest; SrcLen: Integer; VRAM_Safe: Boolean): Integer;
Var
 i, c, len, r, s, last_match_length: Integer; destlen: ui32;
 flag_ptr: ^Byte; mask: ui8; destptr, srcptr: pui8; 
begin
 destlen := 0;
 srcptr := Addr(Source);
 destptr := Addr(Dest);
 if srclen < 0 then srclen := 0;
 If srclen > $FFFFFF then srclen := $FFFFFF;
 vsafe := Byte(VRAM_Safe);
 Result := 0;
 If destptr <> NIL then
  PutUi32(destptr, ((srclen and $FFFFFF) shl 8) or 16) Else Exit;
 Inc(destlen, 4);
 If srclen = 0 then
 begin
  Result := destlen;
  Exit;
 end;
 InitTree;
 s := 0;
 r := RING_SIZE - MATCH_LIMIT;
 mask := 0;
 flag_ptr := NIL;
 FillChar(text_buf[0], R, $E5);
 For len := 0 to MATCH_LIMIT - 1 do
 begin
  If srclen = 0 then Break;
  text_buf[r + len] := GetByte(srcptr);
  Dec(srclen);
 end;
 For I := 1 to MATCH_LIMIT do InsertNode(r - i);
 InsertNode(r);
 Repeat
  If match_length > len then match_length := len;
  If mask = 0 then
  begin
   flag_ptr := Addr(destptr^);
   PutByte(destptr, 0);
   Inc(destlen);
   mask := 128;
  end;
  If match_length <= THRESHOLD then
  begin
   match_length := 1;
   PutByte(destptr, text_buf[r]);
   Inc(destlen);
  end Else
  begin
   flag_ptr^ := flag_ptr^ or mask;
   PutByte(destptr, (((r - match_position - 1) shr 8) and 15) or
							((match_length - (THRESHOLD + 1)) shl 4));
   PutByte(destptr, ((r - match_position - 1) and 255));
   Inc(destlen, 2);
  end;
  mask := mask shr 1;
  last_match_length := match_length;
  For I := 0 to last_match_length - 1 do
  begin
   If srclen <= 0 then Break;
   DeleteNode(s);
   c := GetByte(srcptr);
   text_buf[s] := c;
   Dec(srclen);
   If s < MATCH_LIMIT - 1 then text_buf[s + RING_SIZE] := c;
   s := (s + 1) and (RING_SIZE - 1);
   r := (r + 1) and (RING_SIZE - 1);
   InsertNode(r);
  end;
  While I < last_match_length do
  begin
   DeleteNode(s);
   s := (s + 1) and (RING_SIZE - 1);
   r := (r + 1) and (RING_SIZE - 1);
   Dec(len);
   If len > 0 then InsertNode(r);
   Inc(I);
  end;
 Until len <= 0;
 While destlen and 3 > 0 do
 begin
  PutByte(destptr, 0);
  Inc(destlen);
 end;
 Result := destlen;
end;

Function Lz77_StreamCompress(const Source, Dest: TStream;
                             SrcLen: Integer; VRAM_Safe: Boolean): Integer;
Var
 i, c, len, r, s, last_match_length: Integer; destlen: ui32; temp: Int64;
 flagbyte: Byte; flag_ptr: Int64; mask: ui8; D: Cardinal;
begin
 destlen := 0;
 Result := 0;
 if srclen < 0 then Exit;
 If srclen > Source.Size then Exit;
 If srclen > $FFFFFF then Exit;
 vsafe := Byte(VRAM_Safe);
 D := (srclen shl 8) or 16;
 Dest.Write(D, 4);
 Inc(destlen, 4);
 If srclen = 0 then
 begin
  Result := destlen;
  Exit;
 end;
 InitTree;
 s := 0;
 r := RING_SIZE - MATCH_LIMIT;
 mask := 0;
 FillChar(text_buf[0], R, $E5);
 flag_ptr := -1;
 For len := 0 to MATCH_LIMIT - 1 do
 begin
  If srclen = 0 then Break;
  Source.Read(text_buf[r + len], 1);
  Dec(srclen);
 end;
 For I := 1 to MATCH_LIMIT do InsertNode(r - i);
 InsertNode(r);
 Repeat
  If match_length > len then match_length := len;
  If mask = 0 then
  begin
   temp := Dest.Position;
   If flag_ptr >= 0 then
   begin
    Dest.Position := flag_ptr;
    Dest.Write(flagbyte, 1);
    Dest.Position := temp;
   end;
   flag_ptr := temp;
   flagbyte := 0; Dest.Write(flagbyte, 1);
   Inc(destlen);
   mask := 128;
  end;
  If match_length <= THRESHOLD then
  begin
   match_length := 1;
   Dest.Write(text_buf[r], 1);
   Inc(destlen);
  end Else
  begin
   flagbyte := flagbyte or mask;
   D := (((r - match_position - 1) shr 8) and 15) or
							((match_length - (THRESHOLD + 1)) shl 4);
   Dest.Write(D, 1);
   D := ((r - match_position - 1) and 255);
   Dest.Write(D, 1);
   Inc(destlen, 2);
  end;
  mask := mask shr 1;
  last_match_length := match_length;
  For I := 0 to last_match_length - 1 do
  begin
   If srclen <= 0 then Break;
   DeleteNode(s);
   Source.Read(C, 1);
   text_buf[s] := c;
   Dec(srclen);
   If s < MATCH_LIMIT - 1 then text_buf[s + RING_SIZE] := c;
   s := (s + 1) and (RING_SIZE - 1);
   r := (r + 1) and (RING_SIZE - 1);
   InsertNode(r);
  end;
  While I < last_match_length do
  begin
   DeleteNode(s);
   s := (s + 1) and (RING_SIZE - 1);
   r := (r + 1) and (RING_SIZE - 1);
   Dec(len);
   If len > 0 then InsertNode(r);
   Inc(I);
  end;
 Until len <= 0;
 temp := Dest.Position;
 If flag_ptr >= 0 then
 begin
  Dest.Position := flag_ptr;
  Dest.Write(flagbyte, 1);
  Dest.Position := temp;
 end;
 D := 0;
 While destlen and 3 > 0 do
 begin
  Dest.Write(D, 1);
  Inc(destlen);
 end;
 Result := destlen;
end;

procedure Lz77_DecompressNH(Var Source, Dest; UncompSize: Integer);
Var
 Src, Dst: PByte; I, J, Lng, Offset: Integer; D: Byte; Data: Word;
 WindowOffset: Integer;
begin
 Src := Addr(Source);
 Dst := Addr(Dest);
 While UncompSize > 0 do
 begin
  D := Src^; Inc(Src);
  If D <> 0 then
  begin
   For I := 0 to 7 do
   begin
    If D and $80 <> 0 then
    begin
     Data := Src^ shl 8; Inc(Src);
     Data := Data or Src^; Inc(Src);
     Lng := (Data shr 12) + 3;
     Offset := Data and $FFF;
     WindowOffset := Integer(Dst) - Offset - 1;
     For J := 0 to Lng - 1 do
     begin
      Dst^ := PByte(WindowOffset)^;
      Inc(Dst);
      Inc(WindowOffset);
      Dec(UncompSize);
      If UncompSize = 0 then Exit;
     end;
    end else
    begin
     Dst^ := Src^;
     Inc(Dst);
     Inc(Src);
     Dec(UncompSize);
     If UncompSize = 0 then Exit;
    end;
    D := D shl 1;
   end;
  end Else
  begin
   For I := 0 to 7 do
   begin
    Dst^ := Src^;
    Inc(Dst);
    Inc(Src);
    Dec(UncompSize);
    If UncompSize = 0 then Exit;
   end;
  end;
 end;
end;

Function Lz77Decompress(Var Source, Dest): Integer;
Var Src: PByte;
begin
 Src := Addr(Source);
 Result := -1;
 If Src^ <> $10 then Exit;
 Result := Integer(Pointer(Src)^) shr 8;
 Inc(Src, 4);
 Lz77_DecompressNH(Src^, Dest, Result);
end;

function SwapWord(Value: Word): Word;
asm
 xchg al,ah
end;

Procedure Lz77_StreamDecompressNH(const Source, Dest: TStream; UncompSize: Integer);
Var
 I, J, Lng, Offset: Integer; D, X: Byte; Data: Word;
 WindowOffset, OldPos: Int64;
begin
 While UncompSize > 0 do
 begin
  Source.Read(D, 1);
  If D <> 0 then
  begin
   For I := 0 to 7 do
   begin
    If D and $80 <> 0 then
    begin
     Source.Read(Data, 2);
     Data := SwapWord(Data);
     Lng := (Data shr 12) + 3;
     Offset := Data and $FFF;
     WindowOffset := Dest.Position - Offset - 1;
     OldPos := Dest.Position;
     For J := 0 to Lng - 1 do
     begin
      Dest.Position := WindowOffset;
      Dest.Read(X, 1);
      Inc(WindowOffset);
      Dest.Position := OldPos;
      Dest.Write(X, 1);
      Inc(OldPos);
      Dec(UncompSize);
      If UncompSize = 0 then Exit;
     end;
    end else
    begin
     Source.Read(X, 1);
     Dest.Write(X, 1);
     Dec(UncompSize);
     If UncompSize = 0 then Exit;
    end;
    D := D shl 1;
   end;
  end Else
  begin
   For I := 0 to 7 do
   begin
    Source.Read(X, 1);
    Dest.Write(X, 1);
    Dec(UncompSize);
    If UncompSize = 0 then Exit;
   end;
  end;
 end;
end;

function Lz77_StreamDecompress(const Source, Dest: TStream): Integer;
Var H: Byte;
begin
 Result := 0;
 If (Source.Read(H, 1) = 1) and (H = $10) and
    (Source.Read(Result, 3) = 3) then
  Lz77_StreamDecompressNH(Source, Dest, Result) Else
  Result := -1;  
end;
