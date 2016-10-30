unit WINTEST;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DXDraws;

type
  TForm1 = class(TForm)
    WScreen: TDXDraw;
    Button1: TButton;
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

procedure TForm1.Button1Click(Sender: TObject);
begin

  WScreen.Surface.Canvas.Brush.Color:=$00FF0000;
  WScreen.Surface.Canvas.Rectangle(0,0,32,32);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
end;

end.
