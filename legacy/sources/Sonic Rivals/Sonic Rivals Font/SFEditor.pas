unit SFEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DIB, ExtDlgs, Menus, StdCtrls, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    OpenP: TOpenPictureDialog;
    MainMenu1: TMainMenu;
    Edit1: TMenuItem;
    Font11: TMenuItem;
    Font21: TMenuItem;
    Font31: TMenuItem;
    About1: TMenuItem;
    List: TListBox;
    Img: TImage;
    File1: TMenuItem;
    Save1: TMenuItem;
    Exit1: TMenuItem;
    XT: TEdit;
    YT: TEdit;
    WT: TEdit;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    procedure FormCreate(Sender: TObject);
    Procedure DrawFont(Sender: TObject);
    procedure LoadFont(Sender: TObject);
    procedure Font11Click(Sender: TObject);
    procedure Font21Click(Sender: TObject);
    procedure Font31Click(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Save1Click(Sender: TObject);
    procedure XTChange(Sender: TObject);
    procedure YTChange(Sender: TObject);
    procedure WTChange(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown3Click(Sender: TObject; Button: TUDBtnType);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

Type
TFnt = Packed Record
  X: DWord;
  Y: DWord;
  W: DWord;
end;

Type
TMFont = Packed Record
  Pos: DWord;
  Count: Integer;
  H: DWord;
  FFnt: Array of TFnt;
end;

var Fnt: Array[0..2] of TMFont; Pic: Array[0..2] of TDIB; FontID: Integer; HexError: Boolean;
Flag: Boolean;


Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char;
begin
 HexError := True;
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 HexError := False;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   HexError := True;
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;




Function IntToCr(const V: DWord; const Pos: Boolean): DWord;
var Sum: DWord; n, Step: Integer;
begin
  Step:=$800000;
  //Result:=$3B000000;
  If (FontID>0) and Pos then Result:=$3C000000 else Result:=$3B000000;
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
end;

Function CrToInt(const V: DWord; const Pos: Boolean): DWord;
var Sum: DWord; n, Step: Integer;
begin
  Result:=0;
  Step:=$800000;
  If (FontID>0) and Pos then n:=$3C000000 else n:=$3B000000;
  Sum:=0;
  While n<V do
  begin
  Inc(Result);
  Inc(n,Step);
  Inc(Sum,Step);
    If Sum>=$800000 then
    begin
      Sum:=0;
      Step:=Step div 2;
    end;
  end;
end;

Procedure TForm1.DrawFont(Sender: TObject);
var n:Integer;
begin

   If Font11.Checked then
   begin
    FontID:=0;
   end else If Font21.Checked then
   begin
    FontID:=1;
   end else
   begin
    FontID:=2;
   end;
   List.Clear;
   For n:=0 to Fnt[FontID].Count -1 do
   begin
    List.Items.Add(Format('%s - %d:%d;%d',[IntToHex(n,2), CrToInt(Fnt[FontID].FFnt[n].X, False),
    CrToInt(Fnt[FontID].FFnt[n].Y, True), CrToInt(Fnt[FontID].FFnt[n].W, False)]));
   end;
   List.ItemIndex:=0;
   ListClick(Sender);

   
end;



procedure TForm1.LoadFont(Sender: TObject);
var F: File; n,m: integer;
begin
  //FL:=$28; FS:=191; Adr:=$65CB0;  // Big Font
  //FL:=$28; FS:=$C4; Adr:=$24C90;  // Medium Font
  //FL:=$28; FS:=$BF; Adr:=$13CC0;  // Small Font

  If OpenDialog1.Execute and FileExists(OpenDialog1.FileName) then
  begin
    For n:=0 to 2 do
    begin
      OpenP.Title:='Open font '+IntToStr(n+1);
      OpenP.FileName:='font'+IntToStr(n+1)+'.bmp';
      If OpenP.Execute and FileExists(OpenP.FileName) then
      begin
        Pic[n]:=TDIB.Create;
        Pic[n].LoadFromFile(OpenP.FileName);
      end else
      begin
        {For m:=0 to n do
        begin
          Pic[m].Free;
        end;}
        Close;
        Exit;
      end;
    end;
    //Удачно

     Fnt[0].Count:=191;
     Fnt[1].Count:=$C4;
     Fnt[2].Count:=$BF;
     Fnt[0].Pos:=$65CB0;
     Fnt[1].Pos:=$24C90;
     Fnt[2].Pos:=$13CC0;
     Fnt[0].H:=41;
     Fnt[1].H:=23;
     Fnt[2].H:=17;
     AssignFile(F, OpenDialog1.FileName);
     Reset(F,1);
     //Img.Picture.Graphic:=Pic[0];
     For n:=0 to 2 do
     begin
      SetLength(Fnt[n].FFnt, Fnt[n].Count);
      Seek(F, Fnt[n].Pos);
      BlockRead(F, Fnt[n].FFnt[0], Fnt[n].Count*12);
     end;
     CloseFile(F);
     DrawFont(Sender);

  end else
  begin
    {For n:=0 to 2 do
    begin
     Pic[m].Free;
    end;}
    Close;
    Exit;
  end;


end;






procedure TForm1.FormCreate(Sender: TObject);
begin
//ShowMessage('');
end;

procedure TForm1.Font11Click(Sender: TObject);
begin
  Font11.Checked:=True;
  DrawFont(Sender);
end;

procedure TForm1.Font21Click(Sender: TObject);
begin
  Font21.Checked:=True;
  DrawFont(Sender);
end;

procedure TForm1.Font31Click(Sender: TObject);
begin
  Font31.Checked:=True;
  DrawFont(Sender);
end;
var p: TDIB;
procedure TForm1.ListClick(Sender: TObject);

begin
If not assigned(p) then p:=TDIB.Create;
  With Fnt[FontID] do
  begin
    P.Palette:=Pic[FontID].Palette;
    P.BitCount:=Pic[FontID].BitCount;
    P.PixelFormat:=Pic[FontID].PixelFormat;
    P.Width:=(CrToInt(FFnt[List.ItemIndex].W,False)+3)*8;
    P.Height:=H*8;
    Img.Width:=P.Width;
    Img.Height:=P.Height;
    P.Canvas.CopyRect(Bounds(0,0,(CrToInt(FFnt[List.ItemIndex].W,False)+3)*8,H*8), Pic[FontID].Canvas,
    Bounds(CrToInt(FFnt[List.ItemIndex].X,False),CrToInt(FFnt[List.ItemIndex].Y, True), CrToInt(FFnt[List.ItemIndex].W,False)+3,H));
    Img.Picture.Graphic:=P;
    Flag:=True;
    XT.Text:=IntToStr(CrToInt(FFnt[List.ItemIndex].X,False));
    YT.Text:=IntToStr(CrToInt(FFnt[List.ItemIndex].Y,True));
    WT.Text:=IntToStr(CrToInt(FFnt[List.ItemIndex].W,False));
    UpDown1.Position:=CrToInt(FFnt[List.ItemIndex].X,False);
    UpDown2.Position:=CrToInt(FFnt[List.ItemIndex].Y,True);
    UpDown3.Position:=CrToInt(FFnt[List.ItemIndex].W,False);
    //UpDown1.Min:=0;
    UpDown1.Max:=Pic[FontID].Width;
    UpDown2.Max:=Pic[FontID].Height;
    UpDown3.Max:=Pic[FontID].Width;
    Flag:=False;
  end;
end;

procedure TForm1.Edit2Change(Sender: TObject);
begin
//Edit3.Text:=IntToStr(CrToInt(HexToInt(Edit2.Text)));
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
If Assigned(Pic[0]) then Pic[0].Free;
If Assigned(Pic[1]) then Pic[1].Free;
If Assigned(Pic[2]) then Pic[2].Free;
If Assigned(p) then P.Free;
end;

procedure TForm1.Save1Click(Sender: TObject);
var F: File; n: Integer;
begin
  AssignFile(F, OpenDialog1.FileName);
  Reset(F,1);
  For n:=0 to 2 do
  begin
    Seek(F, Fnt[n].Pos);
    BlockWrite(F, Fnt[n].FFnt[0], Fnt[n].Count*12);
  end;
  CloseFile(F);
end;

procedure TForm1.XTChange(Sender: TObject);
begin
  If not Flag and (StrToInt(XT.Text)>=0) and (StrToInt(XT.Text)+StrToInt(WT.Text)<=Pic[FontID].Width) then
  begin
    Fnt[FontID].FFnt[List.ItemIndex].X:=IntToCr(StrToInt(XT.Text),False);
    List.Items.Strings[List.ItemIndex]:=Format('%s - %d:%d;%d',[IntToHex(List.ItemIndex,2), CrToInt(Fnt[FontID].FFnt[List.ItemIndex].X,False),
    CrToInt(Fnt[FontID].FFnt[List.ItemIndex].Y,True), CrToInt(Fnt[FontID].FFnt[List.ItemIndex].W,False)]);
    ListClick(Sender);
  end
end;

procedure TForm1.YTChange(Sender: TObject);
begin
  If not Flag and (StrToInt(YT.Text)>=0) and (StrToInt(YT.Text)+Fnt[FontID].H<=Pic[FontID].Height+1) then
  begin
    Fnt[FontID].FFnt[List.ItemIndex].Y:=IntToCr(StrToInt(YT.Text), True);
    List.Items.Strings[List.ItemIndex]:=Format('%s - %d:%d;%d',[IntToHex(List.ItemIndex,2), CrToInt(Fnt[FontID].FFnt[List.ItemIndex].X,False),
    CrToInt(Fnt[FontID].FFnt[List.ItemIndex].Y, True), CrToInt(Fnt[FontID].FFnt[List.ItemIndex].W,False)]);
    ListClick(Sender);
  end
end;

procedure TForm1.WTChange(Sender: TObject);
begin
  If not Flag and (StrToInt(WT.Text)>=0) and (StrToInt(XT.Text)+StrToInt(WT.Text)<=Pic[FontID].Width) then
  begin
    Fnt[FontID].FFnt[List.ItemIndex].W:=IntToCr(StrToInt(WT.Text),False);
    List.Items.Strings[List.ItemIndex]:=Format('%s - %d:%d;%d',[IntToHex(List.ItemIndex,2), CrToInt(Fnt[FontID].FFnt[List.ItemIndex].X,False),
    CrToInt(Fnt[FontID].FFnt[List.ItemIndex].Y, True), CrToInt(Fnt[FontID].FFnt[List.ItemIndex].W,False)]);
    ListClick(Sender);
  end
end;

procedure TForm1.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  XT.Text:=IntToStr(UpDown1.Position);
end;

procedure TForm1.UpDown2Click(Sender: TObject; Button: TUDBtnType);
begin
 YT.Text:=IntToStr(UpDown2.Position);
end;

procedure TForm1.UpDown3Click(Sender: TObject; Button: TUDBtnType);
begin
  WT.Text:=IntToStr(UpDown3.Position);
end;

end.
