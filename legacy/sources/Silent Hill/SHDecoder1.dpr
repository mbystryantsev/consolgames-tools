program SHDecoder1;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  PtrSrch,
  Windows,
  SHDec;

var Size, Adr1,Adr2,n: Integer;
F, FW: File; Buf, WBuf: Pointer;
DW1,DW2: ^DWord;
a0,a1,a2,a3,v0,v1,v2,Lo,t0,t1: DWord; DW: ^DWord; W: ^Word;
Label Beg;
begin

  GetMem(Buf, $100000);
  GetMem(WBuf, $100000);
  DW1:=Addr(Buf^);
  DW2:=Addr(WBuf^);


  Size:=0;
  AssignFile(F,'SH1\SILENT_OR');
  Reset(F,1);
  Seek(F,$D7804);
  BlockRead(F, Buf^, $100000);
  CloseFile(F);

  a0:=$8010A600;
  a1:={ $8019A604} ($D7804);
  a2:=$000292C0;
  a3:=$00000000;
  t0:=$03A452F7;
  t1:=$01309125;

beg:
  Inc(Size,4);
  v0:=a3+t1;            // ADDU 	v0,a3,t1
  Lo:=v0*t0;            // MULT 	v0,t0
  Inc(v1);              // ADDIU 	v1,v1,0001
  v0:=DW1^; Inc(DW1);     // LW 		v0,0000(a1)
  Inc(a1,4);            // ADDIU	a1,a1,0004
  a3:=Lo;               // MFLO	a3,Lo
  v0:=v0 XOR a3;        // XOR		v0,v0,a3
  DW2^:=v0;              // SW		v0,0000(a0)
  If v1>a2 Then v0:=a2 // SLT		v0,v1,a2
  Else v0:=v1;

  Inc(a0,4); Inc(DW2);

  If 0<>v0 Then        // BNE		v0,r0,begin
  GoTo beg;

  AssignFile(FW,'SH1\Menus1.bin');
  Rewrite(FW,1);
  Seek(FW,0);
  BlockWrite(FW, WBuf^, Size);
  FreeMem(WBuf);
  CloseFile(FW);
  ReadLn;
end.
