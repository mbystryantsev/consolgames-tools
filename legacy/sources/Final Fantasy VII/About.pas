unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TAboutForm = class(TForm)
    ATimer: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    TU: TLabel;
    Image1: TImage;
    TD: TLabel;
    XTimer: TTimer;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ATimerTimer(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure XTimerTimer(Sender: TObject);
//    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure CreateParams(var Para: TCreateParams); override;
  end;

var
  AboutForm: TAboutForm;
  MT: String = 'http://consolgames.ru/';

implementation

{$R *.dfm}

 procedure TAboutForm.CreateParams(var Para: TCreateParams);
 begin
   inherited;
   Para.WndParent := GetActiveWindow;
 end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  TU.Caption:='                      ';
  TD.Caption:=MT;
  AboutForm.AlphaBlendValue:=0;
  ATimer.Enabled:=True;
  XTimer.Enabled:=True;
end;

procedure TAboutForm.ATimerTimer(Sender: TObject);
begin
  If AboutForm.AlphaBlendValue<255 Then
  AboutForm.AlphaBlendValue:=AboutForm.AlphaBlendValue+1
  else ATimer.Enabled:=False;
end;

procedure TAboutForm.FormClick(Sender: TObject);
begin
  AboutForm.Hide;
  XTimer.Enabled:=False;
end;

var Pos: Integer = 0; Tp: Boolean = False;
procedure TAboutForm.XTimerTimer(Sender: TObject);
var S,SU: String;
begin
  S:=TD.Caption;
  SU:=TU.Caption;
  If Pos=0 Then
  begin
    Pos:=1;Tp:=Not Tp;
  end else if pos=23 Then
  begin
    Pos:=22;Tp:=Not Tp;
  end else
  begin
    S[Pos]:=' ';
    SU[Pos]:=MT[Pos];
    If Tp Then
    begin
      If Pos>1 Then S[Pos-1]:=MT[Pos-1];
      If Pos>1 Then SU[Pos-1]:=' ';
      Inc(Pos);
    end else
    begin
      If Pos<22 Then S[Pos+1]:=MT[Pos+1];
      If Pos<22 Then SU[Pos+1]:=' ';
      Dec(Pos);
    end;
  end;
  TU.Caption:=SU;
  TD.Caption:=S;
end;


end.
