unit ICO_Patch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XPMan, jpeg, ComCtrls, ActnList, ICO_DF,
  PFolderDialog, ShellAPI, Errors, IPS_Patch, Readme, Instruction, ExtCtrls;

type
  TMainForm = class(TForm)
    MainImage: TImage;
    GroupBox1: TGroupBox;
    eDataPath: TEdit;
    XPManifest1: TXPManifest;
    OpenDataDialog: TOpenDialog;
    GroupBox3: TGroupBox;
    eTempPath: TEdit;
    bSelDataPath: TButton;
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
    eCurrentAction: TLabel;
    SelectOutDialog: TPFolderDialog;
    bCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure bSelDataPathClick(Sender: TObject);
    procedure bSelTempPathClick(Sender: TObject);
    procedure SelectTempDialogInitialized(Sender: TObject);
    procedure Button6Click(Sender: TObject);
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
{$R PATCH.RES}

const
  cIPS  = 'IPS.ARC';
  cIPSF = 'ICO_IPS\';
  cARCF = 'ICO_ARC\';
  cDFF  = 'ICO_DF\';
  cPSP_GAME = 'PSP_GAME.ARC';
  cEmbeded  = 'Embeded.LST';
  cStepText: Array[0..6] of String = (
    'Извлечение патча...',
    'Распаковка главного игрового архива...',
    'Распаковка внутренних архивов...',
    'Применение патча...',
    'Сборка внутренних архивов...',
    'Сборка игрового архива...',
    'Удаление временных файлов...');

var
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

Function Extract_patch(FileName: String): Boolean;
var Stream: TCustomMemoryStream;
begin
  Result := False;
  Stream := TMemoryStream.Create;
  Try
    Stream := TResourceStream.Create(HInstance, 'PATCH_DF', RT_RCDATA);
  except
    CreateError('PATCH_DF: Ошибка при загрузке ресурса!');
    Exit;
  end;
  Try
    Stream.SaveToFile(FileName);
  except
    CreateError('PATCH_DF: Ошибка при сохранении файла!');
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
  If Max<=0 Then Exit;
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
  If FindFirst(IPSDir + '*', faAnyFile, SR) <> 0 then Exit;
  Repeat
    If (SR.Name = '.') or (SR.Name = '..') Then Continue;
    If SR.Attr = faDirectory Then
    begin
      ApplyIPSPatches(IPSDir + SR.Name + '\', FilesDir + SR.Name + '\');
      Continue;
    end;
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
    2: AllPercent := 25;
    4: AllPercent := 50;
    5: AllPercent := 75;
    6: AllPercent := 100;
  end;
  eCommonProgress.Position := AllPercent;
  Application.ProcessMessages;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  eTempPath.Text := GetTempDir();
  eCommonProgress.Max       := 100;///Length(cStepText);
  eCommonProgress.Position  := 0;
  eCurrentProgress.Position := 0;
  eDataPath.Text := ExpandFileName(eDataPath.Text);
end;

{Function CancelPressed: Boolean;
begin
  If Cancel Then MessageDlg('Процесс прерван пользователем!', mtWarning, mbOK, 0);
  Result := Cancel;
end;}

procedure TMainForm.bStartClick(Sender: TObject);
var TempDir: String;
Label STEP5, STEP3, STEP2, STEP1, TEMPCLEAR;
begin
  Running := False;
  If not FileExists(eDataPath.Text) Then
  begin
    MessageDlg('Неправильно указан путь к файлу DATA.DF. Укажите путь к '+
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

  Running := True;
  CancelPressed := False;
  ClosePressed  := False;
  TempDir := eTempPath.Text;
  If TempDir[Length(TempDir)]<>'\' Then TempDir := TempDir + '\';
  eDataPath.Enabled    := False;
  eTempPath.Enabled    := False;
  bSelDataPath.Enabled := False;
  bSelTempPath.Enabled := False;
  bStart.Enabled       := False;
  bStart.Visible       := False;
  bCancel.Visible      := True;

//GoTo Step5;

SetStep(0);  // Извлечение патча

  If not Extract_patch(TempDir + cIPS) Then
  begin
    MessageDlg('Не могу извлечь патч! (IPS)', mtError, [mbOK], 0);
    Exit;
  end;

  If not DirectoryExists(TempDir + cIPSF) Then
    ForceDirectories(TempDir + cIPSF);
//GoTo STEP1;
  IPSCount := DFDATAS_Extract(TempDir + cIPS, TempDir + cIPSF, '*', @Progress, @CreateError, @CancelPressed);
  If CancelPressed Then GoTo TEMPCLEAR;


SetStep(1); // Извлечение игрового архива
  If not DirectoryExists(TempDir + cARCF) Then
    ForceDirectories(TempDir + cARCF);
  DFDATAS_Extract(eDataPath.Text, TempDir + cARCF, '', @Progress, @CreateError, @CancelPressed);
  If CancelPressed Then GoTo TEMPCLEAR;

STEP2:
SetStep(2); // Извлечение архивов
  DF_ExtractAll(TempDir + cARCF, TempDir + cDFF, '', @Progress, @CreateError, @CancelPressed, 68);
  If CancelPressed Then GoTo TEMPCLEAR;

SetStep(3); // Применение патча
  ApplyIPSPatches(TempDir + cIPSF, TempDir + cDFF);
  If CancelPressed Then GoTo TEMPCLEAR;



SetStep(4); // Сборка архивов
  If DF_BuildAll(TempDir + cDFF + 'LIST.HDS', TempDir + cARCF, TempDir + cDFF + 'Tex_jimaku\', True,
  @Progress, @CreateError, @CancelPressed) > 0 Then
    MessageDlg('При сборке архивов произошли ошибки. Правильная работа игры не гарантируется.',
      mtError, [mbOK], 0); 
  If CancelPressed Then GoTo TEMPCLEAR;

STEP5:
SetStep(5); // Сборка архива
  If DFDATAS_Build(TempDir + cARCF + 'LIST.LST', eDataPath.Text, TempDir + cARCF, false, @Progress,
      @CreateError, @CancelPressed) > 0 Then
        MessageDlg('При сборке архива произошли ошибки. Правильная работа игры не гарантируется.',
          mtError, [mbOK], 0);;


TEMPCLEAR:
SetStep(6); // Чистка темпов

  eCurrentAction.Caption    := 'Программа удаляет все временные файлы...';
  Application.ProcessMessages;
  DeleteFile  (TempDir + cIPS);
  DeleteFolder(TempDir + cIPSF);
  eCurrentProgress.Position := eCurrentProgress.Max;
  Application.ProcessMessages;
  DeleteFolder(TempDir + cARCF);
  DeleteFolder(TempDir + cDFF);

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

  eDataPath.Enabled     := True;
  eTempPath.Enabled    := True;
  bSelDataPath.Enabled  := True;
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

procedure TMainForm.bSelDataPathClick(Sender: TObject);
begin
  If not OpenDataDialog.Execute Then Exit;
  eDataPath.Text := OpenDataDialog.FileName;
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
