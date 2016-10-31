unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtDlgs, StdCtrls, StrUtils, ExtCtrls, ComCtrls, DIB, Menus;

type
  TX = class(TForm)
    OpenP: TOpenPictureDialog;
    OpenDialog1: TOpenDialog;
    List: TListBox;
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    About1: TMenuItem;
    Exit1: TMenuItem;
    Font21: TMenuItem;
    Font31: TMenuItem;
    About2: TMenuItem;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListClick(Sender: TObject);
    Procedure DrawFont(Sender: TObject)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  X: TX;

implementation

{$R *.dfm}
Type
TFnt = Packed Record
  X: DWord;
  Y: DWord;
  Length: DWord;
end;

Type
TMFont = Packed Record
  Pos: DWord;
  Count: Integer;
  Fnt: Array of TFnt;
end;



Function CrToInt(const V: DWord): DWord;
var Sum: DWord; n, Step: Integer;
begin
  Step:=$800000;
  Result:=$3B000000;
  Sum:=0;
  For n:=0 to V-1 do
  begin
  Inc(Result,Step);
  Inc(Sum,Step);
    If Sum>=$800000 then
    begin
      Sum:=0;
      Step:=Step div 2;
    end;
  end;


  //Vr2.Text:=IntToHex(V2,8);
end;

{procedure TX.Vr1Change(Sender: TObject);
var V1,V2,Sum: DWord; n, Step: Integer; Prev: Byte;
begin
  V1:=StrToInt(Vr1.Text);
  Step:=$800000;
  Prev:= $3B;
  V2:=$3B000000;
  Sum:=0;
  For n:=0 to V1-1 do
  begin
  Inc(V2,Step);
  Inc(Sum,Step);
    If Sum>=$800000 then
    begin
      Sum:=0;
      Step:=Step div 2;
    end;
  end;


  Vr2.Text:=IntToHex(V2,8);

end; }
var Fnt: Array[0..2] of TMFont; Pic: Array[0..2] of TDIB;
procedure TX.FormActivate(Sender: TObject);
var F: File; n,m: integer;
begin
  //FL:=$28; FS:=191; Adr:=$65CB0;  // Big Font
  //FL:=$28; FS:=$C4; Adr:=$24C90;  // Medium Font
  //FL:=$28; FS:=$BF; Adr:=$13CC0;  // Small Font

  For n:=0 to 2 do
  begin
    Pic[n]:=TDIB.Create;
  end;
  If OpenDialog1.Execute and FileExists(OpenDialog1.FileName) then
  begin
    For n:=0 to 2 do
    begin
      OpenP.Title:='Open font '+IntToStr(n+1);
      OpenP.FileName:='font'+IntToStr(n+1)+'.bmp';
      If OpenP.Execute and FileExists(OpenP.FileName) then
      begin
        Pic[n].LoadFromFile(OpenP.FileName);
      end else
      begin
        For m:=0 to 2 do
        begin
          If Assigned(Pic[m]) Then Pic[m].Free;
        end;
        Close;
      end;
    end;
    //Удачно
     Fnt[0].Count:=191;
     Fnt[1].Count:=$C4;
     Fnt[2].Count:=$BF;
     Fnt[0].Pos:=$65CB0;
     Fnt[1].Pos:=$24C90;
     Fnt[2].Pos:=$13CC0;
     AssignFile(F, OpenDialog1.FileName);
     Reset(F,1);
     For n:=0 to 2 do
     begin
      SetLength(Fnt[n].Fnt, Fnt[n].Count);
      Seek(F, Fnt[n].Pos);
      BlockRead(F, Fnt[n].Fnt[0], Fnt[n].Count*12);
     end;

  end else
  begin
    For n:=0 to 2 do
    begin
      If Assigned(Pic[n]) Then Pic[n].Free;
    end;
    Close;
  end;


end;

Procedure TX.DrawFont(Sender: TObject);
var n: integer;
begin
MainMenu1.Items.
end;

procedure TX.FormCreate(Sender: TObject);
begin

end;

procedure TX.ListClick(Sender: TObject);
begin

end;

end.
