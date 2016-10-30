unit MapViewer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DIB, ExtCtrls, ActnList, Menus, PSPRAW, TBXGraphics;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    ActionList: TActionList;
    Img: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  Type
  TCMIHead = Packed Record
    Sign: Array[0..3] of byte;
    Width: DWord;
    Height: DWord;
    Size: DWord;
    DW: Array[0..3] of DWord;
  end;
var
  Form1: TForm1;

implementation

{$R *.dfm}
var BG, Pic: TDIB; BGPal, Pal, Pal2: Array[0..15] of DWord;
Procedure RevPal(var Pal: Array of DWord);
var n: Integer; NewPal: Array of DWord;
begin
  SetLength(NewPal,Length(Pal));
  For n:=0 to Length(Pal)-1 do
  begin
    NewPal[Length(Pal)-n-1]:=Pal[n];
  end;
  For n:=0 to Length(Pal)-1 do
  begin
    NewPal[n]:=Pal[n];
  end;
end;

Procedure InvPal(var Pal: Array of DWord);
var n: Integer; NewPal: Array of DWord;
begin
  For n:=0 to length(pal) do
  begin
    Pal[n]:=((Pal[n] SHL 16) AND $FF0000) + (Pal[n] AND $FF00)+
    ((Pal[n] SHR 16) AND $FF)+(Pal[n] AND $FF000000);
    //ShowMessage(IntToHex(Pal[n],8));
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var F: File; Head: TCMIHead; Buf: Pointer;  DW: ^DWord; n,m: Integer;
 Tile: TDib;  Layer: TDIB;   X,Y: Integer; B: ^Byte;
begin

  Tile:=TDib.Create;
  AssignFile(F, 'SHTEST\mp_hospr.cmi');
  Reset(F,1);
  BlockRead(F, Head, 32);
  Seek(F,$20);
  BlockRead(F, Pal,64);
  Seek(F, 96);
  BlockRead(F, Pal2,64);
  Seek(F,160);
  BlockRead(F, BGPal,64);
  GetMem(Buf, 8192);
  Seek(F, $E0);
  BlockRead(F, Buf^, 8192);
  BG:=TDIB.Create;
  BG.Width:=128;
  BG.Height:=128;
  BG.PixelFormat :=MakeDibPixelFormat(8, 8, 8);
  BG.BitCount:=4;
  SetPal(BG, Pal);
  RawToDib(BG, Buf);
  FreeMem(Buf);
  Layer:=TDIB.Create;
  Layer.Height:=1088;
  Layer.Width:=1980;
  Layer.BitCount:=4;
 { For m:=0 to 1088 div 128 -1 do
    For n:=0 to 1980 div 128-1 do
    begin
      Layer.Canvas.Draw(n*128,m*128,BG);
    end; }
  //Tile:=Pic;
  //===
  GetMem(Buf, $20000);
  Seek(F, $C0E0);
  BlockRead(F, Buf^, $20000);
  Pic:=TDIB.Create;
  Pic.Width:=16384;//512;
  Pic.Height:=16;//512;
  //Img.Height:=Pic.Height;
  //Img.Width:=Pic.Width;
  Pic.BitCount:=4;
  SetPal(Pic, Pal2);
  RawToDIB(Pic, Buf);
  Tile.Width:=16;
  Tile.Height:=16;
  FreeMem(Buf);
  //Img.Picture.Graphic:=Pic;
  Pic.SaveToFile('Test.bmp');
  Tile.BitCount:=4;
  SetPal(Tile, Pal2);
  //Img.Width:=Head.Width;
  //Img.Height:=Head.Height;



  Seek(F, $20E0);
  GetMem(Buf, $A000);
  BlockRead(F, Buf^, $A000);
  DW:=Addr(Buf^);
  SetPal(Layer, Pal);
  For m:=0 to Head.Height div 16-1  do
    For n:=0 to Head.Width div 16-1  do
      begin
        If DW^<$FFFFFFFF then
        begin
          Tile.Canvas.CopyRect(Bounds(0,0,16,16),Pic.Canvas,
          Bounds(DW^-(DW^ div Tile.Height)*Tile.Height, DW^ div Tile.Height,16,16));
          Layer.Canvas.Draw(n*16,m*16,Tile);
        end;
        Inc(DW);
      end;
      Img.Picture.Graphic:=Layer;
      Layer.SaveToFile('Map.bmp');

end;

end.
