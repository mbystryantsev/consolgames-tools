unit mi_MapImage;

interface

uses Windows, SysUtils, Classes, DIB, TilesUnit;

type
 TTileType = (tt2bitNES, tt4bit, tt4bitMSX, tt8bit);
 TMapFormat = (mfSingleByte, mfGBA, mfMSX);
 TMResType = (rtMap, rtMapNoHeader, rtTiles, rtPalette, rtBitmap);
 TRGB = packed record
  R: Byte;
  G: Byte;
  B: Byte;
 end;
 TRGBPal = array[Byte] of TRGB;

 TMapImage = class
  private
    FWidth, FLastWidth: Integer;
    FHeight, FLastHeight: Integer;
    FTileList: TTileList;
    FFixedTiles: TTileList;
    FMapFormat: TMapFormat;
    FPalette: TRGBQuads;
    FByteMap: array of Byte;
    FWordMap: array of Word;
    FPaletteIndex: Byte;
    FTileType: TTileType;
    FSelectPalette: Boolean;
    procedure SetMapFormat(Value: TMapFormat);
    function GetImageWidth: Integer;
    function GetImageHeight: Integer;
    function GetImageSize: Integer;
    function GetOptimization: Boolean;
    procedure SetWidth(Value: Integer);
    procedure SetHeight(Value: Integer);
    procedure SetImageWidth(Value: Integer);
    procedure SetImageHeight(Value: Integer);
    procedure SetSize(W, H: Integer);
    procedure SetTileType(Value: TTileType);
    procedure SetOptimization(Value: Boolean);

    function GetPaletteIndex(var Source; RowStride: Integer): Integer;
  public
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property ImageWidth: Integer read GetImageWidth write SetImageWidth;
    property ImageHeight: Integer read GetImageHeight write SetImageHeight;
    property ImageSize: Integer read GetImageSize;
    property TileType: TTileType read FTileType write SetTileType;
    property MapFormat: TMapFormat read FMapFormat write SetMapFormat;
    property Palette: TRGBQuads read FPalette write FPalette;
    property Optimization: Boolean read GetOptimization write SetOptimization;
    property TileList: TTileList read FTileList;
    property FixedTiles: TTileList read FFixedTiles;
    property PaletteIndex: Byte read FPaletteIndex write FPaletteIndex;

    constructor Create;
    destructor Destroy; override;
    procedure BufDraw(var Dest; RowStride: Integer);
    procedure BufLoad(var Source; RowStride: Integer);
    
    procedure LoadMapFromStream(const Stream: TStream; NoHeader: Boolean);
    procedure LoadTilesFromStream(const Stream: TStream);
    procedure LoadPaletteFromStream(const Stream: TStream);
    procedure LoadFromFile(const FileName: String; MResType: TMResType);
    procedure SaveMapToStream(const Stream: TStream; NoHeader: Boolean);
    procedure SaveTilesToStream(const Stream: TStream);
    procedure SavePaletteToStream(const Stream: TStream);
    procedure SaveToFile(const FileName: String; MResType: TMResType);

    procedure LoadFromBitmapStream(const Stream: TStream);
    procedure SaveToBitmapStream(const Stream: TStream);

    property  SelectPalette: Boolean read FSelectPalette write FSelectPalette;
 end;

const
 CLR_CNT: array[TTileType] of Integer = (4, 16, 16, 256); 

implementation

function SwapWord(Value: Word): Word;
asm
 xchg al,ah
end;

procedure TMapImage.BufDraw(var Dest; RowStride: Integer);
var
 Y, X, BigStride, TW: Integer;
 MB: PByte; Dst, P: PByte;
 MW: PWord absolute MB; W: Word;
begin
 if (FWidth = 0) or (FHeight = 0) then Exit;
 Dst := @Dest;
 TW := FTileList.TileWidth;
 BigStride := RowStride * FTileList.TileHeight;
 case FMapFormat of
  mfSingleByte:
  begin
   MB := Pointer(FByteMap);
   for Y := 0 to FHeight - 1 do
   begin
    P := Dst;
    for X := 0 to FWidth - 1 do
    begin
     with FTileList.FastTiles[MB^] do
     begin
      FirstColor := 0;
      BufDraw(P^, RowStride);
     end;
     Inc(P, TW);
     Inc(MB);
    end;
    Inc(Dst, BigStride);
   end;
  end;
  mfGBA:
  begin
   MW := Pointer(FWordMap);
   for Y := 0 to FHeight - 1 do
   begin
    P := Dst;
    for X := 0 to FWidth - 1 do
    begin
     with FTileList.FastTiles[MW^ and $3FF] do
     begin
      FirstColor := (MW^ shr 12) * 16;
      BufDraw(P^, RowStride, Boolean((MW^ shr 10) and 1),
                             Boolean((MW^ shr 11) and 1));
     end;
     Inc(P, TW);
     Inc(MW);
    end;
    Inc(Dst, BigStride);
   end;
  end;
  mfMSX:
  begin
   MW := Pointer(FWordMap);
   for Y := 0 to FHeight - 1 do
   begin
    P := Dst;
    for X := 0 to FWidth - 1 do
    begin
     W := SwapWord(MW^);
     with FTileList.FastTiles[W and $7FF] do
     begin
      FirstColor := ((W shr 13) and 3) * 16;
      BufDraw(P^, RowStride, Boolean((W shr 11) and 1),
                             Boolean((W shr 12) and 1));
     end;
     Inc(P, TW);
     Inc(MW);
    end;
    Inc(Dst, BigStride);
   end;
  end;
 end;
end;

procedure TMapImage.BufLoad(var Source; RowStride: Integer);
var
 TempTile, Tile: TCustomTile;
 XFlip, YFlip, TempOptimize: Boolean;
 BigStride, TileWidth, X, Y: Integer;
 Src, MB, P: PByte; MW: PWord;
 PalIndex: Integer;
begin
 if (FWidth = 0) or (FHeight = 0) then Exit;
 FTileList.Assign(FFixedTiles);
 FTileList.ResetEmptyBlock;
 TempOptimize := FTileList.Optimization;
 if FMapFormat = mfSingleByte then
  FTileList.Optimization := False;
 Src := @Source;
 TempTile := TTileClass(FTileList.NodeClass).Create;
 TileWidth := TempTile.Width;
 BigStride := RowStride * TempTile.Height;
 MB := Pointer(FByteMap);
 MW := Pointer(FWordMap);
 for Y := 0 to FHeight - 1 do
 begin
  P := Src;
  for X := 0 to FWidth - 1 do
  begin      
   If (FTileType = tt4bit) and FSelectPalette Then
     PalIndex := GetPaletteIndex(P^, RowStride)
   else
     PalIndex := PaletteIndex;
   TempTile.BufLoad(P^, RowStride);
   Inc(P, TileWidth);
   Tile := FTileList.AddOrGet(TempTile.TileData^, XFlip, YFlip);
   case FMapFormat of
    mfSingleByte:
    begin
     MB^ := Tile.TileIndex;
     Inc(MB);
    end;
    mfGBA:
    begin
     MW^ := (Tile.TileIndex and $3FF) or
            (Byte(XFlip) shl 10) or
            (Byte(YFlip) shl 11) or
            ((PalIndex and 15) shl 12);
     Inc(MW);
    end;
    mfMSX:
    begin
     MW^ := SwapWord((Tile.TileIndex and $7FF) or
            (Byte(XFlip) shl 11) or
            (Byte(YFlip) shl 12) or
            ((PalIndex and 3) shl 13));
     Inc(MW);
    end;
   end;
  end;
  Inc(Src, BigStride);
 end;
 TempTile.Free;
 FTileList.SetEmptyBlocksLen(0);
 FTileList.MakeArray;
 FTileList.Optimization := TempOptimize;
end;

constructor TMapImage.Create;
begin
 FTileType := tt4bit;
 FMapFormat := mfSingleByte;
 FTileList := TTileList.Create(TTile4BPP, True);
 FTileList.TileClassAssign := False;
 FFixedTiles := TTileList.Create(TTile4BPP, True);
 FFixedTiles.TileClassAssign := False;
end;

destructor TMapImage.Destroy;
begin
 FFixedTiles.Free;
 FTileList.Free;
end;

function TMapImage.GetImageHeight: Integer;
begin
 Result := FHeight shl 3;
end;

function TMapImage.GetImageSize: Integer;
begin
 Result := (FWidth shl 3) * (FHeight shl 3);
end;

function TMapImage.GetImageWidth: Integer;
begin
 Result := FWidth shl 3;
end;

function TMapImage.GetOptimization: Boolean;
begin
 Result := FTileList.Optimization;
end;

function TMapImage.GetPaletteIndex(var Source;
  RowStride: Integer): Integer;
var X, Y, n: Integer; P: ^Byte; PalIndex: Byte;
  UsedPals: Array[0..15] of Boolean;
  Procedure CheckColor(const B: Byte);
  var n,m: Integer;
  begin
    For m := 0 To 15 do
    begin
      If not UsedPals[m] Then
        Continue;
      For n := 0 To 15 do
      begin
        If Integer(FPalette[m*16 + n]) = Integer(FPalette[B]) Then
          Break;
      end;
      If n = 16 Then
        UsedPals[m] := False;
    end;
  end;
  Function GetColor(const PaletteIndex, ColorIndex: Byte): Integer;
  var n: Integer;
  begin
    Result := 0;
    For n := 0 To 15 do
    begin
      If Integer(FPalette[(PaletteIndex SHL 4) + n]) = Integer(FPalette[ColorIndex]) Then
      begin
        Result := (PaletteIndex SHL 4) + n;
        Exit;
      end;
    end;
  end;
begin
  FillChar(UsedPals, SizeOf(UsedPals), 1);
  Result := 0;
  P := @Source;
  
  For Y := 0 To 7 do
  begin
    For X := 0 To 7 do
    begin
      CheckColor(P^);
      Inc(P);
    end;
    Inc(P, RowStride - 8);
  end;
  For n := 0 To 15 do
  If UsedPals[n] Then
  begin
    P := @Source;
    For Y := 0 To 7 do
    begin
      For X := 0 To 7 do
      begin
        P^ := GetColor(n, P^);
        Inc(P);
      end;
      Inc(P, RowStride - 8);
    end;
    Result := n;
    Exit;
  end;          
  {
  For Y := 0 To 7 do
  begin
    PalIndex := P^ SHR 4;
    Inc(P);
    For X := 1 To 7 do
    begin
      If P^ SHR 4 <> PalIndex Then
        Exit;
      Inc(P);
    end;
    Inc(P, RowStride - 8);
  end;
  Result := PalIndex;
  }
end;

procedure TMapImage.LoadFromBitmapStream(const Stream: TStream);
var Pic, Pic2: TDIB;
begin
 Pic := TDIB.Create;
 Pic.LoadFromStream(Stream);
 ImageWidth := Pic.Width;
 ImageHeight := Pic.Height;
 if Pic.BitCount < 8 then Pic.BitCount := 8;
 if Pic.BitCount > 8 then
 begin
  Pic2 := Pic;
  Pic := TDIB.Create;
  Pic.PixelFormat := MakeDIBPixelFormat(8, 8, 8);
  Pic.BitCount := 8;
  Pic.Width := ImageWidth;
  Pic.Height := ImageHeight;
  Pic.ColorTable := FPalette;
  Pic.UpdatePalette;
  Pic.Fill8bit(0);
  Pic.Canvas.Draw(0, 0, Pic2);
  Pic2.Free;
 end else
 begin
  FPalette := Pic.ColorTable;
  Pic.Width := ImageWidth;
  Pic.Height := ImageHeight;
 end;
 try
  BufLoad(Pic.ScanLine[0]^, -Pic.WidthBytes);
 finally
  Pic.Free;
 end;
end;

procedure TMapImage.LoadFromFile(const FileName: String;
  MResType: TMResType);
var Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
 try
  case MResType of
   rtMap: LoadMapFromStream(Stream, False);
   rtMapNoHeader: LoadMapFromStream(Stream, True);
   rtTiles: LoadTilesFromStream(Stream);
   rtPalette: LoadPaletteFromStream(Stream);
   rtBitmap: LoadFromBitmapStream(Stream);
  end;
 finally
  Stream.Free;
 end;
end;

procedure TMapImage.LoadMapFromStream(const Stream: TStream; NoHeader: Boolean);
var W, H: Integer;
begin
 if not NoHeader then
 case FMapFormat of
  mfSingleByte:
  begin
   Stream.Read(W, 1);
   Stream.Read(H, 1);
   Width := Byte(W);
   Height := Byte(H);
  end;
  mfGBA:
  begin
   Stream.Read(W, 2);
   Stream.Read(H, 2);
   Width := Word(W);
   Height := Word(H);
  end;
  mfMSX:
  begin
   Stream.Read(W, 2);
   Stream.Read(H, 2);
   Width := SwapWord(W);
   Height := SwapWord(H);
  end;
 end;
 if FMapFormat = mfSingleByte then
  Stream.Read(FByteMap[0], Length(FByteMap)) else
  Stream.Read(FWordMap[0], Length(FWordMap) shl 1);
end;

procedure TMapImage.LoadPaletteFromStream(const Stream: TStream);
var RGBPal: TRGBPal; I: Integer;
begin
 FillChar(RGBPal, SizeOf(TRGBPal), 0);
 Stream.Read(RGBPal, SizeOf(RGBPal));
 for I := 0 to 255 do with FPalette[I], RGBPal[I] do
 begin
  rgbRed := R;
  rgbGreen := G;
  rgbBlue := B;
  rgbReserved := 0;
 end;
end;

procedure TMapImage.LoadTilesFromStream(const Stream: TStream);
begin
 FTileList.LoadFromStream(Stream);
end;

procedure TMapImage.SaveMapToStream(const Stream: TStream;
  NoHeader: Boolean);
var W, H: Integer;
begin
 if not NoHeader then
 case FMapFormat of
  mfSingleByte:
  begin
   Stream.Write(FWidth, 1);
   Stream.Write(FHeight, 1);
  end;
  mfGBA:
  begin
   Stream.Write(FWidth, 2);
   Stream.Write(FHeight, 2);
  end;
  mfMSX:
  begin
   W := SwapWord(FWidth);
   Stream.Write(W, 2);
   H := SwapWord(FHeight);
   Stream.Write(H, 2);
  end;
 end;
 if FMapFormat = mfSingleByte then
  Stream.Write(FByteMap[0], Length(FByteMap)) else
  Stream.Write(FWordMap[0], Length(FWordMap) shl 1);
end;

procedure TMapImage.SavePaletteToStream(const Stream: TStream);
var RGBPal: TRGBPal; I: Integer;
begin
 for I := 0 to 255 do with FPalette[I], RGBPal[I] do
 begin
  R := rgbRed;
  G := rgbGreen;
  B := rgbBlue;
 end;
 Stream.Write(RGBPal, SizeOf(RGBPal));
end;

procedure TMapImage.SaveTilesToStream(const Stream: TStream);
var I: Integer;
begin
 with FTileList do
 for I := 0 to Length(FastTiles) - 1 do with FastTiles[I] do
 begin
  TileIndex := I;
  SaveToStream(Stream);
 end;
end;

procedure TMapImage.SaveToBitmapStream(const Stream: TStream);
var Pic: TDIB;
begin
 Pic := TDIB.Create;
 Pic.PixelFormat := MakeDIBPixelFormat(8, 8, 8);
 Pic.BitCount := 8;
 Pic.Width := ImageWidth;
 Pic.Height := ImageHeight;
 Pic.ColorTable := FPalette;
 Pic.UpdatePalette;
 try
  BufDraw(Pic.ScanLine[0]^, -Pic.WidthBytes);
  Pic.SaveToStream(Stream);
 finally
  Pic.Free;
 end;
end;

procedure TMapImage.SaveToFile(const FileName: String;
  MResType: TMResType);
var Stream: TFileStream;
begin
 Stream := TFileStream.Create(FileName, fmCreate);
 try
  case MResType of
   rtMap: SaveMapToStream(Stream, False);
   rtMapNoHeader: SaveMapToStream(Stream, True);
   rtTiles: SaveTilesToStream(Stream);
   rtPalette: SavePaletteToStream(Stream);
   rtBitmap: SaveToBitmapStream(Stream);
  end;
 finally
  Stream.Free;
 end;
end;

procedure TMapImage.SetHeight(Value: Integer);
begin
 if Value <> FHeight then
 begin
  SetSize(FWidth, Value);
  FHeight := Value;
 end;
end;

procedure TMapImage.SetImageHeight(Value: Integer);
begin
 if Value mod 8 <> 0 then Value := (Value shr 3) shl 3 + 8;
 SetHeight(Value div 8);
end;

procedure TMapImage.SetImageWidth(Value: Integer);
begin
 if Value mod 8 <> 0 then Value := (Value shr 3) shl 3 + 8;
 SetWidth(Value div 8);
end;

procedure TMapImage.SetMapFormat(Value: TMapFormat);
var
 I: Integer; WW: Word;
 B: PByte; W: PWord;
begin
 if Value <> FMapFormat then
 begin
  if (FWidth > 0) and (FHeight > 0) then
  Case FMapFormat of
   mfSingleByte:
   Case Value of
    mfGBA:
    begin
     SetLength(FWordMap, FWidth * FHeight);
     B := Pointer(FByteMap);
     W := Pointer(FWordMap);
     for I := 0 to FWidth * FHeight - 1 do
     begin
      W^ := B^;
      Inc(B);
      Inc(W);
     end;
     Finalize(FByteMap);
    end;
    mfMSX:
    begin
     SetLength(FWordMap, FWidth * FHeight);
     B := Pointer(FByteMap);
     W := Pointer(FWordMap);
     for I := 0 to FWidth * FHeight - 1 do
     begin
      W^ := SwapWord(B^);
      Inc(B);
      Inc(W);
     end;
     Finalize(FByteMap);
    end;
   end;
   mfGBA:
   Case Value of
    mfSingleByte:
    begin
     SetLength(FByteMap, FWidth * FHeight);
     B := Pointer(FByteMap);
     W := Pointer(FWordMap);
     for I := 0 to FWidth * FHeight - 1 do
     begin
      B^ := W^;
      Inc(B);
      Inc(W);
     end;
     Finalize(FWordMap);
    end;
    mfMSX:
    begin
     W := Pointer(FWordMap);
     for I := 0 to FWidth * FHeight - 1 do
     begin
      W^ := SwapWord((W^ and $3FF) or
                    ((W^ and $FC00) shl 1));
      Inc(W);
     end;
    end;
   end;
   mfMSX:
   Case Value of
    mfSingleByte:
    begin
     SetLength(FByteMap, FWidth * FHeight);
     B := Pointer(FByteMap);
     W := Pointer(FWordMap);
     for I := 0 to FWidth * FHeight - 1 do
     begin
      B^ := SwapWord(W^);
      Inc(B);
      Inc(W);
     end;
     Finalize(FWordMap);
    end;
    mfGBA:
    begin
     W := Pointer(FWordMap);
     for I := 0 to FWidth * FHeight - 1 do
     begin
      WW := SwapWord(W^);
      W^ := (WW and $3FF) or ((WW and $F800) shr 1);
      Inc(W);
     end;
    end;
   end;
  end;
  FMapFormat := Value;
 end;
end;

procedure TMapImage.SetOptimization(Value: Boolean);
begin
 FTileList.Optimization := Value;
 FFixedTiles.Optimization := Value;
end;

procedure TMapImage.SetSize(W, H: Integer);
var
 TempB: array of Byte;
 TempW: array of Word;
 YY, WW, HH: Integer;
 PB1, PB2: PByte;
 PW1, PW2: PWord;
begin
 if (W <= 0) or (H <= 0) then
 begin
  Finalize(FByteMap);
  Finalize(FWordMap);
 end else
 begin
  if FMapFormat = mfSingleByte then
  begin
   SetLength(TempB, W * H);
   PB1 := Pointer(FByteMap);
   PB2 := Pointer(TempB);
   HH := FLastHeight;
   if HH > H then HH := H;
   WW := FLastWidth;
   if WW > W then WW := W;
   for YY := 0 to HH - 1 do
   begin
    Move(PB1^, PB2^, WW);
    Inc(PB1, FLastWidth);
    Inc(PB2, W);
   end;
   SetLength(FByteMap, Length(TempB));
   Move(TempB[0], FByteMap[0], Length(TempB));
  end else
  begin
   SetLength(TempW, W * H);
   PW1 := Pointer(FWordMap);
   PW2 := Pointer(TempW);
   HH := FLastHeight;
   if HH > H then HH := H;
   WW := FLastWidth;
   if WW > W then WW := W;
   WW := WW shl 1;
   W := W;
   for YY := 0 to HH - 1 do
   begin
    Move(PW1^, PW2^, WW);
    Inc(PW1, FLastWidth);
    Inc(PW2, W);
   end;
   SetLength(FWordMap, Length(TempW));
   Move(TempW[0], FWordMap[0], Length(TempW) shl 1);
  end;
 end;
 FLastWidth := W;
 FLastHeight := H;
end;

procedure TMapImage.SetTileType(Value: TTileType);
var
 I: Integer; Error: Boolean;
 TLS: array[0..1] of TTileList;
begin
 if Value <> FTileType then
 begin
  TLS[0] := NIL;
  TLS[1] := NIL;
  Error := False;
  for I := 0 to 1 do
  begin
   TLS[I] := TTileList.Create;
   TLS[I].TileClassAssign := False;
   with TLS[I] do
   begin
    case Value of
     tt2bitNES: NodeClass := TTile2BPP_NES;
     tt4bit:    NodeClass := TTile4BPP;
     tt4bitMSX: NodeClass := TTile4BPP_MSX;
     tt8bit:    NodeClass := TTile8BPP;
    end;
    try
     if I = 0 then
      Assign(FTileList) else
      Assign(FFixedTiles);
    except
     Error := True;
    end;
   end;
   if Error then Break;
  end;
  if not Error then
  begin
   FTileList.Free;
   FTileList := TLS[0];
   FFixedTiles.Free;
   FFixedTiles := TLS[1];
   FTileType := Value;
  end else
  begin
   TLS[0].Free;
   TLS[1].Free;
   raise Exception.Create('Unexpected error.');
  end;
 end;
end;

procedure TMapImage.SetWidth(Value: Integer);
begin
 if Value <> FWidth then
 begin
  SetSize(Value, FHeight);
  FWidth := Value;
 end;
end;

end.
