unit FontGim;

interface
uses DIB, Windows;
Type
  TFontChar = Record
  X: Word;
  Y: Word;
  W: Word;
  Code: Char;
end;
Type
  TFont = Record
  H: Word;
  Count: Word;
  StopByte: Word;
  Char: Array of TFontChar;
end;

Procedure RawToDib(var pic: TDIB; Buf: Pointer);
Function RoundBy(Value, R: Integer): Integer;
Function GetW(W,R: Integer): Integer;
Procedure LoadGim(FileName: String; var Buf: Pointer; var Pic: TDIB);
Procedure SetPallete(var Pic: TDIB; Pal: Array of DWord);
Procedure LoadFont(var Font: TFont; FileName: String);


implementation

Procedure LoadGim(FileName: String; var Buf: Pointer; var Pic: TDIB);
var F: File; Wrd: Word;
begin
  If not Assigned(Pic) then Pic:=TDIB.Create;
  Pic.BitCount:=4;
  Pic.PixelFormat := MakeDIBPixelFormat(8, 8, 8);
  AssignFile(F, FileName);
  Reset(F,1);
  Seek(F,$48);
  BlockRead(F,   Wrd, 2);
  Pic.Width:=Wrd;
  Seek(F, $4A);
  BlockRead(F, Wrd, 2);
  Pic.Height:=Wrd;
  Seek(F, $80);
  GetMem(Buf, RoundBy(Pic.Height,8)*RoundBy(Pic.Width,32) div 2);
  BlockRead(F, Buf^ {Buf^} , RoundBy(Pic.Height,8)*RoundBy(Pic.Width,32) div 2);
  CloseFile(F);
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function GetW(W,R: Integer): Integer;
begin
  If (R+1)*8>W then Result:=(R+1)*8-W else Result:=8;
end;

Procedure RawToDib(var pic: TDIB; Buf: Pointer);
var SL, B: ^Byte; Wrd: Word; n,m,r,l: Integer;
begin
B:=Addr(Buf^);
  Wrd:= RoundBy(Pic.Height,8);
  For r:=0 to  (Wrd div 8) -1 do
    For l:=0 to (Pic.Width div 32) -1 do
    begin
      Wrd:=GetW(Pic.Height, R)-1;
      For m:=r*8 to r*8+{7} Wrd  {Pic.Height-r*8}    do
      begin
        SL:=Addr(Pic.ScanLine[m]^);
        Inc(SL,l*16);
        For n:=l*16 to l*16+15 do
          begin
            SL^:=B^ SHR 4;
            SL^:=SL^ + ((B^ SHL 4) AND $F0);
            {Img[(Head.biHeight-1 - m) * Head.biWidth + (n*2)]:=(B^ AND $0F);
            Img[(Head.biHeight-1 - m) * Head.biWidth + (n*2+1)]:=B^ SHR 4;}
            Inc(B); Inc(SL);
          end;

        end;
        If wrd<>7 then Inc(B,(7-wrd)*16);
        //If wrd<>7 then Inc(B,(7-wrd)*32);
      end;
end;

Procedure SetPallete(var Pic: TDIB; Pal: Array of DWord);
var n: Integer;
begin
  For n := 0 to 15 do With Pic.ColorTable[n]{, MyPalette} do
  begin
    rgbRed := Pal[n] SHR 16;
    rgbGreen := (Pal[n] SHR 8) AND $000000FF;
    rgbBlue := Pal[n] AND $000000FF;
    rgbReserved := 0;//(Pal SHR 32) AND $000000FF;
  end;
  Pic.UpdatePalette;
end;

Procedure LoadFont(var Font: TFont; FileName: String);
var F: File; Buf: Pointer; n: Integer; W: ^Word;
begin
  AssignFile(F, FileName);
  Reset(F,1);
  BlockRead(F, Font, 6);
  SetLength(Font.Char, Font.Count);
  Seek(F, $118);
  GetMem(Buf, Font.Count*6);
  BlockRead(F, Buf^, Font.Count*6);
  W:=Addr(Buf^);
  For n:=0 to Font.Count-1 do
  begin
    Font.Char[n].X:=W^; Inc(W);
    Font.Char[n].Y:=W^; Inc(W);
    Font.Char[n].W:=W^; Inc(W);
  end;
  FreeMem(Buf);
  CloseFile(F);
end;

end.
