unit GZipMen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, XPMan, ToolWin, ActnList, ImgList, StdCtrls, FF7_Compression;

type
  TBinForm = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolBar1: TToolBar;
    XPManifest1: TXPManifest;
    MainMenu1: TMainMenu;
    N8: TMenuItem;
    N9: TMenuItem;
    GZip1: TMenuItem;
    N10: TMenuItem;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ImageList1: TImageList;
    ActionList1: TActionList;
    AOpenFile: TAction;
    ASaveFile: TAction;
    ASaveAs: TAction;
    ACloseFile: TAction;
    AExtractFile: TAction;
    AExtractGZip: TAction;
    AReplaceFile: TAction;
    FileList: TListBox;
    Label1: TLabel;
    AExit: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    procedure AOpenFileExecute(Sender: TObject);
    procedure ASaveFileExecute(Sender: TObject);
    procedure ASaveAsExecute(Sender: TObject);
    procedure ACloseFileExecute(Sender: TObject);
    procedure AExtractFileExecute(Sender: TObject);
    procedure AExitExecute(Sender: TObject);
    procedure AExtractGZipExecute(Sender: TObject);
    procedure AReplaceFileExecute(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BinForm: TBinForm;

implementation

{$R *.dfm}


var
  GZip: TBinFile;
  OpenedFile: String;

Procedure ShowFiles;
var n: Integer;
begin
  BinForm.FileList.Clear;
  For n:=0 To GZip.Count-1 do BinForm.FileList.Items.Add(Format('%d%s%d%s%d%s%s',
  [n,^I,GZip.Files[n].Size,^I,GZip.Files[n].USize,^I,IntToHex(GZip.Position[n],8)]));
  BinForm.FileList.ItemIndex:=0;
end;

procedure TBinForm.AOpenFileExecute(Sender: TObject);
begin
  //GZip:=TBinFile.Create;
  OpenDialog.FileName:='';
  OpenDialog.Filter:='BIN-архивы (*.BIN)|*.BIN|Все файлы (*.*)|*';
  If OpenDialog.Execute and FileExists(OpenDialog.FileName) Then
  begin
    ACloseFileExecute(Sender);
    GZip.LoadFromFile(OpenDialog.FileName);
    If GZip.Count<=0 Then
    begin
      ACloseFileExecute(Sender);
      ShowMessage('Файл повреждён или не является архивом!');
      Exit;
    end;
    OpenedFile:=OpenDialog.FileName;
    ShowFiles;
    ASaveFile.Enabled:=True;
    ASaveAs.Enabled:=True;
    ACloseFile.Enabled:=True;
    AExtractFile.Enabled:=True;
    AReplaceFile.Enabled:=True;
    AExtractGZip.Enabled:=True;
  end;
  FileList.ItemIndex:=0;
end;

procedure TBinForm.ASaveFileExecute(Sender: TObject);
begin
  If OpenedFile<>'' Then GZip.SaveToFile(OpenedFile);
end;

procedure TBinForm.ASaveAsExecute(Sender: TObject);
begin
  SaveDialog.FileName:=ExtractFileName(OpenedFile);
  SaveDialog.Filter:='BIN-архивы (*.BIN)|*.BIN|Все файлы (*.*)|*';
  If SaveDialog.Execute Then
  begin
    GZip.SaveToFile(SaveDialog.FileName);
    OpenedFile:=SaveDialog.FileName;
  end;
end;

procedure TBinForm.ACloseFileExecute(Sender: TObject);
begin
  If not Assigned(GZip) Then
  begin
    GZip.Free;
    GZip:=TBinFile.Create;
  end;
  ASaveFile.Enabled:=False;
  ASaveAs.Enabled:=False;
  ACloseFile.Enabled:=False;
  AExtractFile.Enabled:=False;
  AReplaceFile.Enabled:=False;
  AExtractGZip.Enabled:=False;
  FileList.Clear;
end;

procedure TBinForm.AExtractFileExecute(Sender: TObject);
begin
  SaveDialog.Filter:='Все файлы (*.*)|*';
  SaveDialog.FileName:=Format('File%d',[FileList.ItemIndex]);
  If SaveDialog.Execute Then GZip.ExtractFile(FileList.ItemIndex,SaveDialog.FileName);
end;

procedure TBinForm.AExitExecute(Sender: TObject);
begin
  BinForm.Close;
end;

procedure TBinForm.AExtractGZipExecute(Sender: TObject);
begin
  SaveDialog.Filter:='Архивы GZip (*.gz)|*.gz|Все файлы (*.*)|*';
  SaveDialog.FileName:=Format('File%d.gz',[FileList.ItemIndex]);
  If SaveDialog.Execute Then GZip.ExtractGZip(FileList.ItemIndex,SaveDialog.FileName);
end;

procedure TBinForm.AReplaceFileExecute(Sender: TObject);
begin
  OpenDialog.Filter:='Все файлы (*.*)|*';
  OpenDialog.FileName:=Format('File%d',[FileList.ItemIndex]);
  If OpenDialog.Execute Then GZip.ReplaceFile(FileList.ItemIndex,OpenDialog.FileName);
  ShowFiles;
end;

initialization
  GZip:=TBinFile.Create;
finalization
  GZip.Free;
end.
