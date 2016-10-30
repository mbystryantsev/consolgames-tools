unit FF7_Field;

interface

uses
Windows, FF7_Dat, FF7_Common, SysUtils;

var
FieldOL: Array[Byte] of Byte = (
1, 3, 3, 3, 3, 3, 3, 5, 2, 15,6, 6, 1, 1, 2, 2,
2, 3, 2, 3, 6, 7, 8, 9, 8, 9, 0, 0, 0, 0, 0, 0,
11,2, 5, 3, 3, 9, 6, 2, 255,1,2, 2, 5, 7, 2,10, 
4, 4, 4, 2, 2, 4, 5, 8, 6, 6, 6, 4, 1, 1, 1, 1, 
3, 5, 6, 2, 0, 5, 0, 5, 7, 4, 2, 2, 0, 5, 0, 5, 
10,6, 4, 2, 2, 3, 7, 7, 5, 5, 5, 7, 8,10, 8, 1, 
10,2, 5, 6, 6, 1, 9, 1, 9, 2, 7, 9, 1, 4, 3, 6, 
4, 2, 3, 4, 4, 8, 4, 5, 4, 5, 3, 3, 3, 3, 2, 3, 
4, 5, 4, 4, 4, 4, 5, 4, 5, 4, 5, 4, 5, 4, 5, 4, 
5, 4, 5, 4, 5, 3, 3, 3, 3, 3, 4, 5, 6, 7, 7,11, 
2, 2, 3, 3, 2,11, 9, 9, 6, 6, 2, 4, 1, 6, 3, 3, 
5, 5, 4, 3, 6, 6, 2, 4, 5, 4, 3, 5, 5, 4, 0, 2, 
11,8,15,12, 1, 3, 3, 2, 2, 2, 4, 3, 3, 3, 2, 2, 
13,2, 2,16,10,10, 4, 4, 3, 1,15, 2, 4, 1, 1,11, 
4, 4, 3, 3, 3, 5, 5, 5, 7,10,10, 5, 5, 8, 8,11, 
2, 5,14, 2, 2, 2, 2, 4, 2, 2, 3, 2, 2, 6, 3, 1);

FieldON: Array[Byte] Of String = (
'RET','REQ','REQSW','REQEW','PREQ','PRQSW','PRQEW','RETTO','JOIN','SPLIT','SPTYE','GTPYE','?0C?','?0D?','DSKGG','SPECIAL',
'JMPF','JMPFL','JMPB','JMPBL','IFUB','IFUBL','IFSW','IFSWL','IFUW','IFUWL','u(1A)','u(1B)','u(1C)','u(1D)','u(1E)','u(1F)',
'MINIGAME','TUTOR','BTMD2','BTRLD','WAIT','NFADE','BLINK','BGMOVIE','KAWAI','KAWIW','PMOVA','SLIP','BGPDH','BGSCR','WCLS','WSIZW',
'IFKEY','IFKEYON','IFKEYOFF','UC','PDIRA','PTURA','WSPCL','WNUMB','STTIM','GOLD+','GOLD-','CHGLD','HMPMAX1','HMPMAX2','MHMMX','HMPMAX3',
'[!]MESSAGE','MPARA','MPRA2','PLACE','u(44)','MP+','u(45)','MP-','[!]ASK','MENU','MENU2','BTLTB','u(4C)','HP+','u(4E)','HP-',
'[!]WINDOW','WMOVE','WMODE','WREST','WCLSE','WROW','GWCOL','SWCOL','STITM','DLITM','CKITM','SMTRA','DMTRA','CMTRA','SHAKE','NOP',
'MAPJUMP','SCRLO','SCRLC','SCRLA','SCR2D','SCRCC','SCR2DC','SCRLW','SCR2DL','MPDSP','VWOFT','FADE','FADEW','IDLCK','LSTMP','SCRLP',
'BATTLE','BTLON','BTLMD','PGTDR','GETPC','PXYZI','PLUS!','PLUS2!','MINUS!','MINUS2!','INC!','INC2!','DEC!','DEC2!','TLKON','RDMSD',
'SETBYTE','SETWORD','BITON','BITOFF','BITXOR','PLUS','PLUS2','MINUS','MINUS2','MUL','MUL2','DIV','DIV2','MOD','MOD2','AND',
'AND2','OR','OR2','XOR','XOR2','INC','INC2','DEC','DEC2','RANDOM','LBYTE','HBYTE','2BYTE','SETX','GETX','SEARCHX',
'PC','CHAR','DFANM','ANIME1','VISI','XYZI','XYI','XYZ','MOVE','CMOVE','MOVA','TURA','ANIMW','FMOVE','ANIME2','ANIM!1',
'CANIM1','CANM!1','MSPED','DIR','TURGEN','TURN','DIRA','GETDIR','GETAXY','GETAI','ANIM!2','CANIM2','CANM!2','ASPED','u(BE)','CC',
'JUMP','AXYZI','LADER','OFST','OFSTW','TALKR','SLIDR','SOLID','PRTYP','PRTYM','PRTYE','IFPRTYQ','IFMEMBQ','MMB+-','MMBLK','MMBUK',
'LINE','LINON','MPJPO','SLINE','SIN','COS','TLKR2','SLDR2','PMJMP','PMJMP2','AKAO2','FCFIX','CCANM','ANIMB','TURNW','MPPAL',
'BGON','BGOFF','BGROL','BGROL2','BGCLR','STPAL','LDPAL','CPPAL','RTPAL','ADPAL','MPPAL2','STPLS','LDPLS','CPPAL2','RTPAL2','ADPAL2',
'MUSIC','SOUND','AKAO','MUSVT','MUSVM','MULCK','BMUSC','CHMPH','PMVIE','MOVIE','MVIEF','MVCAM','FMUSC','CMUSC','CHMST','GAMEOVER');

Type
  TFieldD = Packed Record
    Code: Byte;
    Pos: ^Byte;
    Beg: Integer;
    Len: Byte;
  end;
  TFieldDec = Array of TFieldD;
  TOMessage = Packed Record
    ID: Byte;
    N:  Byte;
    D:  Byte;
  end;

TFHeader = Packed Record
  Sign: DWord;
  Count: DWord;
  HSize: DWord;
  SSize: DWord;
end;


TByteArray = Array of Byte;
var
  MField: Array of TFieldDec;
  MLField: TLField;

//const
  MFieldBytes: TByteArray;

Procedure FieldDecompile(P: Pointer; Size: Integer; var Script: TFieldDec; Codes: TByteArray = NIL);
// FieldDecompile(Поинтер на начало, размер, TFieldDec) - декомпилирует
//(только основа) скрипт в простейший код
Function LoadField(Name: String; var Buf: Pointer; var Field: TLField): Integer;
Function AssignField(Buf: Pointer): TLField;
Function FindField(Field: TLField; Name: String): Integer;
implementation

Function FindOpcode(Code: Byte; P: Pointer; Pos: Integer): Integer;
begin

end;

Function FindField(Field: TLField; Name: String): Integer;
begin
  For Result:=0 To Length(Field)-1 do
  begin
    If Field[Result].Name=Name Then Exit;
  end;
  Result:=-1;
end;

Function AssignField(Buf: Pointer): TLField;
var Head: ^TFHeader; PC: PChar; n: Integer; S: ^TFScript;
begin
  Head:=Buf;
  SetLength(Result,Head^.Count);
  S:=Buf; Inc(DWord(S),16);
  For n:=0 To Head^.Count-1 do
  begin
    Result[n].Name:=S^.Name;
    Result[n].Pos:=Pointer(DWord(Buf)+S^.Pos+Head^.HSize);
    Result[n].Size:=S^.Size;
    Inc(S);
  end;
end;

Function LoadField(Name: String; var Buf: Pointer; var Field: TLField): Integer;
begin
  Result:=LoadFile(Name, Buf);
  Field:=AssignField(Buf);
end;

Procedure FieldDecompile(P: Pointer; Size: Integer; var Script: TFieldDec; Codes: TByteArray = NIL);
var n,m: Integer; B: ^Byte; SZ: Integer; Flag: Boolean;    S: String;
begin
  SZ:=Size;
  B:=P;
  n:=0;
  While Size>0 do
  begin
//  {$O-}
//  S:=Format('%s : %s : %s',[IntToHex(Integer(B)-Integer(P),8),IntToHex(Size,4),IntToHex(SZ-Size,4)]);
//  {$O+}
    Flag:=False;
    If Codes=NIL Then Flag:=True else
    begin
      For m:=Low(Codes) To High(Codes) do
      begin
        If B^=Codes[m] Then
        begin
          Flag:=True;
          Break;
        end;
      end;
    end;
    If Flag Then
    begin
      SetLength(Script, Length(Script)+1);
      Script[n].Code:=B^; Script[n].Len:=FieldOL[B^];
      Script[n].Pos:=Addr(B^);
      Script[n].Beg:=SZ-Size;
    end;
    If FieldOL[B^]=0 Then
    begin
      Inc(B);
      Dec(Size);
    end;
    If B^=$28 Then
    begin
      Inc(B); If Flag Then Script[n].Len:=B^; Dec(Size,B^); Inc(B,B^-1);
    end else
    begin
      Dec(Size,FieldOL[B^]);
      Inc(B,FieldOL[B^]);
    end;
    If Flag Then Inc(n);
  end;
end;

end.
