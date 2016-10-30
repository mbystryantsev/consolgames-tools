unit dd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, XPMan, ComCtrls, ToolWin, BMPFnt, DIB,
  DXDraws, StrUtils;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    List: TListBox;
    Text: TMemo;
    FontAdr: TEdit;
    FontTxt: TEdit;
    Button3: TButton;
    Button4: TButton;
    DXDraw1: TDXDraw;
    ChAvatar: TCheckBox;
    cX: TEdit;
    cY: TEdit;
    cD: TEdit;
    cWH: TEdit;
    ChBG: TCheckBox;
    ChAuto: TCheckBox;
    ChReplace: TCheckBox;
    ChByte: TCheckBox;
    Button5: TButton;
    LBlock: TLabel;
    EGoTo: TEdit;
    Button6: TButton;
    EFind: TEdit;
    Button7: TButton;
    Edit4: TEdit;
    Button8: TButton;
    Button9: TButton;
    SaveDialog1: TSaveDialog;
    ePos1: TRadioButton;
    ePos2: TRadioButton;
    ePos3: TRadioButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cWW: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    cWX: TEdit;
    cWY: TEdit;
    Button10: TButton;
    Label7: TLabel;
    Label8: TLabel;
    cLC: TEdit;
    cAv: TEdit;
    Label9: TLabel;
    cSc: TEdit;
    Label10: TLabel;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button2: TButton;
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Label1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure cXKeyPress(Sender: TObject; var Key: Char);
    procedure cYKeyPress(Sender: TObject; var Key: Char);
    procedure cDKeyPress(Sender: TObject; var Key: Char);
    procedure cWHKeyPress(Sender: TObject; var Key: Char);
    procedure TextChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
//    procedure CButton4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure cXChange(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
  Pic: TBitmap; R: TRect;
  BitmapFont: TBMPFont;
Function CharToWideChar(Ch: Char): WideChar;
implementation
Function CharToWideChar(Ch: Char): WideChar;
Var WS: WideString;
begin
 WS := Ch;
 Result := WS[1];
end;
{$R *.dfm}
var i:integer=0; lb:string;
procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
lb:=inttostr(x)+':'+inttostr(y);
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
//ddd
end;

procedure TForm1.ListClick(Sender: TObject);
begin
Button4Click(Sender);
LBlock.Caption := 'Блок: ' + IntToStr(List.ItemIndex+1) + '/' + IntToStr(List.Items.Count);
LBlock.Refresh;
with list do Text.Text:=Items.Strings[ItemIndex];
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var n,m: integer; c: integer;
begin
end;
//-----    
 
Type
 TTable = Record
  A : String;
  B : String;
 end;

 Type
 TSymb = Record
  Per : TStringList;
  Av  : TStringList;
  AvDel:TStringList;
  ID  : Integer;
 end;

 Type
 TOptions = Record
  X, Y, WH{Высота окна}, WW{Ширина окна}, WX{Окон по гор.},
  WY{Окон по верт.}, LC{Кол-во строк},
  D{Отступ вниз}, Av{Ширина аватар}, Sc{Масштаб}, FW{}, FH{}, FX{}, CH: Integer;
  OFile, Table, BG, Font, Code, Cfg, Path: String;
  Loaded: Boolean;
 end;


 Type
 TWindow = Record
  Lines: Integer;
  Count: Integer;
  Flag: Boolean;
  BigCount: Integer;
  Zoom: Integer;
 end;

  Type
    TFlags = Record
    Carry  : Boolean;
    Window : Boolean;
    Avatar : Boolean;
  end;

var BG: TDIB; Tab: Array of TTable; Symb: TSymb; Flg: TFlags; Opt: TOptions; OFile:String;
//-----
procedure TForm1.Button2Click(Sender: TObject);
var F: TextFile; Flag, cFlag: Boolean; S, Txt: String;
begin
  If not OpenDialog1.execute Then Exit;
  If (FileExists(OpenDialog1.FileName)) then
  begin
    opt.OFile:=OpenDialog1.FileName;
    List.Clear;
    AssignFile(F,OpenDialog1.FileName);
    Reset(F);
    Flag:=False; cFlag:=False;
    While not Eof(F) do
      begin
      Readln(F,S);
      if (S='') and (cFlag=False) then
      begin
        list.Items.Add(Txt);
        Txt:=''; Flag := False; cFlag:=True
      end else
      begin
        If flag = true then txt := txt + #13#10;
        Txt:=Txt + S; Flag:=true; cFlag:=False;
      end;
      //ShowMessage(S+#13#10+inttostr(N));
    end;
    If S<>'' then begin list.Items.Add(Txt); end;
    List.ItemIndex:=0;
    ListClick(Sender);
    CloseFile(F);
  end;
end;
//--


procedure TForm1.Button3Click(Sender: TObject);
var F, F2: TextFile; Flag: Boolean; S, SS, S2, Txt: String; Pic, pic2: TDIB; I, X, Y, n: Integer;
begin
If Assigned(Symb.Per) then begin Symb.Per.Free; end;
If Assigned(Symb.Av) then begin Symb.Av.Free; end;
Symb.ID:=0;

x:=0; y:=0;
 BitmapFont := TBMPFont.Create;               //
 BitmapFont.Transparent := True;              //
 BitmapFont.TransparentColor := 0;//$646464;      //
AssignFile(F2,opt.Path+opt.Code{'ff4txt.txt'});                                    //
Reset(F2);
//pic2  := TDIB.Create;
Pic := TDIB.Create;
BG := TDIB.Create;                           //
Pic.LoadFromFile(opt.Path+opt.Font{'ff4fnt.bmp'});
BG.LoadFromFile(opt.Path+opt.BG{'BGround.bmp'});
  Readln(F2,S);               //
  Readln(F2,SS);
  //CloseFile(F2);
For n:=1 to length(S) do begin
  Readln(F2,S2);
  BitmapFont.AddFromDIBRect(Pic, Bounds(X, Y, StrToInt(S2),opt.fw {16}), StrToInt(S2)*2, opt.fw{16}*2, CharToWideChar(S[n]));
  BitmapFont.AddFromDIBRect(Pic, Bounds(X, Y, StrToInt(S2),opt.fw {16}), StrToInt(S2)*2, opt.fw{16}*2, CharToWideChar(SS[n]));
  inc(x,opt.FW {16});
  if x>=opt.FX*opt.FW {128} then begin
    x:=0; inc(y, opt.FH{16});
  end;
end;
AssignFile(F, opt.Path+opt.Table{'table.txt'});                                    //
Reset(F);
while not eof(f) do begin
  ReadLn(F, S);
  If S='[window]' then
  begin
    symb.ID:=1;
    ReadLn(F, S);
  end else if s='[avatar]' then
  begin
    symb.ID:=2;
    ReadLn(F, S);
  end else if s='[avatar!]' then
  begin 
    symb.ID:=3;
    ReadLn(F, S);
  end;
  If (symb.ID=0) and (pos('=', S)>0) Then begin
    SetLength(Tab, Length(Tab)+1);
    Tab[Length(Tab)-1].A := MidStr(S, 1, pos('=', S)-1);
    Tab[Length(Tab)-1].B := MidStr(S, pos('=', S)+1, Length(S));
    //ShowMessage(Tab[Length(Tab)-1].A+IntToStr(Length(Tab)-1));
  end else if symb.ID=1 then begin
    If not Assigned(Symb.Per) then begin Symb.Per:=TStringList.Create; end;
    Symb.Per.Add(S);
  end else if symb.ID=2 then begin
    If not Assigned(Symb.Av) then begin Symb.Av:=TStringList.Create; end;
    Symb.Av.Add(S);
  end else if symb.ID=3 then begin
    If not Assigned(Symb.AvDel) then begin Symb.AvDel:=TStringList.Create; end;
    Symb.AvDel.Add(S);
  end;
end;
CloseFile(F);
CloseFile(F2);
Pic.Free;
opt.Loaded:=True;
//Button4Click(Sender);
end;

procedure TForm1.Button4Click(Sender: TObject);
var p, ps, n, x, y, l, av, WPos: integer; S: String; Flag, Flag2: Boolean; W: TWindow;
label l0, l1, l21, l20, 1120, 1121, 2120, 2121;
begin

//Применение настроек:

opt.X:=StrToInt(cX.Text);
opt.Y:=StrToInt(cY.Text);
opt.D:=StrToInt(cD.Text);
opt.WH:=StrToInt(cWH.Text);
opt.WW:=StrToInt(cWW.Text);
opt.WX:=StrToInt(cWX.Text);
opt.WY:=StrToInt(cWY.Text);
opt.LC:=StrToInt(cLC.Text);
opt.Av:=StrToInt(cAv.Text);
opt.Sc:=StrToInt(cSc.Text);

//-||


w.Flag := false;
DXDraw1.Surface.FillRect(bounds(0,0,DXDraw1.Width,DXDraw1.Height),0);
x:=opt.x;
y:=opt.y;
if ChBG.Checked = True then begin
DXDraw1.Surface.Canvas.Draw(0,0,BG);
//DXDraw1.Surface.Canvas.Release;
//DXDraw1.Flip;
end;
av:=0;
for n:= 0 to text.Lines.Count-1 do begin
  s:=Text.lines.Strings[n];
  //---



  if w.flag = True then
  begin
    If w.Count>=7 then
      begin
        inc(w.BigCount,opt.WH*opt.WY {212}); w.Count:=-1; x:=opt.x;
      end;
    w.Flag:=False;
    w.Lines:=0;
    w.Count:=w.Count + 1;
    if w.count< 4 then
    begin
      y:=w.BigCount+(opt.WH{53}*(w.Count)+opt.y);
    end else
    begin
      x:=opt.WW{240}+StrToInt(cX.Text);
      y:=w.BigCount+(opt.WH{53}*(w.Count-4)+opt.y);
    end;
  end;

  //Переносы. Проверка, установка флага, а затем всё остальное.
  Flg.Carry:=False;
If Assigned(Symb.Per) then
begin
  For l:=0 to Symb.Per.Count-1 do
  begin
    If Pos(Symb.Per.Strings[l], S)>0 then
    begin
      If Pos(Symb.Per.Strings[l], S)>(Length(S) div 3) then
      begin
        w.Flag:=True;
      end else
      begin
        flg.Carry:=True;
      end;
      break;
    end;
  end;
end;

  if flg.Carry=True then
  begin
    If w.Count>=7 then
      begin
        inc(w.BigCount,opt.WH*opt.WY{212}); w.Count:=-1; x:=opt.x;
      end;
    w.Lines:=0;
    w.Count:=w.Count + 1;
      if w.count<4 then
      begin
        y:=(opt.WH{53}*(w.Count)+opt.y);
      end else
      begin
        x:=opt.ww{240}+opt.x;
        y:=w.BigCount+(opt.WH{53}*(w.Count-4)+opt.y);
      end;

  end;

  //---


  w.Lines:=w.Lines + 1;
  if w.Lines >= opt.LC+1 then
    begin
    If w.Count>=opt.WX*opt.wy-1 {7} then
      begin
        inc(w.BigCount,Opt.WH*Opt.WY{212}); w.Count:=-1; x:=opt.x;
      end;
    w.Count:=w.Count+1;
    w.lines:=1;
    if w.count<4 then
    begin
      y:=w.BigCount+(Opt.WH{53}*(w.Count)+opt.Y);
    end else
    begin
      x:=opt.ww+opt.x;
      y:=w.BigCount+(Opt.WH{53}*(w.Count-4)+opt.Y);

    end;
  end;

  //---
  //Замена типа :)
  if ChReplace.Checked = True then begin
  for l:=0 to Length(tab)-1 do begin
  ps:=0;
  l0:
    p:=pos(Tab[l].A, S);
    If (p>0) and (p>ps) Then begin
      S:=MidStr(S, 1, p-1) + tab[l].B + MidStr(S, p+length(tab[l].A), 1+length(s)-(p+length(tab[l].A)));
      ps:=p+length(tab[l].B)-1;
    end else begin
      GoTo l1;
    end;
    GoTo l0;
    l1:
  end;
  end;

  //---

    //Убираем лишнее)

{  if ChByte.Checked = True then
  begin
    for l:=0 to Length(tab)-1 do
    begin
    l20:
      p:=pos('[#', S);
      If p>0 Then
      begin
        if MidStr(S, p+4, 1) = ']' then
        begin
          S:=MidStr(S, 1, p-1) + MidStr(S, p+5, length(s)-(p+3));
        end else
        begin
          GoTo l21;
        end;
        GoTo l20;
        l21:
      end;
    end;
    for l:=0 to Length(tab)-1 do
    begin
    1120:
      p:=pos(#$7B, S);
      If p>0 Then
      begin
        if MidStr(S, p+3, 1) = #$7D then
        begin
          S:=MidStr(S, 1, p-1) + MidStr(S, p+4, length(s)-(p+2));
        end else
        begin
          GoTo 1121;
        end;
        GoTo 1120;
      end;
      1121:
    end;
  end; }
  //---
  //Типа аватары =)
  if ChAvatar.Checked = True then begin

    if Flag2 = True then begin Flag2:=False; av:=0; end;
    if Flag = True then begin Flag:=False; av:=Opt.Av{32}*opt.Sc; end;


   
  Flg.Avatar:=False;
If Assigned(Symb.Av) then
begin
  For l:=0 to Symb.Av.Count-1 do
  begin
    If Pos(Symb.Av.Strings[l], S)>0 then
    begin
      If Pos(Symb.Av.Strings[l], S)>(Length(S) div 2) then
      begin
        Flag:=True;
      end else
      begin
        flg.Avatar:=True;
      end;
      break;
    end;
  end;
end;

If Assigned(Symb.Per) then
begin
  For l:=0 to Symb.AvDel.Count-1 do
  begin
    If Pos(Symb.AvDel.Strings[l], S)>0 then
    begin
      If Pos(Symb.AvDel.Strings[l], S)>(Length(S) div 2) then
      begin
        Flag2:=True;
      end else
      begin
        flg.Avatar:=False;
        av:=0;
      end;
      break;
    end;
  end;
end;



    if flg.Avatar=True then
    begin
          if midStr(S, pos('[#C5][#A', S),10)<>'[#C5][#AC]' then
          begin
            if (pos('[#C5][#A', S)=length(S)-10) or (pos('[#C5][#A', S)=length(S)-10) then
            begin
              flag:=True;
            end else
            begin av:=Opt.av{32}*opt.Sc;
            end;
          end;
    end;

    {if pos('[#C5][#BA]', S)=length(S)-9 then
    begin
      flag2:=True;
    end else
    begin av:=0; end;}
    end;
  //---
  //Убираем лишнее)

  if ChByte.Checked = True then
  begin
    for l:=0 to Length(tab)-1 do
    begin
    l20:
      p:=pos('[#', S);
      If p>0 Then
      begin
        if S[p+4] = ']' then
        begin
          S:=MidStr(S, 1, p-1) + MidStr(S, p+5, length(s)-(p+3));
        end else
        begin
          GoTo l21;
        end;
        GoTo l20;
        l21:
      end;
    end;
    for l:=0 to Length(tab)-1 do
    begin
    1120:
      p:=pos(#$7B, S);
      If p>0 Then
      begin
        if S[p+3] = #$7D then
        begin
          S:=MidStr(S, 1, p-1) + MidStr(S, p+4, length(s)-(p+2));
        end else
        if S[p+4] = #$7D then
        begin
          S:=MidStr(S, 1, p-1) + MidStr(S, p+5, length(s)-(p+3));
        end else
        begin
          GoTo 1121;
        end;
        GoTo 1120;
      end;
      1121:
    end;
    for l:=0 to Length(tab)-1 do
    begin
    2120:
      p:=pos('/', S);
      If p>0 Then
      begin
        if ((S[p+1] in ['0'..'9']) or (S[p+1] in ['A'..'F']))
        and ((S[p+2] in ['0'..'9']) or (S[p+2] in ['A'..'F'])) then
        begin
          S:=MidStr(S, 1, p-1) + MidStr(S, p+3, length(s)-(p+1));
        end else
        begin
          GoTo 2121;
        end;
        GoTo 2120;
      end;
      2121:
    end;
  end;   
  //---
  w.Zoom:=0;
  If ePos2.Checked = True then begin w.Zoom:= Opt.WH{53}*4; end else if ePos3.Checked = True then begin w.Zoom:=(53*4)*2; end;
  With DXDraw1.Surface do begin
  BitmapFont.CanvasDrawText(Canvas, S, x*opt.Sc+av, {w.BigCount+}(y-w.Zoom)*opt.Sc);
  end;
  inc(y, opt.d);
end;
  DXDraw1.Surface.Canvas.Release;
  DXDraw1.Flip;
  //If ePos2.Checked = True then begin y:=y+53*4; end else if ePos3.Checked = True then begin y:=y+(53*4)*2; end;

end;



procedure TForm1.cXKeyPress(Sender: TObject; var Key: Char);
//var Sender: TEdit;
begin
//If not ((Key in [#8]) and (Length(Sender.Text)>1)) then begin
If not (Key in ['0'..'9', #8]) then Key := #0;
//end;
end;

procedure TForm1.cYKeyPress(Sender: TObject; var Key: Char);
begin
If not (Key in ['0'..'9', #8]) then Key := #0;
end;

procedure TForm1.cDKeyPress(Sender: TObject; var Key: Char);
begin
If not (Key in ['0'..'9', #8]) then Key := #0;
end;

procedure TForm1.cWHKeyPress(Sender: TObject; var Key: Char);
begin
If not (Key in ['0'..'9', #8]) then Key := #0;
end;

procedure TForm1.TextChange(Sender: TObject);
begin
if ChAuto.Checked = True then begin Button4Click(Sender); end;
If (List.Items.Count>0) and (list.ItemIndex >= 0) then begin
List.Items.Strings[list.ItemIndex] := Text.Text; end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

Button11Click(Sender);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
//Button4Click(Sender);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
BG.Free;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
If (List.Items.Count>0) and (StrToInt(EGoTo.Text)>0) and(StrToInt(EGoTo.Text)<List.Items.Count-1) then begin
List.ItemIndex := StrToInt(EGoTo.Text)-1;
ListClick(Sender);
 end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var F: TextFile; n: integer; S: String;
begin
If SaveDialog1.Execute = true then begin
  S:=SaveDialog1.FileName;
  if S<>'' then begin
    AssignFile(F, S);
    Rewrite(F);
    For n:=0 to list.Items.Count-1 do begin
       writeln(F,List.items.strings[n]+#13#10);
       //writeln(#13#10);
    end;
    CloseFile(F);
  end;
end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var n: integer;
label ed;
begin
For n:=List.ItemIndex+1 to List.Items.Count-1 do begin
    If pos(EFind.Text, List.Items.Strings[n])>0 then begin
      list.ItemIndex:=n;
      GoTo ed
    end;
end;
ed:
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
ShowMessage('X - положение текста в окне по X'+#13#10 +'Y - положение текста в окне по Y'
+ #13#10 +'D - интервал между строками'+ #13#10 +'LC - количество строк в окне'+ #13#10 +
'WH - Высота окна'+ #13#10 +'WW - ширина окна'+ #13#10 +
'WX - количество окон по горизонтали'+ #13#10 +'WY - количество окон по вертикали'+
#13#10+'Av - ширина аватар' + #13#10 + 'Sc - масштаб' + #13#10);
end;

procedure TForm1.Button11Click(Sender: TObject);
var F: TextFile; S, Tmp: String;
begin
If FileExists('FFx.ini') then
  begin
    AssignFile(F, 'FFx.ini');
    Reset(F);
    Readln(F,opt.Cfg);
    CloseFile(F);
    Button12Click(Sender);
  end;
end;

procedure TForm1.Button12Click(Sender: TObject);
var F: TextFile; S, Tmp, TR: String;
begin
    AssignFile(F, opt.Cfg);
    Reset(F);
    While not eof(F) do
      begin
        Readln(F, S);
        If pos('=', S)>1 then
          begin
            Tmp:=MidStr(S,1,pos('=', S)-1);
            TR:=MidStr(S,pos('=', S)+1,Length(S)-pos('=', S)+1);
            If Tmp='x' then
              begin
                cX.Text:=TR;
              end else if Tmp='path' Then
              begin
                opt.Path:=TR;
              end else if Tmp='y' Then
              begin
                cY.Text:=TR;
              end else if Tmp='font' Then
              begin                      
                opt.Font:=TR;
              end else if Tmp='fh' Then
              begin                   
                opt.FH:=StrToInt(TR);
              end else if Tmp='fw' Then
              begin
                opt.FW:=StrToInt(TR);
              end else if Tmp='fx' Then
              begin         
                opt.FX:=StrToInt(TR);
              end else if Tmp='ch' Then
              begin                    
                opt.CH:=StrToInt(TR);
              end else if Tmp='table' Then
              begin              
                opt.Table:=TR;
              end else if Tmp='bg' Then
              begin                  
                opt.BG:=TR;
              end else if Tmp='code' Then
              begin
                opt.Code:=TR;
              end else if Tmp='d' Then
              begin
                cD.Text:=TR;
              end else if Tmp='lc' Then
              begin
                cLC.Text:=TR;
              end else if Tmp='wh' Then
              begin
                cWH.Text:=TR;
              end else if Tmp='ww' Then
              begin
                cWW.Text:=TR;
              end else if Tmp='wx' Then
              begin
                cWX.Text:=TR;
              end else if Tmp='wy' Then
              begin
                cWY.Text:=TR;
              end else if Tmp='av' Then
              begin
                cAv.Text:=TR;
              end else if Tmp='sc' Then
              begin
                cSc.Text:=TR;
              end;
          end;
      end;
      CloseFile(F);
      Button3Click(Sender);
end;

procedure TForm1.cXChange(Sender: TObject);
begin
If opt.Loaded=True then begin Button4Click(Sender); end;
end;

procedure TForm1.Button13Click(Sender: TObject);
var F: TextFile; n: integer;
begin

  if opt.OFile<>'' then
  begin
    AssignFile(F, opt.OFile);
    Rewrite(F);
    For n:=0 to list.Items.Count-1 do
    begin
       writeln(F,List.items.strings[n]+#13#10);
       //writeln(#13#10);
    end;
    CloseFile(F);
  end;
end;

end.
