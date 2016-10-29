program Jim2Bmp;

{$APPTYPE CONSOLE}

uses
  SysUtils, TBXGraphics, DIB, Compression, Windows;

//$40,$3040,$8040

Procedure Raw2Dib(var Pic: TDIB; Ptr: Pointer; X,Y,W,H: Integer; Paste: Boolean = False);
var n,m: Integer; B,WB: ^Byte;
begin
  B:=Ptr;
  For m:=Y to Y+H-1 do
  begin
    WB:=Pic.ScanLine[m]; Inc(WB,X);
    If Paste Then Move(WB^,B^,W) else Move(B^,WB^,W); Inc(B,W);
  end;
end;


var Pic: TDIB; Buf: Pointer; n: Integer;
begin
  {Pic:=TDib.Create;
  Pic.BitCount:=8;
  Pic.Width:=512;
  Pic.Height:=48;
  LoadFile('data.jim',Buf);
  Move(Pointer(DWord(Buf)+$8040)^,Pic.ColorTable[0],256*4);
  Raw2Dib(Pic,Pointer(DWord(Buf)+$40),0,0,256,48);
  Raw2Dib(Pic,Pointer(DWord(Buf)+$3040),256,0,256,48);
  Pic.SaveToFile('test.bmp');
  Pic.Free;
  FreeMem(Buf);}

  Pic:=TDib.Create;
  Pic.BitCount:=8;
  Pic.Width:=512*2;
  Pic.Height:=48*58;
  LoadFile('data.jim',Buf);
  Move(Pointer(DWord(Buf)+$8040)^,Pic.ColorTable[0],256*4);
  For n:=0 To 115 do
  begin
    Raw2Dib(Pic,Pointer(DWord(Buf)+$8800*n+$40),(n AND 1)*512,(n div 2)*48,256,48);
    Raw2Dib(Pic,Pointer(DWord(Buf)+$8800*n+$3040),(n AND 1)*512+256,(n div 2)*48,256,48);
  end;
  Pic.SaveToFile('test.bmp');
  Pic.Free;
  FreeMem(Buf);

end.
 