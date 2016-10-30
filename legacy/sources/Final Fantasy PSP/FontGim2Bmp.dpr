program FontGim2Bmp;

{$APPTYPE CONSOLE}

uses
  SysUtils, DIB,
  Windows, FontGim;

{Type
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
 end; }





var Pal: Array[0..15] of DWord = (0, $101010, $202020, $303030, $404040, $505050,
$606060, $707070, $808080, $909090, $A0A0A0, $B0B0B0, $C0C0C0, $D0D0D0, $E0E0E0,
$F0F0F0);
//Hdr: Array[0..15] of byte = ($4D,$49,$47,$2E,$30,$30,$2E,$31,$50,$53,$50,0,0,0,0,0);
S: String;
var F: File; Img: Array of byte;
Buf: Pointer; B,SL: ^Byte; n,m,l,r: Integer; //DW: ^DWord;
HdrCmp: Array[0..15] of byte; Pic: TDIB; Wrd: Word;
begin
  If ParamStr(1)='' Then Exit;
  
  LoadGim(ParamStr(1), Buf, Pic);
  RawToDib(Pic, Buf);

  SetPallete(Pic, Pal);

  S:=ParamStr(1);
  S[Length(S)-2]:='B';
  S[Length(S)-1]:='M';
  S[Length(S)]:='P';

  Pic.SaveToFile(S);
  Pic.Free;
  FreeMem(Buf);

end.
