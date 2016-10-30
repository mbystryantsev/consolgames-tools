unit DList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Menus, ExtCtrls, StdCtrls, ComCtrls, ExtDlgs, DIB;

type
  TForm1 = class(TForm)
    Img: TImage;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    eLoadImage: TAction;
    fSave: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    eLoadImage1: TMenuItem;
    N6: TMenuItem;
    List: TListBox;
    Button1: TButton;
    Button2: TButton;
    eWord0: TEdit;
    eWord1: TEdit;
    eWord2: TEdit;
    eWord3: TEdit;
    eWord4: TEdit;
    Sel: TImage;
    Op: TOpenDialog;
    fOpen: TAction;
    Status: TStatusBar;
    PoP: TOpenPictureDialog;
    procedure N4Click(Sender: TObject);
    procedure fOpenExecute(Sender: TObject);
    procedure SelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure eWord0Exit(Sender: TObject);
    procedure eWord1Exit(Sender: TObject);
    procedure eWord2Exit(Sender: TObject);
    procedure eWord3Exit(Sender: TObject);
    procedure eWord4Exit(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure eLoadImageExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
const
  aNewCord: Integer = $4DEFB90;
  aOldCord: Integer = $4DF15F8;
  aCordAdr: Integer = $4DE9860;
  aBtCount: Integer = $4DE9994;
  aWord:    Integer = $4DF162C;

Type
  TXY = Packed Record
    X,Y: Byte
  end;



procedure TForm1.N4Click(Sender: TObject);
begin
  ShowMessage(
  'Death List Editor for Silent Hill by HoRRoR'+#13#10+
  'http://consolgames.ru/');

end;

var Pos: Integer = 0; oFile: String; BtCount: Word; BT: Array of TXY;
DSel: Boolean; DX,DY: Integer; Wrd: Array[0..4] of Byte;

procedure TForm1.fOpenExecute(Sender: TObject);
var F: File; n: Integer;
begin
  If not (Op.Execute And (FileExists(Op.FileName))) Then Exit;
  AssignFile(F, Op.FileName);
  Reset(F,1);
  oFile:=Op.FileName;
  Seek(F,aCordAdr);
  BlockRead(F, Pos, 2);
  Inc(Pos, $4DEE490);
  Seek(F,aBtCount);
  BlockRead(F, BtCount,2);
  SetLength(BT, BtCount);
  Seek(F,Pos);
  BlockRead(F, BT[0], BtCount*2);
  Seek(F, aWord);
  BlockRead(F,Wrd,5);
  CloseFile(F);

  eWord0.Text := IntToStr(Wrd[0]);
  eWord1.Text := IntToStr(Wrd[1]);
  eWord2.Text := IntToStr(Wrd[2]);
  eWord3.Text := IntToStr(Wrd[3]);
  eWord4.Text := IntToStr(Wrd[4]);

  List.Clear;
  For n:=0 To BtCount-1 do
  List.Items.Add(Format('%d - X: %d; Y: %d',[n, BT[n].X,BT[n].Y]));
  List.ItemIndex:=0;
  ListClick(Sender);
end;

procedure TForm1.SelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DSel:=True;
end;

procedure TForm1.SelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DSel:=False;
end;

procedure TForm1.SelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If not DSel Then Exit;
  If List.ItemIndex<0 Then Exit;
  If Length(BT)=0 Then Exit;
  Sel.Left:=Sel.Left+X;
  Sel.Top:=Sel.Top+Y;
  If Sel.Left-DX>405 Then Sel.Left:=DX+405;
  If Sel.Left<DX Then Sel.Left:=DX;
  If Sel.Top-DY>440 Then Sel.Top:=DY+440;
  If Sel.Top<DY Then Sel.Top:=DY;

  BT[List.ItemIndex].X :=(Sel.Left-DX+90) div 2 +8;
  BT[List.ItemIndex].Y :=(Sel.Top-DY) div 2 +8;

  List.Items.Strings[List.ItemIndex]:=
  Format('%d - X: %d; Y: %d',[List.ItemIndex, BT[List.ItemIndex].X,BT[List.ItemIndex].Y]);
  Status.Panels.Items[2].Text:=
  Format('BX: %d; BY: %d',[BT[List.ItemIndex].X,BT[List.ItemIndex].Y]);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  DX:=Sel.Left;
  DY:=Sel.Top;
end;

procedure TForm1.ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Status.Panels.Items[0].Text:='X: ' + IntToStr(X div 2);
  Status.Panels.Items[1].Text:='Y: ' + IntToStr(Y div 2);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  If Length(BT)<=0 Then Exit;
  List.Items.Delete(List.Items.Count-1);
  SetLength(BT, Length(BT)-1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  If (Length(BT)<=0) or (Length(BT)>=64) Then Exit;
  List.Items.Add(IntToStr(List.Items.Count)+' - X: 0; Y: 0');
  SetLength(BT, Length(BT)+1);
end;

procedure TForm1.ListClick(Sender: TObject);
begin
  Sel.Left:= DX-105+(2*BT[List.ItemIndex].X);
  Sel.Top:= DY-17+(2*BT[List.ItemIndex].Y);
  Status.Panels.Items[2].Text:=
  Format('BX: %d; BY: %d',[BT[List.ItemIndex].X,BT[List.ItemIndex].Y]);
end;

procedure TForm1.eWord0Exit(Sender: TObject);
begin
  If Length(BT)<=0 Then Exit;
  If StrToInt(eWord0.Text)<0 Then eWord0.Text:='0' else
  If StrToInt(eWord0.Text)>Length(BT)-1 Then
  eWord0.Text:=IntToStr(Length(BT)-1);
  Wrd[0]:=StrToInt(eWord0.Text);
end;

procedure TForm1.eWord1Exit(Sender: TObject);
begin
  If Length(BT)<=0 Then Exit;
  If StrToInt(eWord1.Text)<0 Then eWord1.Text:='0' else
  If StrToInt(eWord1.Text)>Length(BT)-1 Then
  eWord1.Text:=IntToStr(Length(BT)-1);
  Wrd[1]:=StrToInt(eWord1.Text);
end;

procedure TForm1.eWord2Exit(Sender: TObject);
begin
  If Length(BT)<=0 Then Exit;
  If StrToInt(eWord2.Text)<0 Then eWord2.Text:='0' else
  If StrToInt(eWord2.Text)>Length(BT)-1 Then
  eWord2.Text:=IntToStr(Length(BT)-1);
  Wrd[2]:=StrToInt(eWord2.Text);
end;

procedure TForm1.eWord3Exit(Sender: TObject);
begin
  If Length(BT)<=0 Then Exit;
  If StrToInt(eWord3.Text)<0 Then eWord3.Text:='0' else
  If StrToInt(eWord3.Text)>Length(BT)-1 Then
  eWord3.Text:=IntToStr(Length(BT)-1);
  Wrd[3]:=StrToInt(eWord3.Text);
end;

procedure TForm1.eWord4Exit(Sender: TObject);
begin
  If Length(BT)<=0 Then Exit;
  If StrToInt(eWord4.Text)<0 Then eWord4.Text:='0' else
  If StrToInt(eWord4.Text)>Length(BT)-1 Then
  eWord4.Text:=IntToStr(Length(BT)-1);
  Wrd[4]:=StrToInt(eWord4.Text);
end;

procedure TForm1.N6Click(Sender: TObject);
var F: File; A: Word;
begin
  A:=$1700;
  If Length(BT)<=0 Then Exit;
  If not FileExists(oFile) Then Exit;
  AssignFile(F, oFile);
  Reset(F,1);
  Seek(F, aCordAdr);
  BlockWrite(F, A, 2);
  Seek(F,aNewCord);
  BlockWrite(F, BT[0], Length(BT)*2);
  Seek(F, aWord);
  BlockWrite(F, Wrd, 5);
  Seek(F, aBtCount);
  A:=Length(BT);
  BlockWrite(F, A,2);
  CloseFile(F);
end;


{
  aNewCord: Integer = $4DEFB90;
  aOldCord: Integer = $4DF15F8;
  aCordAdr: Integer = $4DE9860;
  aBtCount: Integer = $4DE9994;
  aWord:    Integer = $4DF162C;
  }
procedure TForm1.eLoadImageExecute(Sender: TObject);
var Pic: TDIB;
begin
  If not (PoP.Execute and FileExists(PoP.FileName)) Then Exit;
  Pic:=TDIB.Create;
  Pic.LoadFromFile(PoP.FileName);
  Img.Canvas.CopyRect(Bounds(0,0,640,480),Pic.Canvas,
  Bounds(0,0,320,240));
  Pic.Free;
end;

end.
