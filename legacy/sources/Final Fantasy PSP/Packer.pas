unit Packer;


interface
uses
  SysUtils, Windows;
  
Procedure UnPack(var Buffer: Pointer);
Function Pack(var Buf: Pointer; Size: Integer; Lev: Word): Integer;
implementation

Function Pack(var Buf: Pointer; Size: Integer; Lev: Word): Integer;
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
          If {Integer(CRPos)-Integer(RPos)+1}Cnt>=BestRes then
          begin
            BestRes:=Cnt{Integer(CRPos)-Integer(RPos)-1};
            BPos:=Addr(RPos^);
          end;
        end;
        Inc(RPos);
      end;

      //If BestRes>=31 then WriteLn(IntToStr(BestRes));
      If BestRes>1 Then
      begin
        WPos^:=(((Integer(Pos)-Integer(BPos){-1}) div 2) SHL 5)+BestRes-2;
        Inc(WPos);
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
end;


Procedure UnPack(var Buffer: Pointer);
var BW: pointer; B: ^byte; W, Pos, RPos, WPos: ^Word;
CByte, Size, CurSize: DWord; DW: ^DWord; Flag: Boolean;
n, m: Integer;  Back, TW: Word; Count: byte;
begin
  CurSize:=0;
  DW:=Addr(Buffer^);
  Inc(DW); Size:=DW^;
  GetMem(BW,Size); Inc(DW);
  Pos:=Addr(Buffer^);
  WPos:=Addr(BW^);
  While CurSize<Size do
  begin
    CByte:=DW^;
    Pos:=Addr(DW^);
    Inc(Pos,2); Inc(DW,17);
    For n:=0 to 31 do
    begin
      If CurSize>Size then break;
      Flag:=Boolean((CByte shr n) and 1); //Выдвигаем байт
      If Flag=True then //Если 1, то просто копируем
      begin
        WPos^:=Pos^;
        Inc(Wpos); Inc(Pos); Inc(CurSize,2);
      end else
      begin
        B:=Addr(Pos^);
        Count:=B^; Back:=B^; Inc(B); TW:=B^;
        Back:=(Back SHR 5)+(TW SHL 3);
        Count:=Count AND $1F;
        If Back=0 then Back:=$7FF;
        RPos:=Addr(WPos^);
        Inc(RPos, -Back);
        For m:=0 to Count+1 do
        begin
          If Back*2<=CurSize then WPos^:=RPos^
          else WPos^:=0;
          Inc(WPos); Inc(RPos); Inc(CurSize, 2);
        end;
        Inc(Pos);
      end;
    end;
  end;
  FreeMem(Buffer);
  Buffer:=BW;
end;

end.
 