unit WINTEST;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DXDraws, FF7_Window, FF7_Common, FF7_Text;

type
  TForm1 = class(TForm)
    WScreen: TDXDraw;
    Button1: TButton;
    Button2: TButton;
    weX: TEdit;
    weY: TEdit;
    weW: TEdit;
    weH: TEdit;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure WScreenMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WScreenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin

  WScreen.Surface.Canvas.Brush.Color:=$00FF0000;
  WScreen.Surface.Canvas.Rectangle(0,0,32,32);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
end;

var Win: TWin; Rs: TResize;

procedure TForm1.Button2Click(Sender: TObject);
var  Rect: TRect;
begin
  WScreen.Surface.Canvas.Brush.Color:=$00666666;
  Rect.Left:=0; Rect.Top:=0; Rect.Right:=640; Rect.Bottom:=480;
  WScreen.Surface.Canvas.FillRect(Rect);
  Win.X:=StrToInt(weX.Text);
  Win.Y:=StrToInt(weY.Text);
  Win.W:=StrToInt(weW.Text);
  Win.H:=StrToInt(weH.Text);
  DrawWindow(Win, WScreen);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
end;





procedure TForm1.WScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var Rect: TRect;
begin
  If Rs.ROn Then
  begin
    WScreen.Surface.Canvas.Brush.Color:=$00666666;
    Rect.Left:=0; Rect.Top:=0; Rect.Right:=640; Rect.Bottom:=480;
    WScreen.Surface.Canvas.FillRect(Rect);


    Case Rs.RType of
      1:
      begin
        Win.X:=Rs.WX+(X-Rs.X);
        Win.Y:=Rs.WY+(Y-Rs.Y);
      end;
      2:
      begin
        Win.X:=Rs.WX+(X-Rs.X);
        Win.W:=Rs.WW-(X-Rs.X);
      end;
      3:
      begin
        Win.X:=Rs.WX+(X-Rs.X);
        Win.Y:=Rs.WY+(Y-Rs.Y);
        Win.W:=Rs.WW-(X-Rs.X);
        Win.H:=Rs.WH-(Y-Rs.Y);
      end;
      4:
      begin
        Win.Y:=Rs.WY+(Y-Rs.Y);
        Win.H:=Rs.WH-(Y-Rs.Y);
      end;
      5:
      begin
        Win.Y:=Rs.WY+(Y-Rs.Y);
        Win.W:=Rs.WW+(X-Rs.X);
        Win.H:=Rs.WH-(Y-Rs.Y);
      end;
      6: Win.W:=Rs.WW+(X-Rs.X);
      7:
      begin
        Win.W:=Rs.WW+(X-Rs.X);
        Win.H:=Rs.WH+(Y-Rs.Y);
      end;
      8:  Win.H:=Rs.WH+(Y-Rs.Y);
      9:
      begin
        Win.X:=Rs.WX+(X-Rs.X);
        Win.W:=Rs.WW-(X-Rs.X);
        Win.H:=Rs.WH+(Y-Rs.Y);
      end;
    end;
    DrawWindow(Win, WScreen);
    WScreen.Surface.Canvas.Release;
    WScreen.Flip;
    //Form1.Caption:=Format('%d::%d',[Win.X,Win.Y]);
  end else
  begin
    Rs.RType:=CheckWindow(Win,X,Y);
    If Rs.RType>0 Then Rs.Mode:=True;
    Case Rs.RType of
      1:  WScreen.Cursor:=crSizeAll;
      2:  WScreen.Cursor:=crSizeWE;
      3:  WScreen.Cursor:=crSizeNWSE;
      4:  WScreen.Cursor:=crSizeNS;
      5:  WScreen.Cursor:=crSizeNESW;
      6:  WScreen.Cursor:=crSizeWE;
      7:  WScreen.Cursor:=crSizeNWSE;
      8:  WScreen.Cursor:=crSizeNS;
      9:  WScreen.Cursor:=crSizeNESW;
      0:
      begin
        If Rs.Mode Then
        begin
          Rs.Mode:=False;
          WScreen.Cursor:=crDefault;
        end;
      end;
    end;
    Form1.Caption:=Format('%d::%d',[X,Y]);
  end;
end;

procedure TForm1.WScreenMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If Rs.RType>0 Then begin Rs.WX:=Win.X; Rs.WY:=Win.Y; Rs.WW:=Win.W; Rs.WH:=Win.H; Rs.ROn:=True; Rs.X:=X; Rs.Y:=Y; end;
end;

procedure TForm1.WScreenMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Rs.ROn:=False;
  weX.Text:=IntToStr(Win.X);
  weY.Text:=IntToStr(Win.Y);
  weW.Text:=IntToStr(Win.W);
  weH.Text:=IntToStr(Win.H);
end;

procedure TForm1.Button3Click(Sender: TObject);
var Buf: Pointer; Size: Integer;
begin
{  Size:=LoadFile('_FF7\INIT\WINDOW.BIN',Buf);
  Size:=ZLibDecompress(Buf);
  SaveFile('_FF7\_LZ\Test\1.tim',Buf,Size);    }
end;

procedure TForm1.Button4Click(Sender: TObject);
var Font: TWFont; Table: TTableArray;
begin
  Font:=TWFont.Create;
  Font.LoadFont('_FF7\_LZ\Font\Font.tim','_FF7\_LZ\Font\W.dat');
  //Font.DrawChar($A9,WScreen,0,0);
  //Font.DrawIDLine('ABCD',WScreen,Win.X+8,Win.Y+6);
  LoadTable('_FF7\Table_En.tbl',Table);
  //Font.DrawLine('“C'+#$27+'mon newcomer.',WScreen,Table,Win.X+8,Win.Y+6);
  //Font.DrawLine('  F<cPurple>oll<cPurple>ow me.”',WScreen,Table,Win.X+8,Win.Y+6+16);
  Font.DrawText('“C'+#$27+'mon newcomer.'+#13#10+'  F<cPurple>oll<cPurple>ow me.”',WScreen,Table,Win.X+8,Win.Y+6);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
end;

end.
