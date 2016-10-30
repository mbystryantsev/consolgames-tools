unit TilesUnit;

interface

uses SysUtils, Classes, NodeLst, HexUnit, MyClasses;

type
 TTile2bit = Array[0..7, 0..1] of Byte;
 TTile2bit_NES = Array[0..1, 0..7] of Byte;
 TTile4bit = Array[0..7, 0..3] of Byte;
 TTile8bit = Array[0..7, 0..7] of Byte;

 TCustomTile = class(TStreamedNode)
  private
    FTileIndex: Integer;
    FFirstColor: Byte;
  protected
    function GetTileSize: Integer; virtual;
    function GetTileData: Pointer; virtual;
    function GetWidth: Integer; virtual;
    function GetHeight: Integer; virtual;
    procedure Initialize; override;
  public
    property TileIndex: Integer read FTileIndex write FTileIndex;
    property TileSize: Integer read GetTileSize;
    property TileData: Pointer read GetTileData;
    property FirstColor: Byte read FFirstColor write FFirstColor;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;

    procedure Flip(X, Y: Boolean; var Dest); virtual; abstract;
    procedure BufDraw(const Dest; RowStride: Integer;
           XFlip: Boolean = False; YFlip: Boolean = False); virtual;
    procedure BufLoad(const Source; RowStride: Integer); virtual;

    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure Assign(Source: TNode); override;
 end;

 TTileItems = array of TCustomTile;
 TTileClass = class of TCustomTile;

 TTile2BPP_NES = class(TCustomTile)
  private
    FData: TTile2bit_NES;
  protected
    function GetTileSize: Integer; override;
    function GetTileData: Pointer; override;
  public
    property Data: TTile2bit_NES read FData write FData;
    procedure Flip(X, Y: Boolean; var Dest); override;
    procedure BufDraw(const Dest; RowStride: Integer;
           XFlip: Boolean = False; YFlip: Boolean = False); override;
    procedure BufLoad(const Source; RowStride: Integer); override;
 end;

 TTile4BPP = class(TCustomTile)
  private
    FData: TTile4bit;
  protected
    function GetTileSize: Integer; override;
    function GetTileData: Pointer; override;
  public
    property Data: TTile4bit read FData write FData;
    procedure Flip(X, Y: Boolean; var Dest); override;
    procedure BufDraw(const Dest; RowStride: Integer;
           XFlip: Boolean = False; YFlip: Boolean = False); override;
    procedure BufLoad(const Source; RowStride: Integer); override;
 end;

 TTile4BPP_MSX = class(TTile4BPP)
  public
    procedure Flip(X, Y: Boolean; var Dest); override;
    procedure BufDraw(const Dest; RowStride: Integer;
           XFlip: Boolean = False; YFlip: Boolean = False); override;
    procedure BufLoad(const Source; RowStride: Integer); override;
 end;

 TTile8BPP = class(TCustomTile)
  private
    FData: TTile8bit;
  protected
    function GetTileSize: Integer; override;
    function GetTileData: Pointer; override;
  public
    property Data: TTile8bit read FData write FData;
    procedure Flip(X, Y: Boolean; var Dest); override;
    procedure BufDraw(const Dest; RowStride: Integer;
           XFlip: Boolean = False; YFlip: Boolean = False); override;
    procedure BufLoad(const Source; RowStride: Integer); override;
 end;

 PEmptyBlock = ^TEmptyBlock;
 TEmptyBlock = packed record
  ebStart: Integer;
  ebEnd: Integer;
 end;

 TEmptyBlocks = array of TEmptyBlock;

 TTileList = class(TStreamedList)
  private
    FOptimization: Boolean;
    FLastIndex: Integer;
    FMaxIndex: Integer;
    FEmptyBlocks: TEmptyBlocks;
    FCurrentBlock: PEmptyBlock;
    FEmptyTile: TCustomTile;
    FFastTiles: TTileItems;
    FTileSize,
    FTileWidth,
    FTileHeight: Integer;
    FTileClassAssign: Boolean;
    function GetTileItem(Index: Integer): TCustomTile;
    function GetTilesCount: Integer;
  protected
    procedure Initialize; override;
    procedure ClearData; override;
    procedure SetNodeClass(Value: TNodeClass); override;
    procedure AssignAdd(Source: TNode); override;
    procedure AssignNodeClass(Source: TNodeList); override;
  public
    property Optimization: Boolean read FOptimization write FOptimization;
    property EmptyBlocks: TEmptyBlocks read FEmptyBLocks write FEmptyBLocks;
    property TileSize: Integer read FTileSize;
    property TileWidth: Integer read FTileWidth;
    property TileHeight: Integer read FTileHeight;
    property Tiles[Index: Integer]: TCustomTile read GetTileItem;
    property FastTiles: TTileItems read FFastTiles;
    property TilesCount: Integer read GetTilesCount;
    property TileClassAssign: Boolean read FTileClassAssign
                                     write FTileClassAssign;

    function AddFixed(Index: Integer): TCustomTile;
    function AddOrGet(const Source; var XFlip, YFlip: Boolean): TCustomTile;
    constructor Create; overload;
    constructor Create(TileClass: TTileClass; Optimization: Boolean); overload;
    procedure ResetEmptyBlock;
    procedure AddEmptyBlock(StartIndex, EndIndex: Integer);
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure AppendFromStream(const Stream: TStream; Count: Integer);
    procedure MakeArray;
    destructor Destroy; override;
    procedure Assign(Source: TNode); override;
    function FindEmptyIndex(Value: Integer): Integer;
    procedure DeleteEmptyBlock(Index: Integer);
    procedure SetEmptyBlocksLen(Len: Integer);
 end;

 ETileListError = class(Exception);

const
 MSX_Shifts: array[0..7] of Byte =
 (1 shl 2, 0 shl 2, 3 shl 2, 2 shl 2,
  5 shl 2, 4 shl 2, 7 shl 2, 6 shl 2);

implementation

(* TCustomTile *)

procedure TCustomTile.Assign(Source: TNode);
var
 Tile: Pointer;
 W, H, X: Integer;
begin
 inherited;
 W := Width;
 H := Height;
 with TCustomTile(Source) do
 begin
  Self.FFirstColor := FFirstColor;
  X := Width;
  if W < X then W := X;
  X := Height;
  if H < X then H := X;
  GetMem(Tile, W * H);
  BufDraw(Tile^, W);
  X := FTileIndex;
 end;
 FTileIndex := X;
 BufLoad(Tile^, W);
 FreeMem(Tile);
end;

procedure TCustomTile.BufDraw(const Dest; RowStride: Integer;
           XFlip: Boolean = False; YFlip: Boolean = False);
begin
//do nothing
end;

procedure TCustomTile.BufLoad(const Source; RowStride: Integer);
begin
//do nothing
end;

function TCustomTile.GetHeight: Integer;
begin
 Result := 8;
end;

function TCustomTile.GetTileData: Pointer;
begin
 Result := NIL;
end;

function TCustomTile.GetTileSize: Integer;
begin
 Result := 0;
end;

function TCustomTile.GetWidth: Integer;
begin
 Result := 8;
end;

procedure TCustomTile.Initialize;
begin
 FAssignableClass := TCustomTile;
end;

procedure TCustomTile.LoadFromStream(Stream: TStream);
begin
 Stream.Read(TileData^, TileSize);
end;

procedure TCustomTile.SaveToStream(Stream: TStream);
begin
 Stream.Write(TileData^, TileSize);
end;

(* TTile2BPP_NES *)

procedure TTile2BPP_NES.BufDraw(const Dest; RowStride: Integer;
      XFlip, YFlip: Boolean);
var
 XX, YY: Integer;
 Src1, Src2: Byte;
 Dst, P: PByte;
begin
 Dst := @Dest;
 if not XFlip then Inc(Dst, 7);
 for YY := 0 to 7 do
 begin
  P := Dst;
  if YFlip then
  begin
   Src1 := FData[0, 7 - YY];
   Src2 := FData[1, 7 - YY];
  end else
  begin
   Src1 := FData[0, YY];
   Src2 := FData[1, YY];
  end;
  if not XFlip then for XX := 0 to 7 do
  begin
   P^ := FFirstColor + ((Src1 and 1) or ((Src2 and 1) shl 1));
   Src1 := Src1 shr 1;
   Src2 := Src2 shr 1;
   Dec(P);
  end else for XX := 0 to 7 do
  begin
   P^ := FFirstColor + ((Src1 and 1) or ((Src2 and 1) shl 1));
   Src1 := Src1 shr 1;
   Src2 := Src2 shr 1;
   Inc(P);
  end;
  Inc(Dst, RowStride);
 end;
end;

procedure TTile2BPP_NES.BufLoad(const Source; RowStride: Integer);
var
 XX, YY: Integer;
 Clr: Byte;
 Dst1, Dst2: PByte;
 Src, P: PByte;
begin
 Src := @Source;
 Dst1 := Addr(FData[0, 0]);
 Dst2 := Addr(FData[1, 0]);
 for YY := 0 to 7 do
 begin
  P := Src;
  Dst1^ := 0;
  Dst2^ := 0;
  for XX := 7 downto 0 do
  begin
   Clr := P^ - FFirstColor;
   Dst1^ := Dst1^ or ((Clr and 1) shl XX);
   Dst2^ := Dst2^ or (((Clr shr 1) and 1) shl XX);
   Inc(P);
  end;
  Inc(Dst1);
  Inc(Dst2);
  Inc(Src, RowStride);
 end;
end;

procedure TTile2BPP_NES.Flip(X, Y: Boolean; var Dest);
var
 Tile: TTile2bit_NES absolute Dest;
 XX, YY, I: Integer;
 Src, Dst: Byte;
begin
 if X then
 begin
  for YY := 0 to 7 do
  begin
   for I := 0 to 1 do
   begin
    Src := FData[I, YY];
    Dst := 0;
    for XX := 0 to 7 do
    begin
     Dst := Dst or ((Src and 1) shl XX);
     Src := Src shr 1;
    end;
    if Y then
     Tile[I, 7 - YY] := Dst else
     Tile[I, YY] := Dst;
   end;
  end;
 end else if Y then
 begin
  for YY := 0 to 7 do
  begin
   PWord(Addr(Tile[0, YY]))^ :=
   PWord(Addr(FData[0, 7 - YY]))^;
  end;
 end;
end;

function TTile2BPP_NES.GetTileData: Pointer;
begin
 Result := @FData;
end;

function TTile2BPP_NES.GetTileSize: Integer;
begin
 Result := SizeOf(TTile2bit_NES);
end;

(* TTile4BPP *)

procedure TTile4BPP.BufDraw(const Dest; RowStride: Integer;
      XFlip, YFlip: Boolean);
var
 XX, YY: Integer;
 Src: Cardinal;
 Dst, P: PByte;
begin
 Dst := @Dest;
 if XFlip then Inc(Dst, 7);
 for YY := 0 to 7 do
 begin
  P := Dst;
  if YFlip then
   Src := PCardinal(Addr(FData[7 - YY, 0]))^ else
   Src := PCardinal(Addr(FData[YY, 0]))^;
  if XFlip then for XX := 0 to 7 do
  begin
   P^ := FFirstColor + (Src and 15);
   Src := Src shr 4;
   Dec(P);
  end else for XX := 0 to 7 do
  begin
   P^ := FFirstColor + (Src and 15);
   Src := Src shr 4;
   Inc(P);
  end;
  Inc(Dst, RowStride);
 end;
end;

procedure TTile4BPP.BufLoad(const Source; RowStride: Integer);
var
 XX, YY: Integer;
 Dst: PCardinal;
 Src, P: PByte;
begin
 Src := @Source;
 Dst := Addr(FData[0, 0]);
 for YY := 0 to 7 do
 begin
  P := Src;
  Dst^ := 0;
  for XX := 0 to 7 do
  begin
   Dst^ := Dst^ or ((Byte(P^ - FFirstColor) and 15) shl (XX shl 2));
   Inc(P);
  end;
  Inc(Dst);
  Inc(Src, RowStride);
 end;
end;

procedure TTile4BPP.Flip(X, Y: Boolean; var Dest);
var
 Tile: TTile4bit absolute Dest;
 XX, YY: Integer;
 Src, Dst: Cardinal;
begin
 if X then
 begin
  for YY := 0 to 7 do
  begin
   Src := PCardinal(Addr(FData[YY, 0]))^;
   Dst := 0;
   XX := 7 shl 2;
   while XX >= 0 do
   begin
    Dst := Dst or ((Src and 15) shl XX);
    Src := Src shr 4;
    Dec(XX, 4);
   end;
   if Y then
    PCardinal(Addr(Tile[7 - YY, 0]))^ := Dst else
    PCardinal(Addr(Tile[YY, 0]))^ := Dst;
  end;
 end else if Y then
 begin
  for YY := 0 to 7 do
  begin
   PCardinal(Addr(Tile[YY, 0]))^ :=
   PCardinal(Addr(FData[7 - YY, 0]))^;
  end;
 end;
end;

function TTile4BPP.GetTileData: Pointer;
begin
 Result := @FData;
end;

function TTile4BPP.GetTileSize: Integer;
begin
 Result := SizeOf(TTile4bit);
end;

(* TTile4BPP_MSX *)

procedure TTile4BPP_MSX.BufDraw(const Dest; RowStride: Integer;
      XFlip, YFlip: Boolean);
var
 XX, YY: Integer;
 Src: Cardinal;
 Dst, P: PByte;
begin
 Dst := @Dest;
 if XFlip then
  Inc(Dst, 6) else
  Inc(Dst);
 for YY := 0 to 7 do
 begin
  P := Dst;
  if YFlip then
   Src := PCardinal(Addr(FData[7 - YY, 0]))^ else
   Src := PCardinal(Addr(FData[YY, 0]))^;
  if XFlip then for XX := 0 to 3 do
  begin
   P^ := FFirstColor + (Src and 15);
   Src := Src shr 4;
   Inc(P);
   P^ := FFirstColor + (Src and 15);
   Src := Src shr 4;
   Dec(P, 3);
  end else for XX := 0 to 3 do
  begin
   P^ := FFirstColor + (Src and 15);
   Src := Src shr 4;
   Dec(P);
   P^ := FFirstColor + (Src and 15);
   Src := Src shr 4;
   Inc(P, 3);
  end;
  Inc(Dst, RowStride);
 end;
end;

procedure TTile4BPP_MSX.BufLoad(const Source; RowStride: Integer);
var
 XX, YY: Integer;
 Dst: PCardinal;
 Src, P: PByte;
begin
 Src := @Source;
 Dst := Addr(FData[0, 0]);
 for YY := 0 to 7 do
 begin
  P := Src;
  Dst^ := 0;
  for XX := 0 to 7 do
  begin
   Dst^ := Dst^ or ((Byte(P^ - FFirstColor) and 15) shl MSX_Shifts[XX]);
   Inc(P);
  end;
  Inc(Dst);
  Inc(Src, RowStride);
 end;
end;

procedure TTile4BPP_MSX.Flip(X, Y: Boolean; var Dest);
var
 Tile: TTile4bit absolute Dest;
 XX, YY: Integer;
 Src, Dst: Cardinal;
begin
 if X then
 begin
  for YY := 0 to 7 do
  begin
   Src := PCardinal(Addr(FData[YY, 0]))^;
   Dst := 0;
   for XX := 7 downto 0 do
   begin
    Dst := Dst or ((Src and 15) shl MSX_Shifts[XX]);
    Src := Src shr 4;
   end;
   if Y then
    PCardinal(Addr(Tile[7 - YY, 0]))^ := Dst else
    PCardinal(Addr(Tile[YY, 0]))^ := Dst;
  end;
 end else if Y then
 begin
  for YY := 0 to 7 do
  begin
   PCardinal(Addr(Tile[YY, 0]))^ :=
   PCardinal(Addr(FData[7 - YY, 0]))^;
  end;
 end;
end;

(* TTile8BPP *)

procedure TTile8BPP.BufDraw(const Dest; RowStride: Integer;
      XFlip, YFlip: Boolean);
var
 XX, YY: Integer;
 Dst, P, Src: PByte;
 Src64: PInt64 absolute Src;
 Dst64: PInt64 absolute Dst;
begin
 Dst := @Dest;
 if XFlip then Inc(Dst, 7);
 for YY := 0 to 7 do
 begin
  if YFlip then
   Src := Addr(FData[7 - YY, 0]) else
   Src := Addr(FData[YY, 0]);
  if XFlip then
  begin
   P := Dst;
   for XX := 0 to 7 do
   begin
    P^ := Src^;
    Inc(Src);
    Dec(P);
   end;
  end else Dst64^ := Src64^;
  Inc(Dst, RowStride);
 end;
end;

procedure TTile8BPP.BufLoad(const Source; RowStride: Integer);
var
 YY: Integer;
 Dst: PInt64;
 Src: PByte;
 Src64: PInt64 absolute Src;
begin
 Src := @Source;
 Dst := Addr(FData[0, 0]); 
 for YY := 0 to 7 do
 begin
  Dst^ := Src64^;
  Inc(Dst);
  Inc(Src, RowStride);
 end;
end;

procedure TTile8BPP.Flip(X, Y: Boolean; var Dest);
var
 Tile: TTile8bit absolute Dest;
 YY: Integer;
 Src: Int64;
begin
 if X then
 begin
  for YY := 0 to 7 do
  begin
   Src := SwapInt64(PInt64(Addr(FData[YY, 0]))^);
   if Y then
    PInt64(Addr(Tile[7 - YY, 0]))^ := Src else
    PInt64(Addr(Tile[YY, 0]))^ := Src;
  end;
 end else if Y then
 begin
  for YY := 0 to 7 do
  begin
   PInt64(Addr(Tile[YY, 0]))^ :=
   PInt64(Addr(FData[7 - YY, 0]))^;
  end;
 end;
end;

function TTile8BPP.GetTileData: Pointer;
begin
 Result := @FData;
end;

function TTile8BPP.GetTileSize: Integer;
begin
 Result := SizeOf(TTile8bit);
end;

(* TTileList *)

procedure TTileList.AddEmptyBlock(StartIndex, EndIndex: Integer);
var
 L: Integer;
begin
 L := Length(FEmptyBlocks);
 SetLength(FEmptyBlocks, L + 1);
 with FEmptyBlocks[L] do
 begin
  ebStart := StartIndex;
  ebEnd := EndIndex;
 end;
 ResetEmptyBlock;
end;

function TTileList.AddFixed(Index: Integer): TCustomTile;
begin
 Result := Tiles[Index];
 if Result = NIL then
 begin
  Result := AddNode as TCustomTile;
  Result.FTileIndex := Index;
  if FMaxIndex < Index then FMaxIndex := Index;
 end;
end;

function TTileList.AddOrGet(const Source; var XFlip,YFlip: Boolean): TCustomTile;
var
 Buf: Pointer;
 SZ: Integer;
 Link: TNode;
begin
 Buf := NIL;
 Link := RootNode;
 while Link <> NIL do
 begin
  Result := Link as TCustomTile;
  with Result do
  begin
   SZ := TileSize;
   if CompareMem(@Source, TileData, SZ) then
   begin
    XFlip := False;
    YFlip := False;
    Exit;
   end;
   if FOptimization then
   begin
    ReallocMem(Buf, SZ);
    Flip(False, True, Buf^);
    if CompareMem(@Source, Buf, SZ) then
    begin
     XFlip := False;
     YFlip := True;
     Exit;
    end;
    Flip(True, False, Buf^);
    if CompareMem(@Source, Buf, SZ) then
    begin
     XFlip := True;
     YFlip := False;
     Exit;
    end;
    Flip(True, True, Buf^);
    if CompareMem(@Source, Buf, SZ) then
    begin
     XFlip := True;
     YFlip := True;
     Exit;
    end;
   end;
  end;
  Link := Link.Next;
 end;
 Result := AddNode as TCustomTile;
 Move(Source, Result.TileData^, FEmptyTile.TileSize);
 XFlip := False;
 YFlip := False;
 if FCurrentBlock = NIL then with Result do
 begin
  FTileIndex := Count - 1;
  if FMaxIndex < FTileIndex then FMaxIndex := FTileIndex;
 end else
 with FCurrentBlock^ do
 begin
  if FLastIndex < ebStart then FLastIndex := ebStart else
  if FLastIndex > ebEnd then
  begin
   Inc(FCurrentBlock);
   if Cardinal(FCurrentBlock) <=
      Cardinal(Addr(FEmptyBlocks[Length(FEmptyBlocks) - 1])) then
    FLastIndex := FCurrentBlock.ebStart else
   begin
    FLastIndex := Count - 1;
    FCurrentBlock := NIL;
   end;
  end;
  Result.FTileIndex := FLastIndex;
  if FMaxIndex < FLastIndex then FMaxIndex := FLastIndex;
  Inc(FLastIndex);
 end;
end;

procedure TTileList.AppendFromStream(const Stream: TStream; Count: Integer);
var
 I: Integer;
begin
 for I := 0 to Count - 1 do with AddNode as TCustomTile do
 begin
  Inc(FMaxIndex);
  FTileIndex := FMaxIndex;
  LoadFromStream(Stream);
 end;
end;

procedure TTileList.Assign(Source: TNode);
var
 Src: TTileList absolute Source;
 I: Integer;
 Block: PEmptyBlock;
begin
 if (Source <> NIL) and (Source is TTileList) then
 begin
  SetLength(FEmptyBlocks, Length(Src.FEmptyBlocks));
  Move(Src.FEmptyBlocks[0], FEmptyBlocks[0],
       Length(FEmptyBlocks) * SizeOf(TEmptyBlock));
  inherited;
  FOptimization := Src.FOptimization;
  FLastIndex := Src.FLastIndex;
  FMaxIndex := Src.FMaxIndex;
  Block := Pointer(FEmptyBlocks);
  with Src do if FCurrentBlock <> NIL then
  begin
   for I := 0 to Length(FEmptyBlocks) - 1 do
   begin
    if CompareMem(FCurrentBlock, Block, SizeOf(TEmptyBlock)) then
    with Self do
    begin
     FCurrentBlock := Block;
     Break;
    end;
    Inc(Block);
   end;
  end else Self.FCurrentBlock := NIL;
  MakeArray;
 end else AssignError(Source);
end;

procedure TTileList.AssignAdd(Source: TNode);
begin
 if FindEmptyIndex((Source as TCustomTile).FTileIndex) < 0 then
  AddNode.Assign(Source);
end;

procedure TTileList.AssignNodeClass(Source: TNodeList);
begin
 if FTileClassAssign then
  inherited;
end;

procedure TTileList.ClearData;
begin
 FLastIndex := -1;
 FMaxIndex := -1;
 FCurrentBlock := Pointer(FEmptyBlocks);
 Finalize(FFastTiles);
end;

constructor TTileList.Create;
begin
 inherited Create;
 NodeClass := TCustomTile;
 FTileClassAssign := True;
end;

constructor TTileList.Create(TileClass: TTileClass; Optimization: Boolean);
begin
 inherited Create;
 NodeClass := TileClass;
 FOptimization := Optimization;
 FTileClassAssign := True;
end;

procedure TTileList.DeleteEmptyBlock(Index: Integer);
var L: Integer;
begin
 if Index >= 0 then
 begin
  L := Length(FEmptyBlocks);
  if Index = L - 1 then SetLength(FEmptyBlocks, L - 1) else
  if Index < L - 1 then
  begin
   Move(FEmptyBlocks[Index + 1], FEmptyBlocks[Index],
      ((L - Index) - 1) * SizeOf(TEmptyBlock));
   SetLength(FEmptyBlocks, L - 1);
  end else Exit;
  ResetEmptyBlock;
 end;
end;

destructor TTileList.Destroy;
begin
 FEmptyTile.Free;
 inherited;
end;

function TTileList.FindEmptyIndex(Value: Integer): Integer;
var I: Integer;
begin
 for I := 0 to Length(FEmptyBlocks) - 1 do with FEmptyBlocks[I] do
 if (Value >= ebStart) and (Value <= ebEnd) then
 begin
  Result := I;
  Exit;
 end;
 Result := -1;
end;

function TTileList.GetTileItem(Index: Integer): TCustomTile;
var Link: ^TCustomTile; I: Integer;
begin
 Link := RootLink;
 for I := 0 to Count - 1 do
 begin
  Result := Link^;
  if Index = Result.FTileIndex then Exit;
  Inc(Link);
 end;
 Result := NIL;
end;

function TTileList.GetTilesCount: Integer;
begin
 Result := Length(FFastTiles);
end;

procedure TTileList.Initialize;
begin
 NodeClass := TCustomTile;
 FAssignableClass := TTileList;
 FMaxIndex := -1;
end;

procedure TTileList.LoadFromStream(Stream: TStream);
begin
 Clear;
 AppendFromStream(Stream, Stream.Size div FTileSize);
 MakeArray;
end;

procedure TTileList.MakeArray;
var
 Tile: TCustomTile; I: Integer;
begin
 SetLength(FFastTiles, FMaxIndex + 1);
 for I := 0 to FMaxIndex do
 begin
  Tile := Tiles[I];
  if Tile = NIL then
   FFastTiles[I] := FEmptyTile else
   FFastTiles[I] := Tile;
 end;
end;

procedure TTileList.ResetEmptyBlock;
begin
 FLastIndex := -1;
 FCurrentBlock := Pointer(FEmptyBlocks);
end;

procedure TTileList.SaveToStream(Stream: TStream);
var
 Tile: TCustomTile; I: Integer;
begin
 for I := 0 to FMaxIndex do
 begin
  Tile := Tiles[I];
  if Tile = NIL then
  begin
   Tile := FEmptyTile;
   Tile.FTileIndex := I;
  end;
  Tile.SaveToStream(Stream);
 end;
end;

procedure TTileList.SetEmptyBlocksLen(Len: Integer);
begin
 SetLength(FEmptyBlocks, Len);
 ResetEmptyBlock;
end;

procedure TTileList.SetNodeClass(Value: TNodeClass);
begin
 FEmptyTile.Free;
 FEmptyTile := TCustomTile(Value.Create);
 FTileSize := FEmptyTile.TileSize;
 FTileWidth := FEmptyTile.Width;
 FTileHeight := FEmptyTile.Height;
 inherited;
end;

end.
