unit SH5_SYTGFX;

interface

uses DIB, SH5_Common, TBXGraphics;

Type
  DWord = LongWord;


Procedure RawToPic32(Pic: TDIB; P: Pointer; W,H: Integer);
Procedure RawToPic2(Pic: TDIB; P: Pointer; W,H: Integer; BigEndian: Boolean = False);
Function Color16To32(C: Word): DWord;
Function DivColor32(C: DWord; D: Real): DWord;
implementation

Procedure MoveP(var src,dest; Len: Integer; Paste: Boolean);
begin
  If Paste Then Move(src,dest,Len) Else Move(dest,src,Len);
end;

{
    With pBG.ColorTable[n] do
    begin
      rgbRed   := Round(((rgbRed*A)/  100) + ((R*(100-A)) / 100));
      rgbGreen := Round(((rgbGreen*A)/100) + ((G*(100-A)) / 100));
      rgbBlue  := Round(((rgbBlue*A)/ 100) + ((B*(100-A)) / 100));
    end;}

Function Color16To32(C: Word): DWord;
const
  b5 = 8.2258;
  b6 = 4.0476;
begin
  Result := Round((C AND $1F) * b5) or
  (Round(((C SHR 5) AND $3F) * b6 {SHL 10}) SHL 8) or
  (Round(((C SHR 11) AND $1F) * b5{SHL 19}) SHL 16);
end;

Procedure TileToPic(Pic: TDIB; P: Pointer; X,Y,W,H,TW,TH: Integer; RC: Boolean = False; Paste: Boolean = False);
var n,m,l,r,BitCount,ByteCount: Integer; B,WB: ^{Byte}DWord;  TWc,THc: Integer;
Side: Boolean; Incr,Len: Integer;
begin
  Side:=True;
  BitCount:=32;
  B:=P;
  Incr:=4*W*(TW div 2);
  Len:=W*(BitCount div 8);
  If RC Then THc:=TW else THc:=TH;
  If RC Then TWc:=TH else TWc:=TW;
  ByteCount:=W*BitCount div 8;
  For l:=0 To THc-1 do
  begin
    For r:=0 To TWc-1 do
    begin
      If ((l*TW+r) AND $1F)=0 Then Side:=not Side;
      For m:=0 To H-1 do
      begin
        WB:=Pointer(DWord(Pic.ScanLine[Y+m+l*H])+X*4+r*W*(BitCount div 8));
        If Side Then
        begin
          If r<(TW div 2) Then
            MoveP(B^,Pointer(DWord(WB) + Incr)^,Len,Paste)
          else
            MoveP(B^,Pointer(DWord(WB) - Incr)^,Len,Paste);
        end
        else
          MoveP(B^,WB^,Len,Paste);
        Inc(B,ByteCount div 4);
      end;
    end;
  end;
end;

Procedure RawToPic32(Pic: TDIB; P: Pointer; W,H: Integer);
var n,m: Integer;
begin
  Pic.BitCount:=32;
  Pic.Height:=H;
  Pic.Width:=W;
  H:=RoundBy(H,32);
  W:=RoundBy(W,32);
  For m:=0 To (H div 32)-1 do
  For n:=0 To (W div 32)-1 do
  begin
    TileToPic(Pic, P,n*32,m*32,4,2,8,16,False,True);
    Inc(DWord(P),32*32*4);
  end;
end;

Procedure PicToRaw32(Pic: TDIB; P: Pointer; W,H: Integer);
var n,m: Integer;
begin
  For m:=0 To (H div 32)-1 do
  For n:=0 To (W div 32)-1 do
  begin
    TileToPic(Pic, P,n*32,m*32,4,2,8,16);
    Inc(DWord(P),32*32*4);
  end;
end;


Type TRGB = Record R,G,B,A: Byte; end;
Function DivColor32(C: DWord; D: Real): DWord;
begin
  Result:=C;
  With TRGB(Result) do
  begin
    R := Round(R / D);
    G := Round(G / D);
    B := Round(B / D);
  end;
end;

Procedure DecodeBlock2(Pic: TDIB; P: Pointer; X,Y,W,H: Integer; BigEndian: Boolean = False);
Type TRGBAArray = Array[0..3] of Byte;
var n,m: Integer; DW: ^DWord; A: Word; AA: ^Word; WW: ^Word; B: ^Byte; Color: Array[0..3] of DWord;
C: Word;   Num: Integer;
begin
  B := P;
  AA := P;
  WW := P;
  Inc(B,12);
  Inc(WW,4);
  Color[0]:=Color16To32(GetEndianW(WW^, BigEndian)); Inc(WW);
  Color[1]:=Color16To32(GetEndianW(WW^, BigEndian)); Inc(WW);
  Color[2]:=DivColor32(Color[0],1.5);
  Color[3]:=DivColor32(Color[0],3.0);

  For m:=0 To 3 do
  begin
    DW:=Pointer(DWord(Pic.ScanLine[Y+m])+X*4);
    For n:=0 To 3 do
    begin
      DW^:=Color[(B^ SHR (n*2)) and 3];
      A := GetEndianW(AA^,BigEndian);
      DW^ := DW^ or ((((A SHR (n*4)) AND $F)*$11) SHL 24);
      Inc(DW);
    end;
    Inc(B);
    Inc(AA);
  end;
end;

Procedure RawToPic2(Pic: TDIB; P: Pointer; W,H: Integer; BigEndian: Boolean = False);
var n,m: Integer;
begin
  Pic.BitCount:=32;
  Pic.Height:=H;
  Pic.Width:=W;
  H:=RoundBy(H,4);
  W:=RoundBy(W,4);
  For m:=0 To (H div 4)-1 do
  For n:=0 To (W div 4)-1 do
  begin
    DecodeBlock2(Pic, P, n*4, m*4, W, H, BigEndian);
    Inc(DWord(P),16);
  end;
end;

end.
