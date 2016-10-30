unit ExpToCode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LNBPass, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
var F: File; L: Array[1..50] of TLevelData; var n: Integer;
begin
  AssignFile(F,'Little_Ninja_Brothers_(U).nes');
  Reset(F,1);
  Seek(F,$1DA4A);
  BlockRead(F,L,SizeOf(TLevelData)*50);
  Memo1.Clear;
  Memo1.Lines.Add('  cLevelData: Array[1..50] of TLevelData = (');
  For n:=1 To 49 do
  begin
    With L[n] do Memo1.Lines.Add(
    Format('    (Exp: %.5d; MaxHP: %.3d; Attack: %.2d),',[Exp,MaxHP,Attack]));
  end;
  n:=50;
  With L[n] do Memo1.Lines.Add(
  Format('    (Exp: %.5d; MaxHP: %.3d; Attack: %.2d));',[Exp,MaxHP,Attack]));

end;

procedure TForm1.Button2Click(Sender: TObject);
var n: Integer;
begin
  Memo1.Clear;
  For n:=0 To 255 do Memo1.Lines.Add(Format('%.2x unknown',[n]));
end;

end.
