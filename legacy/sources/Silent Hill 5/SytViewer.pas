unit SytViewer;

interface

uses
  ImFrame, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SH5_SYT, SH5_SYTGFX, ActnList, Menus,
  ComCtrls, ImgList, ToolWin, SYT_PropDlg, SH5_Common;

type
  TSytForm = class(TForm)
    MainMenu: TMainMenu;
    ActionList1: TActionList;
    OpenSYTDialog: TOpenDialog;
    SaveSYTDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    StatusBar: TStatusBar;
    aOpenSYT: TAction;
    File1: TMenuItem;
    Open1: TMenuItem;
    ImageListSYT: TImageList;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    aExport: TAction;
    N1: TMenuItem;
    Export1: TMenuItem;
    Image: TImage;
    ImageFrame: TImageFrame;
    Import1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Edit1: TMenuItem;
    Useopt1: TMenuItem;
    SYTproporties1: TMenuItem;
    aSetProp: TAction;
    oUseSProp: TAction;
    N2: TMenuItem;
    Exit1: TMenuItem;
    aSave: TAction;
    aSaveAs: TAction;
    aImport: TAction;
    Button1: TButton;
    procedure aOpenSYTExecute(Sender: TObject);
    procedure aExportExecute(Sender: TObject);
    procedure SaveDialogTypeChange(Sender: TObject);
    procedure aSetPropExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure oUseSPropExecute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure aSaveAsExecute(Sender: TObject);
    procedure aImportExecute(Sender: TObject);
  private
    { Private declarations }
  public
    FTexType, FPlatform: Integer;
    FTexName:            String;
    procedure CreateParams(var Params :TCreateParams); override;
    procedure ShowImage;
    { Public declarations }
  end;

var
  SytForm: TSytForm;
  SYT: TSYT;

implementation

{$R *.dfm}

const
  cDXTType: Array[0..6] of String =
 ('ARGB',
  'DXT1',
  'o_O',
  'DXT3',
  'Хуясе о_О',
  'DXT5',
  'Ты чё твариш деман???');
 
  cExportExt: Array[0..3] of String = ('.tga','.png','.dds','.bmp');

procedure TSytForm.aOpenSYTExecute(Sender: TObject);
begin
  If not OpenSYTDialog.Execute Then Exit;
  If SYT.LoadFromFile(OpenSYTDialog.FileName) Then
    ShowImage;
end;

procedure TSytForm.ShowImage;
begin
  {Case SYT.TexType of
    0: FTexType := 0;
    1: FTexType := 1;
    3: FTexType := 2;
    5: FTexType := 3;
  end;}
  FTexType := SYT.TexType;
  FPlatform := Integer(SYT.BigEndian);
  FTexName  := SYT.TexName;
  ImageFrame.Image.Picture.Graphic := SYT.PNG;
  ImageFrame.Image.Width    := SYT.Width;
  ImageFrame.Image.Height   := SYT.Height;
  StatusBar.Top    := SytForm.Height - StatusBar.Height;
  StatusBar.Panels.Items[0].Text :=
  Format('%s %dx%d',[cDXTType[SYT.TexType],SYT.Width,SYT.Height]);
  StatusBar.Panels.Items[1].Text := ExtractFileName(SYT.SytFileName);
end;

procedure TSytForm.aExportExecute(Sender: TObject);
begin
  SaveDialog.FileName := SYT.SYT.TexName;
  If not SaveDialog.Execute Then Exit;
  Case SaveDialog.FilterIndex of
    1: SYT.SaveTGA(ChangeFileExt(SaveDialog.FileName,'.tga'));
    2: SYT.SavePNG(ChangeFileExt(SaveDialog.FileName,'.png'));
    3: SYT.SaveDDS(ChangeFileExt(SaveDialog.FileName,'.dds'));
    4: SYT.SaveBMP(ChangeFileExt(SaveDialog.FileName,'.bmp'));
  end;
end;

procedure TSytForm.CreateParams(var Params :TCreateParams); {override;}
begin
  inherited CreateParams(Params);
  with Params do
    Params.ExStyle := ExStyle or WS_EX_APPWINDOW;
end;

procedure TSytForm.SaveDialogTypeChange(Sender: TObject);
var Dlg: TSaveDialog; H: HWND; szFileName: Array[0..MAX_PATH-1] of Char;
begin
  Dlg := (Sender as TSaveDialog);
  H := GetParent(SaveDialog.Handle);
  H := FindWindowEx(H, 0, PChar('ComboBoxEx32'), nil);
  GetWindowText(H, szFileName, MAX_PATH);    Case Dlg.FilterIndex of
    1: SetWindowText(H, PChar(ChangeFileExt(szFileName,'.tga')));
    2: SetWindowText(H, PChar(ChangeFileExt(szFileName,'.png')));
    3: SetWindowText(H, PChar(ChangeFileExt(szFileName,'.dds')));
    4: SetWindowText(H, PChar(ChangeFileExt(szFileName,'.bmp')));
  end;
end;

procedure TSytForm.aSetPropExecute(Sender: TObject);
begin
  If PropForm.ShowPropSelect(FPlatform, FTexType, FTexName) Then
  begin
    SYT.Generated := False;
    SYT.TexName   := FTexName;
    SYT.TexType   := FTexType;
    SYT.BigEndian := Boolean(FPlatform);
  end;
end;

procedure TSytForm.FormActivate(Sender: TObject);
begin
  If PropForm.Showing Then PropForm.SetFocus;
end;

procedure TSytForm.oUseSPropExecute(Sender: TObject);
begin
  (Sender as TAction).Checked := not (Sender as TAction).Checked;
end;

procedure TSytForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TSytForm.Button1Click(Sender: TObject);
var H: TTGAHeader; F: File; Size: Integer; Hdr: Array[0..$7F] of Byte;
begin
  SYT.Generate;
  

  Exit;
  AssignFile(F,'D:\ct_font01.SYT');
  Reset(F,1);
  Size:=FileSize(F) - $80;
  Seek(F,0);
  BlockRead(F, Hdr, SizeOf(Hdr));
  Seek(F,$80);
  GetMem(H.Data,Size);
  BlockRead(F,H.Data^,Size);
  CloseFile(F);
  H.Width  := 128;
  H.Height := 128;
  SYT.SwizzleData(H.Data,H.Width,H.Height);
  AssignFile(F,'D:\ct_font01_new.SYT');
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F,Hdr,SizeOf(Hdr));
  BlockWrite(F,H.Data^,H.Width*H.Height*4);
  CloseFile(F);

  SYT.LoadFromFile('D:\ct_font01_new.SYT');
  ShowImage;

end;

procedure TSytForm.aSaveExecute(Sender: TObject);
begin
  SYT.SaveSYT(SYT.SytFileName); 
end;

procedure TSytForm.aSaveAsExecute(Sender: TObject);
const cPlEx: Array[Boolean] of String = ('.SYT', 'X2_SYT');
begin
  SaveSYTDialog.FileName := ChangeFileExt(SYT.TexName, cPlEx[SYT.BigEndian]);
  If not SaveSYTDialog.Execute Then Exit;
  SYT.SaveSYT(SaveSYTDialog.FileName);
end;

procedure TSytForm.aImportExecute(Sender: TObject);
var Ex: String;
begin
  If not OpenDialog.Execute Then Exit;
  Ex := GetUpCase(ExtractFileExt(OpenDialog.FileName));
  If Ex = '.TGA' Then
    SYT.LoadTGA(OpenDialog.FileName)
  else If Ex = '.DDS' Then
    SYT.LoadDDS(OpenDialog.FileName);
  If SYT.TexName = '' Then
    SYT.TexName := ChangeFileExt(ExtractFileName(OpenDialog.FileName), '.tga');
  SYT.Generated := False;
  ShowImage;
end;

initialization
  SYT := TSYT.Create;
Finalization
  SYT.Free;
end.
