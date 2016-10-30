program FontPaste;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DIB;

Type
  DWord = LongWord;
  TByteArray = Array[0..3] of Byte;

Function ToMot(X: Integer; SZ: Byte): Integer;
var B,B1: TByteArray; n: Integer;
begin
  B:=TByteArray(X);
  For n:=0 To Sz-1 do
  begin
    B1[n]:=B[Sz-n-1];
  end;
  Result:=Integer(B1);
  
end;

Function SetLine(iDW, oDW: DWord; InS, OutS: Byte): DWord;
const FF: DWord = $FFFFFFFF;
begin
  If inS>outS Then Result:=iDW SHL (inS-outS)
  else Result:=iDW SHR (OutS-inS);
  Result:=oDW OR (Result AND ((FF SHR outS) and (FF SHL (outS+11))));
end;

Procedure WLn(DW: DWord; outB: Pointer; Shift: Byte);
var B: ^Byte; n: Integer;
begin
  DW:=ToMot(DW,4);
  B:=outB;
  For n:=0 To 10 do
  begin
    B^:=(DW shr ((31-Shift)-n)) AND 1;
    //WriteLn(IntToStr(B^));
    Inc(B);
  end;
end;

Procedure WriteMem(Pic: TDIB; nn: Integer);
var B: ^Byte; n,m: Integer; S: String;
begin
  For n:=0 To 10 do
  begin
    B:=Pic.ScanLine[n]; Inc(B,nn*11);
    S:='';
    For m:=0 To 10 do
    begin
      If Boolean(B^) Then S:=S+'1' else S:=S+'0';
      Inc(B);
    end;
    WriteLn(S);
  end;
end;

Function DibToBit(P: Pointer; var Pic: TDIB): Integer;
var n,m,X,Y: Integer; iDW, oDW: ^DWord; Shift: Integer;  B,WB: ^Byte;
begin
  Result:=0;
  WB:=P;
  For m:=0 To (Pic.Height div 11)-1 do
    For n:=0 To (Pic.Width div 11)-1 do
    begin
      Shift:=7;
      WB^:=0;//WriteMem(Pic,n);
      For Y:=m*11 To m*11+10 do
      begin
      B:=Pic.ScanLine[Y]; Inc(B,n*11);
        For X:=n*11 to n*11+10 do
        begin
          If Shift<0 Then
          begin
            Inc(Result);
            Inc(WB); WB^:=0; Shift:=7;
          end;
          //B^:=$01;
          If Boolean(B^) Then Inc(WB^,1 SHL Shift);
          Dec(Shift); Inc(B);
        end;
      end;
      Inc(WB);
    end;
    If Shift<7 Then Inc(Result);
end;

Procedure BitToDib(P: Pointer; var Pic: TDIB);
var n,m,Y: Integer; iDW, oDW: ^DWord; Shift: Byte;
begin
  For m:=0 To (Pic.Height div 11)-1 do
    For n:=0 To (Pic.Width div 11)-1 do
    begin
       Shift:=0;
      iDW:=P; Inc(DWord(iDW),m*256+n*16);
      For Y:=m*11 To m*11+10 do
      begin
        oDW:=Pic.ScanLine[Y]; Inc(DWord(oDW),n*11);
        WLn(iDW^,oDW,Shift);
        Inc(Shift,11);
        While Shift>7 do
        begin
          Inc(DWord(iDW));
          Dec(Shift,8);
        end;
      end;
    end;
end;

var Pic: TDIB; F: File; Buf: Pointer; Size: Integer;
begin
  WriteLn('Silent Hill: Play Novel font paster by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');
  If ParamCount<2 Then
  begin
    WriteLn('FontExtract.exe "Play Novel.gba" Font.bmp');
  end;
  If not FileExists(ParamStr(1)) or not FileExists(ParamStr(2)) Then
  begin
    WriteLn('File not found!');
    Beep;
    Exit;
  end;
  Pic:=TDIB.Create;
  Try
    Pic.LoadFromFile(ParamStr(2));
  except
    Beep;
    WriteLn('Error! Unable to open font file!');
    Pic.Free;
    Exit;
  end;
  GetMem(Buf,$100000);
  //BlockRead(F,Buf^,$100000);
  Size:=DibToBit(Buf, Pic);
  Pic.Free;
  AssignFile(F,ParamStr(1));
  Reset(F,1);
  Seek(F,$215858);
  BlockWrite(F, Buf^, Size);
  FreeMem(Buf);
end.
 