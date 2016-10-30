program Pack_ff;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, Packer;

{Function Pack(var Buf: Pointer; Size: Integer; Lev: Word): Integer;
var BW: Pointer; W: ^Word; B: ^Byte; DW: ^DWord; CurSize, ASize: DWord;
Pos, CPos, CRPos, BPos, RPos, WPos: ^Word; BestRes: Word; lv, Cnt: Integer;
n,m,l: Integer;
UDWord: ^DWord;
begin
  GetMem(BW, Size+(Size div 64)+8);
  Pos:=Addr(Buf^);
  Inc(Pos,$800);
  WPos:=Addr(BW^);
  WPos^:=$7057; Inc(WPos); WPos^:=$3631; Inc(Wpos);
  WPos^:=Size AND $0000FFFF; Inc(WPos); WPos^:=Size SHR 16; Inc(WPos);
  CurSize:=0;
  ASize:=8;
  While CurSize<Size do
  begin
    UDWord:=Addr(WPos^);
    UDWord^:=0;
    Inc(WPos,2);
    Inc(ASize,4);
    For n:=0 to 31 do
    begin
      UDWord^:=UDWord^ SHR 1;
      BestRes:=0;
      //-
      RPos:=Addr(Pos^);
      If CurSize<lev*2 then lv:=CurSize div 2+8 else lv:=lev;
      Inc(RPos, -lv);
      For m:=0 to lv-1 do
      begin
        If BestRes>=32 then break;
        If RPos^=Pos^ then
        begin
          CPos:=Addr(Pos^);
          CRPos:= Addr(RPos^);
          Inc(CPos); Inc(CRPos);
          Cnt:=1;
          While (CPos^=CRPos^) and (Cnt<=32) and (CRPos<>Pos) and (CurSize+Cnt<Size) do
          begin
            Inc(CPos); Inc(CRPos);  Inc(Cnt);
          end;
          If {Integer(CRPos)-Integer(RPos)+1}//Cnt>=BestRes then
          //begin
          //  BestRes:=Cnt{Integer(CRPos)-Integer(RPos)-1};
          //  BPos:=Addr(RPos^);
          {end;
        end;
        Inc(RPos);
      end;

      //If BestRes>=31 then WriteLn(IntToStr(BestRes));
      If BestRes>1 Then
      begin
       // WPos^:=(((Integer(Pos)-Integer(BPos){-1}//) div 2) SHL 5)+BestRes-2;
        {Inc(WPos);
        Inc(CurSize,(BestRes-1)*2);
        Inc(ASize,2);
        Inc(Pos, BestRes);
      end else
      begin
        Inc(UDWord^,$80000000);
        WPos^:=Pos^;
        Inc(WPos); Inc(Pos);
        Inc(ASize,2); Inc(CurSize,2);
      end;
      //WriteLn(IntToHex(UDWord^,8));
      If CurSize>Size then break;
    end;
  end;
  Result:=ASize;
  FreeMem(Buf);
  Buf:=BW;
end;  }



var UnpBuf: Pointer;  F: File; S, Size: DWord; Level: Word; B: ^Byte; DW: ^DWord;
n: integer;
begin
  If ParamStr(1)='' then
  begin
    WriteLn('Usage: Pack_ff.exe in_file [out_file] [copression buffer (0-2048)]');
    Exit;
  end;
  If (ParamStr(3)='') or (StrToInt(ParamStr(3))>2048) or (StrToInt(ParamStr(3))<0) then
  begin
    Level:=2047
  end else
  begin
    Level:=StrToInt(ParamStr(3));
  end;
  If Level=2048 then Level:=2047;
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  Size:=FileSize(F);
  GetMem(UnpBuf, FileSize(F)+$1000);
  B:=Addr(UnpBuf^);
  Inc(B, $1000);
  BlockRead(F, B^, FileSize(F));
  CloseFile(F);
  DW:=Addr(UnpBuf^);
  For n:=0 to $3FF do
  begin
    DW^:=0;
    Inc(DW);
  end;

  If ParamStr(2)='' Then AssignFile(F, ParamStr(1)+'.PCK')
  else AssignFile(F, ParamStr(2));
  Rewrite(F,1);
  Size:=Pack(UnpBuf, Size, Level);
  BlockWrite(F, UnpBuf^, Size);
  FreeMem(UnpBuf);
  Close(F);
end.
