unit FEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, DIB, StrUtils;

Type
TSymbol = Packed Record
  X,Y,W: Word;
end;


TSymbolArray = Array of TSymbol;

TFont = Packed Record
  Height: Word;
  Count: Word;
  Image: TDIB;
  Shadow: TDIB;
  Symbol: TSymbolArray;//Array of TSymbol;
  CBytes: Array[0..136] of Word;
end;

type
  TForm1 = class(TForm)
    List: TListBox;
    Img: TImage;
    eX: TEdit;
    eY: TEdit;
    eW: TEdit;
    uX: TUpDown;
    uY: TUpDown;
    uW: TUpDown;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure eXChange(Sender: TObject);
    procedure eYChange(Sender: TObject);
    procedure eWChange(Sender: TObject);
    procedure uXClick(Sender: TObject; Button: TUDBtnType);
    procedure uYClick(Sender: TObject; Button: TUDBtnType);
    procedure uWClick(Sender: TObject; Button: TUDBtnType);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
var Flag: Boolean; OpenedFile: String;
Procedure LoadBMPFont(S: String; var Font: TFont);
var F: File;
begin
  AssignFile(F, S);
  Reset(F,1);
  BlockRead(F, Font, 4);
  Seek(F, 6);
  BlockRead(F, Font.CBytes, 137*2);
  SetLength(Font.Symbol, Font.Count);
  Seek(F, $118);
  BlockRead(F, Font.Symbol[0],Font.Count*6);
  Seek(F,0);
  CloseFile(F);
  If not Assigned(Font.Image) Then Font.Image:=TDIB.Create;
  Font.Image.LoadFromFile(LeftStr(S,Length(S)-3)+'BMP');
  If not Assigned(Font.Shadow) Then Font.Shadow:=TDIB.Create;
  Font.Shadow.LoadFromFile(LeftStr(S,Length(S)-4)+'_s.BMP');
end;

var mFont: TFont; Pic: TDIB;
procedure TForm1.FormCreate(Sender: TObject);
var n: Integer;
begin


  LoadBMPFont('FF1PSP\Tools\BigFont.FIF',mFont);
  For n:=0 to mFont.Count-1 do
  begin
    mFont.Symbol[n].X:=(n-(n div 16)*16)*32;
    mFont.Symbol[n].Y:=(n div 16)*32;
    List.Items.Add(IntToHex(n,(n div 256+1)*2));
  end;
  List.ItemIndex:=0;

  If not Assigned(Pic) Then
  begin
    Pic:=TDIB.Create;
    //Pic.ColorTable:=mFont.Image.ColorTable;
  end;
  ListClick(Sender);

  Img.Height:=mFont.Image.Height;
  Img.Width:=mFont.Image.Width;
  Img.Picture.Graphic:=mFont.Image;
end;

procedure TForm1.ListClick(Sender: TObject);
begin
Flag:=True;

  eX.Text:=IntToStr(mFont.Symbol[List.ItemIndex].X);
  eY.Text:=IntToStr(mFont.Symbol[List.ItemIndex].Y);
  eW.Text:=IntToStr(mFont.Symbol[List.ItemIndex].W);
  uX.Position:=mFont.Symbol[List.ItemIndex].X;
  uY.Position:=mFont.Symbol[List.ItemIndex].Y;
  uW.Position:=mFont.Symbol[List.ItemIndex].W;

  With mFont.Symbol[List.ItemIndex] do
  begin
    If mFont.Symbol[List.ItemIndex].W>0 then
    begin
      Pic.Height:=mFont.Height*8;
      Pic.Width:=W*8;
      Img.Height:=mFont.Height*8;
      Img.Width:=W*8;
      Pic.Canvas.CopyRect(Bounds(0,0,W*8, mFont.Height*8), mFont.Image.Canvas, Bounds(X,Y,W,mFont.Height));
      Img.Picture.Graphic:=Pic;
    end;
  end;
Flag:=False;
end;

procedure TForm1.eXChange(Sender: TObject);
begin
  If Flag=False Then
  begin
    mFont.Symbol[List.ItemIndex].X:=StrToInt(eX.Text);
  end;
  ListClick(Sender);
end;

procedure TForm1.eYChange(Sender: TObject);
begin
  If Flag=False Then
  begin
    mFont.Symbol[List.ItemIndex].Y:=StrToInt(eY.Text);
  end;
  ListClick(Sender);
end;

procedure TForm1.eWChange(Sender: TObject);
begin
  If Flag=False Then
  begin
    mFont.Symbol[List.ItemIndex].W:=StrToInt(eW.Text);
  end;
  ListClick(Sender);
end;

procedure TForm1.uXClick(Sender: TObject; Button: TUDBtnType);
begin
  eX.Text:=IntToStr(uX.Position);
end;

procedure TForm1.uYClick(Sender: TObject; Button: TUDBtnType);
begin
  eY.Text:=IntToStr(uY.Position);
end;

procedure TForm1.uWClick(Sender: TObject; Button: TUDBtnType);
begin
  eW.Text:=IntToStr(uW.Position);
end;

procedure TForm1.Button1Click(Sender: TObject);
var F: File;
begin
  AssignFile(F,'FF1PSP\Tools\BigFont.FIF');
  Reset(F,1);
  Seek(F,0);
  BlockWrite(F, mFont, 4);
  Seek(F,6);
  BlockWrite(F, mFont.CBytes, 137*2);
  Seek(F,$118);
  BlockWrite(F, mFont.Symbol[0], 256*6);
  CloseFile(F);
end;

end.
