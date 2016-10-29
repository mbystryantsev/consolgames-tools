unit FF8_Mim;

interface

uses DIB, Classes, SysUtils, Windows, FF8_Compression;

type

  TMapType1 = Packed Record
    mX, mY, mZ: SmallInt;
    mTex:       Byte;
    mUnk0:      Byte;
    mPal:       Word;
    mTX, mTY:   Byte;
    mUnk1:      Byte;
    mBlend:     Byte;
    mAnim:      ShortInt;
    mFrame:     Byte;
  end;

  //TMapType2 = Record(TMapType1);

  TPS2Pal = Array[Byte] of Word;
  TPals   = Array[0..23] of TRGBQuads;
  TByteSet = Set of Byte;
  TLayer = Record
    lZ:   Single;//Integer;
    lPtr: Array of Pointer;
  end;

  TFF8MIM = Class
  constructor Create;
  destructor  Destroy;
  private
    FPS2Pals: Array[0..23] of TPS2Pal;
    FPalettes:    TPals;
    FTiles:       TDIB;
//    FTiles4:      TDIB;
    FImage:       TDIB;
    FMapType:     Integer;
    FPalCount:    Integer;
    FMap:         Pointer;
    FTileCount:   Integer;
    FLayers:      Array of TLayer;

    FWidth:       Integer;
    FHeight:      Integer;
    FCenterX:     Integer;
    FCenterY:     Integer;
    FFrameCount:  Array[Byte] of Integer;
    FAnimCount:   Integer;

    Procedure PS2ToPalettes;
    Procedure AnalyzeMap;
    Procedure DrawTile(_X, _Y, Tex, TX, TY, Pal, Blend: Integer; Tiles4: Boolean = False);
    procedure DrawTiles(const Anim: TByteSet; const Frames: Array of Byte);
    procedure SortLayers;
  public
    Procedure LoadMIM(_Stream: TStream);  overload;
    Procedure LoadMIM(FileName: String); overload;
    Procedure LoadMAP(_Stream: TStream);  overload;
    Procedure LoadMAP(FileName: String); overload;   
    Procedure DrawMap(Anim: Integer = -1; Frame: Integer = 0; BG: Boolean = True); overload;
    Procedure DrawMap(const Anim: TByteSet; const Frames: Array of Byte); overload;

    Property Tiles:      TDIB read FTiles;
    property Image:      TDIB read FImage;
    Function TexCount:   Integer;
    Property PalCount:   Integer read FPalCount;
    property Palettes:   TPals Read FPalettes;
    Function FrameCount(Index: Integer): Integer;
    property AnimationCount: Integer read FAnimCount;
    property Width:      Integer read FWidth;
    property Height:     Integer read FHeight;
    property CenterX:    Integer read FCenterX;
    property CenterY:    Integer read FCenterY;
  end;

implementation

uses
  Dialogs;

{ TFF8MIM }

Procedure DecompressStream(var Stream: TMemoryStream);
var LZSStream: TMemoryStream; Size: Integer;
begin
  If Integer(Stream.Memory^) = Stream.Size - 4 Then
  begin
    LZSStream := TMemoryStream.Create;
    LZSStream.SetSize(1024*1024);
    lzs_decompress(Pointer(DWord(Stream.Memory) + 4), Integer(Stream.Memory^), LZSStream.Memory, Size);
    LZSStream.SetSize(Size);
    Stream.Free;
    Stream := LZSStream;
  end;
end;

constructor TFF8MIM.Create;
begin
  FTiles := TDIB.Create;
  FTiles.BitCount := 8;
  //FTiles4 := TDIB.Create;
  //FTiles4.BitCount := 4;
  FImage          := TDIB.Create;
  FImage.BitCount := 32;
end;

destructor TFF8MIM.Destroy;
begin
  FTiles.Free;
  FImage.Free;
  //FTiles4.Free;
  If FMap <> nil Then
    FreeMem(FMap);
end;

procedure TFF8MIM.LoadMIM(_Stream: TStream);
var Size: Integer; Stream: TMemoryStream;
    Data: Array[0..2] of DWord; P: Pointer; W, Pos: Integer;
    n: Integer;
begin
  Stream := TMemoryStream.Create;
  Stream.SetSize(_Stream.Size); 
  _Stream.Read(Stream.Memory^, Stream.Size);
  DecompressStream(Stream);
  Stream.Read(Data, SizeOf(Data));
  If ((Data[0] and $FF000000) = $80000000) and ((Data[1] and $FF000000) = $80000000)
    and (Data[2] <= $0C) Then
      Size := $6B000{Data[1] - Data[0]}
  else
  begin
    Size := Stream.Size;
    Stream.Seek(0, 0); 
  end;
  If Size = $6B000 Then
    FMapType := 1
  else
    FMapType := 2;
  Case FMapType of
    1: FPalCount := 24;
    2: FPalCount := 16;
  end;
  Stream.Read(FPS2Pals, FPalCount * SizeOf(TPS2Pal));
  FTiles.Height := 256;
  Case FMapType of
    1: FTiles.Width  := 128 * 13;
    2: FTiles.Width  := 128 * 12;
  end;
  FillChar(FTiles.ScanLine[255]^, FTiles.Width * 256, 0);
  P := Stream.Memory;
  W := FTiles.Width;
  Pos := Stream.Position;
  For n := 0 To 255 do
    Move(Pointer(DWord(P) + Pos + (n * W))^, FTiles.ScanLine[n]^, W);

  //FTiles4.Width := W * 2;
  //FTiles4.Height := FTiles.Height;
  //For n := 0 To 255 do
  //  Move(Pointer(DWord(P) + Pos + (n * W))^, FTiles4.ScanLine[n]^, W);

  //FTiles4.SaveToFile('C:\test.bmp');

  PS2ToPalettes;
  Stream.Free;
end;

procedure TFF8MIM.LoadMAP(_Stream: TStream);
var Stream: TMemoryStream;
  Data: Array[0..11] of DWord; n, Size: Integer;
begin
  Stream := TMemoryStream.Create;
  Stream.SetSize(_Stream.Size);
  _Stream.Read(Stream.Memory^, Stream.Size);

  DecompressStream(Stream);
  Stream.Read(Data, SizeOf(Data));
  For n := 0 To 11 do
    If (Data[n] and $FF000000) <> $80000000 Then
      break;
  If n = 12 Then
  begin
    Stream.Seek(Data[3] - Data[0] + $30, 0);
    Size := Data[4] - Data[3];
  end else
  begin
    Stream.Seek(0, 0);
    Size := Stream.Size; 
  end;

  FTileCount := Size div 16 - 1;
  If FMap <> nil Then
    FreeMem(FMap);
  GetMem(FMap, Size - 16);
  Stream.Read(FMap^, Size - 16);
  Stream.Free;
  AnalyzeMap;
  FImage.Width  := FWidth;
  FImage.Height := FHeight;
end;

procedure TFF8MIM.LoadMAP(FileName: String);
var Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  LoadMAP(Stream);
  Stream.Free;
end;

procedure TFF8MIM.LoadMIM(FileName: String);
var Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  LoadMIM(Stream);
  Stream.Free;
end;

procedure TFF8MIM.PS2ToPalettes;
var P, n: Integer;
begin
  For P := 0 To FPalCount - 1 do
  begin
    For n := 0 To 255 do With FPalettes[P, n] do
    begin
      rgbReserved := 0;
      rgbRed      := (FPS2Pals[P, n] and $1F) * 8;
      rgbGreen    := ((FPS2Pals[P, n] shr 5) and $1F) * 8;
      rgbBlue     := ((FPS2Pals[P, n] shr 10) and $1F) * 8;
    end;
  end;
end;

function TFF8MIM.TexCount: Integer;
begin
  If FMapType = 1 Then
    Result := 13
  else
    Result := 12;
end;

procedure TFF8MIM.AnalyzeMap;
var n: Integer; P: Pointer; X, XX, Y, YY: Integer;
 procedure LayerAddOrSet(P: Pointer; Z: Single);
 var n: Integer;
 begin
  If Length(FLayers) > 0 Then
  begin
    For n := 0 To High(FLayers) do
      If FLayers[n].lZ = Z Then
        break;
  end else
    n := 0;
  If n = Length(FLayers) Then
  begin
    SetLength(FLayers, n + 1);
    FLayers[n].lZ := Z;
  end;
  SetLength(FLayers[n].lPtr, Length(FLayers[n].lPtr) + 1);
  FLayers[n].lPtr[High(FLayers[n].lPtr)] := P;
 end;
begin
  XX := Low(Integer);
  X  := High(Integer);
  YY := Low(Integer);
  Y  := High(Integer);
  For n := 0 To High(FLayers) do
    Finalize(FLayers[n].lPtr);
  SetLength(FLayers, 0);
  FAnimCount := -1;
  FillChar(FFrameCount, SizeOf(FFrameCount), $FF);
  P := FMap;
  For n := 0 To FTileCount - 1 do
  begin
    With TMapType1(P^) do
    begin
      LayerAddOrSet(P, mZ / 4096 { $1000 - (mZ and $FFF)});
      If mX < X Then X := mX;
      If mY < Y Then Y := mY;
      If mX > XX Then XX := mX;
      If mY > YY Then YY := mY;
      If mFrame > FFrameCount[mAnim] Then
        FFrameCount[mAnim] := mFrame;
      If (mAnim <> $FF) and (mAnim > FAnimCount) Then
        FAnimCount := mAnim;
    end;
    Inc(DWord(P), 16);
  end;
  FWidth   := XX - X + 16;
  FHeight  := YY - Y + 16;
  FCenterX := -X;
  FCenterY := -Y;
  For n := 0 To High(FFrameCount) do
    Inc(FFrameCount[n]);
  Inc(FAnimCount);
  SortLayers;
end;

procedure TFF8MIM.DrawTile(_X, _Y, Tex, TX, TY, Pal, Blend: Integer; Tiles4: Boolean = False);
var X, Y: Integer; P: PByte; D: PDWord; R,G,B: Integer; C: Byte;
const
  Alpha = 0.5;
begin
  Inc(_X, FCenterX);
  Inc(_Y, FCenterY);
  For Y := _Y to _Y + 15 do
  begin
    D := FImage.ScanLine[Y];
    Inc(D, _X);     
    P := FTiles.ScanLine[TY];
    If Tiles4 Then
      Inc(P, Tex * 128 + TX div 2)
    else
      Inc(P, Tex * 128 + TX);
    Inc(TY);
    For X := _X to _X + 15 do
    begin
      If Tiles4 Then
      begin
        If X mod 2 = 0 Then
          C := P^ and $F
        else
          C := P^ SHR 4;
      end else
        C := P^;
      If C > 0 Then
      begin
        Case Blend of
          0:
          begin     
            With TRGBQuad(D^) do
            begin
              rgbRed   := Round(FPalettes[Pal, C].rgbRed   * Alpha + (1 - Alpha) * rgbRed  );
              rgbGreen := Round(FPalettes[Pal, C].rgbGreen * Alpha + (1 - Alpha) * rgbGreen);
              rgbBlue  := Round(FPalettes[Pal, C].rgbBlue  * Alpha + (1 - Alpha) * rgbBlue );
            end;
          end;
          1,3:
          begin
            With TRGBQuad(D^) do
            begin
              // Add Color
              R  := FPalettes[Pal, C].rgbRed   + rgbRed;
              G  := FPalettes[Pal, C].rgbGreen + rgbGreen;
              B  := FPalettes[Pal, C].rgbBlue  + rgbBlue;
              If R > 255 Then rgbRed   := 255 else rgbRed   := R;
              If G > 255 Then rgbGreen := 255 else rgbGreen := G;
              If B > 255 Then rgbBlue  := 255 else rgbBlue  := B;
            end;
          end;
          2:
            With TRGBQuad(D^) do
            begin
              // Subtract color
              R  := rgbRed   - FPalettes[Pal, C].rgbRed;
              G  := rgbGreen - FPalettes[Pal, C].rgbGreen;
              B  := rgbBlue  - FPalettes[Pal, C].rgbBlue;
              If R < 0 Then rgbRed   := 0 else rgbRed   := R;
              If G < 0 Then rgbGreen := 0 else rgbGreen := G;
              If B < 0 Then rgbBlue  := 0 else rgbBlue  := B;
            end;
          //3: D^ := DWord(FPalettes[Pal, C]);
          4: D^ := DWord(FPalettes[Pal, C]);
          else
            D^ := $FF0000; //MessageDlg(IntToStr(Blend), mtWarning, [mbOK], 0);
        end;
      end;
      If (not Tiles4) or (Tiles4 and (X mod 2 = 1)) Then
        Inc(P);
      Inc(D);
    end;
  end;
end;

procedure TFF8MIM.DrawTiles(const Anim: TByteSet; const Frames: Array of Byte);
var n, m: Integer; P: Pointer;
begin
  P := FMap;
  //For n := 0 To FTileCount - 1 do
  For m := High(FLayers) downto 0  do
  begin
    For n := High(FLayers[m].lPtr) downTo 0 do
    begin
      With TMapType1(FLayers[m].lPtr[n]^) do
      begin
        If ((mAnim = -1) and ($FF in Anim)) or ((mAnim in Anim) and (mFrame = Frames[mAnim])) Then
          DrawTile(mX, mY, (mTex and $F), mTX{ and $7F}, mTY, ((mPal SHR 6) and $F) + 8, mBlend, not Boolean(mTex SHR 7));
      end;
    //Inc(DWord(P), 16);
    end;
  end;
end;

procedure TFF8MIM.DrawMap(Anim: Integer = -1; Frame: Integer = 0; BG: Boolean = True);
var F: Array of Byte;
begin
  FImage.Canvas.Brush.Color := 0;
  FImage.Canvas.FillRect(FImage.Canvas.ClipRect);
  If BG or (Anim = -1) Then
    DrawTiles([Byte(-1)], [0]);
  If Anim >= 0 Then
  begin
    SetLength(F, Anim + 1);
    F[Anim] := Frame;
  end;
  If Anim <> -1 Then
    DrawTiles([Anim], F);
end;

function TFF8MIM.FrameCount(Index: Integer): Integer;
begin
  Result := FFrameCount[Index];
end;

procedure TFF8MIM.DrawMap(const Anim: TByteSet; const Frames: array of Byte);
begin
  FImage.Canvas.Brush.Color := 0;
  FImage.Canvas.FillRect(FImage.Canvas.ClipRect);
  DrawTiles(Anim, Frames);
end;

procedure TFF8MIM.SortLayers;
var
    i : Integer;
    j , n: Integer;
    Tmp : TLayer;
begin
  i := 0;
  N := Length(FLayers);
  while i <= N - 1 do
  begin
    j := 0;
    while j <= N - 2 - i do
    begin
      if FLayers[j].lZ > FLayers[j+1].lZ then
      begin
        //Move(FLayers[j], Tmp, 8);
        //Move(FLayers[j+1], FLayers[j], 8);
        //Move(Tmp, FLayers[j+1], 8);
        Tmp := FLayers[j];
        FLayers[j] := FLayers[j+1];
        FLayers[j+1] := Tmp;
      end;
    Inc(j);
    end;
  Inc(i);
  end;
end;

end.
