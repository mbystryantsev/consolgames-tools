unit TIM2;

interface

Type
 TTIM2Header = Packed Record
  thSignTag: Array[0..3] of Char;    // 'TIM2' ($324D4954)
  thFormatTag:              Byte;    // 3 or 4
  thAlign128:               Boolean; // 0 - 16, 1 - 256
  thLayersCount:            Word;
  thReserved1:              Integer; // null
  thReserved2:              Integer; // null
 end;
 TTIM2LayerHeader = Packed Record
  lhLayerSize:              Integer; // HeaderSize + ImageSize + PaletteSize
  lhPaletteSize:            Integer;
  lhImageSize:              Integer;
  lhHeaderSize:             Word;
  lhColorsUsed:             Word;
  lh256:                    Word;    // = 256 always
  lhControlByte:            Byte;    // $0x - swizzled palette, $8x - normal, 1 - 16, 2 - 24, 3 - 32
  lhFormat:                 Byte;    // 1 - 16bpp, 2 - 24bpp, 3 - 32bpp, 4 - 4bpp, 5 - 8bpp
  lhWidth:                  Word;
  lhHeight:                 Word;
  lhTEX0:    Array[0..7] of Byte;
  lhTEX1:    Array[0..7] of Byte;
  lhTEXA:    Array[0..3] of Byte;
  lhTEXCLUT: Array[0..3] of Byte;
 end;

Function saveTIM2(const FileName: String; Pixels: Pointer; Width, Height, BitCount: Integer; Palette: Pointer = nil;
PalBitCount: Integer = 32; Align128: Boolean = False; PalSwizzled: Boolean = False): Boolean;
Function openTIM2(const FileName: String; var Pixels: Pointer; var Width, Height, BitCount, PalBitCount: Integer; var Palette: Pointer): Boolean;

Function TIM2SwizzlePal(Src, Dest: Pointer; PalBitCount: Integer): Boolean;
implementation

uses
  Dialogs;

Type
  TLayerHeader = TTIM2LayerHeader;
  TByteArray = Array[Word] of Byte;
  PByteArray = ^TByteArray;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function TIM2SwizzlePal(Src, Dest: Pointer; PalBitCount: Integer): Boolean;
var n, Size: Integer; S, D: PByteArray;
  procedure Mov(Num, A1, A2: Integer);
  begin
    Move(S[(Num * 4 + A1) * 8 * Size], D[(Num * 4 + A2) * 8 * Size], Size * 8);
  end;
begin
  Result := False;
  If not (PalBitCount in [16, 24, 32]) Then
    Exit;
  S := Src;
  D := Dest;
  Size := PalBitCount div 8;
  For n := 0 To 7 do
  begin
    Mov(n, 0, 0);
    Mov(n, 2, 1);
    Mov(n, 1, 2);
    Mov(n, 3, 3);
  end;
  Result := True;
end;

Function saveTIM2(const FileName: String; Pixels: Pointer; Width, Height, BitCount: Integer; Palette: Pointer = nil;
PalBitCount: Integer = 32; Align128: Boolean = False; PalSwizzled: Boolean = False): Boolean;
var
  Header: TTIM2Header;
  LayerHeader: TLayerHeader;
  Align, PalSize, PixelsSize: Integer;
  F: File;
const
  null: Integer = 0;
begin
  Result := False;
  If not (BitCount in [4, 8, 16, 24, 32]) or ((BitCount < 16) and (Palette = nil)) Then
    Exit;
  If (BitCount < 16) and not (PalBitCount in [16, 24, 32]) Then
    Exit;
  If (Width <= 0) or (Height <= 0) Then
    Exit;

  If Align128 Then
    Align := 128
  else
    Align := 16;
  FillChar(Header, SizeOf(Header), 0);
  FillChar(LayerHeader, SizeOf(LayerHeader), 0);
  PalSize   := (PalBitCount div 8) * (1 SHL BitCount);
  PixelsSize := Width * Height * (BitCount div 8);
  With Header do
  begin
    thSignTag     := 'TIM2';
    thFormatTag   := 3;
    thAlign128    := Align128;
    thLayersCount := 1;
  end;
  With LayerHeader do
  begin
    lhPaletteSize := RoundBy(PalSize, Align);
    lhImageSize   := RoundBy(PixelsSize, Align);
    lhHeaderSize  := RoundBy(SizeOf(LayerHeader), Align);
    lhLayerSize   := lhPaletteSize + lhImageSize + lhHeaderSize;
    lhColorsUsed  := 1 SHL BitCount;
    lh256         := 256;
    If BitCount < 16 Then
    begin
      Case PalBitCount of
        16: lhControlByte := 1;
        24: lhControlByte := 2;
        32: lhControlByte := 3;
      end;
      If not PalSwizzled Then
        lhControlByte := lhControlByte or $80;
    end;
    Case BitCount of
      4:  lhFormat := 4;
      8:  lhFormat := 5;
      16: lhFormat := 1;
      24: lhFormat := 2;
      32: lhFormat := 3;
    end;
    lhWidth  := Width;
    lhHeight := Height;
  end;

  AssignFile(F, FileName);
  Rewrite(F, 1);
  BlockWrite(F, Header, SizeOf(Header));
  Seek(F, RoundBy(FilePos(F), Align));
  BlockWrite(F, LayerHeader, SizeOf(LayerHeader));
  Seek(F, RoundBy(FilePos(F), Align));
  BlockWrite(F, Pixels^, PixelsSize);
  Seek(F, RoundBy(FilePos(F), Align));
  If BitCount < 16 Then
    BlockWrite(F, Palette^, PalSize);

  If FileSize(F) <> RoundBy(FileSize(F), Align) Then
  begin
    Seek(F, RoundBy(FileSize(F), Align) - 1);
    BlockWrite(F, null, 1);
  end;
  CloseFile(F);
  
  Result := True;
end;

Function openTIM2(const FileName: String; var Pixels: Pointer; var Width, Height, BitCount, PalBitCount: Integer; var Palette: Pointer): Boolean;
var
  Header: TTIM2Header;
  LayerHeader: TLayerHeader;
  Align, PalSize, PixelsSize: Integer;
  Pal: Array[Byte] of Integer;
  F: File;
begin
  Result := False;
  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, Header, SizeOf(Header));
  If Header.thSignTag <> 'TIM2' Then
  begin
    CloseFile(F);
    Exit;
  end;
  If Header.thAlign128 Then
    Align := 128
  else
    Align := 16;
  If Align = 128 Then
    Seek(F, 128);

  BlockRead(F, LayerHeader, SizeOf(LayerHeader));
  If Align = 128 Then
    Seek(F, 256);
  GetMem(Pixels, LayerHeader.lhImageSize);
  BlockRead(F, Pixels^, LayerHeader.lhImageSize);
  Seek(F, RoundBy(FilePos(F), Align));

  Case LayerHeader.lhControlByte and $F of
    1: PalBitCount := 16;
    2: PalBitCount := 24;
    3: PalBitCount := 32;
  end;
  Case LayerHeader.lhFormat of
    4: BitCount := 4;
    5: BitCount := 8;
    1: BitCount := 16;
    2: BitCount := 24;
    3: BitCount := 32;
  end;
  Width := LayerHeader.lhWidth;
  Height := LayerHeader.lhHeight;

  If (LayerHeader.lhFormat in [4, 5]) Then
  begin
    Case LayerHeader.lhFormat of
      4: PalSize := (PalBitCount div 8) * 16;
      5: PalSize := (PalBitCount div 8) * 256;
    end;
    GetMem(Palette, PalSize);
    BlockRead(F, Palette^, PalSize);
    If (LayerHeader.lhFormat = 5) and (LayerHeader.lhControlByte and $F0 = $80) Then
    begin
      TIM2SwizzlePal(Palette, @Pal, PalBitCount);
      Move(Pal, Palette^, PalSize);
    end;                    
  end;
  CloseFile(F);
  Result := True;
end;

end.
