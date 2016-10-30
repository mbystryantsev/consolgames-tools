unit FFTPacker;

interface
uses
  SysUtils, Windows, Dialogs;
Function Decompress(var Buf: Pointer; Size: Integer): Integer;
implementation

Function Decompress(var Buf: Pointer; Size: Integer): Integer;
var WBuf: Pointer; WB, B, RB: ^Byte; Pos, WPos, n: Integer;
Back: Word; Count, Tmp: Byte;
begin
  GetMem(WBuf, $40000);
  B:=Addr(Buf^);
  WB:=Addr(WBuf^);
  Pos:=0; WPos:=0;

  While (Pos<Size) {and (Pos<500) }do
  Begin
    If (B^>=$F0) and (B^<$F8) then
    begin
      Count:=(B^ SHL 4);
      //Count:=Count SHR 4;
      Inc(B);
      Count:=(Count SHR 1) + (B^ SHR 5);
      //B^:=$1;
      Tmp:=B^;
      Tmp:=Tmp SHL 3;
      Back:=TMP SHL 5;
      //ShowMessage(IntToHex(Back,4));
      Inc(B);
     // B^:=$29;
      Back:=Back + B^;
      //  If Back>255 then Back:=Back-2;
      Back:=Back-((Back-1) div $100)*2;
      Inc(B); Inc(Pos,3);
      RB:=Addr(B^);
      Inc(RB, -(Back+3));
      For n:=1 to Count+4 do
      begin
        WB^:=RB^; Inc(WB); Inc(RB);
      end;
      Inc(WPos, Count+4);
    end else
    begin
      WB^:=B^;
      Inc(B); Inc(WB); Inc(Pos); Inc(WPos);
    end;
  end;
  FreeMem(Buf);
  Buf:=WBuf;
  Result:=WPos;
end;

end.
