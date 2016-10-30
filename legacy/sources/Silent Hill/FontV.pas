unit FontV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtDlgs, StdCtrls, ExtCtrls, DIB, ComCtrls, Menus;

type
  TForm1 = class(TForm)
    Img: TImage;
    List: TListBox;
    OD: TOpenDialog;
    OPD: TOpenPictureDialog;
    eW: TEdit;
    UD: TUpDown;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Save1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListClick(Sender: TObject);
    procedure eWChange(Sender: TObject);
    procedure UDClick(Sender: TObject; Button: TUDBtnType);
    procedure Save1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
var F: File; Pic, NPic: TDIB; W: Array[0..125] of byte;
cl: Boolean;
procedure TForm1.FormCreate(Sender: TObject);
var n: Byte;
begin
   If (OPD.Execute And FileExists(OPD.FileName)) AND
    (OD.Execute And FileExists(OD.FileName)) Then
    begin
      Pic:=TDIB.Create;
      NPic:=TDIB.Create;
      NPic.Height:=16*16;
      Pic.LoadFromFile(OPD.FileName);
      If not ((Pic.Height=96) and (pic.Width=256)) Then Exit;
      AssignFile(F, OD.FileName);
      Reset(F,1);
      Seek(F, $120C);
      BlockRead(F, W, 126);
      CloseFile(F);
      For n:=0 To 125 do
      begin
        List.Items.Add(Format('[%s %s-%s]: %d',[IntToHex(n,2),IntToHex(n+$27,2),Char(n+$27),W[n]]));
      end;
      List.ItemIndex:=0;
      ListClick(Sender);
  end else cl:=True;
    //Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  If Assigned(Pic) Then Pic.Free;
  If Assigned(NPic) Then NPic.Free;
end;

procedure TForm1.ListClick(Sender: TObject);
var ID: Byte; WW: Integer;
begin
  ID:=List.ItemIndex;
  UD.Position:=W[ID];
  WW:=W[ID]-1;
  eW.Text:=IntToStr(W[ID]);
  If WW<=0 Then
  begin
    Img.Width:=0;
    Exit;
  end;
  NPic.Width:=WW*16;
  Img.Width:=WW*16;
  NPic.Canvas.CopyRect(Bounds(0,0,WW*16,16*16),
  Pic.Canvas,Bounds((ID-(ID div 21)*21)*12,(ID div 21)*16,WW,16));
  Img.Picture.Graphic:=NPic;
end;

procedure TForm1.eWChange(Sender: TObject);
var n: Integer;
begin
  n:=StrToInt(eW.Text);
  If n<0 Then n:=0;
  If n>255 Then n:=255;
  eW.Text:=IntToStr(n);
  W[List.ItemIndex]:=n;
  UD.Position:=n;
  List.Items.Strings[List.ItemIndex]:=Format('[%s %s-%s]: %d',[IntToHex(List.ItemIndex,2),
  IntToHex(List.ItemIndex+$27,2),Char(List.ItemIndex+$27),W[List.ItemIndex]]);
  ListClick(Sender);
end;

procedure TForm1.UDClick(Sender: TObject; Button: TUDBtnType);
begin
  eW.Text:=IntToStr(UD.Position);
end;

procedure TForm1.Save1Click(Sender: TObject);
begin
  Reset(F,1);
  Seek(F, $120C);
  BlockWrite(F, W, 126);
  CloseFile(F);      
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  If cl Then Close;
end;

end.
