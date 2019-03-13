unit SH0_Patch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, jpeg, ExtCtrls, ComCtrls, ActnList,
  PFolderDialog, ShellAPI, DIB, Errors, IPS_Patch, SH0_ARC, Readme, Instruction;

type
  TMainForm = class(TForm)
    MainImage: TImage;
    GroupBox1: TGroupBox;
    eBootPath: TEdit;
    XPManifest1: TXPManifest;
    OpenBootDialog: TOpenDialog;
    OpenArcDialog: TOpenDialog;
    GroupBox2: TGroupBox;
    eArcPath: TEdit;
    GroupBox3: TGroupBox;
    eTempPath: TEdit;
    bSelBootPath: TButton;
    bSelArcPath: TButton;
    bSelTempPath: TButton;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    eCommonProgress: TProgressBar;
    eCurrentProgress: TProgressBar;
    bStart: TButton;
    Button5: TButton;
    Button6: TButton;
    SelectTempDialog: TPFolderDialog;
    GroupBox6: TGroupBox;
    eCurrentStep: TLabel;
    Button7: TButton;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox7: TGroupBox;
    eAuthors: TMemo;
    Timer1: TTimer;
    Shape1: TShape;
    eCurrentAction: TLabel;
    GroupBox8: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox9: TGroupBox;
    eOutDir: TEdit;
    bSelOutDir: TButton;
    SelectOutDialog: TPFolderDialog;
    bCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bSelBootPathClick(Sender: TObject);
    procedure bSelArcPathClick(Sender: TObject);
    procedure bSelTempPathClick(Sender: TObject);
    procedure SelectTempDialogInitialized(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure bSelOutDirClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    procedure SetStep(Step: Integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
{$R IPS_ARC.RES}
{$R SH0_BG.RES}

const
  cIPS  = 'IPS.ARC';
  cIPSF = 'SH0_IPS\';
  cARCF = 'SH0_ARC\';
  cPSP_GAME = 'PSP_GAME.ARC';
  cEmbeded  = 'Embeded.LST';
  cStepText: Array[0..4] of String = (
    'Извлечение патча...',
    'Распаковка игрового архива...',
    'Применение патча...',
    'Сборка игрового архива...',
    'Удаление временных файлов...');

var BG0, BG1: TDIB; BGState: Boolean = False; Time: Integer = 0;
    BGWaitTime: Integer = 100;
    IPSCount:   Integer = 0;
    AllPercent: Integer = 0;
    CancelPressed: Boolean = False;
    ClosePressed:  Boolean = False;
    Running: Boolean = False;

function GetTempDir: String;
var Buf: array[0..1023] of Char;
begin
  SetString(Result, Buf, GetTempPath(Sizeof(Buf)-1, Buf));
end;

Function ExtractIPS_ARC(FileName: String): Boolean;
var Stream: TCustomMemoryStream;
begin
  Result := False;
  Stream := TMemoryStream.Create;
  Try
    Stream := TResourceStream.Create(HInstance, 'IPS_ARC', RT_RCDATA);
  except
    CreateError('IPS_ARC: Ошибка при загрузке ресурса!');
    Exit;
  end;
  Try
    Stream.SaveToFile(FileName);
  except
    CreateError('IPS_ARC: Ошибка при сохранении файла!');
    Exit;
  end;
  Stream.Free;
  Result := True;
end;

Function ExtractPSP_GAME_ARC(FileName: String): Boolean;
var Stream: TCustomMemoryStream;
begin 
  Result := False;
  Stream := TMemoryStream.Create;
  Try
    Stream := TResourceStream.Create(HInstance, 'PSP_GAME_ARC', RT_RCDATA);
  except
    CreateError('PSP_GAME_ARC: Ошибка при загрузке ресурса!');
    Exit;
  end;
  Try
    Stream.SaveToFile(FileName);
  except
    CreateError('PSP_GAME_ARC: Ошибка при сохранении файла!');
    Exit;
  end;
  Stream.Free;
  Result := True;
end;

Procedure DeleteFolder(Dir: String);
var SR: TSearchRec;
begin
  If not DirectoryExists(Dir) Then Exit;
  If Dir[Length(Dir)] <> '\' Then Dir := Dir + '\';
  If FindFirst(Dir + '*', faAnyFile, SR) <> 0 then Exit;
  Repeat
    If (SR.Name = '.') or (SR.Name = '..') Then Continue;
    If SR.Attr = faDirectory Then
      DeleteFolder(Dir + SR.Name + '\')
    else
    begin
      DeleteFile(Dir + SR.Name);
    end;
  Until (FindNext(SR) <> 0);
  FindClose(SR);
  RemoveDir(Dir);
end;

Procedure ReplaceFile(const FileName, NewFile: String);
begin
  If not FileExists(FileName) Then
  begin
    CreateError(Format('ReplaceFile: Файл не найден! (%s)',[FileName]));
    Exit;
  end;
  If FileExists(NewFile) Then DeleteFile(NewFile);
  If not CopyFile(PChar(FileName),PChar(NewFile), False) Then
    CreateError(Format('ReplaceFile: Не могу копировать файл! (%s->%s)',
    [FileName, NewFile]));
end;

Procedure Progress(Cur,Max: Integer; CurFile: String);
begin
  MainForm.eCurrentAction.Caption :=
    Format('[%d/%d] Обработка файла: %s', [Cur+1,Max,CurFile]);
  If Cur = 0 Then
    MainForm.eCurrentProgress.Max := Max;
  If Cur <= MainForm.eCurrentProgress.Max Then
    MainForm.eCurrentProgress.Position := Cur;
  MainForm.eCommonProgress.Position := AllPercent + Round((Cur / Max) * 100) div 4;
  Application.ProcessMessages;
end;

Procedure ApplyIPSPatches(IPSDir, FilesDir: String);
var SR: TSearchRec; n: Integer;
begin
  If not DirectoryExists(IPSDir) Then
  begin
    CreateError(Format('ApplyIPSPatches: Папка "%s" не найдена!', [IPSDir]));
    Exit;
  end;
  If not DirectoryExists(FilesDir) Then
  begin
    CreateError(Format('ApplyIPSPatches: Папка "%s" не найдена!', [FilesDir]));
    Exit;
  end;
  If IPSDir[Length(IPSDir)] <> '\' Then IPSDir := IPSDir + '\';
  If FilesDir[Length(IPSDir)] <> '\' Then FilesDir := FilesDir + '\';

  n:= 0;
  If FindFirst(IPSDir + '*', faAnyFile XOR faDirectory, SR) <> 0 then Exit;
  Repeat
    If (SR.Name = '.') or (SR.Name = '..') or (SR.Attr = faDirectory)
    or (SR.Name = 'BOOT.BIN.IPS') or (SR.Name = 'LIST.LST') Then Continue;
    If ExtractFileExt(SR.Name) = '.IPS' Then
    begin
      Progress(n, IPSCount, ChangeFileExt(SR.Name, ''));
      If CancelPressed Then Exit;
      IPS_PatchFile(IPSDir + SR.Name, FilesDir + ChangeFileExt(SR.Name, ''));
    end else
      Progress(n, IPSCount, SR.Name);
      ReplaceFile(IPSDir + SR.Name, FilesDir + SR.Name);
    Inc(n);
  Until (FindNext(SR) <> 0);
  FindClose(SR);
end;

Procedure ReplaceEmbeded(BootFile, EmbededFile: String);
const Offset     = $1F3B6C;
      SizeOffset = $1F3B48;
var MF,F: File; Size: Integer; Buf: Pointer;
begin
  If not FileExists(BootFile) Then
  begin
    CreateError(Format('ReplaceEmbeded: Файл "%s" не найден!', [BootFile]));
    Exit;
  end;
  If not FileExists(EmbededFile) Then
  begin
    CreateError(Format('ReplaceEmbeded: Файл "%s" не найден!', [EmbededFile]));
    Exit;
  end;


// BaseFile InFile Offset SizeOffset
  AssignFile(MF, BootFile);
  AssignFile(F , EmbededFile);
  Reset(MF,1);
  Reset(F,1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);
  Seek(MF, Offset);
  BlockWrite(MF, Buf^, Size);
  Seek(MF, SizeOffset);
  BlockWrite(MF, Size, 4);
  CloseFile(MF);
  FreeMem(Buf);
end;

procedure TMainForm.SetStep(Step: Integer);
begin
  eCurrentStep.Caption := Format('[%d/%d] %s',
    [Step+1, Length(cStepText), cStepText[Step]]);
  eCurrentAction.Caption := 'Подготовка...';
  Case Step of
    0: AllPercent := 0;
    1: AllPercent := 25;
    2: AllPercent := 50;
    3: AllPercent := 75;
  end;
  Application.ProcessMessages;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  eTempPath.Text := GetTempDir();
  BG0 := TDIB.Create;
  BG1 := TDIB.Create;
  BG0.LoadFromResourceName(HInstance, 'SH0_BG0');
  BG1.LoadFromResourceName(HInstance, 'SH0_BG1');
  MainImage.Picture.Graphic := BG0;
  eCommonProgress.Max       := 100;///Length(cStepText);
  eCommonProgress.Position  := 0;
  eCurrentProgress.Position := 0;

  eOutDir.Text   := ExpandFileName(eOutDir.Text);
  eBootPath.Text := ExpandFileName(eBootPath.Text);
  eArcPath.Text  := ExpandFileName(eArcPath.Text);
  //SelectTempDialog.SetStatusText(SelectTempDialog.StatusText);
  //SelectOutDialog.SetStatusText(SelectOutDialog.StatusText);
end;

{Function CancelPressed: Boolean;
begin
  If Cancel Then MessageDlg('Процесс прерван пользователем!', mtWarning, mbOK, 0);
  Result := Cancel;
end;}

procedure TMainForm.bStartClick(Sender: TObject);
var TempDir: String; OutDir: String;
Label STEP4, STEP3, STEP2, STEP1, TEMPCLEAR;
begin
  Running := False;
  If not FileExists(eBootPath.Text) Then
  begin
    MessageDlg('Неправильно указан путь к файлу BOOT.BIN. Укажите путь к '+
    'существующему файлу.'
    , mtError, [mbOK], 0);
    Exit;
  end;
  If not FileExists(eArcPath.Text) Then
  begin
    MessageDlg('Неправильно указан путь к файлу SH.ARC. Укажите путь к '+
    'существующему файлу.'
    , mtError, [mbOK], 0);
    Exit;
  end;
  If not DirectoryExists(eTempPath.Text) Then
  begin
    MessageDlg('Неправильно указан путь к папке временных файлов. '+
    'Укажите путь к существующей папке на жёстком диске.'
    , mtError, [mbOK], 0);
    Exit;
  end;
  If not DirectoryExists(eOutDir.Text) Then
  begin
    If not ForceDirectories(eOutDir.Text) Then
    begin 
      MessageDlg('Не могу создать выходную папку!', mtError, [mbOK], 0);
      Exit;
    end;
  end;

  Running := True;
  CancelPressed := False;
  ClosePressed  := False;
  OutDir := eOutDir.Text;
  If OutDir[Length(OutDir)] <> '\' Then OutDir := OutDir + '\';
  TempDir := eTempPath.Text;
  If not DirectoryExists(TempDir) Then
  begin
    MessageDlg('Путь к папке для временных файлов неверен!', mtError, [mbOK], 0);
    Exit;
  end;
  If TempDir[Length(TempDir)]<>'\' Then TempDir := TempDir + '\';
  eOutDir.Enabled      := False;
  bSelOutDir.Enabled   := False;
  eBootPath.Enabled    := False;
  eArcPath.Enabled     := False;
  eTempPath.Enabled    := False;
  bSelBootPath.Enabled := False;
  bSelArcPath.Enabled  := False;
  bSelTempPath.Enabled := False;
  bStart.Enabled       := False;
  bStart.Visible       := False;
  bCancel.Visible      := True;

//GoTo Step2;

  SetStep(0);  // Извлечение патча

  If not ExtractIPS_ARC(TempDir + cIPS) Then
  begin
    MessageDlg('Не могу извлечь патч! (IPS)', mtError, [mbOK], 0);
    Exit;
  end;
  If not ExtractPSP_GAME_ARC(TempDir + cPSP_GAME) Then
  begin
    MessageDlg('Не могу извлечь патч! (PSP_GAME)', mtError, [mbOK], 0);
    Exit;
  end;

  If not DirectoryExists(TempDir + cIPSF) Then
    ForceDirectories(TempDir + cIPSF);
//GoTo STEP2;
  IPSCount := ARC_Extract(TempDir + cIPS, TempDir + cIPSF, '', @Progress, @CreateError, @CancelPressed);
  If CancelPressed Then GoTo TEMPCLEAR;

STEP1:
  SetStep(1); // Извлечение игрового архива
  If not DirectoryExists(TempDir + cARCF) Then
    ForceDirectories(TempDir + cARCF);
  ARC_Extract(eArcPath.Text, TempDir + cARCF, '', @Progress, @CreateError, @CancelPressed);
  If CancelPressed Then GoTo TEMPCLEAR;

STEP2:
  SetStep(2); // Применение патча
  ApplyIPSPatches(TempDir + cIPSF, TempDir + cARCF);

  eCurrentAction.Caption := 'Извлечение PSP_GAME...';
  Application.ProcessMessages;
  If not FileExists(TempDir + cPSP_GAME) Then
    MessageDlg('В сборке патча не найден один из ключевых файлов! Если ошибка повторится, попробуйте '+
    'скачать новую версию патча, если таковая имеется. Если не поможет - попробуйте обратиться на форум '+
    'http://consolgames.ru/forum/'#13#10'Это не смертельно, но перевод будет неполным.',
      mtError, [mbOK], 0)
  else
    ARC_Extract(TempDir + cPSP_GAME, OutDir, '*', nil, @CreateError, @CancelPressed);
  If CancelPressed Then GoTo TEMPCLEAR;

  eCurrentAction.Caption := 'Обработка BOOT.BIN...';
  Application.ProcessMessages;

  If not DirectoryExists(OutDir + 'SYSDIR') Then CreateDir(OutDir + 'SYSDIR');
  CopyFile(PChar(eBootPath.Text), PChar(OutDir + 'SYSDIR\BOOT.BIN'), False);

  If not FileExists(TempDir + cARCF + cEmbeded) Then
    MessageDlg('В сборке патча не найден один из ключевых файлов! Если ошибка повторится, попробуйте '+
    'скачать новую версию патча, если таковая имеется. Если не поможет - попробуйте обратиться на форум '+
    'http://consolgames.ru/forum/'#13#10'Это не смертельно, но перевод может быть неполным.',
      mtError, [mbOK], 0)
  else
  begin
    If Arc_Build(TempDir + cARCF + cEmbeded, TempDir + 'Embeded.arc'{OutDir + 'SYSDIR\BOOT.BIN'},
    'test1;test2', False, {TempDir + 'Embeded.arc'} nil, @CreateError, @CancelPressed) > 0 Then
      MessageDlg('При обработке одного из файлов произошли ошибки. Правильная работа игры не гарантируется.',
        mtError, [mbOK], 0);
    If CancelPressed Then GoTo TEMPCLEAR;
    ReplaceEmbeded(OutDir + 'SYSDIR\BOOT.BIN', TempDir + 'Embeded.arc');
  end;
  If CancelPressed Then GoTo TEMPCLEAR;

STEP3:
  SetStep(3); // Сборка архива
  If not DirectoryExists(OutDir + 'USRDIR') Then CreateDir(OutDir + 'USRDIR');
  If Arc_Build(TempDir + cARCF + 'LIST.LST', OutDir + 'USRDIR\SH.ARC', '', False,
  @Progress, @CreateError, @CancelPressed) > 0 Then
    MessageDlg('При сборке архива произошли ошибки. Правильная работа игры не гарантируется.',
      mtError, [mbOK], 0);;

STEP4:
TEMPCLEAR:
  SetStep(4); // Чистка темпов

  eCurrentAction.Caption    := 'Программа удаляет все временные файлы...';
  Application.ProcessMessages;
  DeleteFile  (TempDir + cIPS);
  DeleteFolder(TempDir + cIPSF);
  eCurrentProgress.Position := eCurrentProgress.Max;
  Application.ProcessMessages;
  DeleteFolder(TempDir + cARCF);
  DeleteFile  (TempDir + 'Embeded.arc');

  eCommonProgress.Position  := 0;
  eCurrentProgress.Position := 0;   
  Running := False;
  If ClosePressed Then Close;

  If CancelPressed Then
  begin
    eCurrentStep.Caption      := 'Процесс прерван пользователем.';
    eCurrentAction.Caption    := 'Патч не был применён.';
    MessageDlg('Процесс прерван пользователем!', mtWarning, [mbOK], 0);
  end else
  begin
    eCurrentStep.Caption      := 'Готово! Все операции успешно завершены.';
    eCurrentAction.Caption    := 'Пересобирайте образ и наслаждайтесь игрой ;)';
  end;
                                 
  eOutDir.Enabled      := True;
  bSelOutDir.Enabled   := True;
  eBootPath.Enabled    := True;
  eArcPath.Enabled     := True;
  eTempPath.Enabled    := True;
  bSelBootPath.Enabled := True;
  bSelArcPath.Enabled  := True;
  bSelTempPath.Enabled := True;
  bStart.Enabled       := True;
  bCancel.Visible      := False;
  bStart.Visible       := True;
end;

procedure TMainForm.Label1Click(Sender: TObject);
begin
  ShellExecute(Handle,'open','http://consolgames.ru/',nil,nil,SW_SHOW);
end;

procedure TMainForm.Label2Click(Sender: TObject);
begin
  ShellExecute(Handle,'open','http://ex-ve.ucoz.ru/',nil,nil,SW_SHOW);
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Inc(Time);
  If (BGState and (Time>1)) or (not BGState and (Time>BGWaitTime)) Then
  begin
    If BGState Then
      MainImage.Picture.Graphic := BG0
    else
      MainImage.Picture.Graphic := BG1;
    BGState := not BGState;
    Time := 0;
    BGWaitTime := 150 + Random(2000);
    Application.ProcessMessages;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  BG0.Free;
  BG1.Free;
end;

procedure TMainForm.bSelBootPathClick(Sender: TObject);
begin
  If not OpenBootDialog.Execute Then Exit;
  eBootPath.Text := OpenBootDialog.FileName;
end;

procedure TMainForm.bSelArcPathClick(Sender: TObject);
begin
  If not OpenArcDialog.Execute Then Exit;
  eArcPath.Text := OpenArcDialog.FileName;
end;

procedure TMainForm.bSelTempPathClick(Sender: TObject);
begin
  If not SelectTempDialog.Execute then Exit;
  eTempPath.Text := SelectTempDialog.FolderName + '\';
end;

procedure TMainForm.SelectTempDialogInitialized(Sender: TObject);
begin
  (Sender as TPFolderDialog).SelectFolder(ExtractFilePath(eTempPath.Text));
end;

procedure TMainForm.Button6Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.bSelOutDirClick(Sender: TObject);
begin
  If not SelectOutDialog.Execute then Exit;
  eOutDir.Text := SelectTempDialog.FolderName + '\';
end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
  ReadmeForm.Show;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  InstructionForm.Show;
end;

procedure TMainForm.bCancelClick(Sender: TObject);
begin
  CancelPressed := True;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If Running Then
  begin
    CanClose := False;
    If MessageDlg('Выполняется установка патча. '+
      'Вы действительно хотите прервать процесс и закрыть приложение?',
      mtConfirmation,[mbYes,mbNo],0) = 6 Then
    begin
      CancelPressed := True;
      ClosePressed  := True;
    end;
  end else
    CanClose := True;
end;

end.
