unit PSPRAW;

interface
uses DIB, Windows, SysUtils, Graphics;


  Type
    TCharName = Array[0..63] of Char;
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
    Name: TCharName;
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
Function GetName(Name: TCharName): String;
Procedure LoadTexture(const F: File; var FHead: TFHead; var Pic: TDIB; var Pos: Integer; SkipImage: Boolean = False);
Procedure SetPal(var Pic: TDIB; Pal: Array of DWord);
Procedure DibToRaw(var pic: TDIB; Buf: Pointer; bpp8to4: boolean = False);
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
var SL, B: ^Byte; Wrd: Word; n,m,r,l,d,BitCount: Integer;
begin
  BitCount:=Pic.BitCount;
  If BitCount>=32 Then BitCount:=16;
  B:=Addr(Buf^);
  Wrd:= RoundBy(Pic.Height,8);
  For r:=0 to  (Wrd div 8) -1 do
    For l:=0 to (Pic.Width div (128 div BitCount)) -1 do
    begin
      Wrd:=GetW(Pic.Height, R)-1;
      For m:=r*8 to r*8+{7} Wrd  {Pic.Height-r*8}    do
      begin
        SL:=Addr(Pic.ScanLine[m]^);
        If Pic.BitCount = 32 Then Inc(SL,l*32) else Inc(SL,l*16);
        For n:=l*16 to l*16+15 do
        begin
            If BitCount>=16 Then
            begin
              If n and 1 = 0 Then
              begin
                Byte(Pointer(DWord(SL)+1)^):=B^ AND $F0;
                Byte(Pointer(DWord(SL)+2)^):=B^ SHL 4; Inc(B);
                Byte(Pointer(DWord(SL)+3)^):=B^ AND $F0;
                Byte(Pointer(DWord(SL)+0)^):=B^ SHL 4; Inc(B); Inc(SL,4);
              end;
            end else
            If BitCount=4 then
            begin
              SL^:=B^ SHR 4;
              SL^:=SL^ + ((B^ SHL 4) AND $F0);
              Inc(B); Inc(SL);
            end else if BitCount=2 then
            begin
            end else if BitCount=1 then
            begin
            end else
            begin
              SL^:=B^;
              Inc(B); Inc(SL);
            end;
        end;

      end;
      If wrd<>7 then Inc(B,(7-wrd)*16);
    end;
end;

Procedure DibToRaw(var pic: TDIB; Buf: Pointer; bpp8to4: boolean = False);
var SL, B: ^Byte; Wrd: Word; n,m,r,l,d, BitCount: Integer;
begin
  BitCount:=Pic.BitCount;
  If BitCount>=24 Then BitCount:=16;
  If bpp8to4 Then BitCount:=4;
  B:=Addr(Buf^);
  Wrd:= RoundBy(Pic.Height,8);
  For r:=0 to  (Wrd div 8) -1 do
    For l:=0 to (Pic.Width div (128 div BitCount)) -1 do
    begin
      Wrd:=GetW(Pic.Height, R)-1;
      For m:=r*8 to r*8+{7} Wrd  {Pic.Height-r*8}    do
      begin
        SL:=Addr(Pic.ScanLine[m]^);
        If Pic.BitCount = 24 Then Inc(SL,l*24) else If bpp8to4 Then Inc(SL,l*32) else Inc(SL,l*16);
        For n:=l*16 to l*16+15 do
          begin
            If BitCount>=16 Then
            begin
              If n and 1 = 0 Then
              begin
                B^:=Byte(Pointer(DWord(SL)+1)^) AND $F0;
                B^:=B^ or (Byte(Pointer(DWord(SL)+2)^) SHR 4); Inc(B);
                B^:=B^ AND $F0;
                B^:=B^ or (Byte(Pointer(DWord(SL)+0)^) SHR 4); Inc(B);
                Inc(SL,3);
              end;
            end else
            If BitCount=4 then
            begin
              If bpp8to4 Then
              begin
                B^:=SL^ AND $F; Inc(SL);
                B^:=B^ + (SL^ AND $F) SHL 4;
              end else
              begin
                B^:=SL^ SHL 4;
                B^:=B^ + ((SL^ SHR 4) AND $0F);
              end;
              Inc(B); Inc(SL);
            end else if BitCount=2 then
            begin
            end else if BitCount=1 then
            begin
            end else
            begin
              B^:=SL^;
              Inc(B); Inc(SL);
            end;
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

Function GetName(Name: TCharName): String;
begin
  Result:=PChar(@Name);
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




Procedure LoadTexture(const F: File; var FHead: TFHead; var Pic: TDIB;
var Pos: Integer; SkipImage: Boolean = False);
var Pal: Array of DWord; Buf: Pointer;
begin
    FHead.Pos:=Pos;
    Seek(F, Pos);// Inc(Pos,208);
    BlockRead(F, FHead, 208);
    If SkipImage Then
    begin
      Inc(Pos,FHead.Size+12);
      Exit;
    end;

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
    //If FHead.Bpp<=8 then
    //  Pic.PixelFormat:=MakeDibPixelFormat(8,8,8)
    If FHead.Bpp=16 Then
      Pic.BitCount := 32
    else
      Pic.BitCount:=FHead.Bpp;
    Pic.Width:=FHead.Width;
    Pic.Height:=FHead.Height;
    GetMem(Buf,(FHead.Height * FHead.Width * FHead.Bpp) div 8);
    BlockRead(F, Buf^,(FHead.Height * FHead.Width * FHead.Bpp) div 8);
    //If FHead.Bpp>8 then Flip(Buf,FHead.Height * FHead.Width);
    RawToDib(Pic, Buf);
    If FHead.Bpp<=8 then SetPal(Pic, Pal); //!!!
    FreeMem(Buf);
    //Inc(Pos,(FHead.Height * FHead.Width * FHead.Bpp) div 8);
    Inc(Pos,FHead.Size+12{-260});
end;



end.
