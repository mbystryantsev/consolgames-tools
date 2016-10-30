unit FF7_Window;

interface

uses DXDraws, FF7_Common, Classes, DIB, Windows, FF7_Text, StrUtils, Graphics;

Type
  TWin = Packed Record
    ID,N: Byte;
    X,Y: SmallInt;
    W,H: Word;
  end;
  TDlg = Packed Record
    ID,N,D: Byte;
  end;
  TAsk = Packed Record
    ID,Bank,Win,Mess,First,Last,Addr: Byte;
  end;

  TAskMsg = Packed Record
    ID: Byte;
    Case Byte of
      0: (N,D: Byte);
      1: (Bank,Win,Mess,First,Last,Addr: Byte);
    end;

  TResize = Packed Record
    Mode, ROn: Boolean;
    RType, WX,WY,WW,WH,X, Y: Integer;
  end;

  TDrawWindow = Class;

  TWFont = Class
  Private
    FDrawWindow: TDrawWindow;
    FTim,FTable: Pointer;
    Pic, RPic, BPic: TDIB;
    W: Array[Byte] of Byte;
    O: Array[Byte] of Byte;
    Function FLoaded: Boolean;
  Public
    Procedure LoadFont(TimFile, WFile: String);
    Property  Loaded: Boolean read FLoaded;
    Function  DrawChar(ID: Byte; DXD: TDXDraw; X,Y: Integer): Byte;
    Procedure DrawIDLine(Line: String; DXD: TDXDraw; X,Y: Integer);
    Function  DrawLine(S: String; DXD: TDXDraw; Table: TTableArray; X,Y: Integer): Integer;
    Procedure DrawText(Text: String; DXD: TDXDraw; Table: TTableArray; X,Y,H: Integer);
    Procedure DrawTextOnWindow(Text: String; DXD: TDXDraw; Table: TTableArray; Win: TWin);
    //S: String;
//    Procedure LoadFromFile(FileName: String);
  end;

  TDrawWindow = Class
  private
    FDXDraw:  TDXDraw;
    FFont:    TWFont;
  public
    Procedure DrawWindowConture(Win: TWin);
    Procedure DrawWindow(Win: TWin);
    Function  CheckWindow(Win: TWin; XX,YY: Integer): Integer;
    Property  DXDraw: TDXDraw read FDXDraw;
  end;


Type
  TWinNames = Record
    Cloud, Barret, Tifa, Aerith, Red, Yuffie, Cait,
    Vincen, Cid, Party1, Party2, Party3: String;
  end;

const
  {WinNames: TWinNames = (
  Cloud: 'Клауд'; Barret: 'Баррет'; Tifa: 'Тифа'; Aerith: 'Аэрис'; Red: 'Ред-XIII';
  Yuffie: 'Юффи'; Cait: 'Кайт Ши'; Vincent: 'Винсент'; Cid: 'Сид'; Party1: '[Party #1]';
  Party2: '[Party #2]'; Party3: '[Party #3]');}
  WinNames: Array[0..11] of String = (
  'Клауд', 'Баррет', 'Тифа', 'Аэрис', 'Ред-XIII', 'Юффи', 'Кайт Ши', 'Винсент',
  'Сид', '[Party #1]', '[Party #2]', '[Party #3]');

var
MFont: TWFont;
MWin: ^TWin;
MDlg: ^TDlg;
MAsk: ^TAsk;
MWText: String = '<TAB><TAB>http://consolgames.ru/';
MFID: Integer = -1;
MDID: Integer = -1;
MFNM: String;
YS: Integer=0;


implementation

{$R Buttons.res}


Procedure TDrawWindow.DrawWindowConture(Win: TWin);
begin
  If FDXDraw = nil Then
  begin
    CreateError('TDrawWindow.DrawWindowConture: DXDraw not initialized!');
    Exit;
  end;
  With Win do
  begin
    FDXDraw.Surface.Canvas.Pen.Color:=$00FFFFFF;
    //WScreen.Surface.Canvas.Brush.Style:=bsClear;
    FDXDraw.Surface.Canvas.Pen.Style:=psDot;
    FDXDraw.Surface.Canvas.Rectangle(X,Y{!}-YS{!},X+W,Y+H{!}-YS{!});
    FDXDraw.Surface.Canvas.Rectangle(X+2,Y+2{!}-YS{!},X+W-2,Y+H-2{!}-YS{!});
  end;
end;

Procedure TDrawWindow.DrawWindow(Win: TWin);
begin       
  If FDXDraw = nil Then
  begin
    CreateError('TDrawWindow.DrawWindowConture: DXDraw not initialized!');
    Exit;
  end;
  With Win do
  begin
    //WScreen.Surface.Canvas.Brush.Style:=bsSolid;
    FDXDraw.Surface.Canvas.Pen.Style:=psSolid;
    FDXDraw.Surface.Canvas.Pen.Color:=$00FFFFFF;
    FDXDraw.Surface.Canvas.Rectangle({8+}X,{8+}Y{!}-YS{!},X+W,Y+H{!}-YS{!});
    FDXDraw.Surface.Canvas.Brush.Color:=$00FF6060;
    FDXDraw.Surface.Canvas.Rectangle(X+2,Y+2{!}-YS{!},X+W-2,Y+H-2{!}-YS{!});
  end;
end;



Function TDrawWindow.CheckWindow(Win: TWin; XX,YY: Integer): Integer;
begin
  Dec(YY,{!}-YS{!});
  //Result:=0;
  With Win do
  If      (XX>X+2)    And (XX<X+W-2) And (YY>Y+2)    And (YY<Y+H-2) Then
    Result:=1
  else If (XX>=X)     And (XX<X+4)   And (YY>Y+2)    And (YY<Y+H-2) Then
    Result:=2
  else If (XX>=X)     And (XX<X+4)   And (YY>=Y)     And (YY<Y+4)   Then
    Result:=3
  else If (XX>X+2)    And (XX<X+W-2) And (YY>=Y)     And (YY<Y+4)   Then
    Result:=4
  else If (XX>=X+W-2) And (XX<=X+W)  And (YY>=Y)     And (YY<Y+4)   Then
    Result:=5
  else If (XX>=X+W-2) And (XX<=X+W)  And (YY>Y+2)    And (YY<Y+H-2) Then
    Result:=6
  else If (XX>=X+W-2) And (XX<=X+W)  And (YY>=Y+H-2) And (YY<=Y+H)  Then
    Result:=7
  else If (XX>X+2)    And (XX<X+W-2) And (YY>=Y+H-2) And (YY<=Y+H)  Then
    Result:=8
  else If (XX>=X)     And (XX<X+4)   And (YY>=Y+H-2) And (YY<=Y+H)  Then
    Result:=9
  else
    Result:=0;
end;

Function TWFont.FLoaded: Boolean;
begin
  If Assigned(Pic) Then Result:=True else Result:=False;
end;

Procedure TWFont.LoadFont(TimFile, WFile: String);
var n: Byte;
begin
  If not Assigned(RPic) Then
  begin
    RPic:=TDIB.Create;
    RPic.LoadFromResourceName(hInstance, 'RIMAGE');
    RPic.Transparent:=True;
    RPic.TransparentColor:=0;
  end;
  If not Assigned(BPic) Then
  begin
    BPic:=TDIB.Create;
    BPic.LoadFromResourceName(hInstance, 'BUTTONS');
    BPic.Transparent:=True;
    BPic.TransparentColor:=0;
  end;
  LoadFile(TimFile,FTim);
  LoadFile(WFile,FTable);
  If not Assigned(Pic) Then
  begin
    Pic:=TDIB.Create;
    Pic.BitCount:=4;
    If ffMode=ff7 Then Pic.Height:=252 else Pic.Height:=120;
    Pic.Width:=256;
    DWord(Pic.ColorTable[0]):=$606060FF;
    DWord(Pic.ColorTable[1]):=0;
    DWord(Pic.ColorTable[3]):=$FFFFFFFF;
    Pic.Transparent:=True;
    Pic.TransparentColor:=0;
    Pic.UpdatePalette;
    Case ffMode of
      ff7: RawToDib(Pic,Pointer(Integer(FTim)+$220));
      ff8: RawToDib(Pic,Pointer(Integer(FTim)+$120));
    end;
    Move(FTable^,W,256);
    For n:=0 To 255 do
    begin
      O[n]:=(W[n] And $E0) SHR 5;
      W[n]:=W[n] And $1F;
    end;
  end;
end;

Function TWFont.DrawChar(ID: Byte; DXD: TDXDraw; X,Y: Integer): Byte;
var XX,YY,WW: Integer;
begin
  //Inc(X,8); Inc(Y,8);
  If ID=$E8 Then
  begin
    Result:=12;
    DXD.Surface.Canvas.Draw(X,Y,RPic);
    Exit;
  end;
  WW:=W[ID];
  Case ID of
    $E1: WW:=12;
    $E0: WW:=30;
    $E2:
    begin
      ID:=$0C; WW:=W[$0C]+W[$00];
    end;
    $E3:  Result:=DrawChar($0E,DXD,X,Y)+DrawChar($02,DXD,X+W[$0E]+O[$0E],Y);
    $E4:  Result:=DrawChar($A9,DXD,X,Y)+DrawChar($02,DXD,X+W[$A9]+O[$A9],Y);
    $F6..$F9:  DXD.Surface.Canvas.CopyRect(Bounds(X,Y-2,16,16),BPic.Canvas,
    Bounds(16*(ID-$F6),0,16,16));
    $EA..$F5: Result:=DrawLine(WinNames[ID-$EA],DXD,MTable,X,Y);
  end;
  If ID in [$F6..$F9] Then Result:=16;
  If ID in [$E3..$E4, $F6..$F9, $EA..$F5] Then Exit;
  Result:=WW+O[ID];
  If ID>$E0 Then Inc(Result,O[ID]);
  YY:=(ID div 21)*12;
  XX:=(ID-((ID div 21)*21))*12;
  DXD.Surface.Canvas.CopyRect(Bounds(X+O[ID],Y,WW,12),Pic.Canvas,
  Bounds(XX,YY,WW,12));
end;

Procedure TWFont.DrawIDLine(Line: String; DXD: TDXDraw; X,Y: Integer);
var n: Integer;
begin
  For n:=0 To Length(Line) do
  Inc(X,DrawChar(Byte(Line[n]),DXD,X,Y));
  //DrawChar(1,DXD,0,0);
end;

Function TWFont.DrawLine(S: String; DXD: TDXDraw; Table: TTableArray; X,Y: Integer): Integer;
var n,m,l,Ln,LnTbl: Integer; B: Byte;
Label Compl;
begin
  Result:=X;
  l:=1;
  Ln:=Length(S);
  LnTbl:=Length(Table)-1;
  While l<=Ln do
  begin
    If S[l]='{' Then
    begin
      If (Length(S)-l>2) and (S[l+3]='}') then
      begin
        B:=HexToInt(MidStr(S,l+1,2));
        Inc(l,4);
        GoTo Compl;
      end;
    end;
    If S[l]='[' Then
    begin
      If (Length(S)-l>2) and (S[l+4]=']') and (S[l+1]='#') then
      begin
        B:=HexToInt(MidStr(S,l+2,2));
        Inc(l,5);
        GoTo Compl;
      end;
    end;
    For m:=0 To LnTbl do
    begin
      If Table[m].Text[1]=S[l] Then
      begin
        If (Length(Table[m].Text)<=Length(S)-l+1) and
        (MidStr(S,l,Length(Table[m].Text))=Table[m].Text) Then
        begin
          If not Table[m].D Then B:=Table[m].Value else B:=$FF;
          Inc(l, Length(Table[m].Text));
          GoTo Compl;
        end;
      end;
    end;
    B:=$1F; // Неизвестный символ
    Inc(l);
    Compl:
    If B<>$FF Then Inc(X,DrawChar(B,DXD,X,Y));
  end;
  Result:=X-Result;
end;

Procedure TWFont.DrawText(Text: String; DXD: TDXDraw; Table: TTableArray; X,Y,H: Integer);
var n,Up: Integer; List: TStringList; S: String;
begin
  Up:=Y;
  List:=TStringList.Create;
  List.Text:=Text;
  For n:=0 to List.Count-1 do
  begin
    S:=List.Strings[n];
    DrawLine(S,DXD,Table,X,Y);
    If (S<>'') and (H>0) and (S[Length(S)]='~') Then
    begin
      If (Y-UP+8)>=H-8 Then Inc(Up,RoundBy(Y-UP-H+16,16));
      Inc(Up,H);
      Y:=Up;
    end else Inc(Y,16);
  end;
  List.Free;
end;

Procedure TWFont.DrawTextOnWindow(Text: String; DXD: TDXDraw; Table: TTableArray; Win: TWin);
var Rect: TRect; List: TStringList; n,TH: Integer; S: String; HWin: TWin;
begin
  TH:=0;
  HWin:=Win;
  List:=TStringList.Create;
  List.Text:=Text;
  DXD.Surface.Canvas.Brush.Color:=$00666666;
  Rect.Left:=0; Rect.Top:=0; Rect.Right:=640; Rect.Bottom:=480;
  DXD.Surface.Canvas.FillRect(Rect);
  DrawWindow(Win,DXD);
  For n:=0 To List.Count-1 do
  begin
    Inc(TH,16);
    S:=List.Strings[n];
    If (S<>'') and (S[Length(S)]='~') Then
    begin
      If TH>Win.H-8 Then Inc(HWin.Y,RoundBy(TH-Win.H+8,16));
      Inc(HWin.Y, Win.H);
      DrawWindowConture(HWin,DXD);
      TH:=0;
    end;
  end;
  DrawText(Text,DXD,Table,Win.X+8,Win.Y+6 {!}-YS{!},Win.H);
  DXD.Surface.Canvas.Release;
  DXD.Flip;
  List.Free;

end;


end.
