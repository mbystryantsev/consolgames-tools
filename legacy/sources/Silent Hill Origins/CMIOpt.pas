unit CMIOpt;

interface

Uses
DIB_classic, CMIUnit, Windows, PSPRAW, SysUtils;


Type
  TLrT = Array[0..511,0..511] of Byte;
  TLr  = Array[0..1919,0..1087] of Byte;
  TMask =Array[0..511,0..511] of Boolean;
  TUpdateProc = Procedure(Progress, Max: Integer);
  TFlags = Array[0..8160+2040-1] of Boolean;

var
  Lr0,Lr1: TLr;
  Mask: TMask;
  Tiles: TLrT;
  UX: Integer=0;
  UY: Integer=0;
  Flags: TFlags;
  AllCount: Integer=0;


Procedure DibToLr(Pic: TDIB; LBp: Pointer);
Procedure LrToDib(Pic: TDIB; LBp: Pointer);
Procedure TilesToDib(Pic: TDIB; LBp: Pointer);
Procedure DibToTiles(Pic: TDIB; LBp: Pointer);
Function CmpByNull(Ptr: Pointer; X,Y: Integer): Boolean;
Procedure OptimizeMap(CmiPtr: Pointer; Layer0,Layer1: TDIB; var T: TDIB;
UpdateProc: TUpdateProc; var Big: Integer);
Procedure OptMap(CmiPtr: Pointer; Layer0,Layer1: TDIB; var T: TDIB;
UpdateProc: TUpdateProc; var Big: Integer);

implementation




//Function CompareTiles(): Integer; assembler;
//asm

{function CompareMem(P1, P2: Pointer; Length: Integer): Boolean; assembler;
asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,P1
        MOV     EDI,P2
        MOV     EDX,ECX
        XOR     EAX,EAX
        AND     EDX,3
        SAR     ECX,2
        JS      @@1     // Negative Length implies identity.
        REPE    CMPSD
        JNE     @@2
        MOV     ECX,EDX
        REPE    CMPSB
        JNE     @@2
@@1:    INC     EAX
@@2:    POP     EDI
        POP     ESI
end;}
//end;


Procedure DibToLr(Pic: TDIB; LBp: Pointer);
var n,m: Integer; B: ^Byte; PLr: ^TLr;
begin
//CompareMem
  PLr:=LBp;
  For m:=0 To Pic.Height-1 do
  begin
    B:=Pic.ScanLine[m];
    For n:=0 To (Pic.Width div 2)-1 do
    begin
      PLr^[n*2+1,m]:=B^ and $F;
      PLr^[n*2,m]:=B^ SHR 4;
      Inc(B);
    end;
  end;
end;

Procedure DibToTiles(Pic: TDIB; LBp: Pointer);
var n,m: Integer; B: ^Byte; PLr: ^TLrT;
begin
  PLr:=LBp;
  For m:=0 To Pic.Height-1 do
  begin
    B:=Pic.ScanLine[m];
    For n:=0 To (Pic.Width div 2)-1 do
    begin
      PLr^[n*2+1,m]:=B^ and $F;
      PLr^[n*2,m]:=B^ SHR 4;
      Inc(B);
    end;
  end;
end;

Procedure LrToDib(Pic: TDIB; LBp: Pointer);
var n,m: Integer; B: ^Byte; PLr: ^TLr;
begin
  PLr:=LBp;
  For m:=0 To Pic.Height-1 do
  begin
    B:=Pic.ScanLine[m];
    For n:=0 To (Pic.Width div 2)-1 do
    begin
      B^:=PLr^[n*2+1,m];
      B^:=B^+(PLr^[n*2,m] SHL 4);
      Inc(B);
    end;
  end;
end;

Procedure TilesToDib(Pic: TDIB; LBp: Pointer);
var n,m: Integer; B: ^Byte; PLr: ^TLrT;
begin
  PLr:=LBp;
  For m:=0 To Pic.Height-1 do
  begin
    B:=Pic.ScanLine[m];
    For n:=0 To (Pic.Width div 2)-1 do
    begin
      B^:=PLr^[n*2+1,m];
      B^:=B^+(PLr^[n*2,m] SHL 4);
      Inc(B);
    end;
  end;
end;

Procedure SetMask(X,Y: Integer);
var m,n: Integer;
begin
  For m:=0 To 15 do
    For n:=0 To 15 do
      Mask[X+n,Y+m]:=True;
end;

Procedure UnSetMask(X,Y: Integer);
var m,n: Integer;
begin
  For m:=0 To 15 do For n:=0 To 15 do Mask[X+n,Y+m]:=False;
end;

var NullAr: Array[0..15] of Byte = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

Function CmpByNull(Ptr: Pointer; X,Y: Integer): Boolean;
var n,m: Integer; Lr: ^TLr;
begin
  Lr:=Ptr;
  Result:=False;
  For m:=0 To 15 do
    //For n:=0 To 15 do
      //If Lr^[n+X,m+Y]<>0 Then Exit;
      If not CompareMem(Addr(Lr^[X+m,Y]), Addr(NullAr),16) Then Exit;
  Result:=True;
end;

Function GetTileCount(Ptr: Pointer; X,Y,TX,TY: Integer): Integer;
var n,m: Integer; Lr: ^TLr;
begin
  Lr:=Ptr;
  Result:=0;
  For m:=0 To 15 do
    For n:=0 To 15 do
    begin
      If Mask[TX+n, TY+m] Then
      begin
        If Tiles[TX+n,TY+m]=Lr^[X+n,Y+m] Then Inc(Result) else
        begin
          Result:=-1;
          Exit;
        end;
      end;
    end;
end;

Procedure PlugTile(Ptr: Pointer; X,Y,TX,TY: Integer);
var n,m: Integer; Lr: ^TLr;
begin
  Lr:=Ptr;
  For m:=0 To 15 do For n:=0 To 15 do
    Tiles[TX+n,TY+m]:=Lr^[X+n,Y+m];
end;

Function SetTile(Ptr: Pointer; X,Y: Integer): Integer;
var n,m: Integer; Lr: ^TLr; Count, Best, bX, bY: Integer; bFlag: Boolean;
begin
  bX:=0; bX:=0; bFlag:=False;
  Best:=-1;
  Lr:=Ptr;
  If CmpByNull(Ptr,X,Y) Then
  begin
    Result:=-1;
    Exit;
  end;
  For m:=0 To UY do
  begin
    For n:=0 To UX do
    begin
      Count:=GetTileCount(Ptr,X,Y,n,m);
      If Count>=256 Then
      begin
        Result:=m*512+n;
        Exit;
      end else
      If Count>Best Then
      begin
        bFlag:=False;
        Best:=Count;
        bX:=n; bY:=m;
      end;// else
      {If (Count=Best) And not bFlag Then
      begin
        If (UX>UY) and (n<bX) then
        begin
          bFlag:=True;
          bX:=n; bY:=m;
        end else
        If (UY>UX) and (m<bY) then
        begin
          bFlag:=True;
          bX:=n; bY:=m;
        end;
      end;}
    end;
  end;
  If Best=-1 Then
  begin
    Result:=-2;
    Exit;
  end;
  SetMask(bX,bY);
  Result:=bY*512+bX;
  PlugTile(Ptr,X,Y,bX,bY);
  If UX<bX+16 Then UX:=bX+16;
  If UY<bY+16 Then UY:=bY+16;
  If UX>511-16 Then UX:=511-16;
  If UY>511-16 Then UY:=511-16;

  {If bY>=4 Then
  begin
    Result:=11111;
  end;}
end;

Procedure NullMask;
var n,m: Integer;
begin
  For m:=0 To 511 do For n:=0 To 511 do Mask[n,m]:=False;
end;

Procedure NullTiles;
var n,m: Integer;
begin
  For m:=0 To 511 do For n:=0 To 511 do Tiles[n,m]:=0;
end;

Procedure OptimizeMap(CmiPtr: Pointer; Layer0,Layer1: TDIB; var T: TDIB;
UpdateProc: TUpdateProc; var Big: Integer);
var n,m,Num,V: Integer; CMI: ^TCMI;
begin
  Big:=0; Num:=0;
  NullMask; NullTiles;
  CMI:=CmiPtr;
  DibToLr(Layer0,Addr(Lr0));
  For m:=0 To (1088 div 16)-1 do
  begin
  UpdateProc(m,(1088 div 16)+(1088 div 32));
    For n:=0 to (1920 div 16)-1 do
    begin
      V:=SetTile(Addr(Lr0),n*16,m*16);
      If V=-2 Then
        Inc(Big)
      else
        CMI^.Layer0[Num]:=V;
      Inc(Num);
    end;
  end;
  Num:=0;
  DibToLr(Layer1,Addr(Lr1));
  For m:=0 To (1088 div 32)-1 do
  begin
    UpdateProc(m+(1088 div 16),(1088 div 16)+(1088 div 32));
    For n:=0 to (1920 div 32)-1 do
    begin
      V:=SetTile(Addr(Lr1),n*16,m*16);
      If V=-2 Then
        Inc(Big)
      else
        CMI^.Layer0[Num]:=V;
        Inc(Num);
    end;
  end;
  TilesToDib(T,Addr(Tiles));
  DibToRaw(T,Addr(CMI.Tiles));
end;

var MaxTCnt: Integer = 1;
Function GetBest(Ptr0,Ptr1,CmiPtr: Pointer): Integer;
var n,m,Num,Best,V,bX,bY,bNum: Integer; Lr: ^TLr; CMI: ^TCMI;  Ptr: Pointer;
X,Y,TCnt: Integer;
Label nxt;
begin
  CMI:=CmiPtr;
  Best:=-2;
  //Lr:=Ptr0;
  Ptr:=Ptr0;
  TCnt:=0;
  For Num:=0 To 8160{+2040}-1 do
  begin
    If not Flags[Num] Then
    begin
      If Num<8160 Then
      begin
        Y:=Num div 68;
        X:=Num-(Y*68);
      end else
      begin
        Y:=(Num-8160) div 34;
        X:=(Num-8160)-(Y*34);
      end;
      Y:=Y*16; X:=X*16;
      If Num=8160 Then Ptr:=Ptr1;
      If CmpByNull(Ptr,X,Y) Then
      begin
        Flags[Num]:=True;
        Inc(AllCount);
        If Num<8160 Then
        begin
          CMI^.Layer0[Num]:=DWord(-1);
        end else
          CMI^.Layer1[Num-8160]:=DWord(-1);
        end;
      end;
    If not Flags[Num] Then
    begin
      Inc(TCnt);
      If TCnt>MaxTCnt Then GoTo nxt;//Break;
      For m:=0 To UY do
      For n:=0 To UX do
      begin
        V:=GetTileCount(Ptr,X,Y,n,m);
        If V=256 Then
        begin
          Flags[Num]:=True;
          Inc(AllCount);
          If Num<8160 Then CMI^.Layer0[Num]:=m*512+n
          else CMI^.Layer1[Num-8160]:=m*512+n;
          GoTo nxt;
        end;
        If (V>Best) and (V<>256) Then
        begin
          Best:=V; bNum:=Num;
          bX:=n;
          bY:=m;
        end;
      end;
    end;
  nxt:
  end;
  //GX:=bX; GY:=bY; GNum:=bNum;
  If bNum<8160 Then
  begin
    Y:=bNum div 68;
    X:=bNum-(Y*68);
  end else
  begin
    Y:=(bNum-8160) div 34;
    X:=(bNum-8160)-(Y*34);
  end;
  If bNum<8160 Then Ptr:=Ptr0 Else Ptr:=Ptr1;
  PlugTile(Ptr,X,Y,bX,bY);
  SetMask(bX,bY);
  If UX<bX+16 Then UX:=bX+16;
  If UY<bY+16 Then UY:=bY+16;
  Result:=Best;
  Inc(AllCount);
end;


Procedure OptMap(CmiPtr: Pointer; Layer0,Layer1: TDIB; var T: TDIB;
UpdateProc: TUpdateProc; var Big: Integer);
var n,m,Num,V: Integer; CMI: ^TCMI; GB: Integer;
begin
  Big:=0; UX:=0; UY:=0;
  AllCount:=0; GB:=0;
  NullMask; NullTiles;
  CMI:=CmiPtr;
  DibToLr(Layer0,Addr(Lr0));
  DibToLr(Layer1,Addr(Lr1));

  For n:=0 To 8160+2040-1 do Flags[n]:=False;

  While (GB>=0) and (AllCount<8000) do
  begin
    GB:=GetBest(Addr(Lr0),Addr(Lr1),CmiPtr);
    UpdateProc(AllCount,8160+2040-1);
  end;

  If GB=-1 Then
  begin
    For n:=0 To 8160+2040-1 do
    begin
      If Flags[n] Then Inc(Big);
    end;
  end;

  TilesToDib(T,Addr(Tiles));
  DibToRaw(T,Addr(CMI.Tiles));
end;

end.
