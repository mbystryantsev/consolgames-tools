unit TextView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, XPMan, ComCtrls, ToolWin,
  StrUtils, Menus, ActnList, ImgList, TntStdCtrls, SynEdit, TntClasses,
  TableText, TextUnit, OpenGL, OpenGLUnit, FontUnit, VirtualTrees, ViewUnit,
  DrawFrameUnit;

type
  TMainForm = class(TForm)
    OpenTextDialog: TOpenDialog;
    SaveTextDialog: TSaveDialog;
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
    ImageList1: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    N8: TMenuItem;
    FindDialog: TFindDialog;
    AFind: TAction;
    AFindNext: TAction;
    StatusBar: TStatusBar;
    AGoTo: TAction;
    XPManifest1: TXPManifest;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    N11: TMenuItem;
    N12: TMenuItem;
    AExit: TAction;
    TabControl: TTabControl;
    APinDraw: TAction;
    N13: TMenuItem;
    MainText: TSynEdit;
    SplitterItems: TSplitter;
    ALoadTable: TAction;
    Search1: TMenuItem;
    Find1: TMenuItem;
    FindNext1: TMenuItem;
    GoTo1: TMenuItem;
    LoadTable1: TMenuItem;
    OpenTableDialog: TOpenDialog;
    Splitter2: TSplitter;
    AShowItems: TAction;
    AShowItems1: TMenuItem;
    ListStrings: TVirtualStringTree;
    ListItems: TVirtualStringTree;
    SplitterDraw: TSplitter;
    procedure MainTextChange(Sender: TObject);
    procedure AOpenExecute(Sender: TObject);
    procedure AFindExecute(Sender: TObject);
    procedure AFindNextExecute(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure AGoToExecute(Sender: TObject);
    procedure AExitExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure ALoadTableExecute(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure AShowItemsExecute(Sender: TObject);
    procedure APinDrawExecute(Sender: TObject);
    procedure ListItemsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure ListStringsGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure ListItemsFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure ListStringsFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure FormResize(Sender: TObject);
    procedure ASaveExecute(Sender: TObject);
    procedure SplitterDrawMoved(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    { Private declarations }
  public
    procedure Find(FD: TFindDialog; Sender: TObject);
    procedure DrawMessage();
  end;


  TTextFile = Record
    FileName:   String;
    TableFile:  String;
    Saved:      Boolean;
    GameText:   TGameTextSet;
    ItemIndex:  Integer;
    StrIndex:   Integer;
    SelStart:   Integer;
    SelEnd:     Integer;
    SelLength:  Integer;
  end;
  PTextFile = ^TTextFile;

  TTextFileSet = Class
    FTextFiles: Array of TTextFile;
  private
    function GetCount: Integer;
    function GetTextFile(Index: Integer): PTextFile;
  public
    Destructor Destroy(); override;
    Function Add(AFileName: String): Integer;
    Procedure SaveInfo(Index, ItemIndex, StrIndex, SelStart, SelEnd, SelLength: Integer);

    Property Count: Integer read GetCount;
    Property TextFiles[Index: Integer]: PTextFile Read GetTextFile;
  end;


var
  MainForm:  TMainForm;
  CurTextIndex: Integer = 0;
  CurText:   TGameTextSet = nil;
  CurTextItemIndex: Integer;
  CurItem:   TGameText = nil;
  CurItemStringIndex: Integer;
  CurString: ^TTextMessage = nil;
  Documents: TTextFileSet;
  DrawFrame: TDrawFrame;


implementation

uses ViewForm;

{$R *.dfm}

{$INCLUDE Window.inc}

function WidePosExX(const SubStr, S: WideString; Offset: Cardinal): Integer;
var
  I,X{,C}: Integer;
  Len, LenSubStr: Integer;
begin
  If S = '' Then
  begin
    Result := 0;
    Exit;
  End;
  if Offset = 1 then
    Result := Pos(SubStr, S)
  else
  begin
    I := Offset;
    LenSubStr := Length(SubStr);
    Len := Length(S) - LenSubStr + 1;
    while I <= Len do
    begin
      if (S[I] = SubStr[1]) or (SubStr[1] = '?') then
      begin
        X := 1;
        while (X < LenSubStr) and ((S[I + X] = SubStr[X + 1]) or (SubStr[X + 1] = '?')) do
            Inc(X);
        if (X = LenSubStr) then
        begin
          Result := I;
          exit;
        end;
      end;
      Inc(I);
    end;
    Result := 0;
  end;
end;

procedure TMainForm.MainTextChange(Sender: TObject);
var S: WideString; W, H, Code: Integer;
begin                                   
  If CurString = nil Then Exit;
  CurString.Strr := MainText.Text;
  DrawMessage();
end;

Function GetParamID(S: String; A: Array of String): Integer;
var n: Integer;
begin
  For Result:=Low(A) To High(A) do If UpperCase(S)=A[Result] Then Exit;
  Result:=-1;
end;


procedure TMainForm.AOpenExecute(Sender: TObject);
var n: Integer;
begin
  If not OpenTextDialog.Execute() or not FileExists(OpenTextDialog.FileName) Then Exit;
  n := Documents.Add(OpenTextDialog.FileName);
  If n = -1 Then
  begin
    MessageDlg('Unable to open file!', mtError, [mbOK], 0);
    Exit;
  end;
  If n = TabControl.RowCount Then
    TabControl.Tabs.Add(ExtractFileName(Documents.TextFiles[n]^.FileName));

  //Documents.TextFiles[n].GameText.LoadTable('Mario&Luidgy\data\tables\Table_Ru.tbl'); 
  TabControl.TabIndex := n;
  TabControlChange(Sender);
end;

Procedure TMainForm.Find(FD: TFindDialog; Sender: TObject);
var n,Pos,X,FPos,l, i: Integer; S, ST: WideString; FDown: Boolean;
  Node: PVirtualNode;
Label BRK;
  Function CheckForWord(S: String; Pos,Len: Integer): Boolean;
  begin
    //IsCharAlphaNumericW
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
  If CurItem = nil Then Exit;

  FDown:=frDown in FD.Options;
  Pos:=MainText.SelStart+1;
  If MainText.SelLength>0 Then
  begin
    If FDown Then Inc(Pos);
  end;
  If not FDown Then Dec(Pos);
  If not FDown and (Pos=0) Then Pos:=-1;
  S:=FD.FindText;
  If S='' Then Exit;

  n := ListStrings.FocusedNode.Index;
  If not (frMatchCase in FD.Options) then
    CharUpperBuffW(PWideChar(S), Length(S));
  While (n<=CurText.Items[0].Count-1) and (n>=0) do
  begin
    ST:=CurText.Items[0].Items[n].Strr;
    If not (frMatchCase in FD.Options) then
      CharUpperBuffW(PWideChar(ST), Length(ST));
      //ST:=UpperCase(ST);
    If FDown Then FPos:=PosEx(S,ST,Pos) else FPos:=PosExRev(S,ST,Pos);
    If (FPos>0) Then
    begin
      If (frWholeWord in FD.Options) and (not CheckForWord(ST,FPos,Length(S))) Then
        GoTo BRK;
      //ListStrings.FocusedNode.Index := n;
      Node := ListStrings.RootNode.FirstChild;
      For i := 0 to n - 1 do
        Node := Node.NextSibling;
      ListStrings.FocusedNode := Node;
      ListStrings.Selected[Node] := True;
      //ListStringsFocusChanged(
      X := 0;
      For n := 1 To FPos - 1 do
        If (ST[n] = #10) and ((ST[n - 1] <> #13) or (n = 1)) Then
          Inc(X);
      MainText.SelStart:=FPos - 1 + X;
      MainText.SelLength:=Length(S);
      MainText.SetFocus;
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

procedure TMainForm.AFindExecute(Sender: TObject);
begin
  FindDialog.Execute;
end;

procedure TMainForm.AFindNextExecute(Sender: TObject);
begin
  If FindDialog.FindText='' Then
  begin
    FindDialog.Execute;
    Exit;
  end else
    Find(FindDialog,Sender);
end;

procedure TMainForm.FindDialogFind(Sender: TObject);
begin
  Find(FindDialog,Sender);
end;

var PrevGoTo: String='0';
procedure TMainForm.AGoToExecute(Sender: TObject);
var n: Integer;
begin
  PrevGoTo:=InputBox('Перейти к строке...','Введите номер строки:',PrevGoTo);
  Try
    n:=StrToInt(PrevGoTo);
  except
    ShowMessage('Вы должны ввести числовое значение!');
  end;
  If (n >= 0) and (n < ListStrings.RootNodeCount) Then
  begin
    //ListStrings.Fo
    // := n;
    //ListStringsClick(Sender);
  end;
end;

procedure TMainForm.AExitExecute(Sender: TObject);
begin
  Close;
end;

{ TTextFileSet }

Function TTextFileSet.Add(AFileName: String): Integer;
var i: Integer;
begin
  AFileName := ExpandFileName(AFileName);
  For i := 0 To High(FTextFiles) do
  begin
    If FTextFiles[i].FileName = AFileName Then
    begin
      Result := i;
      Exit;
    end;
  end;
  If not FileExists(AFileName) Then
  begin
    Result := -1;
    Exit;
  end;
  SetLength(FTextFiles, Length(FTextFiles) + 1);
  With FTextFiles[High(FTextFiles)] do
  begin
    FileName := AFileName;
    GameText := TGameTextSet.Create;
    GameText.LoadTextFromFile(AFileName);
    Saved := True;
    SelStart  := 0;
    SelEnd    := 0;
    SelLength := 0;
    ItemIndex := 0;
    StrIndex  := 0;

  end;
  Result := High(FTextFiles);
end;

destructor TTextFileSet.Destroy;
var i: Integer;
begin
  For i := 0 To High(FTextFiles) do
  begin
    FTextFiles[i].GameText.Free;
    Finalize(FTextFiles[i].FileName);
  end;
  Finalize(FTextFiles);
  inherited;
end;

function TTextFileSet.GetCount: Integer;
begin
  Result := Length(FTextFiles);
end;

function TTextFileSet.GetTextFile(Index: Integer): PTextFile;
begin
  Result := @FTextFiles[Index];
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
(*
  Exit;
  FormView.Width  := Self.Width;
  FormView.Height := 480;
  FormView.Visible := True;
  FormView.Top := Self.Top + Self.Height;
  FormView.Left := Self.Left;
  FormView.Show;
*)
end;

procedure TMainForm.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  //Exit;
  (*
  If APinDraw.Checked Then
  begin
    FormView.Top := Self.Top + Self.Height;
    FormView.Left := Self.Left;
    FormView.Width := NewWidth;
    If Self.WindowState = wsMaximized Then
      MessageDlg('!!!', mtWarning, [mbOK], 0);
  end;
  *)
  //NewHeight := NewHeight div 2;
end;

procedure TMainForm.ALoadTableExecute(Sender: TObject);
begin
  If (CurText = nil) or Not OpenTableDialog.Execute Then
    Exit;
  CurText.LoadTable(OpenTableDialog.FileName);
  Documents.GetTextFile(TabControl.TabIndex)^.TableFile := ExpandFileName(OpenTableDialog.FileName);
  DrawMessage();
end;

procedure TMainForm.TabControlChange(Sender: TObject);
begin
  //Documents.SaveInfo(CurTextIndex, CurTextItemIndex, CurItemStringIndex, MainText.SelStart, MainText.SelEnd, MainText.SelLength);
  CurTextIndex := TabControl.TabIndex;
  CurText := Documents.GetTextFile(TabControl.TabIndex)^.GameText;
  ListItems.RootNodeCount := CurText.Count;
  ListItems.Refresh;
  AShowItemsExecute(Sender);
  ListItems.FocusedNode := ListItems.RootNode.FirstChild;
  ListItems.Selected[ListItems.RootNode.FirstChild] := True;
  ListItemsFocusChanged(ListItems, ListItems.RootNode.FirstChild, -1);

end;

procedure TMainForm.AShowItemsExecute(Sender: TObject);
begin
//  AShowItems.Checked := not AShowItems.Checked;
  SplitterItems.Visible := AShowItems.Checked and (CurText <> nil) and (CurText.Count > 1);
  ListItems.Visible := SplitterItems.Visible;
end;

procedure TMainForm.APinDrawExecute(Sender: TObject);
begin
//
end;

procedure TMainForm.ListItemsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
//  Case Column of
//    0:  CellText := IntToStr(Node.Index);
//    1:
  CellText := CurText.Items[Node.Index].Name;
//  end;
end;

procedure TMainForm.ListStringsGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
  If CurText = nil Then Exit;
  CellText := CurText.Items[CurTextItemIndex].Strings[Node.Index];
end;

procedure TMainForm.ListItemsFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  CurTextItemIndex := Node.Index;
  CurItem := CurText.Items[CurTextItemIndex];                 
  ListStrings.FocusedNode := nil;
  ListStrings.Selected[ListStrings.RootNode.FirstChild] := True;
  ListStrings.RootNodeCount := CurItem.Count;
  ListStrings.FocusedNode := ListStrings.RootNode.FirstChild;
  //ListStringsFocusChanged(ListStrings, ListStrings.RootNode.FirstChild, 0);
end;

procedure TMainForm.ListStringsFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  If Node = nil Then Exit;
  Viewer.SceneX := 0;
  Viewer.SceneY := 0;
  CurItemStringIndex := Node.Index;
  CurString := @CurItem.Items[CurItemStringIndex];
  //CurString := CurItem.
  StatusBar.Panels[1].Text := Format('String: %d/%d',[ListStrings.FocusedNode.Index, CurText.Items[CurTextItemIndex].Count]);
  MainText.Text := CurText.Items[CurTextItemIndex].Items[ListStrings.FocusedNode.Index].Strr;
  DrawMessage();
  //MainTextChange(Sender);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  If not AllowResize Then Exit;
  FormView.SetBounds(0, 0, MainForm.ClientWidth - 4, StatusBar.Top - SplitterDraw.BoundsRect.Bottom - 4)
  //FormView.Width  := ;
  //FormView.Height := ; //MainForm.ClientHeight;
end;

procedure TTextFileSet.SaveInfo(Index, ItemIndex, StrIndex, SelStart,
  SelEnd, SelLength: Integer);
begin
  FTextFiles[Index].ItemIndex := ItemIndex;
  FTextFiles[Index].StrIndex  := StrIndex;
  FTextFiles[Index].SelLength := SelLength;
  FTextFiles[Index].SelStart  := SelStart;
  FTextFiles[Index].SelEnd    := SelEnd;
end;

procedure TMainForm.DrawMessage;
var f: real;
begin
  If (CurText = nil) or (CurString = nil) Then Exit;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  If CurText.TableCount > 0 Then
  begin
    Viewer.Table      := CurText;
    Viewer.MarioFont  := MarioFont;
    f := FormView.ClientHeight;
    Viewer.Height     := Trunc(f / Viewer.Scale);
    Viewer.DrawString(CurString.Strr);
  end else
    MarioFont.DrawString('Table is not loaded.', 16, 16);
  SwapBuffers(DC);
end;

procedure TMainForm.ASaveExecute(Sender: TObject);
begin
  If TabControl.TabIndex < 0 Then Exit;
  With Documents.FTextFiles[TabControl.TabIndex] do
  begin
    GameText.SaveTextToFile(FileName);
    Saved := True;
  end;
end;

procedure TMainForm.SplitterDrawMoved(Sender: TObject);
begin
  FormResize(Sender);
end;

procedure TMainForm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin                        
  If not ViewFocus Then Exit;
  Viewer.Scale := Viewer.Scale - 0.1;
  If Viewer.Scale < 0.5 Then Viewer.Scale := 0.5;
  MainForm.DrawMessage();
  Handled := True;
end;

procedure TMainForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  If not ViewFocus Then Exit;
  Viewer.Scale := Viewer.Scale + 0.1;
  If Viewer.Scale > 4.0 Then Viewer.Scale := 4.0;
  MainForm.DrawMessage();
  Handled := True;
end;

procedure TMainForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  ViewFocus := False
end;

Initialization
  Documents := TTextFileSet.Create;
  Viewer := TTextViewer.Create;
Finalization
  Documents.Free;
  Viewer.Free;
end.
