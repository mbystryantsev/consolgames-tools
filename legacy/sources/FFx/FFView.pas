unit FFView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, XPMan, ComCtrls, ToolWin, BMPFnt, DIB,
  DXDraws, StrUtils, TextUnit, Menus, ActnList, ImgList;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
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
    Label7: TLabel;
    Label8: TLabel;
    cLC: TEdit;
    cAv: TEdit;
    Label9: TLabel;
    cSc: TEdit;
    Label10: TLabel;
    Button11: TButton;
    Button12: TButton;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    AOpen: TAction;
    ASave: TAction;
    ASaveAs: TAction;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    ImageList1: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    N8: TMenuItem;
    N9: TMenuItem;
    AVarList: TAction;
    FindDialog: TFindDialog;
    AFind: TAction;
    AFindNext: TAction;
    Status: TStatusBar;
    AGoTo: TAction;
    N10: TMenuItem;
    XPManifest1: TXPManifest;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    N11: TMenuItem;
    N12: TMenuItem;
    AExit: TAction;
    Panel1: TPanel;
    List: TListBox;
    Text: TMemo;
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
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure cXChange(Sender: TObject);
    procedure AOpenExecute(Sender: TObject);
    procedure ASaveExecute(Sender: TObject);
    procedure AVarListExecute(Sender: TObject);
    procedure AFindExecute(Sender: TObject);
    procedure AFindNextExecute(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure AGoToExecute(Sender: TObject);
    procedure ASaveAsExecute(Sender: TObject);
    procedure AExitExecute(Sender: TObject);
    
  private
    { Private declarations }
  public
    procedure ApplySettings;
    procedure Find(FD: TFindDialog; Sender: TObject);
    procedure VarInput(Sender: TObject; var Key: Char);
  end;
var
  Form1: TForm1;
  Pic: TBitmap; R: TRect;
  BitmapFont: TBMPFont;
  MFont: TFont;

implementation


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
  Status.Panels[0].Text := Format('Блок: %d/%d',[List.ItemIndex+1,List.Items.Count]);
  If List.ItemIndex>=0 Then Text.Text:=MText[List.ItemIndex];
  Button4Click(Sender);
  //With List do Text.Text:=Items.Strings[ItemIndex];
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
  Per : TText;
  Av  : TText;
  NoAv: TText;
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
    TFlags = Packed Record
    Carry  : Boolean;
    Window : Boolean;
    Avatar : Boolean;
    NoAvatar:Boolean;
  end;

var BG: TDIB; Tab: Array of TTable; Symb: TSymb; Flg: TFlags; Opt: TOptions; OFile:String;
//-----
procedure TForm1.Button2Click(Sender: TObject);
begin
end;
//--


procedure TForm1.Button3Click(Sender: TObject);
var F, F2: TextFile; Flag: Boolean; S, SS, S2, Txt: String; Pic, pic2: TDIB; I, X, Y, n: Integer;
begin
  Finalize(Symb.Per);
  Finalize(Symb.Av);
  Finalize(Symb.NoAv);

  Symb.ID:=0;

  x:=0; y:=0;
  //$646464;
  AssignFile(F2,opt.Path+opt.Code{'ff4txt.txt'});
  Reset(F2);
//pic2  := TDIB.Create;
  Pic := TDIB.Create;
  BG := TDIB.Create;                           //
  Pic.LoadFromFile(opt.Path+opt.Font{'ff4fnt.bmp'});
  BG.LoadFromFile(opt.Path+opt.BG{'BGround.bmp'});
  Readln(F2,S);               //
  Readln(F2,SS);
  //CloseFile(F2);
  For n:=1 to length(S) do
  begin
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
  while not eof(f) do
  begin
    ReadLn(F, S);
    If      S='[window]'  then begin symb.ID:=1; ReadLn(F, S); end
    else if S='[avatar]'  then begin symb.ID:=2; ReadLn(F, S); end
    else if S='[avatar!]' then begin symb.ID:=3; ReadLn(F, S); end;
    Case Symb.ID of
      0:
      begin
        If pos('=', S)>0 Then
        begin
          SetLength(Tab, Length(Tab)+1);
          Tab[Length(Tab)-1].A := MidStr(S, 1, pos('=', S)-1);
          Tab[Length(Tab)-1].B := MidStr(S, pos('=', S)+1, Length(S));
        end;
      end;
      1:
      begin
        SetLength(Symb.Per,Length(Symb.Per)+1);
        Symb.Per[High(Symb.Per)]:=S;
      end;
      2:
      begin
        SetLength(Symb.Av,Length(Symb.Av)+1);
        Symb.Av[High(Symb.Av)]:=S;
      end;
      3:
      begin
        SetLength(Symb.NoAv,Length(Symb.NoAv)+1);
        Symb.NoAv[High(Symb.NoAv)]:=S;
      end;
    end;
  end;
  CloseFile(F);
  CloseFile(F2);
  Pic.Free;
  opt.Loaded:=True;
//Button4Click(Sender);
end;

procedure TForm1.ApplySettings;
begin
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
end;

procedure TForm1.Button4Click(Sender: TObject);
var p, ps, n, x, y, l, av, WPos: integer; S: String; W: TWindow;
label l0, l1, l21, l20, 1120, 1121, 2120, 2121;
begin
  ApplySettings;
  FillChar(Flg,4,0);

  w.Flag := false;
  DXDraw1.Surface.FillRect(bounds(0,0,DXDraw1.Width,DXDraw1.Height),0);
  x:=opt.x;
  y:=opt.y;
  if ChBG.Checked = True then DXDraw1.Surface.Canvas.Draw(0,0,BG);
  av:=0;
  For n:= 0 to Text.Lines.Count-1 do
  Begin
    S:=Text.Lines.Strings[n];
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
  For l:=0 to High(Symb.Per) do
  begin
    If Pos(Symb.Per[l], S)>0 then
    begin
      If Pos(Symb.Per[l], S)>(Length(S) div 3) then
      begin
        w.Flag:=True;
      end else
      begin
        flg.Carry:=True;
      end;
      break;
    end;
  end;

  if flg.Carry then
  begin
    If w.Count>=7 then
      begin
        inc(w.BigCount,opt.WH*opt.WY); w.Count:=-1; x:=opt.x;
      end;
    w.Lines:=0;
    w.Count:=w.Count + 1;
      if w.count<4 then
      begin
        y:=(opt.WH*(w.Count)+opt.y);
      end else
      begin
        x:=opt.ww+opt.x;
        y:=w.BigCount+(opt.WH*(w.Count-4)+opt.y);
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

  //Типа аватары =)
  if ChAvatar.Checked Then
  begin
    If Flg.NoAvatar Then Flg.Avatar:=False;
    If InText(Text.Lines[n],Symb.Av) Then Flg.Avatar:=True;
    Flg.NoAvatar:=InText(Text.Lines[n],Symb.NoAv);
    If Flg.Avatar Then av:=opt.Av else av:=0;
  end;

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
  With DXDraw1.Surface do
  BitmapFont.CanvasDrawText(Canvas, S, (x+av)*opt.Sc, {w.BigCount+}(y-w.Zoom)*opt.Sc);
  inc(y, opt.d);
end;
  DXDraw1.Surface.Canvas.Release;
  DXDraw1.Flip;
  //If ePos2.Checked = True then begin y:=y+53*4; end else if ePos3.Checked = True then begin y:=y+(53*4)*2; end;

end;


procedure TForm1.VarInput(Sender: TObject; var Key: Char);
begin
  If not (Key in ['0'..'9', #8]) then Key := #0;
end;



procedure TForm1.cXKeyPress(Sender: TObject; var Key: Char);
begin
  If not (Key in ['0'..'9', #8]) then Key := #0;
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
  if ChAuto.Checked = True Then Button4Click(Sender);
  If list.ItemIndex >= 0 Then
  begin
    MText[list.ItemIndex] := Text.Text;
    List.Items.Strings[list.ItemIndex]:=Format('%.64s',[MText[list.ItemIndex]]);
  end;
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

Const cConfigArray: Array[0..18] of String = ('PATH','X','Y','FONT','FH','FW','FX',
'CH','TABLE','BG','CODE','D','LC','WH','WW','WX','WY','AV','SC');

Function GetParamID(S: String; A: Array of String): Integer;
var n: Integer;
begin
  For Result:=Low(A) To High(A) do If GetUpCase(S)=A[Result] Then Exit;
  Result:=-1;
end;

procedure TForm1.Button12Click(Sender: TObject);
var S, L, R: String; List: TStringList; n,ID: Integer;
begin
    List:=TStringList.Create;
    List.LoadFromFile(opt.Cfg);
    For n:=0 To List.Count-1 do
    begin
      S:=List.Strings[n];
      If pos('=', S)>1 then
      begin
        L:=MidStr(S,1,pos('=', S)-1);
        R:=MidStr(S,pos('=', S)+1,Length(S)-pos('=', S)+1);
        ID:=GetParamID(L,cConfigArray);
        Case ID of
           0: opt.Path:=R;
           1: cX.Text:=R;
           2: cY.Text:=R;
           3: opt.Font:=R;
           4: opt.FH:=StrToInt(R);
           5: opt.FW:=StrToInt(R);
           6: opt.FX:=StrToInt(R);
           7: opt.CH:=StrToInt(R);
           8: opt.Table:=R;
           9: opt.BG:=R;
          10: opt.Code:=R;
          11: cD.Text:=R;
          12: cLC.Text:=R;
          13: cWH.Text:=R;
          14: cWW.Text:=R;
          15: cWX.Text:=R;
          16: cWY.Text:=R;
          17: cAv.Text:=R;
          18: cSc.Text:=R;
        end;
      end;
    end;
  List.Free;
  Button3Click(Sender);
end;

procedure TForm1.cXChange(Sender: TObject);
begin
  If opt.Loaded=True then begin Button4Click(Sender); end;
end;

procedure TForm1.AOpenExecute(Sender: TObject);
var n: Integer;
begin
  If not OpenDialog1.execute Then Exit;
  If (FileExists(OpenDialog1.FileName)) then
  begin
    Finalize(MText);
    LoadText(OpenDialog1.FileName,MText);
    Text.Clear;
    List.Clear;
    For n:=0 To High(MText) do List.Items.Add(Format('%.64s',[MText[n]]));
    List.ItemIndex:=0;
    ListClick(Sender);
    opt.OFile:=OpenDialog1.FileName;
    Status.Panels[1].Text := opt.OFile;
  end;
end;

procedure TForm1.ASaveExecute(Sender: TObject);
begin
  If opt.OFile='' then Exit;
  Try
    SaveText(opt.OFile,MText);
  except
    ShowMessage('Ошибка при сохранении!');
    Exit;
  end;
  Status.Panels[1].Text:=Opt.OFile;
end;

procedure TForm1.AVarListExecute(Sender: TObject);
begin
ShowMessage('X - положение текста в окне по X'+#13#10 +'Y - положение текста в окне по Y'
+ #13#10 +'D - интервал между строками'+ #13#10 +'LC - количество строк в окне'+ #13#10 +
'WH - Высота окна'+ #13#10 +'WW - ширина окна'+ #13#10 +
'WX - количество окон по горизонтали'+ #13#10 +'WY - количество окон по вертикали'+
#13#10+'Av - ширина аватар' + #13#10 + 'Sc - масштаб' + #13#10);
end;


Procedure TForm1.Find(FD: TFindDialog; Sender: TObject);
var n,Pos,FPos,l: Integer; S, ST: String; FDown: Boolean;
Label BRK;
  Function CheckForWord(S: String; Pos,Len: Integer): Boolean;
  begin
    Result:=True;
    If not ((Pos=1) or ((Pos>1) and (not (S[Pos-1] in ['a'..'z','A'..'Z','а'..'я','А'..'Я'])))) Then
    begin
      Result:=False;
      Exit;
    end;
    If not ((Len+Pos-1=Length(S)) or ((Len+Pos-1<>Length(S)) and
    not (S[Pos+Len] in ['a'..'z','A'..'Z','а'..'я','А'..'Я']))) Then
    begin
      Result:=False;
      Exit;
    end;
  end;
begin
  FDown:=frDown in FD.Options;
  Pos:=Text.SelStart+1;
  If Text.SelLength>0 Then
  begin
    If FDown Then Inc(Pos);
  end;
  If not FDown Then Dec(Pos);
  If not FDown and (Pos=0) Then Pos:=-1;
  S:=FD.FindText;
  If S='' Then Exit;
  n:=List.ItemIndex;
  While (n<=High(MText)) and (n>=0) do
  begin
    ST:=MText[n];
    If not (frMatchCase in FD.Options) then
    begin
      ST:=GetUpCase(ST);
      S:= GetUpCase(S);
    end;
    If FDown Then FPos:=PosEx(S,ST,Pos) else FPos:=PosExRev(S,ST,Pos);
    If (FPos>0) Then
    begin
      If (frWholeWord in FD.Options) and (not CheckForWord(ST,FPos,Length(S))) Then
        GoTo BRK;
      List.ItemIndex:=n;
      ListClick(Sender);
      Text.SelStart:=FPos-1;
      Text.SelLength:=Length(S);
      Text.SetFocus;
      FD.CloseDialog;
      Exit;
      BRK:
    end;
    If FDown Then Inc(n) else Dec(n);
    If FDown Then Pos:=1 else Pos:=0;
  end;
  FD.CloseDialog;
  ShowMessage('Текст не найден!');
end;

procedure TForm1.AFindExecute(Sender: TObject);
begin
  FindDialog.Execute;
end;

procedure TForm1.AFindNextExecute(Sender: TObject);
begin
  If FindDialog.FindText='' Then
  begin
    FindDialog.Execute;
    Exit;
  end else
    Find(FindDialog,Sender);
end;

procedure TForm1.FindDialogFind(Sender: TObject);
begin
  Find(FindDialog,Sender);
end;

var PrevGoTo: String='0';
procedure TForm1.AGoToExecute(Sender: TObject);
var n: Integer;
begin
  PrevGoTo:=InputBox('Перейти к строке...','Введите номер строки:',PrevGoTo);
  Try
    n:=StrToInt(PrevGoTo);
  except
    ShowMessage('Вы должны ввести числовое значение!');
  end;
  If (n>=1) and (n<=List.Count) Then
  begin
    List.ItemIndex:=n-1;
    ListClick(Sender);
  end;
end;

procedure TForm1.ASaveAsExecute(Sender: TObject);
begin
  If not SaveDialog1.Execute Then Exit;
  Opt.OFile:=SaveDialog1.FileName;
  ASaveExecute(Sender);
end;

procedure TForm1.AExitExecute(Sender: TObject);
begin
  Close;
end;

Initialization
  MFont:=TFont.Create;
  BitmapFont := TBMPFont.Create;
  BitmapFont.Transparent := True;
  BitmapFont.TransparentColor := 0;
Finalization
  MFont.Free;
  BitmapFont.Free;
end.
