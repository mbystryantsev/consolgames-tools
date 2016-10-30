unit PSPRAW;

interface
uses DIB, Windows, SysUtils, Graphics;


  Type
	  TFHead = Packed Record
    Unknown0: Array[0..3] of DWord;
    Size: DWord;
	  Unknown: Array[0..4] of DWord;
	  Width : Word;
	  Height: Word;
    Bpp: Byte;
    Unk1: Byte;
    Unk2: Word;
    Unknown2: Array[0..23] of DWord;
    Name: Array[0..63] of byte;
    Pos: DWord;
  end;

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

Type 
 TRGBA = Packed Record
  R: Byte;
  G: Byte;
  B: Byte;
  A: Byte;
 end;

Procedure RawToDib(var pic: TDIB; Buf: Pointer);
Function RoundBy(Value, R: Integer): Integer;
Function GetW(W,R: Integer): Integer;
Procedure LoadGim(FileName: String; var Buf: Pointer; var Pic: TDIB);
Procedure SetPallete(var Pic: TDIB; Pal: Array of DWord);
Procedure LoadFont(var Font: TFont; FileName: String);
Procedure Flip(var Buf: Pointer; Size: Integer);
Function GetName(Bytes: Array of byte): String;
Procedure LoadTexture(const F: File; var FHead: TFHead; var Pic: TDIB; var Pos: Integer);
Procedure SetPal(var Pic: TDIB; Pal: Array of DWord);
Procedure DibToRaw(var pic: TDIB; Buf: Pointer);
Procedure LoadGimFont(FileName: String; var Pic: TDIB; Pal: Array of DWord);
implementation

Procedure LoadGimFont(FileName: String; var Pic: TDIB; Pal: Array of DWord);
var F: File; Wrd: Word; Buf: Pointer;
begin
  LoadGim(FileName, Buf, Pic);
  RawToDib(Pic, Buf);
  FreeMem(Buf);
  SetPallete(Pic, Pal);
end;

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
var SL, B: ^Byte; Wrd: Word; n,m,r,l,d: Integer;
begin
B:=Addr(Buf^);
  Wrd:= RoundBy(Pic.Height,8);
  For r:=0 to  (Wrd div 8) -1 do
    For l:=0 to (Pic.Width div (128 div Pic.BitCount)) -1 do
    begin
      Wrd:=GetW(Pic.Height, R)-1;
      For m:=r*8 to r*8+{7} Wrd  {Pic.Height-r*8}    do
      begin
        SL:=Addr(Pic.ScanLine[m]^);
        Inc(SL,l*16);
        For n:=l*16 to l*16+15 do
          begin
            {If Pic.BitCount<8 then
            begin
              SL^:=0;
              For d:=0 to 8 div Pic.BitCount -1 do
              begin }
                {SL^:=SL^+(B^ SHR Pic.BitCount*(8 div Pic.BitCount - d-1) - d) AND
                (($FF SHL Pic.BitCount) SHR (Pic.BitCount*(8 div Pic.BitCount - d-1)));}
                If Pic.BitCount=4 then
                begin
                  SL^:=B^ SHR 4;
                  SL^:=SL^ + ((B^ SHL 4) AND $F0);
                end else if Pic.BitCount=2 then
                begin
                end else if Pic.BitCount=1 then
                begin
                end else
                begin
                  SL^:=B^;
                end;
              //end;
           { end else
            begin
              SL^:=B^;
            end;}
            //SL^:=B^ SHR 4;
            //SL^:=SL^ + ((B^ SHL 4) AND $F0);
            {Img[(Head.biHeight-1 - m) * Head.biWidth + (n*2)]:=(B^ AND $0F);
            Img[(Head.biHeight-1 - m) * Head.biWidth + (n*2+1)]:=B^ SHR 4;}
            Inc(B); Inc(SL);
          end;

        end;
        If wrd<>7 then Inc(B,(7-wrd)*16);
        //If wrd<>7 then Inc(B,(7-wrd)*32);
      end;
end;

Procedure DibToRaw(var pic: TDIB; Buf: Pointer);
var SL, B: ^Byte; Wrd: Word; n,m,r,l,d: Integer;
begin
B:=Addr(Buf^);
  Wrd:= RoundBy(Pic.Height,8);
  For r:=0 to  (Wrd div 8) -1 do
    For l:=0 to (Pic.Width div (128 div Pic.BitCount)) -1 do
    begin
      Wrd:=GetW(Pic.Height, R)-1;
      For m:=r*8 to r*8+{7} Wrd  {Pic.Height-r*8}    do
      begin
        SL:=Addr(Pic.ScanLine[m]^);
        Inc(SL,l*16);
        For n:=l*16 to l*16+15 do
          begin
            If Pic.BitCount=4 then
            begin
              B^:=SL^ SHL 4;
              B^:=B^ + ((SL^ SHR 4) AND $0F);
            end else if Pic.BitCount=2 then
            begin
            end else if Pic.BitCount=1 then
            begin
            end else
            begin
              B^:=SL^;
            end;
            Inc(B); Inc(SL);
          end;
        end;
        If wrd<>7 then Inc(B,(7-wrd)*16);
      end;
end;



Procedure SetPallete(var Pic: TDIB; Pal: Array of DWord);
var n,i: Integer;
begin
 N := Length(Pal);
 If N > 256 then N := 256;
 For I := 0 to N - 1 do With Pic.ColorTable[I], TRGBA(Pal[I]) do
 begin
  rgbRed := B;
  rgbGreen := G;
  rgbBlue := R;
  rgbReserved := A;
 end;
 Pic.UpdatePalette;
end;

Procedure SetPal(var Pic: TDIB; Pal: Array of DWord);
var n,i: Integer; S: String;
begin
 N := Length(Pal);
 If N > 256 then N := 256;
 For I := 0 to N - 1 do With Pic.ColorTable[I], TRGBA(Pal[I]) do
 begin
  S:= (Format('%d %d %d %d',[R,G,B,A]));
  rgbRed := R;
  rgbGreen := G;
  rgbBlue := B;
  rgbReserved := A;
 end;
 Pic.UpdatePalette;
end;

Function GetName(Bytes: Array of byte): String;
var n: integer;
begin
  Result:='';
  For n:=0 to Length(Bytes)-1 do
  begin
    If Bytes[n]=0 then begin Exit; end else Result:=Result+Char(Bytes[n]);
  end;
end;

Procedure Flip(var Buf: Pointer; Size: Integer);
var W: ^Word; n: Integer;
begin
  W:=Addr(Buf^);
  For n:=0 to Size do
  begin
    //WriteLn(IntToStr(W^));
    //W^:=$0000;
    W^:=((W^ SHL 11) AND $F800) + ((W^ SHR 11) AND $001F) + (W^ AND $7E0);
    //W^:=((W^ SHL 10) AND $F800) + ((W^ SHR 10) AND $003E) + (W^ AND $7C0);
    Inc(W);
  end;
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




Procedure LoadTexture(const F: File; var FHead: TFHead; var Pic: TDIB; var Pos: Integer);
var Pal: Array of DWord; Buf: Pointer;
begin
    FHead.Pos:=Pos;
    Seek(F, Pos);// Inc(Pos,208);
    BlockRead(F, FHead, 208);
    If FHead.Bpp<=8 then
    begin
      Seek(F,Pos+208);
      //Inc(Pos,(1 SHL FHead.Bpp)*4);
      SetLength(Pal, 1 SHL FHead.Bpp);
      BlockRead(F, Pal[0], (1 SHL FHead.Bpp)*4);
      Seek(F, Pos+(1 SHL FHead.Bpp)*4+208);
    end else
    begin
      Seek(F,Pos+208);
    end;

    {If not Assigned(Pic) then} Pic:=TDIB.Create;
    If FHead.Bpp<=8 then
    begin
      Pic.PixelFormat:=MakeDibPixelFormat(8,8,8)
    end else if FHead.Bpp=16 then
    begin
      Pic.PixelFormat:=MakeDibPixelFormat(5, 6, 5);
    end;
//If FHead.Bpp>16 then
      //FHead.Bpp:=24;
    Pic.BitCount:=FHead.Bpp;
    Pic.Width:=FHead.Width;
    Pic.Height:=FHead.Height;
    GetMem(Buf,(FHead.Height * FHead.Width * FHead.Bpp) div 8);
    BlockRead(F, Buf^,(FHead.Height * FHead.Width * FHead.Bpp) div 8);
    //If FHead.Bpp>8 then Flip(Buf,FHead.Height * FHead.Width);
    RawToDib(Pic, Buf);
    If FHead.Bpp<=8 then SetPallete(Pic, Pal);
    FreeMem(Buf);
    //Inc(Pos,(FHead.Height * FHead.Width * FHead.Bpp) div 8);
    Inc(Pos,FHead.Size+12{-260});
end;



end.
