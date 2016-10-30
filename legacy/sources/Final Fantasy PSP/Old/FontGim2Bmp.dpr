program FontGim2Bmp;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows;

Type
 TBitmapHead = Packed Record
  bfType:    Array[0..1] of Char; // 'BM'
  bfSize:    DWord;               // Размер файла
  Reserved1: DWord;               //
  bfOffBits: DWord;               // Размер заголовка + размер палитры (адрес с графикой)
  biSize:    DWord;               // Размер заголовка
  biWidth:   DWord;               // Ширина
  biHeight:  DWord;               // Высота
  biPlanes:  Word;                // =1
  biBitCnt:  Word;                // bpp
  biCompr:   Boolean;             // Сжат/не сжат
  Reserved2: Array[0..2] of Byte; //
  biSizeImg: DWord;               // Размер данных изображения
  biXpelsM:  DWord;               // =0
  biYpelsM:  DWord;               // =0
  biClrUsed: DWord;               // Кол-во используемых цветов в рисунке
  biClrImpr: DWord;               // Общее кол-во цветов
 end;

 Type
  TLines = Record
  Line: Array of byte;
 end;

Procedure PreSetBmp(var Head: TBitmapHead);
begin
  With Head do
  begin
    bfType:='BM'; // 'BM'
    bfOffBits:=$36;
    biSize:=$28;
    biPlanes:=1;
    biBitCnt:=32;
    biCompr:=False;
    biXpelsM:=0;
    biYpelsM:=0;
    biClrUsed:=0;
    biClrImpr:=0;
  end;
end;

var Pal: Array[0..15] of DWord = (0, $101010, $202020, $303030, $404040, $505050,
$606060, $707070, $808080, $909090, $A0A0A0, $B0B0B0, $C0C0C0, $D0D0D0, $E0E0E0,
$F0F0F0);
Hdr: Array[0..15] of byte = ($4D,$49,$47,$2E,$30,$30,$2E,$31,$50,$53,$50,0,0,0,0,0);
S: String;
var Head: TBitmapHead; F: File; Img: Array of byte;
Buf: Pointer; B: ^Byte; n,m,l,r: Integer; DW: ^DWord;
HdrCmp: Array[0..15] of byte;
begin
  If ParamStr(1)='' Then Exit;
  PreSetBmp(Head);
  AssignFile(F, ParamStr(1));
  Reset(F,1);
  BlockRead(F, HdrCmp, 16);
  //If HdrCmp<>Hdr then Exit;
  Seek(F,$48);
  BlockRead(F, Head.biWidth, 2);
  Seek(F, $4A);
  BlockRead(F, Head.biHeight, 2);
  GetMem(Buf, Head.biHeight*Head.biWidth);
  Seek(F, $80);
  BlockRead(F, Buf^, Head.biHeight*Head.biWidth div 2);
  CloseFile(F);
  B:=Addr(Buf^);
  SetLength(Img, Head.biHeight*Head.biWidth);
  For r:=0 to  (Head.biHeight div 8) -1 do
    For l:=0 to (Head.biWidth div 32) -1 do
      For m:=r*8 to r*8+7 do
        For n:=l*16 to l*16+15 do
          begin
            Img[(Head.biHeight-1 - m) * Head.biWidth + (n*2)]:=(B^ AND $0F);
            Img[(Head.biHeight-1 - m) * Head.biWidth + (n*2+1)]:=B^ SHR 4;
            Inc(B);
          end;
  B:=Addr(Buf^);
  For m:=0 to Head.biHeight-1 do
    For n:=0 to Head.biWidth-1 do
      begin
        B^:=Img[m * Head.biWidth + n];
        Inc(B);
      end;
  {AssignFile(F, 'FF1PSP\TEST.CHR');
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F, Buf^, Head.biWidth*Head.biHeight);
  CloseFile(F);
  //FreeMem(Buf);}


  Head.biBitCnt:=8;
  Head.bfOffBits:=$36+64;
  S:=ParamStr(1);
  S[Length(S)-2]:='B';
  S[Length(S)-1]:='M';
  S[Length(S)]:='P';
  AssignFile(F, S);
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F, Head, $36);
  Seek(F, $36);
  BlockWrite(F, Pal, 64);
  Seek(F, $36+64);
  BlockWrite(F, Buf^, Head.biHeight*Head.biWidth);
  CloseFile(F);
  FreeMem(Buf);  
end.
