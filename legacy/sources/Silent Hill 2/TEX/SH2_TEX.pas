unit SH2_TEX;

interface

{$INCLUDE config.inc}

uses
  Windows, SysUtils, Graphics, DIB, ps2swizzle, PS2Textures,
  TIM2, targa{$IFDEF PNG}, Classes, TBXGraphics{$ENDIF};

Type

  ETexError = Class(Exception);

  TPaletteHeader = Packed Record
    phPalSize:   DWord;
    phNull1:      DWord;
    phNull2:      DWord;
    phPalCount:   Word;
    phWidth:      Byte;  // ?
    phHeight:     Byte;
    phNull3:      Array[0..31] of Byte;
  end;

  TPS2RGBQuad = Packed Record
    rgbRed, rgbGreen, rgbBlue, rgbAlpha: Byte;
  end;
  TPS2RGBQuads = Array[Byte] of TPS2RGBQuad;

  TTexPalette = Packed Record
    Header: TPaletteHeader;
    Colors: Array[0..255] of TPS2RGBQuads;
  end;

  TTGAHeader = TGA_Header;

  TMapHeader = Packed Record
    mhTag77:          DWord;
    mhReserved:       Dword;
    mpHZ0:            DWord;
    mpDataOffset:     DWord;
    mpImageOffset:    Array[0..2] of DWord;
    mpPaletteOffset:  Array[0..2] of DWord;
    mpTextureCount:   DWord;
  end;    

  TTexHeader = Packed Record
    thNull:           DWord;
    thHeaderSize:     DWord;
    thPaletteOffset:  DWord;
    thTagA7:          DWord;
    thNull2:          Array[0..$2F] of Byte;
  end;
  TTexLayerHeader = Packed Record
    lhTexID:          DWord;
    lhNull:           DWord;
    lhWidth:          Word;
    lhHeight:         Word;
    lhBitCount:       DWord;  // 8bpp = $5008, 32bpp = $5018
    lhImageSize:      DWord;
    lhDataSize:       DWord;
    lhBitCountInfo:   DWord;
    lhHz4:            Byte;
    lhHz5:            Byte;
    lhTag99:          Word;
    lhNull2:          Array[0..$60-1] of Byte;
  end;

  TTex = Class

    FHeader:      TTexHeader;
    FLayerHeader: TTexLayerHeader;
    FPalette:     TTexPalette;
    FPS2Palette:  TPS2RGBQuads;
    FPalCount:    Integer;
    //FSwzPalette:  TPS2RGBQuads;

    FDIB:       TDIB;
    FDIB32:     TDIB;
    FTGA:       TTGAHeader;
{$IFDEF PNG}
    FPNG:       TPNGBitmap;
{$ENDIF}
    FWidth:     Integer;
    FHeight:    Integer;
    FBitCount:  Integer;
    FData:      Pointer;
    FPS2Data:   Pointer;
    FDataSize:  Integer;
    FImageData: Pointer;
    procedure LoadTexPalette(Index: Integer = 0);
    procedure UnswizzleData;
    procedure LoadDIB;
    procedure LoadPalette;
    procedure SwizzlePal;
{$IFDEF PNG}
    procedure DIB2PNG;
{$ENDIF}
  public
    
  constructor Create;
  destructor Destroy;
    property  Bitmap: TDIB Read FDIB;
    Procedure LoadFromFile(FileName: String);
    Procedure LoadFromMemory(Memory: Pointer; Size: Integer);
    Procedure SaveToTGA(const FileName: String);
    Procedure SaveToTIM2(const FileName: String);
    procedure SaveToFile(const FileName: String);

    procedure LoadFromBitmap(const FileName: String);
    Procedure LoadFromTIM2(const FileName: String);
    Procedure LoadFromTGA(const FileName: String);
    procedure ImportFromFile(const FileName: String);
    function  ImportFromMap(const FileName: String; TextureIndex: Integer = 0): Integer;

    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property BitCount: Integer read FBitCount;
    property PalCount: Integer read FPalCount;

{$IFDEF PNG}
    property PNG:      TPNGBitmap read FPNG;
{$ENDIF}
  end;

const
  palMatrix: Array[0..15] of Byte = (//(0, 4, 1,
  	 0,  4,  1,  5,  2, 6, 3, 7,
     8,  12,  9,  13, 10, 14, 11, 15);
implementation

Procedure FlipHalfBytes(Data: Pointer; Size: Integer);
var B: ^Byte;
begin
  B := Data;
  While Size > 0 do
  begin
    B^ := (B^ SHL 4) or (B^ SHR 4);
    Inc(B);
    Dec(Size);
  end;
end;

Procedure RevColors(Data: Pointer; Size: Integer; CalcAlpha: Boolean = True; AlphaToPS2: Boolean = False);
var D: ^DWord;
begin
  D := Data;
  Size := Size div 4;
  While Size > 0 Do
  begin
    D^ := ((D^ SHL 16) and $FF0000) or ((D^ SHR 16) and $FF) or (D^ and $FF00FF00);
    If CalcAlpha Then
    begin
      If AlphaToPS2 Then
      begin                                                    
        If (D^ and $FF000000) = $FF000000 Then
          D^ := (D^ and $FFFFFF) or $80000000
        else
          D^ := (D^ and $FFFFFF) or ((D^ SHR 1) and $FF000000);
      end else
      begin
        If (D^ and $FF000000) = $80000000 Then
          D^ := D^ or $FF000000
        else
          D^ := (D^ and $FFFFFF) or ((D^ and $FF000000) SHL 1);
      end;
    end;
    Inc(D);
    Dec(Size);
  end;
end;

{ TTex }



constructor TTex.Create;
begin
  FDIB := TDIB.Create;
  FDIB32 := TDIB.Create;
  {$IFDEF PNG}
  FPNG := TPNGBitmap.Create;
  {$ENDIF}
end;

destructor TTex.Destroy;
begin
  If FData <> nil Then
    FreeMem(FData);
  If FPS2Data <> nil Then
    FreeMem(FPS2Data);
  FDIB.Free;
  FDIB32.Free;       
  {$IFDEF PNG}
  FPNG.Free;
  {$ENDIF}
end;

procedure TTex.LoadFromFile(FileName: String);
var F: File; Buf: Pointer; Size: Integer;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);

  LoadFromMemory(Buf, Size);
  FreeMem(Buf);
end;

procedure TTex.LoadFromMemory(Memory: Pointer; Size: Integer);
begin
  Move(Memory^, FHeader, SizeOf(FHeader));
  Move(Pointer(DWord(Memory) + FHeader.thHeaderSize)^, FLayerHeader, SizeOf(TTexLayerHeader));
  (*If FLayerHeader.lhBitCountInfo = 0{ $11300} Then
    FBitCount := 32
  else
    FBitCount := 8;
  *)

  Case FLayerHeader.lhBitCount and $FF of
    $04: FBitCount := 4;
    $08: FBitCount := 8;
    $18: FBitCount := 32;
  end;

  FWidth := FLayerHeader.lhWidth;
  FHeight := FLayerHeader.lhHeight;

  FDataSize := (FBitCount * FWidth * FHeight) div 8;
  If FData <> nil Then FreeMem(FData);
  If FPS2Data <> nil Then FreeMem(FPS2Data);
  GetMem(FData, FDataSize);
  GetMem(FPS2Data, FDataSize);
  Move(Pointer(DWord(Memory) + SizeOf(TTexHeader) + (FLayerHeader.lhDataSize - FLayerHeader.lhImageSize))^, FPS2Data^, FDataSize);

  UnswizzleData;
  If FBitCount = 32 Then
  begin
    RevColors(FData, FDataSize);
    FPalCount := 0;
  end;
  LoadDIB;
  If FBitCount in [4, 8] Then
  begin
    ZeroMemory(@FPalette, SizeOf(FPalette));
    Move(Pointer(DWord(Memory) + FHeader.thPaletteOffset)^, FPalette.Header, SizeOf(TPaletteHeader));
    Move(Pointer(DWord(Memory) + FHeader.thPaletteOffset + SizeOf(TPaletteHeader))^, FPalette.Colors, FPalette.Header.phPalSize);
    FPalCount := FPalette.Header.phPalCount;
    LoadTexPalette;
  end;
  //FDIB.SaveToFile('C:\Test.bmp');
  {$IFDEF PNG}
  DIB2PNG;
  {$ENDIF}
end;

procedure TTex.LoadTexPalette(Index: Integer = 0);
var n, m: Integer;
    RGB: ^TRGBQuads;
    Temp: TRGBQuads;
    F: File;
begin
  //Move(FPalette.Colors, gsmem, SizeOf(FPalette.Colors));
  //writeTexPSMCT32(0, $400, 0, 0, $40, $40, @FPalette.Colors, False);
  //Move(gsmem, FSwzPalette, SizeOf(TPS2RGBQuads));
  writeTexPSMCT32(0, 1, 0, 0, $40, $40, @FPalette.Colors);



  (*
  Assign(F, 'C:\gsmem.bin');
  Rewrite(F, 1);
  BlockWrite(F, gsmem, sizeof(gsmem));
  CloseFile(F);
  *)
  

  RGB := @gsmem[Index * $100];
  For n := 0 To (1 SHL FBitCount) - 1 do
  begin
    With RGB^[(palMatrix[n shr 4] shl 4) or columnWordZ32[n and $F]] do
    begin
      FPS2Palette[n] := TPS2RGBQuad(RGB^[(palMatrix[n shr 4] shl 4) or columnWordZ32[n and $F]]);
      FDIB.ColorTable[n].rgbBlue :=   rgbRed;
      FDIB.ColorTable[n].rgbRed :=    rgbBlue;
      FDIB.ColorTable[n].rgbGreen :=  rgbGreen;
      If rgbReserved = $80 Then
        FDIB.ColorTable[n].rgbReserved := $FF
      else
        FDIB.ColorTable[n].rgbReserved := rgbReserved SHL 2;
    end;
  end;

  (*
  Assign(F, 'C:\ps2pal.bin');
  Rewrite(F, 1);
  BlockWrite(F, FPS2Palette, sizeof(FPS2Palette));
  CloseFile(F);
  *)
  //FDIB.ColorTable := RGB^;

  FDIB.UpdatePalette;
end;

procedure TTex.SaveToTGA(const FileName: String);
var Buf: Pointer; n: Integer;
begin
  If FBitCount = 32 Then
    saveTGA(FileName, FWidth, FHeight, FData, True)
  else
  begin
    GetMem(Buf, FWidth * FHeight * 4);
    For n := 0 To FHeight -1 do
      Move(FDIB32.ScanLine[FHeight - n - 1]^, Pointer(DWord(Buf) + FWidth * n * 4)^, FWidth * 4);
    saveTGA(FileName, FWidth, FHeight, Buf{, True});
    FreeMem(Buf);
  end;
end;

{$IFDEF PNG}
Procedure TTex.DIB2PNG;
var PixelData: TPixelData32; DIBPic: TDIB;
begin
  If FBitCount in [4, 8] Then
  begin
    //FDIB.PixelFormat := MakeDIBPixelFormat(8, 8, 8);
    FDIB32.Assign(FDIB);
    FDIB32.BitCount := 32;
    DIBPic := FDIB32;
  end else
    DIBPic := FDIB;
    
  With FPNG do
  begin
   Transparent := True;
   If DIB <> nil Then DIB.Free;
   TDIB32(Addr(DIB)^) := TDIB32.Create;
   DIB.SetSize(DIBPic.Width, DIBPic.Height);
   PixelData.Bits := DIBPic.TopPBits;
   PixelData.ContentRect.Left := 0;
   PixelData.ContentRect.Top  := 0;
   PixelData.ContentRect.Right := Width;
   PixelData.ContentRect.Bottom := Height;
   PixelData.RowStride := -Width;
   DIB.CopyFrom(PixelData, 0, 0, PixelData.ContentRect);
  end;
end;
{$ENDIF}

procedure TTex.SaveToTIM2(const FileName: String);
begin
  SaveTIM2(FileName, FPS2Data, FWidth, FHeight, FBitCount, @FPS2Palette, 32, False, False);
end;

procedure TTex.LoadFromTIM2(const FileName: String);
var
  Buf, PalBuf: Pointer;
  Width, Height, BitCount, PalBitCount: Integer;
  procedure FreeMemory;
  begin
    If Buf <> nil Then FreeMem(Buf);
    If PalBuf <> nil Then FreeMem(PalBuf);
  end;
begin
  PalBuf := nil;
  Buf := nil;
  If not openTIM2(FileName, Buf, Width, Height, BitCount, PalBitCount, PalBuf) Then Exit;
  If (BitCount = 8) and (PalBitCount < 32) Then
  begin
    FreeMemory;
    raise ETexError.CreateFmt('Unsupported palette bit count - %d! Palette bit count must be 32.',
      [BitCount]);
  end;
  If not (BitCount in [8, 32]) Then
  begin
    FreeMemory;
    raise ETexError.CreateFmt('Unsupported bit count - %d! Bit count must be 8 or 32.',
      [BitCount]);
  end;
  FWidth := Width;
  FHeight := Height;
  FBitCount := BitCount;
  If FData <> nil Then FreeMem(FData);
  If FPS2Data <> nil Then FreeMem(FPS2Data);
  FDataSize := Width * Height * (BitCount div 8);
  GetMem(FPS2Data, FDataSize);
  GetMem(FData, FDataSize);
  Move(Buf^, FPS2Data^, FDataSize);
  Move(Buf^, FData^, FDataSize);

  //FDIB.BitCount := BitCount;
  If BitCount = 32 Then RevColors(FData, FDataSize, True);
  If BitCount = 8 Then
  begin
    Move(PalBuf^, FPS2Palette, 256 * 4);
    LoadPalette;
  end;
  LoadDIB;

  FreeMemory;
  {$IFDEF PNG}
  DIB2PNG;
  {$ENDIF}
end;

procedure TTex.UnswizzleData;
const
  a = 512;
  b = 32;

begin
 If BitCount = 4 Then
  begin

    //writeTexPSMCT32(0, 0, 1, 4, a, (FDataSize div a) div 4, FPS2Data, True, True);
    //writeTexPSMT4(0, 0, 4, 0, b, (FDataSize div b) * 2, FData, False, True);

    //Move(FPS2Data^, gsmem, FDataSize);
    //TexSwizzle4(0, 0, 1, 0, FWidth, FHeight, FPS2Data);
    Unswizzle4(FPS2Data^, FData^, a, (FDataSize div a) * 2);
    //Move(FData, gsmem, FDataSize);
    //writeTexPSMCT32(0, 0, 1, 0, b, (FDataSize div b) div 4, FData, False);

    //Unswizzle8(FData^, FPS2Data^, b, (FDataSize div b));
    //Move(FPS2Data^, FData^, FDataSize);

    //Move(FData^, FPS2Data^, FDataSize);
    FlipHalfBytes(FData, FDataSize);
  end else If FBitCount = 8 Then
  begin
    Unswizzle8(FPS2Data^, FData^, FWidth, FHeight);
    Move(FData^, FPS2Data^, FDataSize);
  end else
    Move(FPS2Data^, FData^, FDataSize);
end;

procedure TTex.LoadDIB;
var n, BytesPerLine: Integer;
begin
  //Move(Pointer(DWord(Memory) + SizeOf(FTexHeader))^, FData^, FDataSize);
  FDIB.Width  := FWidth;
  FDIB.Height := FHeight;
  FDIB.BitCount := FBitCount;

  //Move(FData^, FDIB.ScanLine[FHeight - 1]^, SizeOf(FDataSize));
  BytesPerLine := (FWidth * FBitCount) div 8;
  For n := 0 To FHeight - 1 do
    Move(Pointer(DWord(FData) + n * BytesPerLine)^, FDIB.ScanLine[n]^, BytesPerLine);

end;

procedure TTex.LoadPalette;
var n: Integer;
begin
  For n := 0 To 1 SHL FBitCount do With FDIB.ColorTable[n] do
  begin
    rgbBlue := FPS2Palette[n].rgbBlue;
    rgbGreen := FPS2Palette[n].rgbGreen;
    rgbRed := FPS2Palette[n].rgbRed;
    If FPS2Palette[n].rgbAlpha = $80 Then
      rgbReserved := $FF
    else
      rgbReserved := FPS2Palette[n].rgbAlpha SHL 1;
  end;
  FDIB.UpdatePalette;
end;

procedure TTex.SwizzlePal;
begin
end;

procedure TTex.ImportFromFile(const FileName: String);
var F: File; Sign: Array[0..3] of Char; PicType: Integer;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, Sign, 4);
  CloseFile(F);
  If CompareMem(PChar('BM'), @Sign, 2) Then
    PicType := 0 // BMP
  else If CompareMem(PChar('TIM2'), @Sign, 4) Then
    PicType := 2
  {$IFDEF PNG}
  else If CompareMem(PChar(#$89'PNG'), @Sign, 4) Then
    PicType := 3 // PNG
  {$ENDIF}
  else
    PicType := 1; // TGA

  Case PicType of
    0: LoadFromBitmap(FileName);
    1: LoadFromTGA(FileName);
    2: LoadFromTIM2(FileName);
    //3: LoadFromTGA(FileName);
  end;

end;

procedure TTex.LoadFromTGA(const FileName: String);
var Header: TTGAHeader; Y, L: Integer;
begin
  Header := loadTGA(FileName);
  FWidth := Header.Width;
  FHeight := Header.Height;
  FBitCount := 32;
  If FData <> nil Then FreeMem(FData);
  If FPS2Data <> nil Then FreeMem(FPS2Data);
  FDataSize := FWidth * FHeight * 4;
  GetMem(FData, FDataSize);
  GetMem(FPS2Data, FDataSize);
  L := FWidth * 4;
  For Y := FHeight - 1 downto 0 do
    Move(Pointer(DWord(Header.Data) + (FHeight - 1 - Y) * L)^, Pointer(DWord(FData) + L * Y)^, L);
  //Move(Header.Data^, FData^, FDataSize);
  Move(FData^, FPS2Data^, FDataSize);
  FreeMem(Header.Data);
  RevColors(FPS2Data, FDataSize, True, True);
  LoadDIB;
  {$IFDEF PNG}
  DIB2PNG;
  {$ENDIF}
end;

procedure TTex.SaveToFile(const FileName: String);
var F: File; Buf: Pointer; Pal: TPS2RGBQuads; n: Integer;
begin
  With FHeader, FLayerHeader do
  begin
    thHeaderSize := SizeOf(TTexHeader); 
    thTagA7 := $A7A7A7A7;    
    lhWidth := FWidth;
    lhHeight := FHeight;
    lhImageSize := FDataSize;
    lhDataSize  := FDataSize + $80;
    If FBitCount = 8 Then
    begin
      lhBitCount     := $5008;
      lhBitCountInfo := $11300;
      thPaletteOffset := FDataSize + $C0;
      If FPalette.Header.phPalSize = 0 Then
      begin
        FPalette.Header.phPalSize := $1000;
        FPalette.Header.phPalCount := 4;
        FPalette.Header.phWidth    := $40;
        FPalette.Header.phHeight   := $40;
      end;
    end else
    begin
      lhBitCount     := $5018;
      lhBitCountInfo := 0;
      thPaletteOffset := 0;
    end;
  end;
  AssignFile(F, FileName);
  Rewrite(F, 1);
  BlockWrite(F, FHeader, SizeOf(FHeader));
  BlockWrite(F, FLayerHeader, SizeOf(FLayerHeader));
  If FBitCount = 32 Then
  begin
    BlockWrite(F, FPS2Data^, FDataSize);
  end else
  begin
    GetMem(Buf, FDataSize);
    Swizzle8(FPS2Data^, Buf^, FWidth, FHeight);
    BlockWrite(F, Buf^, FDataSize);
    FreeMem(Buf);
    For n := 0 To 255 do
      Pal[(palMatrix[n shr 4] shl 4) or columnWordZ32[n and $F]] := FPS2Palette[n];
    Move(Pal, gsmem, SizeOf(Pal));
    writeTexPSMCT32(0, $1, 0, 0, $40, $40, @FPalette.Colors, False);
    BlockWrite(F, FPalette, SizeOf(FPalette.Header) + FPalette.Header.phPalSize);
  end;
  CloseFile(F);
end;

procedure TTex.LoadFromBitmap(const FileName: String);
var DIB: TDIB; n: Integer;
begin
  DIB := TDIB.Create;
  DIB.LoadFromFile(FileName);
  If not (DIB.BitCount in [8, 32]) Then
  begin
    DIB.Free;
    raise ETexError.Create('Bit count must be 8 or 32!');
  end;
  FDIB.Free;
  FDIB := DIB;
  FWidth := FDIB.Width;
  FHeight := FDIB.Height;
  FBitCount := FDIB.BitCount;
  If FData <> nil Then FreeMem(FData);
  If FPS2Data <> nil Then FreeMem(FPS2Data);
  FDataSize := FWidth * FHeight * (FBitCount div 8);
  GetMem(FData, FDataSize);
  GetMem(FPS2Data, FDataSize);
  For n := 0 To FDIB.Height - 1 do
    Move(FDIB.ScanLine[n]^, Pointer(DWord(FData) + n * FWidth * (FBitCount div 8))^, FWidth * (FBitCount div 8));
  //Move(Header.Data^, FData^, FDataSize);
  Move(FData^, FPS2Data^, FDataSize);
  If FBitCount = 32 Then
    RevColors(FPS2Data, FDataSize, True, True)
  else
  begin
    For n := 0 to High(FPS2Palette) do With FDIB.ColorTable[n] do
    begin
      FPS2Palette[n].rgbRed   := rgbRed;
      FPS2Palette[n].rgbGreen := rgbGreen;
      FPS2Palette[n].rgbBlue  := rgbBlue;
      FPS2Palette[n].rgbAlpha := $80;
      rgbReserved := $FF;
    end;
  end;
  {$IFDEF PNG}
  DIB2PNG;
  {$ENDIF}

end;

function TTex.ImportFromMap(const FileName: String; TextureIndex: Integer): Integer;
var
  F: File; MapHeader: TMapHeader; LayerHeader: TTexLayerHeader; Buf: Pointer;
  TexHeader: ^TTexHeader; PalHeader: TPaletteHeader;
begin
  Result := 0;
  Assign(F, FileName);
  Reset(F, 1);
  BlockRead(F, MapHeader, SizeOf(MapHeader));
  If MapHeader.mhTag77 <> $77777777 Then
  begin
    CloseFile(F);
    //raise ETexError.Create('This map file contain no textures.'); 
    Exit;
  end;
  If (TextureIndex < 0) or (TextureIndex > MapHeader.mpTextureCount - 1) Then
  begin
    CloseFile(F);
    raise ETexError.CreateFmt('Texture index error! (%d)', [TextureIndex]); 
  end;

  Seek(F, MapHeader.mpImageOffset[TextureIndex]);
  BlockRead(F, LayerHeader, SizeOf(LayerHeader));
  GetMem(Buf, LayerHeader.lhDataSize + SizeOf(TTexHeader) + SizeOf(TPS2RGBQuads) * 16 * 16);
  TexHeader := Buf;
  ZeroMemory(Buf, SizeOf(TTexHeader));
  TexHeader^.thHeaderSize := SizeOf(TTexHeader);
  TexHeader^.thTagA7 := $A7A7A7A7;
  TexHeader^.thPaletteOffset := SizeOf(TTexHeader) + LayerHeader.lhDataSize;
  Move(LayerHeader, Pointer(DWord(Buf) + SizeOf(TTexHeader))^, SizeOf(LayerHeader));

  BlockRead(F, Pointer(DWord(Buf) + SizeOf(TTexHeader) + SizeOf(TTexLayerHeader))^, LayerHeader.lhImageSize);
  Seek(F, MapHeader.mpPaletteOffset[TextureIndex]);
  BlockRead(F, PalHeader, SizeOf(TPaletteHeader));
  Move(PalHeader, Pointer(DWord(Buf) + SizeOf(TTexHeader) + LayerHeader.lhDataSize)^, SizeOf(PalHeader));
  BlockRead(F, Pointer(DWord(Buf) + SizeOf(TTexHeader) + LayerHeader.lhDataSize + SizeOf(TPaletteHeader))^, PalHeader.phPalSize);
  CloseFile(F);
  LoadFromMemory(Buf, SizeOf(TTexHeader) + LayerHeader.lhDataSize + PalHeader.phPalSize + SizeOf(PalHeader));
  FreeMem(Buf);

  Result := MapHeader.mpTextureCount;
end;

end.