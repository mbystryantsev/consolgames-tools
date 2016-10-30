unit FFT;

interface

uses Windows, FF7_Common, FF7_Text,SysUtils;

Function FFT_LZ_Decompress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
Function FFT_LZ_Compress(Buf: Pointer; var WBuf: Pointer; Size: Integer; level: Word = $FE1): Integer;
Procedure FFT_ExtractMainText(Buf: Pointer; Size: Integer; Table: TTableArray; var Text: TText);
implementation


{
  ((((Back - (Back SHR 7)) SHR 1) - (Back SHR 7)) SHR 7) AND $F;
}
Function FFT_LZ_Compress(Buf: Pointer; var WBuf: Pointer; Size: Integer; level: Word = $FE1): Integer;
var Pos, WPos,RPos,BestLink,n,m,MaxC,C,Link: Integer; Count,BestRes,Back: Word;
RB, B, WB, RPs, NPs: ^Byte;
begin
  C:=level; If C>$FE1 Then C:=$FE1;
  GetMem(WBuf, $40000);
  B:=Addr(Buf^);
  WB:=Addr(WBuf^);
  While DWord(B)-DWord(Buf)<=Size do
  begin
    Link:=(DWord(B)-DWord(Buf))-C;
    If Link<0 Then Link:=0;
    BestRes:=0;
    For n:=Link to (DWord(B)-DWord(Buf))-1 do
    begin
      NPs:=Pointer(DWord(Buf)+(DWord(B)-DWord(Buf)));
      RPs:=Pointer(DWord(WBuf)+n);
      Count:=0;
      While (not (RPs^ in [$F0..$F4])) and (DWord(RPs)-DWord(WBuf)<(DWord(B)-DWord(Buf))) and (RPs^<>$FE) and (Count<$43) do
      begin
        If NPs^=RPs^ Then Inc(Count) else Break;
        Inc(NPs); Inc(RPs);
      end;
      If Count>=BestRes Then
      begin
        BestRes:=Count;
        BestLink:=n;
      end;
    end;
    If BestRes>3 then
    begin
      If BestRes>$43 Then BestRes:=$43;
      WB^:=$F0+((BestRes-4) SHR 3) AND $7;
      Inc(WB);
      WB^:=((BestRes-4) SHL 5) and $E0;
      Back:=(DWord(WB)-DWord(WBuf))-BestLink-1; //!!!
      WB^:=WB^ OR (((((Back - (Back SHR 7)) SHR 1) - (Back SHR 7)) SHR 7) AND $F);
      Inc(WB);
      WB^:=Back AND $FF;
      Inc(WB);
      Inc(B, BestRes);
    end else
    begin
      WB^:=B^;
      Inc(WB); Inc(B);
    end;
  end;
  Result:=DWord(WB)-DWord(WBuf)-1;//WPos-1;
  ReallocMem(WBuf,Result);
end;

{
(B0 AND 3) SHL 3
B1 SHR 5 + rB0 + 4 // 7
B1 And $F              // 0
((rB1 SHL 7 - rB1) SHL 1 + B2 : Link
}
Function FFT_LZ_Decompress(inBuf: Pointer; var outBuf: Pointer; Size: Integer): Integer;
var WB, B: ^Byte; Back,Count: Word;
begin
  GetMem(outBuf, $40000);
  B:=Addr(inBuf^); WB:=Addr(outBuf^);
  While (DWord(B)-DWord(inBuf)<Size) do
  Begin
    If (B^>=$F0) and (B^<$F4) then
    begin
      Count:=(B^ AND 3) SHL 3; Inc(B);
      Count:=(B^ SHR 5) + Count + 4;
      Back:=B^ AND $F; Inc(B);
      Back:=(((Back SHL 7) - Back) SHL 1) + B^; Inc(B);
	    Move(Pointer(DWord(B)-Back-2)^,WB^,Count);  Inc(WB,Count);
    end else begin WB^:=B^; Inc(B); Inc(WB); end;
  end;
  Result:=DWord(WB)-DWord(outBuf);
  ReallocMem(outBuf,Result);
end;

Function CheckTextBlock(P: Pointer): Boolean;
var DW: ^DWord; B: ^Byte;
begin
  DW:=P; Result:=False;
  If (DW^=$F2F2F2F2) or (DW^>=$2000-5) Then Exit else
  begin
    B:=Pointer(DWord(P)+DW^-1);
    If B^<>$DB Then Exit else Result:=True;
  end;
end;

Procedure FFT_ExtractText(P: Pointer; Size: Integer; Table: TTableArray; var Text: TText; ID: Integer);
var B: ^Byte; DW: ^DWord; n: Integer; W: ^Word;
begin
  B:=P;
  For n:=0 To High(Integer) do
  begin
    If DWord(B)-DWord(P)>=Size Then Break;
    SetLength(Text[ID].S,n+1);
    Inc(B,ExtractText(B,Table,Text[ID].S[n].Text,False,$FE));
    W:=Addr(B^);
    If W^=0 Then Break;
    DW:=Addr(B^); If DW^=$F2F2F2F2 Then Break;
  end;
end;

Procedure FFT_ExtractMainText(Buf: Pointer; Size: Integer; Table: TTableArray; var Text: TText);
var n,Count: Integer; DW: ^DWord;
begin
  Count:=0;
  For n:=0 To (Size div $2000)-1 do
  begin
    If CheckTextBlock(Pointer(DWord(Buf)+$2000*n)) Then
    begin
      SetLength(Text,Count+1);
      DW:=Pointer(DWord(Buf)+$2000*n);
      Text[Count].Name:=Format('%.4x:%.8x',[n,DW^]);
      FFT_ExtractText(Pointer(DWord(Buf)+n*$2000+DW^),$2000,Table,Text,Count);
      Inc(Count);
    end;
  end;
end;

end.
