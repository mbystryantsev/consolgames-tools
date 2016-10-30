unit LNBPass;

interface

uses SysUtils, Windows;

Type
  TByteArray = Array of Byte;
  TSaveEquiped = Packed Record
    ePunch,
    eSword,
    eShield,
    eRobe,
    eTalisman,
    eAmulet,
    eLight,
    eTStars,
    eTreasure,
    eBells: Byte;
  end;
  TSaveItems = Packed Record
    iBattery,
    iWhirlyBird,
    iMedicine,
    iSweetBun,
    iMeatBun,
    iDragstar,
    iSkBoard,
    iBooBomb: Byte;
  end;

  TSaveData = Packed Record
    sLoc:           Byte;
    sCities:        Array[0..1] of Byte;
    sUsedTr:        Byte;
    sJKicks:        Byte;
    sM,sTStars:     Byte;
    sExp:           Array[0..1] of Byte;
    sMoney:         Array[0..3] of Byte;
    sEq:            TSaveEquiped;
    sIt:            TSaveItems;
    sLU:            Array[0..5] of Byte;
  end;
  TRamLinks = Array[0..30] of ^Byte;
  TLevelData = Packed Record
    Exp:          Word;
    MaxHP,Attack: Byte;
  end;

var Ram:  TRamLinks;
    Save: TSaveData;
    Pass: Array[0..47] of Byte;

const
  cEqPunch: Array[0..8] of String =
  ('Nothing','Iron Claw','Crush Punch','Mega Punch','Fire Punch',
   'Blunt Punch','Golden Claw','Lee'#$27's Punch','Prism Claw');
  cEqSword: Array[0..5] of String =
  ('Nothing','Hawk Sword','Hawk Sword','Tiger Sword','Eagle Sword',
   'Prism Sword');
  cEqShield:Array[0..4] of String =
  ('Nothing','Scale Shield','Mirror Shield','Fire Shield','Prism Shield');
  cEqRobe:  Array[0..4] of String =
  ('Nothing','White Robe','Black Robe','Lee'#$27's Robe','Sacred Robe');
  cEqTalisman:Array[0..7] of String =
  ('Nothing','Talisman-a','Talisman-B','Talisman ???','Talisman-Y',
   'Talisman-E','Talisman-Omega','Talisman ???');
  cEqPendant:Array[0..6] of String =
  ('Nothing','Amulet-I','Amulet-II','Amulet ???','Amulet ???',
   'Amulet-III','Amulet-IV');
  cEqLight: Array[0..4] of String =
  ('Nothing','Match','Candle','Torch','Piece of the Sun');
  cEqAmulet: Array[0..6] of String =
  ('Nothing','Amulet-I','Amulet-II','Amulet ???','Amulet ???',
   'Amulet-III','Amulet-IV');


  cLevelData: Array[1..50] of TLevelData = (
    (Exp: 00000; MaxHP: 010; Attack: 01),
    (Exp: 00015; MaxHP: 014; Attack: 02),
    (Exp: 00080; MaxHP: 017; Attack: 03),
    (Exp: 00210; MaxHP: 019; Attack: 04),
    (Exp: 00390; MaxHP: 030; Attack: 05),
    (Exp: 00590; MaxHP: 035; Attack: 06),
    (Exp: 00840; MaxHP: 038; Attack: 07),
    (Exp: 01140; MaxHP: 040; Attack: 08),
    (Exp: 01500; MaxHP: 042; Attack: 09),
    (Exp: 01900; MaxHP: 044; Attack: 10),
    (Exp: 02300; MaxHP: 047; Attack: 11),
    (Exp: 02700; MaxHP: 060; Attack: 12),
    (Exp: 03100; MaxHP: 065; Attack: 13),
    (Exp: 03500; MaxHP: 068; Attack: 14),
    (Exp: 04000; MaxHP: 070; Attack: 15),
    (Exp: 04550; MaxHP: 074; Attack: 16),
    (Exp: 05150; MaxHP: 076; Attack: 17),
    (Exp: 05800; MaxHP: 092; Attack: 18),
    (Exp: 06500; MaxHP: 100; Attack: 19),
    (Exp: 07100; MaxHP: 105; Attack: 20),
    (Exp: 07700; MaxHP: 108; Attack: 21),
    (Exp: 08300; MaxHP: 112; Attack: 22),
    (Exp: 09050; MaxHP: 115; Attack: 23),
    (Exp: 09950; MaxHP: 118; Attack: 24),
    (Exp: 10850; MaxHP: 148; Attack: 25),
    (Exp: 11850; MaxHP: 155; Attack: 26),
    (Exp: 12850; MaxHP: 158; Attack: 27),
    (Exp: 14150; MaxHP: 180; Attack: 28),
    (Exp: 15750; MaxHP: 186; Attack: 29),
    (Exp: 17650; MaxHP: 190; Attack: 30),
    (Exp: 19750; MaxHP: 195; Attack: 31),
    (Exp: 21950; MaxHP: 199; Attack: 32),
    (Exp: 24250; MaxHP: 202; Attack: 33),
    (Exp: 26650; MaxHP: 204; Attack: 34),
    (Exp: 29050; MaxHP: 207; Attack: 35),
    (Exp: 31450; MaxHP: 211; Attack: 36),
    (Exp: 33850; MaxHP: 215; Attack: 37),
    (Exp: 36350; MaxHP: 218; Attack: 38),
    (Exp: 38850; MaxHP: 220; Attack: 39),
    (Exp: 41350; MaxHP: 224; Attack: 40),
    (Exp: 43850; MaxHP: 227; Attack: 41),
    (Exp: 46350; MaxHP: 230; Attack: 42),
    (Exp: 48850; MaxHP: 235; Attack: 43),
    (Exp: 51350; MaxHP: 239; Attack: 44),
    (Exp: 53850; MaxHP: 242; Attack: 45),
    (Exp: 56350; MaxHP: 245; Attack: 46),
    (Exp: 58850; MaxHP: 248; Attack: 47),
    (Exp: 61350; MaxHP: 250; Attack: 48),
    (Exp: 63850; MaxHP: 253; Attack: 49),
    (Exp: 65535; MaxHP: 255; Attack: 50));

    cPassChain: String = '-BCDsFGH+JKLMNcPQRSTtVWXYZ234567';


Function ShowArr(A: TByteArray; S: String = ' '): String;
Procedure PassToBin(S: String; var A: TByteArray);
Procedure DecPass(var A: TByteArray);
Function GetCheckSum(const src; Count: Integer): DWord;
Function GetData(A: TByteArray; var D: TByteArray; I: Byte = 0): Integer;
Function GetSaveData(A: TByteArray): DWord;
Function GetLevel(Exp: Word): Byte;
Procedure GeneratePassword(Decr: Byte = $FF; Original: Boolean = False);
Function ShiftRigth(var A: TByteArray; VC: Boolean;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
Function ShiftValRigth(var A: TByteArray; V: Integer; Count: Byte;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
Function ShiftLeft(var A: TByteArray; VC: Boolean;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
Function ShiftValLeft(var A: TByteArray; V: Integer; Count: Byte;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
Function GetCRCLen(pLen: Byte): Integer;
implementation

const
  cDataLen: Array[0..35] of Byte = (
  {8,}8,7,8,8,8,8,1,7,{8,}8,2,3,4,4,2,
  4,2,{8,}3,4,3,4,3,1,3,1,{6,}3,4,3,4,
  4,1,8,8,8,8,8,8);

  cAdrs: Array[0..29] of Word = (
  $0421, $0447, $0436, $0431, $0437, $0432, $0438, $0400,
  $0454, $0455, $042A, $042B, $0439, $0457, $0445, $0446,
  $043B, $0450, $043C, $044F, $043D, $044E, $043E, $044D,
  $043F, $044C, $0444, $0449, $044A, $044B);

Function GetCheckSum(const src; Count: Integer): DWord;
var n,m: Integer; V: Byte; B: ^Byte; C: Boolean; Ac: Word;
begin
  Result:=0; Ac:=0; V:=0;
  B:=Addr(Src);
  For m:=1 To Count do
  begin
    Ac:=0;
    V:=m;
    C:=Boolean(V and 1);
    V:=V SHR 1;
    For n:=0 to 7 do
    begin
      If C Then Inc(Ac,B^);
      C:=Boolean(V and 1);  V:=V SHR 1;
      V:=V or (Ac SHL 7);
      Ac:=Ac SHR 1;
      //Write('(', V, ',', Ac, ',', Byte(c), ') ');
    end;
    Inc(Result,V+(Ac SHL 8));
    Inc(B);
    //WriteLn(': ', V, ' ', Result);
  end;
end;

Function RoundBy(Val,R: Integer): Integer;
begin
  Result:=(Val div R)*R;
  If Result<>Val Then Inc(Result,R);
end;

(*

$BC80:98        TYA
$BC81:48        PHA
$BC82:A0 08     LDY #$08
$BC84:A9 00     LDA #$00

$BC86:06 0D     ASL $000D = #$19
$BC88:2A        ROL
$BC89:E6 0D     INC $000D = #$19
$BC8B:38        SEC
$BC8C:E5 0C     SBC $000C = #$08
$BC8E:B0 04     BCS $BC94
$BC90:65 0C     ADC $000C = #$08
$BC92:C6 0D     DEC $000D = #$19
$BC94:88        DEY
$BC95:D0 EF     BNE $BC86

$BC97:85 0C     STA $000C = #$08
$BC99:68        PLA
$BC9A:A8        TAY
$BC9B:60        RTS
||
\/
*)

Function GetCRCLen(pLen: Byte): Integer;
{var Ac: Word; n: Integer;
begin
  Ac:=0;
  For n:=0 To 7 do
  begin
    Ac:=((Ac SHL 1) or ((pLen SHR 7) and 1)) - 8;
    pLen:=(pLen SHL 1)+1;
    If ShortInt(Ac)<0 Then
    begin
      Inc(Ac,8);
      Dec(pLen);
    end;
  end;
  Result:=pLen;
  If Ac <> 0 Then Inc(Result);  }
begin
  Result := pLen div 8;
end;

Procedure GeneratePassword(Decr: Byte = $FF; Original: Boolean = False);
var MM: Byte; Mask: Array[0..3] of Byte; A,D: TByteArray; CRC: Array[0..3] of Byte;
n,m,l,r,idx,midx: Integer; f: Real; B: Boolean; Data: Array[0..33] of Byte; pLen,opLen: Integer;
const cMLen: Array[0..3] of Byte = (8,8,8,6);
begin
  pLen:=0;
  SetLength(A,$30);
  FillChar(A[0],$30,0);
  DWord(Mask):=0;
  MM:=0;
  idx:=29;
  midx:=4;
  Randomize;
  If Decr>$1F Then Decr:=Random($20);
  //Decr:=$0D;
  FillChar(Pass,Length(Pass),$FF);
  For n:=0 to 29 do
    DWord(Mask):=DWord(Mask) or (Byte(Ram[n]^<>0) SHL n);
  For n:=3 downto 0 do
    MM:=MM or (Byte(Mask[3-n]<>0) SHL n);
  For m:=3 downTo 0 do
  begin
    If Mask[m]<>0 Then
    begin
      For n:=cMLen[m]-1 DownTo 0 do
      begin
        If Ram[idx]^<>0 Then
        begin
          ShiftValRigth(A,Ram[idx]^,cDataLen[idx],4);
          Inc(pLen,cDataLen[idx]);
        end;
        dec(idx);
      end;
      ShiftValRigth(A,Mask[m],cMLen[m],4);
      Inc(pLen,cMLen[m]);
    end else Dec(idx,cMLen[m]);
  end;

  {m := 8;
  For n:=0 To 29 do
    If Ram[n]^<>0 Then Inc(m,cDataLen[n]);
  For n:=0 To 3 do
    If Mask[n]<>0 Then Inc(m,cMLen[n]);}
  Inc(pLen, 8);
  //m:=RoundBy(m,5) div 5;
  l:=RoundBy(m,8) div 8;
  //If Original Then
  //  pLen:=GetCRCLen(RoundBy(m+8,5))
  //else
  //  pLen:=GetCRCLen({RoundBy(}m{,5)}{pLen+8});
  pLen:= pLen div 8 + 1;

  A[3]:=Decr;
  DWord(CRC):=GetCheckSum(A[3],{Length(A)-3}pLen);

  ShiftValRigth(A,CRC[2],4,0,2);
  ShiftValRigth(A,CRC[1],8,0,2);
  ShiftValRigth(A,CRC[0],8,0,2);
  A[2]:=A[2] or (MM SHL 4);


  SetLength(D,Length(Pass));
  FillChar(D[0],Length(D),0);

  //m:=RoundBy(m+8,5) div 5;
  //m:=(m+11) div 5;  
//  For n := 0 To High(A) do
//    Write(A[n], ' ');
  //If Original Then
  //  m:=(RoundBy(m,5) div 5)+(pLen-GetCRCLen(RoundBy(m,5)))
  //else
  //  m:=RoundBy(m,5) div 5;
  f := (pLen * 8) / 5;
  m := Trunc(f);
  If f = m Then Dec(m);

  For n:=m-1 downto 0 do
  begin
    ShiftValLeft(D,0,3,5);
    ShiftValLeft(D,A[4],5,5,5+m);
    For r:=0 To 4 do ShiftLeft(A,False,4);
  end;

  For n:=0 To 5 do
  begin
    ShiftValLeft(D,0,3,0,5);
    ShiftValLeft(D,A[0],5,0,5);
    For r:=0 To 4 do ShiftLeft(A,False,0,2);
  end;
  For n:=0 To High(D) do D[n]:=(D[n]+Decr) and $1F;
  //DecPass(D);

  Move(D[0],Pass,6+m);
  //For n:=6+m to .. do Pass[n]:=Decr;
end;

Function GetLevel(Exp: Word): Byte;
begin
  For Result:=1 To 50 do
    If Exp<cLevelData[Result].Exp Then Break;
  Dec(Result);
end;


Procedure PassToBin(S: String; var A: TByteArray);
var n,m: Integer; Temp: String;
begin
  Temp:='';
  For n:=1 To Length(S) do
    If S[n] in ['A'..'Z','2'..'7','s','t','c','-','+'] Then
      Temp:=Temp+S[n] else
    If S[n] = '^' Then
      Temp:=Temp+'t' else
    If S[n] = '·' Then
      Temp:=Temp+'s' else
    If S[n] = '°' Then
      Temp:=Temp+'c';
  S:=Temp;
  SetLength(A,Length(S));
  For m:=0 To High(A) do
  begin
    For n:=1 To Length(cPassChain) do
      If S[m+1]=cPassChain[n] Then
      begin
        A[m]:=n-1;
        break;
      end;
    If n>$20 Then A[n]:=255;
  end;
end;

Procedure DecPass(var A: TByteArray);
var n: Integer; D: Byte;
begin
  D:=A[5];
  For n:=0 To High(A) do
    A[n]:=$1F and (A[n]-D);
end;

Function ShowArr(A: TByteArray; S: String = ' '): String;
var n: Integer;
begin
  Result:='';
  For n:=0 To High(A)-1 do
    Result:=Format('%s%.2x%s',[Result,A[n],S]);
  Result:=Format('%s%.2x',[Result,A[High(A)]]);
end;

Function ShiftRigth(var A: TByteArray; VC: Boolean;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
var n: Integer; C: Boolean;
begin
  If ID2=0 Then ID2:=High(A);
  Result:=Boolean(A[ID2] and 1);
  For n:=ID1 To ID2 do
  begin
    C:=Boolean(A[n] and 1);
    A[n]:=A[n] SHR 1;
    If VC Then A[n]:=A[n] or $80;
    VC:=C;
  end;
end;

Function ShiftValRigth(var A: TByteArray; V: Integer; Count: Byte;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
var n: Integer; VV: Boolean;
begin
  For n:=0 To Count-1 do
  begin
    ShiftRigth(A,Boolean(V and 1),ID1,ID2);
    V:=V SHR 1;
  end;
end;

Function ShiftLeft(var A: TByteArray; VC: Boolean;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
var n: Integer; C: Boolean;
begin
  If ID2=0 Then ID2:=High(A);
  Result:=Boolean(A[ID1] SHR 7);
  For n:=ID2 DownTo ID1 do
  begin
    C:=Boolean(A[n] SHR 7);
    A[n]:=A[n] SHL 1;
    If VC Then A[n]:=A[n] or 1;
    VC:=C;
  end;
end;

Function ShiftValLeft(var A: TByteArray; V: Integer; Count: Byte;
ID1: Integer = 0; ID2: Integer = 0): Boolean;
var n: Integer; VV: Boolean;
begin
  For n:=7 downto 8-Count do
    ShiftLeft(A,Boolean((V SHR n) and 1),ID1,ID2);
end;

Function GetData(A: TByteArray; var D: TByteArray; I: Byte = 0): Integer;
var n,m,r: Integer; VC,C: Boolean; V: Byte;
begin
  Result:=0;
  SetLength(D,Length(A)-1+4);
  FillChar(D[0],Length(D),0);
  For m:=High(A) downto 6 do
  begin
    V:=A[m];
    For n:=0 To 4 do
    begin
      ShiftRigth(D,Boolean(V and 1),4);
      V:=V SHR 1;
    end;
    Inc(Result,5);
  end;
  For m:=5 downto 0 do
  begin
    V:=A[m];
    For n:=0 To 4 do
    begin
      ShiftRigth(D,Boolean(V and 1),0,3);
      V:=V SHR 1;
    end;
  end;
  D[3]:=I;
  For n:=High(D) DownTo 4 do If D[n]<>0 Then break;
  If n<High(D) Then SetLength(D,n+1);
end;

Function GetShiftVal(var A: TByteArray; BitCount: Byte;
ID1: Integer = 0; ID2: Integer = 0): Byte;
var n,m: Integer;
begin
  If ID2=0 Then ID2:=High(A);
  Result:=0;
  //A[4]:=$FF;
  For n:=0 To BitCount-1 do
  begin
    Result:=Result SHL 1;
    Result:=Result or Byte(ShiftLeft(A,False,ID1,ID2));
  end;
end;


const cMaskL: Array[0..3] of Byte = (8,8,8,6);
Function GetSaveData(A: TByteArray): DWord;
var MM,Mask: Byte; n,m,idx,midx: Integer;
begin
  mIDX:=0;
  IDX:=0;
  Result:=0;
  FillChar(Save,SizeOf(TSaveData),0);
  MM:=A[2] SHR 4;
  For m:=3 downto 0 do
  begin
    If Boolean((MM SHR m) and 1) Then
    begin
      Mask:=GetShiftVal(A,cMaskL[mIDX],4);
      Result:=(Mask SHL (mIDX*8)) or Result;
      For n:=0 to cMaskL[mIDX]-1 do
      begin
        //If IDX>=30 Then break;
        If Boolean((Mask SHR n) and 1) Then
          Ram[IDX]^:=GetShiftVal(A,cDataLen[IDX],4);
        Inc(IDX);
      end;
    end else
      Inc(IDX,8);
    Inc(mIDX);
  end;
  For n:=0 To 5 do Save.sLU[n]:=GetShiftVal(A,8,4);

end;

{
  8,7,8,8,8,8,1,7, 8,2,3,4,4,2,4,2,
  3,4,3,4,3,1,3,1, 3,4,3,4,4,1,8,8,
  8,8,8,8
}

Initialization
  With Save, sIt, sEq do
  begin
    Ram[$00]:=@sLoc;          //0421 ?(8)
    Ram[$01]:=@eBells;        //0447 7
    Ram[$02]:=@sMoney[0];     //0436 8
    Ram[$03]:=@sExp[0];       //0431 8
    Ram[$04]:=@sMoney[1];     //0437 8
    Ram[$05]:=@sExp[1];       //0432 8
    Ram[$06]:=@sMoney[2];     //0438 1
    Ram[$07]:=@sJKicks;       //0400 7
    Ram[$08]:=@sCities[0];    //0454 8
    Ram[$09]:=@sCities[1];    //0455 2
    Ram[$0A]:=@sM;            //042A 3
    Ram[$0B]:=@sTStars;       //042B 4
    Ram[$0C]:=@ePunch;        //0439 4
    Ram[$0D]:=@sUsedTr;       //0457 2
    Ram[$0E]:=@eTStars;       //0445 3(4)
    Ram[$0F]:=@eTreasure;     //0446 2
    Ram[$10]:=@eSword;        //043B 3
    Ram[$11]:=@iBooBomb;      //0450 4
    Ram[$12]:=@eShield;       //043C 3
    Ram[$13]:=@iSkBoard;      //044F 4
    Ram[$14]:=@eRobe;         //043D 3
    Ram[$15]:=@iDragstar;     //044E 1
    Ram[$16]:=@eTalisman;     //043E 3
    Ram[$17]:=@iMeatBun;      //044D 1
    Ram[$18]:=@eAmulet;       //043F 3
    Ram[$19]:=@iSweetBun;     //044C 4
    Ram[$1A]:=@eLight;        //0444 3
    Ram[$1B]:=@iBattery;      //0449 4
    Ram[$1C]:=@iWhirlyBird;   //044A 4
    Ram[$1D]:=@iMedicine;     //044B 1
  end;
  FillChar(Save,SizeOf(TSaveData),0);
end.
(* $0421, $0447, $0436, $0431, $0437, $0432, $0438, $0400,
   $0454, $0455, $042A, $042B, $0439, $0457, $0445, $0446,
   $043B, $0450, $043C, $044F, $043D, $044E, $043E, $044D,
   $043F, $044C, $0444, $0449, $044A, $044B *)