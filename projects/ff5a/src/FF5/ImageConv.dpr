program ImageConv;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DIB,
  Classes,
  mi_MapImage,
  TilesUnit,
  GBAUnit,  
  Windows,
  TableText in '..\FFText\TableText.pas';

Type
  TTileSize = (
    ts8x8,   ts16x8,  ts8x16,
    ts16x16, ts32x8,  ts8x32,
    ts32x32, ts32x16, ts16x32,
    ts64x64, ts64x32, ts32x64
  );
  TOAM = Array[0..2] of Word;
  TTileArray = Array of TTile4bit;


procedure LoadTile(Src: Pointer; var Tile: TTile4bit; RowStride: Integer);
var XX, YY: Integer; P: ^Byte;
begin
  P := Src;
  For YY := 0 To 7 do
  begin
    For XX := 0 To 3 do
    begin                
      Tile[YY, XX] := (P^ and $F);
      Inc(P);
      Tile[YY, XX] := Tile[YY, XX] or (P^ SHL 4);
      Inc(P);
    end;
    Inc(P, RowStride - 8);
  end;
end;

Function BitmapToTiles(Bitmap: TDIB; var Tiles: TTileArray; Cut: Boolean = False): Integer;
var
  EmptyTile: TTile4Bit;
  n, XX, YY, RowStride: Integer;
begin
  If Bitmap.BitCount <> 8 Then Bitmap.BitCount := 8;
  SetLength(Tiles, (Bitmap.Width div 8) * (Bitmap.Height div 8));
  RowStride := -Bitmap.WidthBytes;
  n := 0;
  For YY := 0 To Bitmap.Height div 8 - 1 do
  begin
    For XX := 0 To Bitmap.Width div 8 - 1 do
    begin
      LoadTile(Pointer(Integer(Bitmap.ScanLine[YY * 8]) + (XX * 8)), Tiles[n], RowStride);
      Inc(n);
    end;
  end;
  Result := n;
  If Cut Then
  begin
    FillChar(EmptyTile, SizeOf(EmptyTile), 0);
    For n := Result - 1 downto 0 do
      If not CompareMem(@Tiles[n], @EmptyTile, SizeOf(TTile4bit)) Then
        break;
    SetLength(Tiles, n + 1);
    Result := n + 1;
  end;
end;

Function Minimum(const A, B: Integer): Integer;
begin
  If A > B Then
    Result := B
  else
    Result := A;
end;

procedure ProcessSprites(const SX, SY: Integer; W, H, X, Y: Integer; var T: Integer;
  var Tiles: TTileArray; TilesStream, OAMStream: TStream; var SpriteCount: Integer);
const Sizes: Array[0..3] of Integer = (8, 16, 32, 64);
Function GetMax(Min, Max: Integer): Integer;
var n: Integer;
begin
  Result := -1;
  For n := High(Sizes) DownTo Low(Sizes) do
    If (Sizes[n] <= Max) and (Sizes[n] >= Min) Then
    begin
      Result := Sizes[n];
      Exit;
    end;
end;
Function GetSprite(X, Y, TW, TH: Integer): TOAM;
var O, S, XX, YY: Integer;
begin
  If TW > TH Then       O := 1
  else If TW < TH Then  O := 2
  else                  O := 0;
  Case O of
    0:
    Case TW of
      8:  S := 0;
      16: S := 1;
      32: S := 2;
      64: S := 3;
    end;
    1:
    Case TW of
      16: S := 0;
      32: If TH = 8 Then S := 1 else S := 2;
      64: S := 3;
    end;
    2:
    Case TW of
      8: If TH = 16 Then S := 0 else S := 1;
      16: S := 2;
      32: S := 3;
    end;
  end;
  FillChar(Result, SizeOf(Result), 0);
  Result[0] := ((SY + Y) and $FF)  or (O SHL 14);
  Result[1] := ((SX + X) and $1FF) or (S SHL 14);
  Result[2] := T and $3FF;
  Inc(SpriteCount);
  Inc(T, (TW div 8) * (TH div 8));
  For YY := (Y div 8) to (Y div 8) + (TH div 8) - 1 do
    For XX := (X div 8) to (X div 8) + (TW div 8) - 1 do
      TilesStream.Write(Tiles[YY * (W div 8) + XX], SizeOf(TTile4bit));
end;
var WW, HH, XX, YY, TW, TH: Integer; Sprite: TOAM;
Label LabelH;
begin
  WW := W - X;
  HH := H - Y;
  TW := GetMax(8, WW);

LabelH:

  Case TW of
    64:
    begin
      TH := GetMax(32, Minimum(64, HH));
      If TH = -1 Then
      begin
        TW := 32;
        GoTo LabelH;
      end;
    end;
    32:
    begin
      TH := GetMax(8, Minimum(32, HH));
      If TH = -1 Then
      begin
        TW := 16;
        GoTo LabelH;
      end;
    end;
    16:
    begin
      TH := GetMax(8, Minimum(16, HH));
      If TH = -1 Then
      begin
        TW := 8;
        GoTo LabelH;
      end;
    end;
    8: TH := GetMax(8, Minimum(16, HH));
  end;

  For YY := 0 To (HH div TH) - 1 do
  begin
    For XX := 0 To (WW div TW) - 1 do
    begin
      Sprite := GetSprite(X + XX * TW, YY + YY * TW, TW, TH);
      OAMStream.Write(Sprite, SizeOf(Sprite));
    end;
  end;
  XX := X + (WW div TW) * TW;
  YY := Y + (HH div TH) * TH;
  If YY < H Then
    ProcessSprites(SX, SY, W, H, X, YY, T, Tiles, TilesStream, OAMStream, SpriteCount);
  If XX < W Then
    ProcessSprites(SX, SY, W, YY, XX, Y, T, Tiles, TilesStream, OAMStream, SpriteCount);

end;

procedure ImageToSprites(SX, SY: Integer; ImageFile: String; TilesStream: TStream; OAMStream: TStream);
var
  TilesPos, OAMPos: Integer; Tiles: TTileArray; Bitmap: TDIB;
  XX, YY, W, H, n: Integer; RowStride, T, SpriteCount: Integer;
begin
  Bitmap := TDIB.Create;
  Bitmap.LoadFromFile(ImageFile);
  If Bitmap.BitCount <> 8 Then
    Bitmap.BitCount := 8;
  SetLength(Tiles, (Bitmap.Width div 8) * (Bitmap.Height div 8));
  RowStride := -Bitmap.WidthBytes;
  n := 0;
  For YY := 0 To Bitmap.Height div 8 - 1 do
  begin
    For XX := 0 To Bitmap.Width div 8 - 1 do
    begin
      LoadTile(Pointer(Integer(Bitmap.ScanLine[YY * 8]) + (XX * 8)), Tiles[n], RowStride);
      Inc(n);
    end;
  end;

  T := 0;
  //TilesStream.Write(Tiles[0], Length(Tiles) * SizeOf(TTile4bit));
  //TilesStream.Seek(8, 0);
  n := 1;
  TilesStream.Write(n, 4);
  n := Length(Tiles);
  TilesStream.Write(n, 4);
  OAMStream.Seek(2, 0);
  SpriteCount := 0;
  ProcessSprites(SX, SY, Bitmap.Width, Bitmap.Height, 0, 0, T, Tiles, TilesStream, OAMSTream, SpriteCount);

  OAMStream.Seek(0, 0);
  OAMStream.Write(SpriteCount, 2);

  Bitmap.Free;
  Finalize(Tiles);  
end;

procedure ImageToSpriteSet(SX, SY: Integer; ImageFile: String; TilesStream: TStream; OAMStream: TStream);
var
  TilesPos, OAMPos: Integer; Tiles: TTileArray; Bitmap: TDIB;
  Pos, XX, YY, W, H, n: Integer; RowStride, T, SpriteCount: Integer;
  EmptyTile: TTile4Bit;
const
  OAMFooter: Array[0..4] of Word = ($40, $40, 1, 0, 4);
begin
  FillChar(EmptyTile, SizeOf(EmptyTile), 0);
  Bitmap := TDIB.Create;
  Bitmap.LoadFromFile(ImageFile);
  If Bitmap.BitCount <> 8 Then
    Bitmap.BitCount := 8;
  SetLength(Tiles, (Bitmap.Width div 8));
  RowStride := -Bitmap.WidthBytes;

  n := 1;
  TilesStream.Write(n, 4);
  TilesStream.Seek(8, 0);

  n := 4;
  OAMStream.Write(n, 4);
  n := (Bitmap.Height div 8) + $10000;
  OAMStream.Write(n, 4);
  n := 6;
  OAMStream.Write(n, 4);

  Pos := (Bitmap.Height div 4) + 12;
  T := 0;
  For YY := 0 To Bitmap.Height div 8 - 1 do
  begin
    OAMStream.Seek(12 + YY * 2, 0);
    n := Pos div 2;
    OAMStream.Write(n, 2);
    OAMStream.Seek(Pos, 0); 
    For XX := 0 To Bitmap.Width div 8 - 1 do
      LoadTile(Pointer(Integer(Bitmap.ScanLine[YY * 8]) + (XX * 8)), Tiles[XX], RowStride);
    For W := High(Tiles) downto Low(Tiles) do
      If not CompareMem(@Tiles[W], @EmptyTile, SizeOf(TTile4bit)) Then
        Break;
    Inc(W);
    Pos := OAMStream.Position;
    OAMStream.Write(W, 2);
    SpriteCount := 0;
    ProcessSprites(SX, SY, W * 8, 8, 0, 0, T, Tiles, TilesStream, OAMStream, SpriteCount);
    n := 0;
    OAMStream.Write(n, 2);
    OAMStream.Seek(Pos, 0);
    OAMStream.Write(SpriteCount, 2);
    Pos := OAMStream.Size;
  end;

  TilesStream.Seek(4, 0);
  TilesStream.Write(T, 4);

  n := (Pos + 2) div 2;
  OAMStream.Seek(Pos, 0);
  OAMStream.Write(n, 2);
  OAMStream.Write(OAMFooter, SizeOf(OAMFooter));
  Dec(n);
  OAMStream.Seek(10, 0);
  OAMStream.Write(n, 2);

  Bitmap.Free;
  Finalize(Tiles);  
end;

Procedure CompressStream(var Stream: TMemoryStream; Huffman: Boolean = False);
var LZStream: TMemoryStream;
begin
  LZStream := TMemoryStream.Create;
  LZStream.SetSize(Stream.Size + Stream.Size div 8 + 4);
  If Huffman Then
    LZStream.SetSize(HuffCompress(Stream.Memory^, LZStream.Memory^, Stream.Size, False)) 
  else
    LZStream.SetSize(LZ77Compress(Stream.Memory^, LZStream.Memory^, Stream.Size, True));
  Stream.Free;
  Stream := LZStream;
end;



Procedure Error(const S: string; Level: TErrorType = etError);
const
  cMsg: Array[TErrorType] of String = ('', '***HINT: ', '***WARNING: ', '***ERROR: ');
begin
  WriteLn(cMsg[Level] + S);
end;


// -s 448 248 data\menu\press.bmp data\menu\res\press.oam data\menu\res\press.lz
// -l data\logo\bmp\title.bmp data\logo\res\title.map data\logo\res\title.lz
// -l -c -mc -mh -Fdata\mplayer_fixed.chr data\logo\bmp\mplayer.bmp data\mplayer.map data\mplayer.chr
var
  Key, SrcFile, DestMap, Param, DestChr, FixedTiles: String;
  Code, n, BitCount, X, Y: Integer;
  SingleMap, Compression, MapCompression, MapHeader, Header: Boolean;
  MapImage: TMapImage;
  TileType: TTileType;
  Stream, OAMStream: TMemoryStream;
  Append: Boolean = False;
  FileStream: TFileStream;
  List: TStringList;
  PtrOffset, Count, Position: Integer;
  S: String;
  Pic: TDIB;
  GBAPAL: Array[0..255] of Word;
  Color: TRGBQuad;
  Tiles: TTileArray;
  Buf: Pointer;
  P: PByte;
  Table: TTable;
  WS: WideString;
  UsePtrs: Boolean = True;

begin
  (*
    ImageConv.exe <Key> <SrcFile> <DestMap> <DestChr>
    Keys:
      -l - logo
      -s - single-byte tilemap
      -4 - 4bpp
      -8 - 8bpp
  *)


  Key := ParamStr(1);

  SingleMap := False;
  TileType := tt8bit;
  Compression := True;
  MapHeader := False;
  Header    := True;
  MapCompression := False;
  For n := 2 to ParamCount do
  begin
    Param := ParamStr(n);
    If (Param[1] = '-') Then
    begin
      Case Param[2] of
        'a','A': Append := True;
        'h','H': Header := False;
        's','S': SingleMap := True;
        '4':     TileType := tt4bit;
        '8':     TileType := tt8bit;
        'c','C': Compression := False;
        'f','F': FixedTiles := PChar(@Param[3]);
        'p','P': UsePtrs := not UsePtrs;      
        'm','M':
        begin
          Case Param[3] of
            'c','C': MapCompression := True;
            'h','H': MapHeader := True;
          end;
        end;
      end;
    end else
      Break;
  end;

  If Key = '-staff' Then
  begin
    Table := TTable.Create(@Error);
    Table.LoadTable(ParamStr(n)); 
    List := TStringList.Create;
    List.LoadFromFile(ParamStr(n + 1));
    Stream := TMemoryStream.Create;
    Stream.SetSize(Length(List.Text));

    P := Stream.Memory;
    WS := DeleteCarrets(List.Text);
    Stream.SetSize(Table.ExportString(P, WS, True));

    Table.Free;
    List.Free;
    Stream.SaveToFile(ParamStr(n + 2));
    Stream.Free;
    WriteLn('Staff converted!');
  end else
  If Key = '-bmp2chr' Then
  begin
    Pic := TDIB.Create;
    Pic.LoadFromFile(ParamStr(n));
    BitmapToTiles(Pic, Tiles, True);
    Pic.Free;
    Stream := TMemoryStream.Create;
    If Header Then
    begin
      X := 1;
      Stream.Write(X, 4);
      X := Length(Tiles);
      Stream.Write(X, 4); 
    end;
    Stream.Write(Tiles[0], Length(Tiles) * SizeOf(TTile4bit));
    If Compression Then
      CompressStream(Stream);
    Stream.SaveToFile(ParamStr(n + 1));
    Stream.Free;
    WriteLn('Bitmap successfully converted to tiles!');
  end else
  If Key = '-intro' Then
  begin
    // -intro [keys] <InBitmap> <OutChr> <OutPal>
    // -intro data\intro\intro.bmp data\intro\intro.lzhuff data\intro\intro.gbapal
    Pic := TDIB.Create;
    Pic.LoadFromFile(ParamStr(n));
    If Pic.BitCount <> 8 Then
      Pic.BitCount := 8;
    Stream := TMemoryStream.Create;
    For Y := 0 to Pic.Height - 1 do
      Stream.Write(Pic.ScanLine[Y]^, Pic.Width);
    //Stream.Write(Pic.ScanLine[Pic.Height - 1]^, Pic.Width * Pic.Height);
    CompressStream(Stream);
    CompressStream(Stream, True);
    Stream.SaveToFile(ParamStr(n + 1));
    Stream.Clear;
    Color.rgbReserved := 0;
    For X := 0 To 255 do
    begin
      With Pic.ColorTable[X] do
      begin
        Color.rgbBlue  := rgbRed;
        Color.rgbGreen := rgbGreen;
        Color.rgbRed   := rgbBlue;
      end;
      GBAPAL[X] := Color2GBA(DWord(Color));
    end;
    Stream.Write(GBAPAL, SizeOf(GBAPAL));
    Stream.SaveToFile(ParamStr(n + 2));
    Stream.Free;
    Pic.Free;
    WriteLn('Intro generated!');
  end else
  If Key = '-s' Then
  begin
    Val(ParamStr(n + 0), X, Code);
    Val(ParamStr(n + 1), Y, Code);
    SrcFile := ParamStr(n + 2);
    DestMap := ParamStr(n + 3);
    DestChr := ParamStr(n + 4);

    Stream := TMemoryStream.Create;
    OAMStream := TMemoryStream.Create;
    ImageToSprites(X, Y, SrcFile, Stream, OAMStream);
    OAMStream.SaveToFile(DestMap);
    If Compression Then
      CompressStream(Stream);
    Stream.SaveToFile(DestChr);
    Stream.Free;
    OAMStream.Free;
    WriteLn('Spriteset generated sucessfully!');
    Exit;
  end else
  If Key = '-ss' Then
  begin           
    Val(ParamStr(n + 0), X, Code);
    Val(ParamStr(n + 1), Y, Code);
    SrcFile := ParamStr(n + 2);
    DestMap := ParamStr(n + 3);
    DestChr := ParamStr(n + 4);

    Stream := TMemoryStream.Create;
    OAMStream := TMemoryStream.Create;
    ImageToSpriteSet(X, Y, SrcFile, Stream, OAMStream);
    OAMStream.SaveToFile(DestMap);
    If Compression Then
      CompressStream(Stream);
    Stream.SaveToFile(DestChr);
    Stream.Free;
    OAMStream.Free;
    WriteLn('Sprite generated sucessfully!');
    Exit;
  end else
  If Key = '-compress' Then
  begin
    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(ParamStr(n));
    CompressStream(Stream);
    DestChr := ParamStr(n + 1);
    If DestChr = '' Then
      DestChr := ParamStr(n);
    Stream.SaveToFile(DestChr);
    Stream.Free;
    WriteLn('Compressed successfully!');
    Exit;
  end else
  If Key = '-text' Then
  begin
    List := TStringList.Create;
    Stream := TMemoryStream.Create;
    If UsePtrs Then
    begin
      Dec(n, 2);
      List.LoadFromFile(ParamStr(n + 2));  
      Val(ParamStr(n + 3), PtrOffset, Code);
      If Code <> 0 Then Exit;
      Val(ParamStr(n + 4), Count,     Code);
      If Code <> 0 Then Exit;
      Val(ParamStr(n + 5), Position,  Code);
      If Code <> 0 Then Exit;
      FileStream := TFileStream.Create(ParamStr(6), fmOpenWrite);
      Y := 0;
      FileStream.Seek(Position, 0);
      For n := 0 To Count - 1 do
      begin
        X := FileStream.Position + $08000000;
        Stream.Write(X, 4);
        S := List.Strings[n];
        FileStream.Write(S[1], Length(S));
        X := Stream.Position mod 4;
        If X = 0 Then X := 4;
        FileStream.Write(Y, X);
      end;
      FileStream.Seek(PtrOffset, 0);
      FileStream.Write(Stream.Memory^, Stream.Size);
      FileStream.Free;
    end else
    begin         
      List.LoadFromFile(ParamStr(n + 1));
      Table := TTable.Create(@Error);
      Table.LoadTable(ParamStr(n));
      Count := 0;
      If FixedTiles <> '' Then
        Val(FixedTiles, Count, Code);

      Stream.SetSize(64*1024);
      P := Stream.Memory;
      For Y := 0 To List.Count - 1 do
      begin
        WS := List.Strings[Y];
        If (Count > 0) and (Length(WS) > Count) Then
          SetLength(WS, Count)
        else If (Count > 0) and (Length(WS) < Count) Then
          For X := Length(WS) to Count - 1 do
            WS := WS + WideChar($20);
        Table.ExportString(P, WS);
      end;
      Stream.SetSize(LongWord(P) - LongWord(Stream.Memory));
      Stream.SaveToFile(ParamStr(n + 2)); 
    end;
    Stream.Free;
    List.Free;
    WriteLn('Text converted!');
  end else
  if Key = '-l' Then
  begin

    SrcFile := ParamStr(n + 0);
    DestMap := ParamStr(n + 1);
    DestChr := ParamStr(n + 2);

    MapImage := TMapImage.Create;
    MapImage.SelectPalette := True;
    MapImage.Optimization := True;
    MapImage.TileType := TileType;
    If SingleMap Then
      MapImage.MapFormat := mfSingleByte
    else
      MapImage.MapFormat := mfGBA;
    If FixedTiles <> '' Then
      MapImage.FixedTiles.LoadFromFile(FixedTiles);

    MapImage.LoadFromFile(SrcFile, rtBitmap);

    Stream := TMemoryStream.Create;

    If MapHeader Then
    begin
      n := 2;
      Stream.Write(n, 4);
      n := MapImage.Width * MapImage.Height;
      Stream.Write(n, 4);  
      n := MapImage.Width;
      Stream.Write(n, 1); 
      n := MapImage.Height;
      Stream.Write(n, 3);
    end;
    MapImage.SaveMapToStream(Stream, True);
    If MapCompression Then
      CompressStream(Stream);
    Stream.SaveToFile(DestMap);
    Stream.Clear;
    If Header Then
    begin
      n := 1;
      Stream.Write(n, 4);
      Stream.Seek(8, 0);
    end;
    MapImage.SaveTilesToStream(Stream);
    If Header Then
    begin
      n := Stream.Size div 32;
      Stream.Seek(4, 0);
      Stream.Write(n, 4);
    end;
    If Compression Then
      CompressStream(Stream);

    Stream.SaveToFile(DestChr);

    Stream.Free;
    MapImage.Free;
    WriteLn('Done!');
  end;



  { TODO -oUser -cConsole Main : Insert code here }
end.

