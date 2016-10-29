program Tim2Jim;

{$APPTYPE CONSOLE}

uses
  SysUtils, Compression, Windows;

//$40,$3040,$8040   ,2B8040

{Procedure Raw2Dib(var Pic: TDIB; Ptr: Pointer; X,Y,W,H: Integer; Paste: Boolean = False);
var n,m: Integer; B,WB: ^Byte;
begin
  B:=Ptr;
  For m:=Y to Y+H-1 do
  begin
    WB:=Pic.ScanLine[m]; Inc(WB,X);
    If Paste Then Move(WB^,B^,W) else Move(B^,WB^,W); Inc(B,W);
  end;
end;}

Procedure MoveTim(const P1,P2; W,H: Integer);
var n,m: Integer; B,WB: ^Byte;
begin
  B:=Addr(P1); WB:=Addr(P2);
  For m:=0 to H-1 do
  begin
    Move(B^,WB^,W); Inc(B,1024); Inc(WB,W);
  end;
end;


var Head: Array[0..$3F] of Byte = (
$54,$49,$4D,$32,4,0,1,0,0,0,0,0,0,0,0,0,
$30,$84,0,0,0,4,0,0,0,$80,0,0,$30,0,0,1,
0,1,3,5,0,1,$80,0,0,0,$30,$E1,1,0,0,0,
$60,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

var P,Buf,WBuf,Pal: Pointer; n: Integer; B: ^Byte;
begin

  LoadFile(ParamStr(1),Buf);
  Pal:=Pointer(DWord(Buf)+$2B8040);
  GetMem(WBuf,$8800*116);
  //Move(Pointer(DWord(Buf)+$8040)^,Pic.ColorTable[0],256*4);
  P:=Pointer(DWord(WBuf));
  B:=Pointer(DWord(Buf)+$40);
  For n:=0 To (116 div 1)-1 do
  begin
    Move(Head,P^,$40);
    MoveTim(Pointer(DWord(Buf)+$40+$C000*(n div 2)+(512*(n and 1)))^,Pointer(DWord(P)+$40)^,256,48);
    MoveTim(Pointer(DWord(Buf)+$40+$C000*(n div 2)+256+(512*(n and 1)))^,Pointer(DWord(P)+$3040)^,256,48);
    Move(Pal^,Pointer(DWord(P)+$8040)^,$400);
    FillChar(Pointer(DWord(P)+$6040)^,$2000,B^);
    FillChar(Pointer(DWord(P)+$8440)^,$3C0,$0A);
    Inc(DWord(P),$8800);
  end;
  FreeMem(Buf);
  SaveFile(ParamStr(2),WBuf,$8800*116);
  FreeMem(WBuf);
end.
 