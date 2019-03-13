unit CMIUnit;

interface


uses
  Windows, DIB_classic, Types,Controls, SysUtils, PSPRAW, Dialogs;

// TCMIGfx: 256x256
// TCMIImg: 1980x1088 = 8416 DWords = 21058 bytes 
{$DEFINE ALL_LAYERS}

Type
  TPackingMethod = (pmAbstract, pmGrid, pmColumns, pmRows, pmColRow, pmSquare);
  TCMITile = Array[0..255] of Byte;
  TA0 = Array[0..8160-1] of TCMITile;
  TA1 = Array[0..2040-1] of TCMITile;
  TAT = Array[0..511,0..511] of Byte;
  TF0 = Array[0..8160-1] of Boolean;
  TF1 = Array[0..2040-1] of Boolean;
  TMask = Array[0..511,0..511] of Boolean;

  TCMIHeader = Packed Record
    Sign: Array[0..3] of byte;
    Width:    DWord;
    Height:   DWord;
    Size:     DWord;
    L0Count:  DWord;
    L1Count:  DWord;
    BGSize:   DWord;
    TilesWH:  DWord;
  end;
  TCMIPal = Array[0..15] of DWord;
  TCMIBG = Array[0..63,0..127] of Byte;
  TCMILayer0 = Array[0..$2000-1] of DWord;
  TCMILayer1 = Array[0..$800-1] of DWord;
  TCMITiles = Array[0..255,0..511] of Byte;
  TOptimizeProgress = Procedure(Count,ID,LimX,LimY,T0,T1: Integer);
  TCMI = Class
    Constructor Create;
  private
    FOptimized: Boolean;
    FOpened:    Boolean;
    LimX,LimY: Integer;
    Mask: TMask;
    Function FindBestPlace(ID,Layer: Integer; var bX,bY,bT: Integer): Boolean;
    Function CompareTile(ID,TX,TY,Layer: Integer; var TCount: Integer): Boolean;
  public
    Head: TCMIHeader;
    Pal: Array[0..2] of TCMIPal;
    BG: TCMIBG;
    Layer0: TCMILayer0;
    Layer1: TCMILayer1;
    Tiles:  TCMITiles;
    T: TAT;
    L0: TA0;
    L1: TA1;
    F0: TF0;
    F1: TF1;
    vLevel0,vLevel1: Integer;
    Col: Boolean;
    Row: Boolean;
    ColRow: Boolean;
    Sqr: Boolean;
    crXY: Integer;
    sqLimX,sqLimY: Integer;
    sqAngle: Integer;

    OptimizeProgress: TOptimizeProgress;
    Procedure TilesToDib(var Pic: TDIB);
    Procedure DibToTiles(var Pic: TDIB);
    Procedure TilesToRaw(var dest);
    Procedure DibToLayer(Pic: TDIB; Layer: Pointer);
    Procedure LayerToDib(Pic: TDIB; Layer: Pointer);
    Procedure AssignLayer(var Pic: TDIB; W,H: Integer; Bpp: Integer = 4);
    Procedure PlugTile(ID,TX,TY,Layer: Integer);
    Procedure GetLayer0(var Pic: TDIB; Tiles: TDIB);
    Procedure GetLayer1(var Pic: TDIB; Tiles: TDIB);
    Procedure GetLayers(var pBG,pTiles,pLayer0,pLayer1: TDIB);
    Procedure LoadFromFile(FileName: String);
    Function  SaveToFile(FName: String): Boolean;
    Procedure BuildMap(var Pic: TDIB; pLayer0,pLayer1,pBG: TDIB);
    Procedure Optimize(pLayer0,pLayer1: TDIB; Method: TPackingMethod = pmAbstract; Level0: Integer = 8160; Level1: Integer = 2040);
    Property  Optimized: Boolean read FOptimized write FOptimized;
    Property  Opened: Boolean read FOpened;
  end;

//Function FindNextBlock({Mask: TMask; L0: TA0; Tiles: TAT;} X,Y: Integer): Integer;
//Procedure DibToAr(var Pic: TDIB; pBD: Pointer);
//Procedure ArToDib(var Pic: TDIB; pBD: Pointer);

//Procedure ArToDibL0(var Pic: TDIB; L: TA0);
//Procedure DibToArL0(var Pic: TDIB; L: TA0);

var   bCancel: Boolean = False;

implementation



uses PrForm;    
const cNoSpaceMessage = 'No enough space!';
var     sqYes,sqYYY:  Boolean;

Constructor TCMI.Create;
begin
  FOptimized := False;
  FOpened    := False;
end;

Type
  TTileOptData = Record
    X,Y,B: Integer;
    F: Boolean;
  end;

var ZeroTile: Array[0..3] of DWord = (0,0,0,0);
newX: Integer = -1; newY: Integer = -1;
ODL0: Array[0..8160-1] of TTileOptData;
ODL1: Array[0..2040-1] of TTileOptData;


  Procedure TCMI.DibToLayer(Pic: TDIB; Layer: Pointer);
  var n,m,l,r: Integer; B: ^Byte; Tile: ^TCMITile;
  begin
    Tile:=Layer;
    For m:=0 To (Pic.Height div 16)-1 do
      For n:=0 To (Pic.Width div 16)-1 do
      begin
        For l:=0 To 15 do
        begin
          B:=Pic.ScanLine[m*16+l];
          Inc(B,n*8);
          For r:=0 To 7 do
          begin
            Tile^[l*16+r*2+1]:=B^ and $F;
            Tile^[l*16+r*2]:=B^ SHR 4;
            Inc(B);
          end;
        end;
      Inc(Tile);
      end;
  end;

  Procedure TCMI.LayerToDib(Pic: TDIB; Layer: Pointer);
  var n,m,l,r: Integer; B: ^Byte; Tile: ^TCMITile;
  begin
    Tile:=Layer;
    For m:=0 To (Pic.Height div 16)-1 do
      For n:=0 To (Pic.Width div 16)-1 do
      begin
        For l:=0 To 15 do
        begin
          B:=Pic.ScanLine[m*16+l];
          Inc(B,n*8);
          For r:=0 To 7 do
          begin
            B^:=Tile^[l*16+r*2+1] and $F;
            B^:=B^ or Tile^[l*16+r*2] SHL 4;
            Inc(B);
          end;
        end;
      Inc(Tile);
    end;
  end;

  Procedure TCMI.TilesToDib(var Pic: TDIB);
  var n,m: Integer; WB,B: ^Byte;
  begin
    WB:=@T;
    For m:=0 To 511 do
    begin
      B:=Pic.ScanLine[m];
      For n:=0 To (512 div 2)-1 do
      begin
        B^:=(WB^ SHL 4); Inc(WB);
        B^:=B^ or (WB^ and $F); Inc(WB);
        Inc(B);
      end;
    end;
  end;

  Procedure TCMI.DibToTiles(var Pic: TDIB);
  var n,m: Integer; WB,B: ^Byte;
  begin
    WB:=@T;
    For m:=0 To 511 do
    begin
      B:=Pic.ScanLine[m];
      For n:=0 To (512 div 2)-1 do
      begin                
        WB^:=B^ and $F; Inc(WB);
        WB^:=B^ SHR 4; Inc(WB);
        Inc(B);
      end;
    end;
  end;

  Procedure TCMI.TilesToRaw(var dest);
  var Pic: TDIB;
  begin
    AssignLayer(Pic,512,512);
    TilesToDib(Pic);
    SetPal(Pic,Pal[1]);
    DibToRaw(Pic,@dest);
    Pic.Free;
  end;

  Procedure TCMI.PlugTile(ID,TX,TY,Layer: Integer);
  var n,m: Integer; B: ^Byte; //Tile: ^TCMITile;
  begin
    Case Layer of
      0: B:=@L0[ID];
      1: B:=@L1[ID];
    end;
    For m:=TY To TY+15 do
    For n:=TX To TX+15 do
    begin
      T[m,n]:=B^;
      Mask[m,n]:=True;
      Inc(B);
    end;
    If not (Col or ColRow) and (LimX-TX<32) Then LimX:=TX+32; // LimX<TX+16 Then LimX:=TX+32;
    If not (Row or ColRow) and (LimY-TY<32) Then LimY:=TY+32; // LimY<TY+16 Then LimY:=TY+32;
    If ColRow Then
    begin
      If (not sqYes) and (TX+32>LimX) Then LimX:=TX+32;
      If (not sqYes) and (TY+32>LimY) Then LimY:=TY+32;
      If Sqr Then
      begin
        If sqYes Then
        begin
          If TX-16<sqLimX Then sqLimX:=TX-16;
          If TY-16<sqLimY Then sqLimY:=TY-16;
          If sqLimX<0 Then sqLimX:=0;
          If sqLimY<0 Then sqLimY:=0;
        end;
      end;
    end;

    If LimX>=512 Then LimX:=511;
    If LimY>=512 Then LimY:=511;
    Case Layer of
      0: Layer0[ID]:=TY*512+TX;
      1: Layer1[ID]:=TY*512+TX;
    end;
    newX:=TX; newY:=TY;
    //sqYes:=False;
  end;

  Function TCMI.CompareTile(ID,TX,TY,Layer: Integer; var TCount: Integer): Boolean;
  var n,m: Integer; B,PT: ^Byte; PM: ^Boolean;
  begin
    Result:=False;
    TCount:=0;
    Case Layer of
      0: B:=@L0[ID];
      1: B:=@L1[ID];
    end;
    PM:=@Mask[TY,TX];
    PT:=@T[TY,TX];
    For m:=0 To 15 do
    begin
      For n:=0 To 15 do
      begin
        If PM^ Then
        begin
          If PT^=B^ Then Inc(TCount) else Exit;
        end;
        Inc(B); Inc(PT);  Inc(PM);
      end;
      Inc(PM,512-16);
      Inc(PT,512-16);
    end;
    Result:=True;
  end;

  Procedure CheckOptData(P: Pointer);
  var OD: ^TTileOptData;
  begin
    OD:=P;
    If not OD^.F Then Exit;
    If ((OD^.X>newX-16) and (OD^.X<newX+32)) and ((OD^.Y>newY-16) and (OD^.Y<newY+32))
      Then OD^.F := False;
  end;


  Function TCMI.FindBestPlace(ID,Layer: Integer; var bX,bY,bT: Integer): Boolean;
  var n,m,cT,FromX,FromY,ToX,ToY: Integer; OptData: ^TTileOptData;  clRet: Integer;
  Label ColRowRet;
  begin
    Case Layer of
      0: OptData:=@ODL0[ID];
      1: OptData:=@ODL1[ID];
    end;
    Result:=False;
    cT:=-1;
    CheckOptData(OptData);
    If not (Col or Row or ColRow) and OptData^.F Then
    begin
      bX:=OptData^.X;
      bY:=OptData^.Y;
      bT:=OptData^.B;
      ToY:=newY+31;
      ToX:=newX+31;
      FromX:=newX-15;
      FromY:=newY-15;
      If FromX<0 Then FromX:=0;
      If FromY<0 Then FromY:=0;
      If FromX>512-15 Then FromX:=512-15;
      If FromY>512-15 Then FromY:=512-15;
      If ToX>512-15 Then ToX:=512-15;
      If ToY>512-15 Then ToY:=512-15;
    end else
    begin
      ToY:=LimY-15;
      ToX:=LimX-15;
      FromX:=0;
      FromY:=0;
      bT:=-1;
    end;
    If Col Then FromX:=ToX;
    If Row Then FromY:=ToY;
    clRet:=0;
    //sqYes:=False;
ColRowRet:
    If ColRow Then
    begin
      case clRet of
        0:
        begin
          FromX:=crXY;
          FromY:=crXY;
          ToX:=LimX-15;//512-15;
          ToY:=crXY;
        end;
        1:
        begin
          FromY:=crXY;
          FromX:=crXY;
          ToY:=LimY-15;//512-15;
          ToX:=crXY;
        end;
        2:
        begin
          FromX:=sqLimX;
          ToX:=512-crXY-16;
          FromY:=512-crXY-16;
          ToY:=512-crXY-16;
        end;
        3:
        begin
          FromX:=512-crXY-16;
          ToX:=512-crXY-16;
          FromY:=sqLimY;
          ToY:=512-crXY-16;
        end;
      end;
      If ToY>512-16 Then ToY:=512-16;
      If ToX>512-16 Then ToX:=512-16;
    end;
    For m:=FromY To ToY{LimY-15} do
    begin
      For n:=FromX To ToX{LimX-15} do
      begin
        If CompareTile(ID,n,m,Layer,cT) Then
        begin
          If bT<cT Then
          begin
            bT:=cT; bX:=n; bY:=m; sqYYY:=(clRet>=2);
            If bT=16*16 Then begin Result:=True; Exit; end;
          end;
        end;
      end;
    end;
    If (ColRow and (clRet=0)) or (Sqr and (clRet<3)) Then
    begin
      Inc(clRet);
      GoTo ColRowRet;
    end;
    OptData^.F := True;
    OptData^.X := bX;
    OptData^.Y := bY;
    OptData^.B := bT;
    Result:=bT>=0;
  end;


Function Check8XY(X,Y,bX,bY: Integer): Boolean;
begin
  {If bX=bX and 7 Then bX:=1 else bX:=0;
  If bY=bY and 7 Then bY:=1 else bY:=0;
  If X=X and 7 Then X:=1 else X:=0;
  If Y=Y and 7 Then Y:=1 else Y:=0;
  Result:=(X+Y>bX+bY);}
  Result := (X<bX) and (Y<bY);
end;

Procedure TCMI.Optimize(pLayer0,pLayer1: TDIB; Method: TPackingMethod = pmAbstract; Level0: Integer = 8160; Level1: Integer = 2040);
var n,m,l,r: Integer; EmptyTile: TCMITile; bL,Res,bRes,X,Y,bX,bY,Count,bID,AllMax: Integer;
L0ID,L1ID: Array of Integer; LCount,LC, LMax: Array[0..1] of Integer; CurIDNum: Integer; NoSpace: Boolean;
TempTile: ^TCMITile; lastLevel0,lastLevel1: Integer; GridNum: Integer; Grid: Boolean;
Label brk;

  Procedure Plug;
  var n: Integer;
  begin
    If (not Grid) and (bRes<0) Then
    begin
      If Col Then
      begin
        If LimX>=512-15 Then
        begin
          ShowMessage(cNoSpaceMessage);
          NoSpace:=True;
          Exit;
        end;
        Inc(LimX,16);
        LimY:=15;
        bX:=LimX-15;
        bY:=0;
        If bL=0 Then bID:=L0ID[0] else bID:=L1ID[0];
        CurIDNum:=0;
      end else
      If Row Then
      begin
        If LimY>=512-15 Then
        begin
          ShowMessage(cNoSpaceMessage);
          NoSpace:=True;
          Exit;
        end;
        Inc(LimY,16);
        LimX:=15;
        bY:=LimY-15;
        bX:=0;
        If bL=0 Then bID:=L0ID[0] else bID:=L1ID[0];
        CurIDNum:=0;
      end else
      If ColRow Then
      begin
        If (sqr and (crXY>=256-15)) or ((not Sqr) and (crXY>=512-15)) Then
        begin
          ShowMessage(cNoSpaceMessage);
          NoSpace:=True;
          Exit;
        end;
        sqAngle:=0;
        Inc(crXY,16);
        bY:=crXY;
        bX:=crXY;
        LimX:=crXY+16{+15};
        LimY:=LimX;
        If bL=0 Then bID:=L0ID[0] else bID:=L1ID[0];
        CurIDNum:=0;
        If Sqr Then
        begin
          sqLimX:=512-crXY-32;
          sqLimY:=sqLimX;
        end;
      end else
      begin
        ShowMessage(cNoSpaceMessage);
        NoSpace:=True;
        Exit;
      end;
    end;
    If Sqr and (sqAngle<2) Then
    begin
      If bL=0 Then bID:=L0ID[0] else bID:=L1ID[0];
      CurIDNum:=0;
      Case sqAngle of
        0:
        begin
          bX:=crXY;
          bY:=crXY;
          sqYes:=False;
        end;
        1:
        begin
          sqYes:=True;
          bX:=512-crXY-16;
          bY:=512-crXY-16;
        end;
      end;
      Inc(sqAngle);
    end;
    Inc(Count);
    Inc(LCount[bL]);
    PlugTile(bID,bX,bY,bL);
    Case bL of
      0:
      begin
        TempTile:=@L0[L0ID[CurIDNum]];
        F0[bID]:=True;
        L0ID[CurIDNum]:=L0ID[LMax[0]];
      end;
      1:
      begin
        TempTile:=@L1[L1ID[CurIDNum]];
        F1[bID]:=True;
        L1ID[CurIDNum]:=L1ID[LMax[1]];
      end;
    end;
    Dec(LMax[bL]);
    n:=0;
    While n<=LMax[0] do
    begin
      If CompareMem(TempTile,@L0[L0ID[n]],SizeOf(TCMITile)) Then
      begin
        Layer0[L0ID[n]]:=bY*512+bX;
        F0[L0ID[n]]:=True;
        L0ID[n]:=L0ID[LMax[0]];
        Dec(LMax[0]);
        Inc(Count);
        Inc(LCount[0]);
      end;
      Inc(n);
    end;
    n:=0;
    While n<=LMax[1] do
    begin
      If CompareMem(TempTile,@L1[L1ID[n]],SizeOf(TCMITile)) Then
      begin
        Layer1[L1ID[n]]:=bY*512+bX;
        F1[L1ID[n]]:=True;
        L1ID[n]:=L1ID[LMax[1]];
        Dec(LMax[1]);
        Inc(Count);
        Inc(LCount[1]);
      end;
      Inc(n);
    end;

    //Inc(LCount[bL]));
    OptimizeProgress(Count,bID,LimX,LimY,Length(F0)-LCount[0],Length(F1)-LCount[1]);
    Level0 := vLevel0;
    Level1 := vLevel1;
  end;

  Procedure GetGrid;
  begin
    If GridNum=32*32 Then
    begin
      ShowMessage(cNoSpaceMessage);
      NoSpace:=True;
      Exit;
    end;
    bY:=(GridNum div 32);
    bX:=(GridNum-bY*32)*16;
    bY:=bY*16;
    Inc(GridNum);
  end;

begin
  Grid    := (Method=pmGrid);
  Col     := (Method=pmColumns);
  Row     := (Method=pmRows);
  ColRow  := (Method=pmColRow) or (Method=pmSquare);
  Sqr     := (Method=pmSquare);
  crXY    := 0;
  GridNum := 0;
  sec     := 0;
  GetLocalTime(bTime);
  FillChar(LCount,SizeOf(LCount),0);
  FillChar(Layer0,SizeOf(Layer0),$FF);
  FillChar(Layer1,SizeOf(Layer1),$FF);
  vLevel0 := Level0;
  vLevel1 := Level1;
  bCancel := False;
  Count   :=0;
  NoSpace := False;
  FillChar(EmptyTile,256,0);
  //ShowMessage(Format('%d %d',[SizeOf(Mask),Length(Mask)]));
  FillChar(Mask,SizeOf(Mask),0);
  FillChar(F0,Length(F0),0);
  FillChar(F1,Length(F1),0);
  FillChar(ODL0, Length(ODL0)*SizeOf(TTileOptData),0);
  FillChar(ODL1, Length(ODL1)*SizeOf(TTileOptData),0);
  FillChar(T,512*512,$FF);
  LimX    := 15;
  LimY    := 15;
  sqLimX  := 512-32;
  sqLimY  := 512-32;
  sqAngle := 0;
  DIBToLayer(pLayer0,@L0);
  DIBToLayer(pLayer1,@L1);
  For n:=0 To High(L0) do If CompareMem(@L0[n],@EmptyTile,256) Then
  begin
    Layer0[n]:=$FFFFFFFF;
    Inc(Count);
    Inc(LCount[0]);
    F0[n]:=True;
  end;
  For n:=0 To High(L1) do If CompareMem(@L1[n],@EmptyTile,256) Then
  begin
    Layer1[n]:=$FFFFFFFF;
    Inc(Count);
    Inc(LCount[1]);
    F1[n]:=True;
  end;
  ProgressForm.ProgressBar.Max := Length(L0)+Length(L1);
  ProgressForm.ProgressBar.Min := Count;

  SetLength(L0ID, Length(F0)-LCount[0]);
  SetLength(L1ID, Length(F1)-LCount[1]);
  m:=0;
  For n:=0 To High(F0) do
  begin
    If not F0[n] Then
    begin
      L0ID[m]:=n;
      Inc(m);
    end;
  end;
  m:=0;
  For n:=0 To High(F1) do
  begin
    If not F1[n] Then
    begin
      L1ID[m]:=n;
      Inc(m);
    end;
  end;

  LMax[0]:=High(L0ID);
  LMax[1]:=High(L1ID);
  LC[0]:=LCount[0];
  LC[1]:=LCount[1];
  //Grid:=LMax[0]+LMax[1]<=32*32;
  lastLevel0:=Level0;
  lastLevel1:=Level1;
  //For m:=LC[0] to High(L0) do
  bL:=0;
{$IFDEF ALL_LAYERS}
  While (LMax[0]>=0) or (LMax[1]>=0)  do //-
{$ELSE}
  While LMax[0]>=0 do
{$ENDIF}
  begin
    If Grid Then
    begin
      GetGrid;
      If NoSpace Then Break;
      bID:=L0ID[0];
      CurIDNum:=0;
      Plug;
      Continue;
    end;
    If NoSpace Then break;
    If Level0>lastLevel0 Then
    begin
      For n:=0 to LMax[0] do ODL0[L0ID[n]].F:=False;
    end;
    lastLevel0:=Level0;
    bRes:=-1;
    If Level0>LMax[0] Then AllMax:=LMax[0] else AllMax:=Level0-1;
    For n:=AllMax+1 to  LMax[0] do ODL0[L0ID[n]].F:=False;
    For n:=0 To AllMax {LMax[0]} do
    begin
      If NoSpace Then break;
      If FindBestPlace(L0ID[n],0,X,Y,Res) Then
      begin
        If (Res>bRes) or ((Res=bRes) and Check8XY(X,Y,bX,bY)) Then
        begin
          bRes:=Res; bX:=X; bY:=Y; bID:=L0ID[n]; CurIDNum:=n;
          bL:=0; sqYes:=sqYYY;
        end;
        If bRes=16*16 Then
        begin
          For m:=CurIDNum+1 to AllMax do ODL0[L0ID[m]].F:=False;
          break;
        end;
      end;
    end;
{$IFDEF ALL_LAYERS}
{$ELSE}
    Plug;
    If bCancel Then GoTo brk;
  end;

  bL:=1;
  While LMax[1]>=0 do
  begin
{$ENDIF}
    If Grid Then
    begin
      GetGrid;
      If NoSpace Then Break;
      bID:=L1ID[0];
      CurIDNum:=0;
      Plug;
      Continue;
    end;    
    If NoSpace Then break;
    If Level1>lastLevel1 Then
    begin
      For n:=0 to LMax[1] do ODL1[L1ID[n]].F:=False;
    end;
    lastLevel1:=Level1;
{$IFDEF ALL_LAYERS}
{$ELSE}
    bRes:=-1;
{$ENDIF}
    If Level1>LMax[1] Then AllMax:=LMax[1] else AllMax:=Level1-1;
    For n:=AllMax+1 to LMax[1] do ODL1[L1ID[n]].F:=False;
    For n:=0 To AllMax {LMax[1]} do
    begin
      If FindBestPlace(L1ID[n],1,X,Y,Res) Then
      begin
       // If Res>bRes Then
        If (Res>bRes) or ((Res=bRes) and Check8XY(X,Y,bX,bY)) Then
        begin
          bRes:=Res; bX:=X; bY:=Y; bID:=L1ID[n]; CurIDNum:=n;
          bL:=1; sqYes:=sqYYY;
        end;
        If bRes=16*16 Then
        begin
          For m:=CurIDNum+1 to AllMax do ODL1[L1ID[m]].F:=False;
          break;
        end;
      end;
    end;
    Plug;
    If bCancel Then break;
  end;

  brk:
  For n:=0 To 511 do
  For m:=0 To 511 do
    If T[n,m]=255 Then T[n,m]:=0;

  TilesToRaw(Tiles);
end;

Procedure FillBlock(var Pic: TDIB; X,Y: Integer);
var B: ^Byte; n,m: Integer;
begin
  For m:=0 to 15 do
  begin
    B:=Pic.ScanLine[Y+m];
    Inc(B,X div 2);
    FillChar(B^,8,0);
  end;
end;

Procedure TCMI.LoadFromFile(FileName: String);
var F: File;
begin
  If not FileExists(FileName) Then Exit;
  AssignFile(F,FileName);
  Reset(F,1);
  If (FileSize(F)<180448) {or (Head.Sign<>'CMI1')} Then
  begin
    CloseFile(F);
    Exit;
  end;
  Seek(F, 0);
  BlockRead(F, Head, 180448);
  CloseFile(F);
  FOptimized:=True;
  FOpened := True;
end;

Procedure TCMI.GetLayers(var pBG,pTiles,pLayer0,pLayer1: TDIB);
var n: Integer;
begin
  If not Assigned(pTiles) Then AssignLayer(pTiles, 512,512);
  SetPal(pTiles, Pal[0]);
  RawToDib(pTiles,@Tiles);
  {pTiles.Transparent := True;
  pTiles.TransparentColor := 0;}

  If not Assigned(pBG) Then AssignLayer(pBG,128,128);
  SetPal(pBG,Pal[2]);
  For n:=0 To 15 do
  begin
    With pBG.ColorTable[n] do
    begin
      rgbRed   := Round(((rgbRed*25)/  100) + ((255*75) / 100));
      rgbGreen := Round(((rgbGreen*25)/100) + ((255*75) / 100));
      rgbBlue  := Round(((rgbBlue*25)/ 100) + ((255*75) / 100));
    end;
  end;
  pBG.UpdatePalette;
  RawToDib(pBG,@BG);

  If not Assigned(pLayer1) Then AssignLayer(pLayer1,1920 div 2,1088 div 2);
  SetPal(pLayer1,Pal[0]);
  GetLayer1(pLayer1,pTiles);
  pLayer1.Transparent := True;
  pLayer1.TransparentColor := 0;

  If not Assigned(pLayer0) Then AssignLayer(pLayer0,1920,1088);
  SetPal(pLayer0,Pal[1]);
  GetLayer0(pLayer0,pTiles);
  pLayer0.Transparent := True;
  pLayer0.TransparentColor := 0;

end;

Procedure Bpp4to8(Pic4,Pic8: TDIB; Increment: Byte = 0);
var n,m: Integer; B4,B8: ^Byte;
begin
  For m:=0 To Pic4.Height-1 do
  begin
    B4:=Pic4.ScanLine[m];
    B8:=Pic8.ScanLine[m];
    For n:=0 To (Pic4.Width div 2)-1 do
    begin
      B8^:=Increment+(B4^ shr 4); Inc(B8);
      B8^:=Increment+(B4^ and $f);  Inc(B8); Inc(B4);
    end;
  end;
end;

Procedure TCMI.BuildMap(var Pic: TDIB; pLayer0,pLayer1,pBG: TDIB);
var m,n: Integer; Pallete: Array[0..$30-1] of DWord; pL0,pL1,pL1T: TDIB;
begin
  For n:=0 To 2 do Move(Pal[n],Pallete[n*16],16*4);
  AssignLayer(Pic,1920,1088,8);
  AssignLayer(pL0,1920,1088,8);
  AssignLayer(pL1,1920,1088,8);
  AssignLayer(pL1T,1920 div 2, 1088 div 2,8);
  SetPal(pL1T,Pal[0]);
  Bpp4to8(pLayer1,pL1T);

  SetPal(pL1,Pallete);
  SetPal(pL0,Pallete);
  SetPal(Pic,Pallete);
  For n:=0 To 15 do
    Pic.ColorTable[n+32] := pBG.ColorTable[n];
  Pic.UpdatePalette;

  pL1.Canvas.CopyRect(Bounds(0,0,1920,1088),pL1T.Canvas,Bounds(0,0,960,544));
  pL1.Transparent := True;
  pL1.TransparentColor := 0;

  bpp4To8(pLayer0,pL0,16);
  pL0.Transparent := True;
  pL0.TransparentColor := 16; 
  //pL0.SaveToFile('C:\test.bmp'); 

  For m:=0 To (1088 div 128) do
    For n:=0 to (1920 div 128)-1 do
      Pic.Canvas.Draw(n*128,m*128,pBG);

  Pic.DrawDIB(0,0,pL1);
  Pic.DrawDIB(0,0,pL0); 

    {ProgressForm.Screen.Surface.TransparentColor := 0;
    ProgressForm.Show;
    ProgressForm.Screen.Surface.Canvas.Draw(0,0,Pic);
    ProgressForm.Screen.Surface.Canvas.Release;
    ProgressForm.Screen.Flip;}

  pL1T.Free;
  pL1.Free;
  pL0.Free;
end;



Procedure TCMI.AssignLayer(var Pic: TDIB; W,H: Integer; Bpp: Integer = 4);
begin
  Pic:=TDIB.Create;
  Pic.BitCount:=Bpp;
  Pic.Width:=W;
  Pic.Height:=H;
end;



Procedure TCMI.GetLayer0(var Pic: TDIB; Tiles: TDIB);
var n,m,c,X,Y: Integer;
begin
  SetPal(Tiles,Pal[1]);
  c:=0;
  For m:=0 To (Pic.Height div 16)-1 do
    For n:=0 To (Pic.Width div 16)-1 do
    begin
      If Layer0[c]<$FFFFFFFF Then
      begin
        Y := Layer0[c] div 512;
        X := Layer0[c] - Y*512;
        Pic.Canvas.CopyRect(Bounds(n*16,m*16,16,16),Tiles.Canvas,Bounds(X,Y,16,16));
      end else
        FillBlock(Pic,n*16,m*16);
      Inc(C);
    end;
end;

Procedure TCMI.GetLayer1(var Pic: TDIB; Tiles: TDIB);
var n,m,c,X,Y: Integer;
begin
  SetPal(Tiles,Pal[0]);
  c:=0;
  For m:=0 To (Pic.Height div (16))-1 do
    For n:=0 To (Pic.Width div (16))-1 do
    begin
      If Layer1[c]<$FFFFFFFF Then
      begin
        Y := Layer1[c] div (512 div 1);
        X := Layer1[c] - Y*(512 div 1);
        Pic.Canvas.CopyRect(Bounds(n*(16),m*(16),16,16),Tiles.Canvas,Bounds(X,Y,16,16));
      end else
        FillBlock(Pic,n*16,m*16);
      Inc(C);
    end;
end; 


Function TCMI.SaveToFile(FName: String): Boolean;
var F: File;
begin
  AssignFile(F, FName);
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F,Head,180448);
  CloseFile(F);
end;

end.
