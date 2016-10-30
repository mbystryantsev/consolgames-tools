unit FF7_TextEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Menus, FF7_Field, FF7_Common, FF7_Compression,
  FF7_Text, FF7_Window, GZipMen, BldDat, BagReport, ConvImg, ToCEditor,
  ToolWin, ActnList, XPMan, WinEditor, StrUtils, ImgList, ExtCtrls, About,
  PFolderDialog, FFT, FF8;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    FList: TListBox;
    FileList: TListBox;
    MsgList: TListBox;
    Status: TStatusBar;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    edText: TMemo;
    orText: TMemo;
    GroupBox2: TGroupBox;
    Log: TMemo;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ActionList1: TActionList;
    ODialog: TOpenDialog;
    AOpenProject: TAction;
    XPManifest1: TXPManifest;
    ImageList1: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    edSFile: TEdit;
    ToolButton6: TToolButton;
    AGoToU: TAction;
    ASave: TAction;
    ABuildFile: TAction;
    ABuildFiles: TAction;
    ToolButton7: TToolButton;
    WList: TListBox;
    ToolButton8: TToolButton;
    AKSet: TAction;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    DAT1: TMenuItem;
    DAT2: TMenuItem;
    ToolButton9: TToolButton;
    FindDialog: TFindDialog;
    ToolButton10: TToolButton;
    AFind: TAction;
    AFindNext: TAction;
    N9: TMenuItem;
    N10: TMenuItem;
    AFindNext1: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    AWinEditor: TAction;
    N13: TMenuItem;
    AAbout: TAction;
    chAlpha: TCheckBox;
    AAlphaSet: TAction;
    TrackBar1: TTrackBar;
    ABC: TPanel;
    Panel1: TPanel;
    ABC2: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    CheckBox1: TCheckBox;
    ALog: TAction;
    CheckBox2: TCheckBox;
    AOnTop: TAction;
    AFindScriptMes: TAction;
    ToolButton11: TToolButton;
    N14: TMenuItem;
    N15: TMenuItem;
    LZ1: TMenuItem;
    LZ2: TMenuItem;
    BIN1: TMenuItem;
    ADecompressLZ: TAction;
    ACompressLZ: TAction;
    ABinArc: TAction;
    LZUOpenDialog: TOpenDialog;
    LZUSaveDialog: TSaveDialog;
    oC1: TMenuItem;
    N16: TMenuItem;
    KERNELBIN1: TMenuItem;
    KERNELBIN2: TMenuItem;
    AExtractKernelText: TAction;
    AExtractText: TAction;
    APasteKernelText: TAction;
    ATOCEditor: TAction;
    FDialog: TPFolderDialog;
    ALoadTable: TAction;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    AShowTable: TAction;
    chChangedOnly: TCheckBox;
    AShowStat: TAction;
    ToolButton12: TToolButton;
    N20: TMenuItem;
    N21: TMenuItem;
    AImgConv: TAction;
    AImgConv1: TMenuItem;
    N22: TMenuItem;
    LevelBar: TTrackBar;
    Image1: TImage;
    Image2: TImage;
    chLZNull: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    N23: TMenuItem;
    FF8DAT1: TMenuItem;
    FF81: TMenuItem;
    AFF8ExtractText: TAction;
    AFF8ExtractField: TAction;
    N24: TMenuItem;
    ToolButton13: TToolButton;
    Label1: TLabel;
    chToc: TCheckBox;
    AFF8ToC: TAction;
    Button4: TButton;
    ANewProject: TAction;
    N25: TMenuItem;
    procedure edTextExit(Sender: TObject);
    procedure AOpenProjectExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBar1Change(Sender: TObject);
    procedure edTextChange(Sender: TObject);
    procedure FileListClick(Sender: TObject);
    procedure MsgListClick(Sender: TObject);
    procedure FListClick(Sender: TObject);
    procedure edSFileChange(Sender: TObject);
    procedure AGoToUExecute(Sender: TObject);
    procedure ASaveExecute(Sender: TObject);
    procedure AKSetExecute(Sender: TObject);
    procedure ABuildFileExecute(Sender: TObject);
    procedure AFindExecute(Sender: TObject);
    Procedure Find(FD: TFindDialog; Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure AFindNextExecute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure AWinEditorExecute(Sender: TObject);
    procedure AAboutExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AAlphaSetExecute(Sender: TObject);
    procedure ALogExecute(Sender: TObject);
    procedure AOnTopExecute(Sender: TObject);
    procedure AFindScriptMesExecute(Sender: TObject);
    procedure ADecompressLZExecute(Sender: TObject);
    procedure ABinArcExecute(Sender: TObject);
    procedure ACompressLZExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ABuildFilesExecute(Sender: TObject);
    procedure AExtractKernelTextExecute(Sender: TObject);
    procedure AExtractTextExecute(Sender: TObject);
    procedure ALoadTableExecute(Sender: TObject);
    procedure AShowTableExecute(Sender: TObject);
    procedure AShowStatExecute(Sender: TObject);
    procedure AImgConvExecute(Sender: TObject);
    procedure ATOCEditorExecute(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure LevelBarChange(Sender: TObject);
    procedure chLZNullClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AFF8ExtractTextExecute(Sender: TObject);
    procedure AFF8ExtractFieldExecute(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ANewProjectExecute(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure LoadProject(FileName: String);
    Procedure Initilize(Sender: TObject);
    Procedure ApFinalize;
    { Public declarations }
  end;






var
  Form1: TForm1;
  FirstRes: Boolean = True;
  chFF8CD: Array[1..4] of TCheckBox;

implementation

uses NewProject;

{$R *.dfm}

var TestWin: TWin;
  CtrlPressed, AltPressed: Boolean;

Procedure TForm1.Initilize(Sender: TObject);
var Bts: DWord;
begin
  Settings.DatBuilding:=False;
  Settings.Opened:=False;
  ALogExecute(Sender);
  GetMem(BBuf,$100000);
  GetMem(DBuf,$800000);
  GetMem(TBuf,$100000);
  MWin:=Addr(TestWin);
  MWin^.W:=64;
  MWin^.H:=16;
  MWin^.X:=0;
  MWin^.Y:=0;
  Bts:=$2F504840;
  MFont:=TWFont.Create;
  SetLength(MFieldBytes,4);
  Move(Bts,MFieldBytes[0],4);//:=($40, $48, $50)
  //ShowMessage(IntToStr(Bts));
  //
end;

Procedure TForm1.ApFinalize;
begin
  MFont.Free;
  FreeMem(BBuf);
  FreeMem(TBuf);
  FreeMem(DBuf);
end;

Procedure TForm1.LoadProject(FileName: String);
var List: TStringList; n: Integer; S,S2: String;
begin
  List:=TStringList.Create;
  List.LoadFromFile(FileName);
  For n:=0 To List.Count-1 do
  begin
    S:=GetPart2(List.Strings[n],'=',1);
    S2:=GetPart2(List.Strings[n],'=',2);
    If S=SettingNames.Path.FieldIn
    Then Settings.Path.FieldIn:=S2
    else If S=SettingNames.Path.Text
    Then Settings.Path.Text:=S2
    else If S=SettingNames.Path.OrText
    Then Settings.Path.OrText:=S2
    else If S=SettingNames.Path.Opt
    Then Settings.Path.Opt:=S2
    else If S=SettingNames.Path.Table
    Then Settings.Path.Table:=S2
    else If S=SettingNames.Path.Scripts
    Then Settings.Path.Scripts:=S2
    else If S=SettingNames.Path.FieldOut
    Then Settings.Path.FieldOut:=S2
    else If S=SettingNames.Path.FontTim
    Then Settings.Path.FontTim:=S2
    else If S=SettingNames.Path.FontDat
    Then Settings.Path.FontDat:=S2
    else If S=SettingNames.Path.Project
    Then Settings.Path.Project:=S2
    else If S=SettingNames.Alpha
    Then Settings.Alpha:=StrToInt(S2)
    else If S=SettingNames.HideRetry
    Then Settings.HideRetry:=Boolean(StrToInt(S2))
    else If GetUpCase(S)='FFMODE'
    Then ffMode:=StrToInt(S2);
  end;
end;

Function CheckProject(S: TSettings): Boolean;
begin
  Result:=True;
  If not DirectoryExists(S.Path.FieldIn) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[FieldIn]  Папка "%s" не существует!',[S.Path.FieldIn]));
  end;
  If not DirectoryExists(S.Path.FieldOut) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[FieldOut] Папка "%s" не существует!',[S.Path.FieldOut]));
  end;
  If not FileExists(S.Path.Table) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[FontTable]Файл "%s" не существует!',[S.Path.FontTim]));
  end;
  If not FileExists(S.Path.FontTim) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[FontTim]  Файл "%s" не существует!',[S.Path.FontTim]));
  end;
  If not FileExists(S.Path.FontDat) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[FontDat]  Файл "%s" не существует!',[S.Path.FontDat]));
  end;
  If not FileExists(S.Path.Text) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[Text]     Файл "%s" не существует!',[S.Path.Text]));
  end;
  If not FileExists(S.Path.Opt) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[Opt]      Файл "%s" не существует!',[S.Path.Opt]));
  end;

  If ffMode<>7 Then Exit;

  If not FileExists(S.Path.Scripts) Then
  begin
    Result:=False; Form1.Log.Lines.Add(Format('[Scripts]  Файл "%s" не существует!',[S.Path.Scripts]));
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var I: Integer;
begin
  Initilize(Sender);
  For I := 1 to 4 do
  begin
    chFF8CD[I]:=TCheckBox.Create(Form1.GroupBox2);
    With chFF8CD[I] do
    begin
      Parent:=Form1.GroupBox2;
      Left := 8+24+I*16;
      Top := {CBTop + }32;
      Hint:=Format('Вставлять текст в диск №%d',[I]);
      ShowHint:=True;
      Width:=16;
      If I=1 Then Checked:=True;
    end;
  end;
end;




procedure TForm1.edTextExit(Sender: TObject);
begin
//  ShowMessage('!');
end;

procedure TForm1.AOpenProjectExecute(Sender: TObject);
var n,m: Integer; TempWin: TWin;
begin
  Settings.ViewOrText:=False;
  chChangedOnly.Enabled:=False;
  ODialog.Filter:='Проект cg_project (*.cg_project)|*.cg_project|Все файлы|*';
  If not (ODialog.Execute and FileExists(ODialog.FileName)) Then
  begin
    Log.Lines.Add(Format('[project]  Ошибка загрузки проекта. Файл "%s" не найден!',[ODialog.FileName]));
    Exit;
  end;
  LoadProject(ODialog.FileName);
  Log.Lines.Add(Format('Загружен проект "%s". Проверяем...',[ODialog.FileName]));
  If CheckProject(Settings) Then Log.Lines.Add('Проект успешно загружен. Грузим файлы...')
  else
  begin
    Log.Lines.Add('Сбой загрузки. Проект содержит ошибки!');
    Exit;
  end;
  Try
    SetLength(MText,0);//!
    OpenOpt(Settings.Path.Opt,MText);
    OpenText(Settings.Path.Text,MText);
    If ffMode=7 Then Settings.FieldSize:=LoadField(Settings.Path.Scripts,FBuf, MLField);
    If FileExists(Settings.Path.OrText) Then
    begin
      OpenOpt(Settings.Path.Opt,OText);
      OpenText(Settings.Path.OrText,OText);
      Log.Lines.Add('Найден и загружен оригинальный текст (индексты оптимизации ДОЛЖНЫ СОВПАДАТЬ С РЕДАКТИРУЕМЫМ!)');
      Settings.ViewOrText:=True;
    end;
    Log.Lines.Add('Текст успешно загружен. Вроде бы... Погружаем фонт...');
  except
    SetLength(MText,0);
    If Assigned(FBuf) Then FreeMem(FBuf);
    Log.Lines.Add('Фак! Загрузка текста сбойнула!');
    Exit;
  end;
  Try
    If ffMode=7 Then MFont.LoadFont(Settings.Path.FontTim,Settings.Path.FontDat);
    Log.Lines.Add('Фонты в кузове. Но что-то обязательно должно глюкануть... Погрузаем тейбл.');
  except
    Log.Lines.Add('Йа баг! Не дам грузануть шрифт! Еррор, в общем.');
    Exit;
  end;
  Try
    Finalize(MTable); //!
    LoadTable(Settings.Path.Table,MTable);
    Log.Lines.Add('Тейбл запогрузан. Заливаю текст в листы...');
  except
    Log.Lines.Add('Йа баг! Тейбл сегодня не в духе! Еррор, в общем.');
    SetLength(MTable,0);
    Exit;
  end;
  If Length(MTable)<=0 Then
  begin
    Log.Lines.Add('Таблица загрузилась, но пустая...');
    AShowTable.Enabled:=False;
    Exit;
  end else AShowTable.Enabled:=True;
  Try
    FileList.Clear;
    For n:=0 To High(MText) do FileList.Items.Add(MText[n].Name);
    FileList.ItemIndex:=0;
    Log.Lines.Add('Листы полны. Полнее некуда.');
  except
    Log.Lines.Add('ЫЫЫ! Не везёт тебе сёдня, всё на последнем этапе загнулось...');
    Exit;
  end;
  If ffMode=7 Then
  begin
    Try
      SetLength(MField,Length(MText));
      MLField:=AssignField(FBuf);
      For n:=0 To High(MField) do
      begin
        m:=FindField(MLField,MText[n].Name);
        FieldDecompile(MLField[m].Pos,MLField[m].Size,MField[n],TByteArray(MFieldBytes));
      end;
      Log.Lines.Add('Скрипты декомпилированы. Всё готово и успешно фунциклирует 8-)');
    except
      Log.Lines.Add('Ошибка декомпиляции/выборки скриптов((');
      Exit;
    end;
  end;
  If Settings.ViewOrText Then chChangedOnly.Enabled:=True;
  ASave.Enabled:=True;
  ABuildFile.Enabled:=True;
  //ABuildFiles.Enabled:=True;
  AKSet.Enabled:=True;
  AGoToU.Enabled:=True;
  ABuildFiles.Enabled:=True;
  edText.Enabled:=True;
  AFind.Enabled:=True;
  AShowStat.Enabled:=True;
  AFindNext.Enabled:=True;
If ffMode=7 Then  AFindScriptMes.Enabled:=True;
  AExtractKernelText.Enabled:=True;
  //Application.ProcessMessages;
  FileListClick(Sender);
If ffMode=7 Then
begin
  TestWin.X:=90;
  TestWin.Y:=128;
  TestWin.W:=200;
  TestWin.H:=24;
  MWin:=Addr(TestWin);
  MFont.DrawTextOnWindow('<TAB><TAB>http://consolgames.ru/',WForm.WScreen,MTable,MWin^);
end;
  FirstRes := False;
  WForm.YBar.Left:=WForm.weX.Left;
  WForm.YBar.Visible:=True;
  Settings.Opened:=True;
  WForm.weX.Enabled:=True;
  WForm.weY.Enabled:=True;
  WForm.weW.Enabled:=True;
  WForm.weH.Enabled:=True;

  If ffMode<>7 Then
  begin
    edSFile.CharCase:=ecLowerCase;
    WForm.Enabled:=False;
    WForm.Hide;
    AWinEditorExecute(Sender);
    AWinEditor.Enabled:=False;
    WForm.AOnTopSet.Enabled:=False;
  end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ApFinalize;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Form1.AlphaBlendValue:=TrackBar1.Position*4-1;
end;

Function GetOID(Num,ID: Integer; Win: Boolean): Integer;
var n: Integer;
begin
  Result:=0;
  For n:=0 To High(MField[Num]) do
  begin
    Case Byte(Win) of
      0: If (MField[Num,n].Code=$40) or (MField[Num,n].Code=$48) Then Dec(ID);
      1: If (MField[Num,n].Code in [$50,$2F]) Then Dec(ID);
    end;
    If ID<0 Then Exit;
    Inc(Result);
  end;
  Result:=-1;
end;

Function GetLID(Num,ID: Integer; Win: Boolean): Integer;
var n: Integer;
begin
  Result:=-1;
  If ID<0 Then Exit;
  For n:=0 To ID do
  begin
    Case Byte(Win) of
      0: If (MField[Num,n].Code=$40) or (MField[Num,n].Code=$48) Then Inc(Result);
      1: If (MField[Num,n].Code in [$50,$2F]) Then Inc(Result);
    end;
  end;
end;

var ned: Boolean = False;
procedure TForm1.edTextChange(Sender: TObject);
var Win: TWin; n,m,l: Integer;
Label FExit;
begin
  If ned=True Then GoTo FExit;
  ned:=True;
  n:=FileList.ItemIndex;
  m:=MsgList.ItemIndex;

  If (ffMode=7) and (MWin^.N=m) Then MFont.DrawTextOnWindow(edText.Text,WForm.WScreen, MTable, MWin^);


  {Win.X:=16;
  Win.Y:=16;
  Win.W:=200;
  Win.H:=100;}
  {Try
    //DrawWindow(Win,WForm.WScreen);
    //MFont.DrawText(edText.Text,WForm.WScreen,MTable,Win.X+8,Win.Y+8);
    //WForm.WScreen.Surface.Canvas.Release;
    //WForm.WScreen.Flip;
  except
    Log.Lines.Add('Ошибка при прорисовке текста :(');
  end;}
  Try
    If MText[n].S[m].Retry Then
    begin
      l:=FindMessage(MText[n].S[m].RName,MText);
      MText[l].S[MText[n].S[m].RID].Text:=edText.Text;  
    end else
      MText[n].S[m].Text:=edText.Text;
  except
    Beep;
  end;
If ffMode=7 Then GoTo FExit;

  //If (MFID=FileList.ItemIndex) and (MDID=MsgList.ItemIndex) Then
  n:=FileList.ItemIndex; m:=MsgList.ItemIndex;
  If (MText[n].S[m].Retry and (MText[n].S[m].RName=MFNM) and (MText[n].S[m].RID=MDID))
  or ((MText[n].Name=MFNM) and (m=MDID)) Then
  begin
    MWText:=edText.Text;
    MFont.DrawTextOnWindow(MWText,WForm.WScreen,MTable,MWin^);
  end;
  FExit:
  ned:=False;
end;

procedure TForm1.FileListClick(Sender: TObject);
var n,m: Integer; Dlg: ^TDlg; Ask: ^TAsk; Win: ^TWin; A: ^TAskMsg; C: Char;
begin
  MsgList.Clear;
  For n:=0 To High(MText[FileList.ItemIndex].S) do
  begin
    If MText[FileList.ItemIndex].S[n].Retry Then
    begin
      m:=FindMessage(MText[FileList.ItemIndex].S[n].RName,MText);
      If m<0 Then
      begin
        Log.Lines.Add('Сбой при работе со списком сообщений =(');
        Exit;
      end;
      MsgList.Items.Add(Format('--[%.2x] %s',[n,
      LeftStr(MText[m].S[MText[FileList.ItemIndex].S[n].RID].Text,32)]));
    end else
      MsgList.Items.Add(Format('++[%.2x] %s',[n,
      LeftStr(MText[FileList.ItemIndex].S[n].Text,32)]));
  end;

If ffMode=7 Then
begin

  m:=FileList.ItemIndex;
  //n:=Length(MField);
  FList.Clear;
  WList.Clear;
  //FileList.ItemIndex:=n;
  For n:=0 To Length(MField[FileList.ItemIndex])-1 do
  begin
    If MField[m,n].Code=$40 then
    begin
      Dlg:=Addr(MField[m,n].Pos^);
      FList.Items.Add(Format('M %d:%d',[Dlg^.N, Dlg^.D]));
    end else
    If MField[m,n].Code=$48 then
    begin
      Ask:=Addr(MField[m,n].Pos^);
      FList.Items.Add(Format('A %d:%d',[Ask^.Win, Ask^.Mess]));
    end else
    If MField[m,n].Code in [$50,$2F] then
    begin
      Win:=Addr(MField[m,n].Pos^);
      If Win^.ID=$50 Then C:='W' else C:='R';
      WList.Items.Add(Format('%s %d %d:%d',[C,Win^.N, Win^.X, Win^.Y]));
    end;
    //FList.Items.Add(Format('%s',[{IntToHex(MField[m,n].Code,2)}FieldON[MField[m,n].Code]]));
  end;

end;

  Status.Panels.Items[0].Text:=Format('%s [%d/%d]',[MText[FileList.ItemIndex].Name,
  FileList.ItemIndex+1,FileList.Items.Count]);
  MsgList.ItemIndex:=0;
  MsgListClick(Sender);
end;

Procedure ShowText(const Text: TText; const Name: String; const ID: Integer; Memo: TMemo);
var n,m: Integer;
begin
  n:=FindMessage(Name,Text);
  If n<0 Then Memo.Text:=Format('__!!!Файл "%s" не найден!!!__',[Name]) else
  begin
    If (ID<0) or (ID>High(Text)) Then Memo.Text:=Format('__!!!Индекс ("%s",%d) вне границ!!!__',[Name,ID]) else
    begin
      If Text[n].S[ID].Retry Then
      begin
        m:=FindMessage(Text[n].S[ID].RName,Text);
        If (m<0) or (Text[n].S[ID].RID>High(Text)) or (Text[n].S[ID].RID<0) then
        begin
          Memo.Text:=Format('__!!!Файл "%s" не найден или ID %d вне границ (оптимизация)!!!__',
          [Name,Text[n].S[ID].RID]);
          Exit;
        end;
        Memo.Text:=Text[m].S[Text[n].S[ID].RID].Text;
      end else
        Memo.Text:=Text[n].S[ID].Text;
    end;
  end;
end;

procedure TForm1.MsgListClick(Sender: TObject);
var m: Integer;
begin
  If  MText[FileList.ItemIndex].S[MsgList.ItemIndex].Retry
  Then AGoToU.Enabled:=True else AGoToU.Enabled:=False;
  Status.Panels.Items[1].Text:=Format('%d/%d',[MsgList.ItemIndex+1,MsgList.Items.Count]);
  If MText[FileList.ItemIndex].S[MsgList.ItemIndex].Retry Then
  begin
    Status.Panels.Items[2].Text:='Retry';
    m:=FindMessage(MText[FileList.ItemIndex].S[MsgList.ItemIndex].RName,MText);
    edText.Text:=MText[m].S[MText[FileList.ItemIndex].S[MsgList.ItemIndex].RID].Text;
  end else
  begin
    Status.Panels.Items[2].Text:='Unique';
    edText.Text:=MText[FileList.ItemIndex].S[MsgList.ItemIndex].Text;
  end;
  If Settings.ViewOrText Then ShowText(OText,MText[FileList.ItemIndex].Name,MsgList.ItemIndex,orText);
If ffMode<>7 Then Exit;
  If CtrlPressed Then
  begin
    MWText:=edText.Text;
    MFont.DrawTextOnWindow(MWText,WForm.WScreen,MTable,MWin^);
  end;
end;

procedure TForm1.FListClick(Sender: TObject);
var ID, MID, LID: Integer; Ask: ^TAsk; Msg: ^TOMessage; n,m: Integer; TempWin: ^TWin;
S,Pos: String;
Label BRK;
begin
  Status.Panels.Items[3].Text:=Format('Script: %d/%d',
  [FList.ItemIndex+1,FList.Items.Count]);
  ID:=GetOID(FileList.ItemIndex,FList.ItemIndex, False);
  //If MField[FileList.ItemIndex,ID].Code=$40 Then
  //begin
    Msg:=Addr(MField[FileList.ItemIndex,ID].Pos^);
    Ask:=Addr(Msg^);
    Pos:=IntToHex(Integer(Msg)-Integer(MLField[FileList.ItemIndex].Pos),8);
    If Msg^.ID=$40 Then Status.Panels.Items[4].Text:=Format('MSG: N=%d; D=%d; Pos: %s',[Msg^.N,Msg^.D,Pos])
    else Status.Panels.Items[4].Text:=Format('ASK: N=%d; D=%d; Pos: %s',[Ask^.Win,Ask^.Mess,Pos]);
    If ((Msg^.ID=$40) and (Msg^.D<MsgList.Items.Count))
    or ((Ask^.ID=$48) and (Ask^.Mess<MsgList.Items.Count)) Then
    begin
      For n:=ID-1 downto 0 do
      //For n:=0 To High(MField[FileList.ItemIndex]) do
      begin
        If MField[FileList.ItemIndex,n].Code in [$50,$2F] then
        begin
          TempWin:=Addr(MField[FileList.ItemIndex,n].Pos^);
          If ((Msg^.ID=$40) and (TempWin.N=Msg^.N))
          or ((Ask^.ID=$48) and (TempWin.N=Ask^.Win)) Then
          begin
            MWin:=Addr(TempWin^);
            LID:=GetLID(FileList.ItemIndex,n,True);
            WList.ItemIndex:=LID;
            GoTo BRK;
          end;
        end;
      end;
      WList.ItemIndex:=-1;
      MWin:=Addr(TestWin);
      BRK:
      //MID:=GetOID(FileList.ItemIndex,TempWin^.N,True);
      If Msg^.ID=$40 Then MsgList.ItemIndex:=Msg^.D else MsgList.ItemIndex:=Ask^.Mess;
      MsgListClick(Sender);
      If n<Length(MField[FileList.ItemIndex]) Then
      begin
          MFont.DrawTextOnWindow(edText.Text,
          WForm.WScreen, MTable, MWin^);
          weCoord:=True;
          WForm.weX.Text:=IntToStr(MWin^.X);
          WForm.weY.Text:=IntToStr(MWin^.Y);
          WForm.weW.Text:=IntToStr(MWin^.W);
          WForm.weH.Text:=IntToStr(MWin^.H);
          weCoord:=False;
      end;
    end;

    If MText[FileList.ItemIndex].S[MsgList.ItemIndex].Retry then
    begin
      n:=FindMessage(MText[FileList.ItemIndex].S[MsgList.ItemIndex].RName,MText);
      MWText:=MText[n].S[MText[FileList.ItemIndex].S[MsgList.ItemIndex].RID].Text;
    end else
    begin
      MWText:=MText[FileList.ItemIndex].S[MsgList.ItemIndex].Text;
    end;
    n:=FileList.ItemIndex; m:=MsgList.ItemIndex;
    MFID:=n;
    //MDID:=m;
    If MText[n].S[m].Retry Then
    begin
      MFNM:=MText[n].S[m].RName;
      MDID:=MText[n].S[m].RID;
    end else
    begin
      MFNM:=MText[n].Name;
      MDID:=m;
    end;
    If MWin^.ID=$50 Then S:='Win' else S:='Res';
    WForm.Status.Panels.Items[1].Text:=Format('[%d] %s, %d; %s: №%d, ID=%d',
    [FileList.ItemIndex, MText[FileList.ItemIndex].Name,MsgList.ItemIndex,S,WList.ItemIndex+1,MWin^.N]);
  //end;
  { else
  If MField[FileList.ItemIndex,FList.ItemIndex].Code=$50 Then
  begin
    ID:=GetOID(FileList.ItemIndex, WList.ItemIndex, True);
    TempWin:=Addr(MField[FileList.ItemIndex,ID].Pos^);
    With TempWin^ do
    Status.Panels.Items[4].Text:=Format('MSG: N=%d; X=%d; Y=%d; W=%d; H=%d;',[N,X,Y,W,H]);
  end; }
end;

procedure TForm1.AFindExecute(Sender: TObject);
begin
  FindDialog.Execute;
end;

procedure TForm1.edSFileChange(Sender: TObject);
var n: Integer;
begin
  If Length(edSFile.Text)<=0 Then Exit;
  For n:=0 To FileList.Items.Count-1 do
  begin
    If (Length(edSFile.Text)<=Length(FileList.Items.Strings[n]))
    and (LeftStr(edSFile.Text,Length(edSFile.Text))
    =LeftStr(FileList.Items.Strings[n],Length(edSFile.Text))) Then
    begin
      FileList.ItemIndex:=n;
      FileListClick(Sender);
      Exit;
    end;
  end;
end;

procedure TForm1.AGoToUExecute(Sender: TObject);
var n,m,l: Integer;
begin
  n:=FileList.ItemIndex;
  m:=MsgList.ItemIndex;
  If ((n<0) or (m<0)) or ((n>High(MText)) or (m>High(MText[n].S))) Then Exit;
  If MText[n].S[m].Retry then
  begin
    l:=FindMessage(MText[n].S[m].RName,MText);
    FileList.ItemIndex:=l;
    FileListClick(Sender);
    MsgList.ItemIndex:=MText[n].S[m].RID;
    MsgListClick(Sender);
  end;
end;

procedure TForm1.ASaveExecute(Sender: TObject);
begin
  Try
    SaveText(Settings.Path.Text,MText);
    SaveOpt(Settings.Path.Opt,MText);
    If ffMode=7 Then SaveFile(Settings.Path.Scripts,FBuf,Settings.FieldSize);
    Log.Lines.Add('Файлы проекта сохранены.');
  except
    Log.Lines.Add('Злостная ошибка... Надо было делать бэкапы. Хотя, может всё цело...');
  end;
end;

procedure TForm1.AKSetExecute(Sender: TObject);
var n: Integer; Flag: Boolean; S: String;
begin
  S:=edText.Text;
  Flag:=False;
  For n:=1 To Length(S) do
  begin
    If S[n]='"' Then
    begin
      If Flag Then begin S[n]:='”'; Flag:=False; end else
      begin Flag:=True; S[n]:='“'; end;
    end;
  end;
  edText.Text:=S;
end;

procedure TForm1.ABuildFileExecute(Sender: TObject);
var L: TFF8LBA; var Buf,WBuf: Pointer; n,m,Size,LSize,Count: Integer; Name: String;
F: File; FH: ^TLBASet; Dat: TFF8Dat; LToc: Boolean; B: Array[1..4] of Boolean;
begin
  Case ffMode of
    7: BDat(MText,FileList.ItemIndex);
    8:
    begin
      FillChar(B,4,0);
      LToc:=chToc.Checked;
      Name:=Format('%s\%s',[Settings.Path.FieldIn,MText[FileList.ItemIndex].Name]);
      If not FileExists(Name) Then
      begin
        ShowMessage(Format('Входной файл "%s" не найден!',[MText[FileList.ItemIndex].Name]));
        Exit;
      end;
      Dat:=TFF8Dat.Create;
      Dat.LoadFromFile(Name);
      Dat.ReplaceText(MText,FileList.ItemIndex,MTable);
    //Dat.SaveToFile('FF8\!.ss',False);
      FF8_LoadLBA(Format('%s\DAT.LIST',[Settings.Path.FieldIn]),L);
      For m:=1 to 4 do
      begin
        Name:=Format('%s\FF8DISC%d.IMG',[Settings.Path.FieldOut,m]);
        If FileExists(Name) and chFF8CD[m].Checked Then
        begin
          B[m]:=True;
          AssignFile(F,Name);
          Reset(F,1);
          If LToc Then
          begin
            LSize:=FF8_LoadToc(F,Buf);
            //Count:=FF8_GetLBACount(Buf);
            FH:=Pointer(DWord(Buf)+$28900);
          end;
          For n:=0 To {Count-1}High(L[1]) do
          begin
            If L[m,n].Name=Dat.FName then
            begin
              Size:=Dat.WriteToFile(F,$800*(L[m,n].LBA-LBADef),True,L[m,n].Size);
              If Size=0 Then ShowMessage(Format('FF8DISC%d - файл %s не влез. Но это временная проблема ;)'
              ,[m,Dat.Name])) else if LToc Then
              begin
                FH^[m].Size:=Size;
              end;
            end;
            If LToc Then Inc(FH);
          end;
          //If LToc Then FreeMem(Buf);
        end;
        If LToc and B[m] Then
        begin
          Size:=LZ_Compress(Buf,WBuf,LSize,$FFF,False);
          If Size>RoundBy(LSize,$800) Then ShowMessage('Таблица контента не влезла, пишите ХоРРоРу. Проблема временная.')
          else FF8_SaveToc(F,WBuf,Size);
          FreeMem(WBuf);
          FreeMem(Buf);
        end;
        If B[m] Then CloseFile(F);
      end;
      Dat.Free;
    end;
  end;
end;

Procedure TForm1.Find(FD: TFindDialog; Sender: TObject);
var n,m,Num,Pos,FPos,l: Integer; S, ST: String; FDown: Boolean;
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
  Num:=MsgList.ItemIndex;
  Pos:=edText.SelStart+1;
  If edText.SelLength>0 Then
  begin
    If FDown Then Inc(Pos);
  end;
  If not FDown Then Dec(Pos);
  If not FDown and (Pos=0) Then Pos:=-1;
  S:=FD.FindText;
  If S='' Then Exit;
  n:=FileList.ItemIndex;
  While (n<=High(MText)) and (n>=0) do
  begin
    m:=Num;
    While (m<=High(MText[n].S)) and (m>=0) do
    begin
      If MText[n].S[m].Retry Then
      begin
        l:=FindMessage(MText[n].S[m].RName,MText);
        ST:=MText[l].S[MText[n].S[m].RID].Text
      end else
        ST:=MText[n].S[m].Text;
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
        FileList.ItemIndex:=n;
        FileListClick(Sender);
        MsgList.ItemIndex:=m;
        MsgListClick(Sender);
        edText.SelStart:=FPos-1;
        edText.SelLength:=Length(S);
        edText.SetFocus;
        FD.CloseDialog;
        Exit;
        BRK:
      end;
      If FDown Then Inc(m) else Dec(m);
      If FDown Then Pos:=1 else Pos:=0;
    end;
    Num:=0;
    If FDown Then Inc(n) else Dec(n);
  end;
  FD.CloseDialog;
  ShowMessage('Текст не найден!');
end;

procedure TForm1.FindDialogFind(Sender: TObject);
begin
  Find(FindDialog,Sender);
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

procedure TForm1.Button1Click(Sender: TObject);
var TempWin: TWin;
begin
  TempWin.X:=90;
  TempWin.Y:=128;
  TempWin.W:=200;
  TempWin.H:=24;
  MFont.DrawTextOnWindow('<TAB><TAB>http://consolgames.ru/',WForm.WScreen,MTable,TempWin);
  //MFont.DrawIDLine('HTTP'+#$1A#$0F#$0F+'CONSOLGAMES'+#$0E+'RU'+#$0F,WForm.WScreen,128,128);
  //ShowMessage(IntToStr(PosExRev('345','12345',5)));
  //ShowMessage(GetUpCase('Тра-ля-ляяя!!'));
  //If frMatchCase in FindDialog.Options then ShowMessage('!');
end;

procedure TForm1.AWinEditorExecute(Sender: TObject);
begin
  AWinEditor.Checked:=not AWinEditor.Checked;
  If AWinEditor.Checked Then WForm.Show else WForm.Hide;;
end;

procedure TForm1.AAboutExecute(Sender: TObject);
begin
  AboutForm.Show;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //ShowMessage(IntToStr(Key));
  If Key=17 Then CtrlPressed:=True;
  If Key=18 Then AltPressed:=True;
  If CtrlPressed and (Key=40) and (MsgList.ItemIndex<MsgList.Items.Count-1) Then
  begin
    MsgList.ItemIndex:=MsgList.ItemIndex+1;
    MsgListClick(Sender);
  end else
  If CtrlPressed and (Key=38) and (MsgList.ItemIndex>0) Then
  begin
    MsgList.ItemIndex:=MsgList.ItemIndex-1;
    MsgListClick(Sender);
  end else
  If AltPressed and (Key=37) and (FileList.ItemIndex>0) Then
  begin
    FileList.ItemIndex:=FileList.ItemIndex-1;
    FileListClick(Sender);
  end else
  If AltPressed and (Key=39) and (FileList.ItemIndex<FileList.Items.Count-1) Then
  begin
    FileList.ItemIndex:=FileList.ItemIndex+1;
    FileListClick(Sender);
  end else
  If AltPressed and (Key=40) and (FList.ItemIndex<FList.Items.Count-1) Then
  begin
    FList.ItemIndex:=FList.ItemIndex+1;
    FListClick(Sender);
  end else
  If AltPressed and (Key=38) and (FList.ItemIndex>0) Then
  begin
    FList.ItemIndex:=FList.ItemIndex-1;
    FListClick(Sender);
  end;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key=17 Then CtrlPressed:=False;
  If Key=18 Then AltPressed:=False;
end;

var CheckRecursion: Boolean = False;
procedure TForm1.AAlphaSetExecute(Sender: TObject);
begin
    AAlphaSet.Checked := not AAlphaSet.Checked;
    If AAlphaSet.Checked Then
    begin
      TrackBar1.Enabled:=True;
      Form1.AlphaBlend:=True;
    end else
    begin
      TrackBar1.Enabled:=False;
      Form1.AlphaBlend:=False;
    end;
end;

procedure TForm1.ALogExecute(Sender: TObject);
begin
  ALog.Checked:=not ALog.Checked;
  If ALog.Checked Then Log.Visible:=True
  else Log.Visible:=False;
  Splitter3.Visible:=Log.Visible;
end;

procedure TForm1.AOnTopExecute(Sender: TObject);
begin
  AOnTop.Checked := not AOnTop.Checked;
  If AOnTop.Checked Then Form1.FormStyle:=fsStayOnTop
  else Form1.FormStyle:=fsNormal;
end;

procedure TForm1.AFindScriptMesExecute(Sender: TObject);
var sm,n,m,l,ID,a,b: Integer; SName: String; Msg: ^TAskMsg; Round: Boolean;
begin
  If ffMode<>7 Then Exit;
  Round:=False;
  n:=FileList.ItemIndex;
  m:=MsgList.ItemIndex;
  If FList.ItemIndex>0 Then
  begin
    l:=GetOID(FileList.ItemIndex,FList.ItemIndex,False);
    Inc(l);
  end else l:=0;
  a:=n; sm:=m;
  GetTextNM(a,sm,MText);
  SName:=MText[a].Name;
  While True do
  begin
    If not Round and (n>=FileList.Items.Count) Then
    begin
      Round:=True;
      n:=0;
    end;
    If (Length(MField[n])<=0) and Round and (n>=FileList.ItemIndex) Then
    begin
      Beep;
      Exit;
    end;
    For m:=m to High(MText[n].S) do
    begin
      a:=n; b:=m;
      GetTextNM(a,b, MText);
      If (MText[a].Name=SName) and (b=sm) Then
      begin
        For l:=l To High(MField[n]) do
        begin
          If Round and (n>=FileList.ItemIndex) Then
          begin
            If m>=MsgList.ItemIndex Then
            begin
              If (FList.ItemIndex<0) or (l>=FList.ItemIndex) Then
              begin
                Beep;
                Exit;
              end;
            end;
          end;
          Msg:=Addr(MField[n,l].Pos^);
          If Msg^.ID=$40 Then ID:=Msg^.D else ID:=Msg^.Mess;
          If (Msg^.ID in [$40,$48]) and (ID=sm) Then
          begin
            FileList.ItemIndex:=n;
            FileListClick(Sender);
            ID:=GetLID(n,l,False);
            FList.ItemIndex:=ID;
            FListClick(Sender);
            Exit;
          end;
        end;
        l:=0;
      end;
    end;
    m:=0;
    Inc(n);
  end;
end;

procedure TForm1.ADecompressLZExecute(Sender: TObject);
var Buf,WBuf: Pointer; Size: Integer;
begin
  LZUOpenDialog.Filter:='Все файлы архивов|*.LZS;*.DAT;*.BSX;*.MIM;*.packed|Все файлы|*';
  LZUSaveDialog.Filter:='Все файлы (*.*)|*';
  If LZUOpenDialog.Execute and FileExists(LZUOpenDialog.FileName) Then
  begin
    FileMode := fmOpenRead;
    Try
      Size:=LoadFile(LZUOpenDialog.FileName,Buf);
    except
      ShowMessage('Ошибка при открытии файла!');
      FreeMem(Buf);
      FileMode := fmOpenReadWrite;
      Exit;
    end;
    FileMode := fmOpenReadWrite;
    If (Size<=0) or not TestArc(Buf,Size) Then
    begin
      ShowMessage('Файл невозможно открыть, не является архивом, либо повреждён!');
      FreeMem(Buf);
      Exit;
    end;
    Try
      Size:=LZ_Decompress(Buf,WBuf);
    except
      ShowMessage('Ошибка при распаковке файла!');
      FreeMem(Buf); FreeMem(WBuf);
      Exit;
    end;
    LZUSaveDialog.FileName := LZUOpenDialog.FileName + '.unpacked';
    If LZUSaveDialog.Execute Then
    begin
      Try
        SaveFile(LZUSaveDialog.FileName,WBuf,Size);
      except
        ShowMessage('Ошибка при сохранении файла!');
        FreeMem(Buf); FreeMem(WBuf);
        Exit;
      end;
    end;
  end;
  FreeMem(Buf); FreeMem(WBuf);
end;

procedure TForm1.ABinArcExecute(Sender: TObject);
begin
  BinForm.Show;
end;

procedure TForm1.ACompressLZExecute(Sender: TObject);
var Buf,WBuf: Pointer; Size: Integer;
begin
  LZUSaveDialog.Filter:='Все файлы архивов|*.LZS;*.DAT;*.BSX;*.MIM;*.packed|Все файлы|*';
  LZUOpenDialog.Filter:='Все файлы (*.*)|*';
  If LZUOpenDialog.Execute and FileExists(LZUOpenDialog.FileName) Then
  begin
    FileMode := fmOpenRead;
    Try
      Size:=LoadFile(LZUOpenDialog.FileName,Buf);
    except
      ShowMessage('Ошибка при открытии файла!');
      FreeMem(Buf);
      FileMode := fmOpenReadWrite;
      Exit;
    end;
    FileMode := fmOpenReadWrite;
    If Size<=0 Then
    begin
      ShowMessage('Файл невозможно открыть, либо повреждён!');
      FreeMem(Buf);
      Exit;
    end;
    Try
      Size:=LZ_Compress(Buf,WBuf,Size,level, lzNull{chLZNull.Checked});
    except
      ShowMessage('Ошибка при запаковке файла!');
      FreeMem(Buf); FreeMem(WBuf);
      Exit;
    end;
    If GetUpCase(RightStr(LZUOpenDialog.FileName,9))='.UNPACKED' Then
      LZUSaveDialog.FileName := LeftStr(LZUOpenDialog.FileName,Length(LZUOpenDialog.FileName)-9)
    else
      LZUSaveDialog.FileName := LZUOpenDialog.FileName + '.packed';
    If LZUSaveDialog.Execute Then
    begin
      Try
        SaveFile(LZUSaveDialog.FileName,WBuf,Size);
      except
        ShowMessage('Ошибка при сохранении файла!');
        FreeMem(Buf); FreeMem(WBuf);
        Exit;
      end;
    end;
  end;
  FreeMem(Buf); FreeMem(WBuf);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  If Settings.DatBuilding Then
    BDForm.SetFocus;
end;

Procedure GetStat(var chFiles,chMessages,UchMessages,MsgCount,UMsgCount: Integer; var chFMask: TBoolArr);
var n,m,l,r: Integer;
begin
  chMessages:=0; chFiles:=0; MsgCount:=0; UMsgCount:=0; UchMessages:=0;
  SetLength(chFMask,Length(MText));
  For n:=0 To High(MText) do
  begin
    chFMask[n]:=False;
    For m:=0 To High(MText[n].S) do
    begin
      Inc(MsgCount); If not MText[n].S[m].Retry Then Inc(UMsgCount);
      l:=n; r:=m;
      GetTextNM(l,r,MText);
      If MText[l].S[r].Text<>OText[l].S[r].Text Then
      begin
        If not chFMask[n] Then
        begin
          chFMask[n]:=True; Inc(chFiles);
        end;
        Inc(chMessages);
        If (l=n) and (r=m) Then Inc(UchMessages);
      end;
    end;
  end;
end;

procedure TForm1.ABuildFilesExecute(Sender: TObject);
var n, Errors, NotFound: Integer; ErText,NfText: String; ChMsg: TBoolArr;
mc,umc,mch,fch,umch: Integer; Proc: Boolean; Dat: TFF8Dat;
Label FF8End;
begin
  If ffMode=8 Then Exit;
  If Settings.ViewOrText and chChangedOnly.Checked Then
  begin
    GetStat(fch,mch,umch,mc,umc,ChMsg);
  end;
  CancelPressed:=False;
  ABuildFiles.Enabled:=False;
  ErText:=''; NfText:=''; Errors:=0; NotFound:=0;
  BDForm.Caption:='Сборка DAT-файлов...';
  BDForm.Show;
  Settings.DatBuilding:=True;
  BDForm.bCancel.Enabled:=True;
  BDForm.Progress.Max:=FileList.Count;
  Case ffMode of
    7:
    begin
      For n:=0 To FileList.Count-1 do
      begin
        If Settings.ViewOrText and chChangedOnly.Checked Then Proc:=ChMsg[n]
        else Proc:=True;
        If Proc Then
        begin
          If CancelPressed Then Break;
          BDForm.Progress.Position:=n;
          BDForm.Panel.Caption:=Format('Ошибок: %d,  %d/%d [%d%%]  %s',
          [Errors+NotFound,n+1,FileList.Count,Round(n/FileList.Count*100),MText[n].Name]);
          Application.ProcessMessages;
          If FileExists(Settings.Path.FieldIn+MText[n].Name) Then
          begin
            Try
              BDat(MText,n);
            except
              Inc(Errors); ErText:=ErText+MText[n].Name+#13#10;
            end;
          end else
          begin
            NfText:=NfText+MText[n].Name+#13#10;
            Inc(NotFound);
          end;
        end;
      end;
    end;
    8:
    begin
      Dat:=TFF8Dat.Create;
      For n:=0 To FileList.Count-1 do
      begin
        If Settings.ViewOrText and chChangedOnly.Checked Then Proc:=ChMsg[n]
        else Proc:=True;
        If Proc Then
        begin
          If CancelPressed Then GoTo ff8End;
          BDForm.Progress.Position:=n;
          BDForm.Panel.Caption:=Format('Ошибок: %d,  %d/%d [%d%%]  %s',
          [Errors+NotFound,n+1,FileList.Count,Round(n/FileList.Count*100),MText[n].Name]);
          Application.ProcessMessages;
          If FileExists(Settings.Path.FieldIn+MText[n].Name) Then
          begin
            Try

              BDat(MText,n);
            except
              Inc(Errors); ErText:=ErText+MText[n].Name+#13#10;
            end;
          end else
          begin
            NfText:=NfText+MText[n].Name+#13#10;
            Inc(NotFound);
          end;
        end;
      end;
      FF8End:
    end;
  end;
  If NotFound>0 Then ReportForm.Memo.Text:=Format('Не найдено входных файлов: %d. Список: %s',
  [NotFound,NfText]);
  If Errors>0 Then ReportForm.Memo.Text:=Format('Ошибок при обработке: %d. Список:'#13#10'%s',
  [Errors,ErText]);
  If NotFound+Errors>0 Then
  begin
    ReportForm.Caption:='Отчёт об ошибках';
    ReportForm.Memo.Lines.Add(Format('Всего ошибок: %d',[Errors+NotFound]));
    ReportForm.Show;
  end;
  BDForm.Progress.Position:=n;
  BDForm.bCancel.Enabled:=False;
  If n=FileList.Count Then BDForm.Panel.Caption:='Готово!' else BDForm.Panel.Caption:='Прервано...';
  BDForm.Panel.Caption:=Format('%s Ошибок: %d',[BDForm.Panel.Caption,Errors+NotFound]);
  Settings.DatBuilding:=False;
  ABuildFiles.Enabled:=True;
  CancelPressed:=False;
end;

procedure TForm1.AExtractKernelTextExecute(Sender: TObject);
var Text: TText; Zip: TBinFile; Er: Boolean; Tab: Boolean;
Label Error;
begin
  Er:=False;
  If Length(MTable)<=0 Then Tab:=True else Tab:=False;
  If Tab Then
  begin
    LZUOpenDialog.Filter:='Файлы таблиц (*.tbl)|*.tbl|Все файлы (*.*)|*';
    If LZUOpenDialog.Execute and FileExists(LZUOpenDialog.FileName) Then
    begin
      Try
        LoadTable(LZUOpenDialog.FileName,MTable);
        If Length(MTable)<=0 Then
        begin
          ShowMessage('Ошибка при загрузке таблицы!');
          Exit;
        end;
      except
        ShowMessage('Ошибка при загрузке таблицы!');
        Exit;
      end;
    end else Exit;
  end;
  LZUOpenDialog.Filter:='KERNEL.BIN|KERNEL.BIN|Все файлы|*';
  LZUOpenDialog.FileName:='KERNEL.BIN';
  If LZUOpenDialog.Execute and FileExists(LZUOpenDialog.FileName) Then
  begin
    Zip:=TBinFile.Create;
    Try
      Zip.LoadFromFile(LZUOpenDialog.FileName);
    except
      ShowMessage('Ошибка при загрузке архива!');
      Er:=True;
    end;
    If Er Then GoTo Error;
    Try
      ExtractKernelText(Zip,MTable,Text);
      If Length(MTable)<=0 Then
      begin
        ShowMessage('Нечего извлекать!');
        Er:=True;
      end Else
      OptimizeText(Text);
    except
      ShowMessage('Ошибка при извлечении и обработке текста!');
      Er:=True;
    end;
    If Er Then GoTo Error;
    Try
      LZUSaveDialog.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
      LZUSaveDialog.FileName:='KERNEL.TXT';
      If LZUSaveDialog.Execute Then SaveText(LZUSaveDialog.FileName,Text);
      LZUSaveDialog.Filter:='Файлы оптимизации текста (*.idx)|*.idx|Все файлы (*.*)|*';
      LZUSaveDialog.FileName:='KERNEL.IDX';
      If LZUSaveDialog.Execute Then SaveOpt(LZUSaveDialog.FileName,Text);
    except
      ShowMessage('Ошибка при сохранении файлов!');
    end;
  end;
  Error:
    If Tab Then Finalize(MTable);
    LZUOpenDialog.FileName:='';
    LZUSaveDialog.FileName:='';
    If Assigned(Zip) Then Zip.Free;
end;

Function ExTxPr(n: Integer; S: String): Boolean;
begin
  Result:=CancelPressed;
  BDForm.Panel.Caption:=Format('Обработка файла: %s, №%d',[S,n+1]);
  Application.ProcessMessages;
end;

var OpTxPrCount: Integer;
Function OpTxPr(n: Integer; S: String): Boolean;
begin
  Result:=CancelPressed;
  BDForm.Panel.Caption:=Format('[%s] Отимизация текста: %d/%d',
  [S,n+1,OpTxPrCount]);
  BDForm.Progress.Position:=n;
  Application.ProcessMessages;
end;

procedure TForm1.AExtractTextExecute(Sender: TObject);
var Tab,Er: Boolean; ScriptSize: Integer; Text: TText; Buf: Pointer;
Label Error;
begin
  BDForm.bCancel.Enabled:=True;
  BDForm.Progress.Position:=0;
  BDForm.Caption:='Извлечение текста';
  Er:=False;
  If Length(MTable)<=0 Then Tab:=True else Tab:=False;
  If Tab Then
  begin
    LZUOpenDialog.Filter:='Файлы таблиц (*.tbl)|*.tbl|Все файлы (*.*)|*';
    If LZUOpenDialog.Execute and FileExists(LZUOpenDialog.FileName) Then
    begin
      Try
        LoadTable(LZUOpenDialog.FileName,MTable);
      except
        ShowMessage('Ошибка при загрузке таблицы!');
        Exit;
      end;
    end else Exit;
  end;
  If Length(MTable)<=0 Then
  begin
    If Tab Then Finalize(MTable);
    Exit;
  end;
  FDialog.Caption:='Укажите папку FIELD';
  If FDialog.Execute and DirectoryExists(FDialog.FolderName) Then
  begin
    BDForm.Show;
    Settings.DatBuilding:=True;
    Try
      ScriptSize:=ExtractAllText(FDialog.FolderName,Text,MTable,Buf,ExTxPr);
    except  
      ShowMessage('Ошибка при извлечении текста!');
      Er:=True;
    end;
    If Er Then GoTo Error;
    OpTxPrCount:=Length(Text);
    BDForm.Progress.Max:=OpTxPrCount-1;
    Try
      OptimizeText(Text, OpTxPr);
    except
      ShowMessage('Ошибка при оптимизации текста!');
      FreeMem(Buf);
      Er:=True;
    end;
    If Er Then GoTo Error;
    Try
      LZUSaveDialog.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
      If LZUSaveDialog.Execute Then SaveText(LZUSaveDialog.FileName, Text);
      LZUSaveDialog.Filter:='Файлы оптимизации текста (*.idx)|*.idx|Все файлы (*.*)|*';
      If LZUSaveDialog.Execute Then SaveOpt(LZUSaveDialog.FileName, Text);
      LZUSaveDialog.Filter:='Файлы скриптов (*.fsc)|*.fsc|Все файлы (*.*)|*';
      If LZUSaveDialog.Execute Then SaveFile(LZUSaveDialog.FileName,Buf,ScriptSize);
    except
      ShowMessage('Ошибка при сохранении файла!');
      Er:=True;
    end;
    If Er Then GoTo Error;
  end;
  Error:
  CancelPressed:=False;
  If Tab Then Finalize(MTable);
  BDForm.bCancel.Enabled:=False;
  Settings.DatBuilding:=False;
end;


procedure TForm1.ALoadTableExecute(Sender: TObject);
begin
  LZUOpenDialog.Filter:='Файлы таблиц (*.tbl)|*.tbl|Все файлы (*.*)|*';
  If LZUOpenDialog.Execute and FileExists(LZUOpenDialog.FileName) Then
  begin
    Finalize(MTable);
    Try
      LoadTable(LZUOpenDialog.FileName,MTable);
    except
      ShowMessage('Ошибка при загрузке таблицы!');
      Exit;
    end;
  end;
  If Length(MTable)>0 Then AShowTable.Enabled:=True;
end;

procedure TForm1.AShowTableExecute(Sender: TObject);
var Txt: String; n: Integer;
begin
  Txt:='';
  If Length(MTable)<=0 Then ReportForm.Memo.Text:='Таблица не загружена' else
  begin
    For n:=0 To High(MTable) do
    begin
      With MTable[n] do
      begin
        If D Then Txt:=Format('%s%.4x=%s'#13#10,
        [Txt,((Value SHL 8) AND $FF00) OR (Value SHR 8),Text])
        else Txt:=Format('%s%.2x=%s'#13#10,[Txt,Value,Text])
      end;
    end;
  end;
  ReportForm.Memo.Text:=Txt;
  ReportForm.Caption:='Просмотр таблицы';
  ReportForm.Show;
end;

procedure TForm1.AShowStatExecute(Sender: TObject);
var F,M,UM,MsgCount,UMsgCount: Integer; Mask: TBoolArr;
begin
  GetStat(F,M,UM,MsgCount,UMsgCount,Mask);
  ShowMessage(Format('Файлов: %d'#13#10'Изменённых: %d'#13#10'Всего сообщений: %d'+
  #13#10'Из них уникальных: %d'#13#10'Изменено сообщений: %d'#13#10+
  'Из них уникальных: %d'#13#10'Прогресс: %d%%',
  [Length(MText),F,MsgCount,UMsgCount,M,UM,UM*100 div (UMsgCount-1)]));
end;

procedure TForm1.AImgConvExecute(Sender: TObject);
begin
  ConvForm.Show;
end;

procedure TForm1.ATOCEditorExecute(Sender: TObject);
begin
  ToCForm.Show;
end;

procedure TForm1.FormDeactivate(Sender: TObject);
begin
  CtrlPressed:=False;
  AltPressed:=False;
end;

procedure TForm1.LevelBarChange(Sender: TObject);
begin
  Level:=$1FF+$FFF-LevelBar.Position;
end;

procedure TForm1.chLZNullClick(Sender: TObject);
begin
  LZNull:=chLZNull.Checked;
end;


procedure TForm1.Button2Click(Sender: TObject);
//var Msg: TMsg; Buf: Pointer; Text: TText; W: ^Word;
var Buf: Pointer; Text: TText;
begin
  CreateError('Да блин...');
  Exit;
{  //LoadFile('FF8\Test\Test.msg',Buf);
  //LoadText(Buf,MTable,Msg,True,True);
  //ShowMessage('Done!');

  //FF8_ExtractField('FF8\IMG','FF8\FIELD');
  Finalize(MTable);
  LoadTable('FF8\Table_En.TBL',MTable);
  LoadFile('FF8\MTE\BD2C3B8.msg',Buf);
  //W:=Buf; ShowMessage(IntToHex(W^,2));
  SetLength(Text,1);
  LoadText(Buf,MTable,Text[0],False,False,[],0);
  FreeMem(Buf);
  SaveText('FF8\MTE\Locations.txt',Text);
}

{
  FFT_LZ_Decompress(Addr(Test[1]),Buf,$20);
  Move(Buf^,Test[1],$20);
  ShowMessage(Test);
}
  Finalize(MTable);
  LoadTable('FFT\Table.tbl',MTable);
  FFT_ExtractMainText(Buf,LoadFile('FFT\CD\EVENT\TEST.EVT',Buf),MTable,Text);
  OptimizeText(Text);
  SaveText('FFT\TEST.TXT',Text);
  Finalize(Text);
  FreeMem(Buf);
end;

procedure TForm1.Button3Click(Sender: TObject);
var Text: TText;  Dat: TFF8Dat; ID: Integer;
begin        //bghoke_2.dat
  Finalize(MTable);
  LoadTable('FF8\Table_Ru.TBL',MTable);
  //FF8_ExtractAllText('FF8\IMG\OR_FF8DISC1.IMG',Text,MTable);}
  //FF8_ExtractField('FF8\IMG','FF8\FIELD');
//  FF8_ExtractAllText('FF8\Field\',Text,MTable);
//  OptimizeText(Text);
//  SaveText('FF8\Text.txt',Text);

      Dat:=TFF8Dat.Create;
      OpenOpt('FF8\FF8.idx',Text);
      OpenText('FF8\FF8.txt',Text);
      Dat.LoadFromFile('FF8\Field\bghoke_2.dat');
      ID:=FindMessage('bghoke_2.dat',Text);
      Dat.ReplaceText(Text,ID,MTable);
      Dat.SaveToFile('FF8\Test\Testing.DAT!'); 
      Dat.Free;

end;

procedure TForm1.AFF8ExtractTextExecute(Sender: TObject);
var Tab,Er: Boolean; ScriptSize: Integer; Text: TText; Buf: Pointer;
Label Error;
begin
  BDForm.bCancel.Enabled:=True;
  BDForm.Progress.Position:=0;
  BDForm.Caption:='Извлечение текста (FF8)';
  Er:=False;
  If Length(MTable)<=0 Then Tab:=True else Tab:=False;
  If Tab Then
  begin
    LZUOpenDialog.Filter:='Файлы таблиц (*.tbl)|*.tbl|Все файлы (*.*)|*';
    If LZUOpenDialog.Execute and FileExists(LZUOpenDialog.FileName) Then
    begin
      Try
        LoadTable(LZUOpenDialog.FileName,MTable);
      except
        ShowMessage('Ошибка при загрузке таблицы!');
        Exit;
      end;
    end else Exit;
  end;
  If Length(MTable)<=0 Then
  begin
    If Tab Then Finalize(MTable);
    Exit;
  end;
  FDialog.Caption:='Укажите папку FIELD';
  If FDialog.Execute and DirectoryExists(FDialog.FolderName) Then
  begin
    BDForm.Show;
    Settings.DatBuilding:=True;
    Try
      FF8_ExtractAllText(FDialog.FolderName,Text,MTable,ExTxPr);
    except  
      ShowMessage('Ошибка при извлечении текста!');
      Er:=True;
    end;
    If Er Then GoTo Error;
    OpTxPrCount:=Length(Text);
    BDForm.Progress.Max:=OpTxPrCount-1;
    Try
      OptimizeText(Text, OpTxPr);
    except
      ShowMessage('Ошибка при оптимизации текста!');
      FreeMem(Buf);
      Er:=True;
    end;
    If Er Then GoTo Error;
    Try
      LZUSaveDialog.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
      If LZUSaveDialog.Execute Then SaveText(LZUSaveDialog.FileName, Text);
      LZUSaveDialog.Filter:='Файлы оптимизации текста (*.idx)|*.idx|Все файлы (*.*)|*';
      If LZUSaveDialog.Execute Then SaveOpt(LZUSaveDialog.FileName, Text);
    except
      ShowMessage('Ошибка при сохранении файла!');
      Er:=True;
    end;
    If Er Then GoTo Error;
  end;
  Error:
  CancelPressed:=False;
  If Tab Then Finalize(MTable);
  BDForm.bCancel.Enabled:=False;
  Settings.DatBuilding:=False;
end;

procedure TForm1.AFF8ExtractFieldExecute(Sender: TObject);
  Procedure P(n: Integer; S: String);
  begin
    BDForm.Progress.Position:=n;
    BDForm.Panel.Caption:=S;
    Application.ProcessMessages;
  end;
var InFolder,OutFolder: String; n: Integer;
begin
  //InFolder:='FF8\IMG';
  //OutFolder:='FF8\IMG\Test';
  If FDialog.Execute and not DirectoryExists(FDialog.FolderName) Then
  begin
    ShowMessage(Format('Папка "%s" не существует!',[FDialog.FolderName]));
    Exit;
  end;
  InFolder:=FDialog.FolderName;
  For n:=1 To 4 do
  begin
    If not FileExists(Format('%s\FF8DISC%d.IMG',[InFolder,n])) Then
    begin
      ShowMessage(Format('Файл "FF8DISC%d.IMG" не найден!',[n]));
      Exit;
    end;
  end;
  If FDialog.Execute and not DirectoryExists(FDialog.FolderName) Then
  begin
    ShowMessage(Format('Папка "%s" не существует!',[FDialog.FolderName]));
    Exit;
  end;
  OutFolder:=FDialog.FolderName;
  CancelPressed:=False;
  ABuildFiles.Enabled:=False;
  BDForm.Caption:='[FF8] Извлечение DAT-файлов...';
  BDForm.Show;
  Settings.DatBuilding:=True;
  BDForm.bCancel.Enabled:=True;
  BDForm.Progress.Max:=100;
  FF8_ExtractField(InFolder,OutFolder,@P); 
  BDForm.bCancel.Enabled:=False;
  Settings.DatBuilding:=False;
  ABuildFiles.Enabled:=True;
  CancelPressed:=False;  
end;



var Test: String = 'ABC it is compression, mother her, compression!';
procedure TForm1.Button4Click(Sender: TObject);
var Buf,WBuf: Pointer; Size: Integer;
begin
{  SetLength(Test,FFT_LZ_Compress(Addr(Test[1]),Buf,Length(Test)));
  Move(Buf^,Test[1],Length(Test));
  FreeMem(Buf);
  ShowMessage(Test);
  SaveFile('FFT\_TEST\pack',Addr(Test[1]),Length(Test));
  SetLength(Test,FFT_LZ_Decompress(Addr(Test[1]),Buf,Length(Test)));
  Move(Buf^,Test[1],Length(Test));
  FreeMem(Buf);
  SaveFile('FFT\_TEST\unpack',Addr(Test[1]),Length(Test));
  ShowMessage(Test);}
  LoadFile('FFT\CD\EVENT\TEST.EVT',Buf);
  Size:=FFT_LZ_Compress(Pointer(DWord(Buf)+$48F9),WBuf,$ED4);
  SaveFile('FFT\_TEST\dlg',WBuf,Size);
  FreeMem(Buf); FreeMem(WBuf);


  Size:=LoadFile('FFT\_TEST\dlg',Buf);
  Size:=FFT_LZ_Decompress(Pointer(DWord(Buf)+$0),WBuf,Size);
  SaveFile('FFT\_TEST\dlg_u',WBuf,Size);
  FreeMem(Buf); FreeMem(WBuf);
end;

procedure TForm1.ANewProjectExecute(Sender: TObject);
begin
  NewProjectForm.Show;
end;

Initialization
end.
