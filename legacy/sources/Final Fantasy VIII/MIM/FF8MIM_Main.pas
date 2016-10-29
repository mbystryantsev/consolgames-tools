unit FF8MIM_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FF8_MIM, ActnList, Menus, ComCtrls, XPMan,
  ToolWin, ImgList, ExtDlgs;

type
  TMainForm = class(TForm)
    TexPic: TImage;
    eTexture: TComboBox;
    ePalette: TComboBox;
    FieldImage: TImage;
    eFrame: TComboBox;
    ActionList: TActionList;
    ActionOpen: TAction;
    OpenDialog: TOpenDialog;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    ToolBar1: TToolBar;
    XPManifest: TXPManifest;
    ToolButton1: TToolButton;
    ImageList: TImageList;
    ActionOpen1: TMenuItem;
    SaveImage1: TMenuItem;
    ASaveImage: TAction;
    ToolButton2: TToolButton;
    eAnim: TComboBox;
    eBG: TCheckBox;
    StatusBar: TStatusBar;
    SavePictureDialog: TSavePictureDialog;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    APrevFile: TAction;
    ASaveTexture: TAction;
    SaveTexture1: TMenuItem;
    ToolButton6: TToolButton;
    ANextFile: TAction;
    eShowAnim: TCheckBox;
    ScrollBarH: TScrollBar;
    ScrollBarV: TScrollBar;
    N1: TMenuItem;
    NextFile1: TMenuItem;
    NextFile2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure eTextureChange(Sender: TObject);
    procedure ePaletteChange(Sender: TObject);
    procedure eFrameChange(Sender: TObject);
    procedure ActionOpenExecute(Sender: TObject);
    procedure eAnimChange(Sender: TObject);
    procedure eBGClick(Sender: TObject);
    procedure ASaveImageExecute(Sender: TObject);
    procedure APrevFileExecute(Sender: TObject);
    procedure ASaveTextureExecute(Sender: TObject);
    procedure eTextureKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ANextFileExecute(Sender: TObject);
    procedure eShowAnimClick(Sender: TObject);
    procedure ScrollBarHChange(Sender: TObject);
  private
    { Private declarations }
  public
    FFileName: String;
    Procedure FillLists;
    procedure FillFrames;
    Procedure DrawTexture;
    Procedure DrawPicture;
    Procedure Open(FileName: String);
  end;

  TAnimInfo = Record
    aiFrame: Integer;
    aiShow:  Boolean;
  end;

var
  MainForm:   TMainForm;
  MIM:        TFF8MIM;
  Animations: Array of TAnimInfo;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MIM := TFF8MIM.Create;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  If MIM <> nil Then MIM.Free;
  MIM := nil;
end;

procedure TMainForm.FillLists;
var n: Integer;
begin
  eTexture.Items.Clear;
  For n := 0 To MIM.TexCount - 1 do
    eTexture.Items.Add(Format('Texture %2.2d', [n]));
  ePalette.Items.Clear;
  For n := 0 To MIM.PalCount - 1 do
    ePalette.Items.Add(Format('Palette %2.2d', [n]));
  eAnim.Clear;
  eAnim.Items.Add('Background');
  For n := 0 To MIM.AnimationCount - 1 do
    eAnim.Items.Add(Format('Animation %2.2d', [n]));
  eTexture.ItemIndex := 0;
  ePalette.ItemIndex := 8;
  eAnim.ItemIndex   := 0;
  eFrame.Enabled := False;
  DrawTexture;
  eAnim.Enabled := MIM.AnimationCount > 0;
end;

procedure TMainForm.eTextureChange(Sender: TObject);
begin
  DrawTexture;
end;

procedure TMainForm.ePaletteChange(Sender: TObject);
begin
   DrawTexture;
end;

procedure TMainForm.DrawTexture;
begin
  With MIM, Tiles do
  begin
    ColorTable := Palettes[ePalette.ItemIndex];
    UpdatePalette;
    TexPic.Canvas.CopyRect(Bounds(0, 0, 128, 256), Tiles.Canvas,
      Bounds(eTexture.ItemIndex * 128, 0, 128, 256));
    //TexPic.Canvas.StretchDraw(Bounds(0, 0, 128, 256), Tiles);
  end;
end;

procedure TMainForm.DrawPicture;
var n: Integer; S: Set of Byte; F: Array of Byte; W, H: Integer;
begin

  S := [];
  SetLength(F, Length(Animations));
  If eAnim.ItemIndex > 0 Then
  begin
    S := [eAnim.ItemIndex - 1];
    F[eAnim.ItemIndex - 1] := Animations[eAnim.ItemIndex - 1].aiFrame;
  end;
  For n := 0 To High(Animations) do With Animations[n] do
  begin
    If aiShow Then
    begin
      S := S + [n];
      F[n] := aiFrame;
    end;
  end;
  If eBG.Checked or (eAnim.ItemIndex = 0) Then
    S := S + [$FF];
  MIM.DrawMap(S, F);

{
  If eAnim.ItemIndex = 0 Then
    MIM.DrawMap(eAnim.ItemIndex - 1, 0, eBG.Checked)
  else
    MIM.DrawMap(eAnim.ItemIndex - 1, eFrame.ItemIndex, eBG.Checked);
}
  W := MIM.Width  - ScrollBarH.Position * 16;
  H := MIM.Height - ScrollBarV.Position * 16;
  If W > 640 Then W := 640;
  If H > 480 Then H := 480;
  FieldImage.Canvas.CopyRect(Bounds(0, 0, W, H), MIM.Image.Canvas,
    Bounds(ScrollBarH.Position * 16, ScrollBarV.Position * 16, W, H));
  FieldImage.Width := W;
  FieldImage.Height := H;
  //FieldImage.Picture.Graphic := MIM.Image;
end;

procedure TMainForm.eFrameChange(Sender: TObject);
begin
  If eAnim.ItemIndex > 0 Then
    Animations[eAnim.ItemIndex - 1].aiFrame := eFrame.ItemIndex;
  DrawPicture;
end;

procedure TMainForm.ActionOpenExecute(Sender: TObject);
begin
  If not OpenDialog.Execute Then Exit;
  Open(OpenDialog.FileName);
end;

procedure TMainForm.Open(FileName: String);
var MapName: String;
begin
  If not FileExists(FileName) Then
  begin
    MessageBox(0, 'File not found!', 'Error!', MB_ICONERROR or MB_OK);
    Exit;
  end;
  MapName := ChangeFileExt(FileName, '.map');
  If not FileExists(MapName) Then
    MapName := ChangeFileExt(FileName, '.dat');
  If not FileExists(MapName) Then
  begin
    MessageBox(0, 'Map file (.dat or .map) not found!', 'Error!', MB_ICONERROR or MB_OK);
    Exit;
  end;
  MIM.LoadMIM(FileName);
  FFileName := FileName;
  MIM.LoadMAP(MapName);
  SetLength(Animations, MIM.AnimationCount);
  FillChar(Animations[0], Length(Animations) * SizeOf(TAnimInfo), 0);

  FillLists;
  FillFrames;
  try               
    ScrollBarH.Position := 0;
    ScrollBarV.Position := 0;
    If MIM.Width > 640 Then
      ScrollBarH.Max := (MIM.Width - 640) div 16;
    If MIM.Height > 480 Then
      ScrollBarV.Max := (MIM.Height - 480) div 16;
    ScrollBarH.Enabled := MIM.Width > 640;
    ScrollBarV.Enabled := MIM.Height > 480;
  finally
    DrawPicture;
    StatusBar.Panels[0].Text := Format('%dx%d', [MIM.Width, MIM.Height]);
    StatusBar.Panels[1].Text := ExtractFileName(FFileName);
  end;
end;

procedure TMainForm.FillFrames;
var n: Integer;
begin
  eFrame.Clear;
  eFrame.Enabled := True;
  For n := 0 To MIM.FrameCount(eAnim.ItemIndex - 1) - 1 do
    eFrame.Items.Add(Format('Frame %2.2d', [n]));
  If eAnim.ItemIndex > 0 Then
    eFrame.ItemIndex := Animations[eAnim.ItemIndex - 1].aiFrame
  else
    eFrame.ItemIndex := 0;  
  If (eAnim.ItemIndex = 0) or (MIM.FrameCount(eAnim.ItemIndex - 1) < 2) Then
  begin
    eFrame.Enabled := False;
    Exit;
  end;
end;

procedure TMainForm.eAnimChange(Sender: TObject);
begin
  FillFrames;
  If eAnim.ItemIndex > 0 Then
    eShowAnim.Checked := Animations[eAnim.ItemIndex - 1].aiShow
  else
    eShowAnim.Checked := True;
  eShowAnim.Enabled := eAnim.ItemIndex > 0;
  DrawPicture;
end;

procedure TMainForm.eBGClick(Sender: TObject);
begin
  DrawPicture;
end;

procedure TMainForm.ASaveImageExecute(Sender: TObject);
var Name: String;
begin
  If FFileName = '' Then Exit;
  Name := ChangeFileExt(ExtractFileName(FFileName), '');
  SavePictureDialog.FileName := Name + '.bmp';

  {
  If eAnim.ItemIndex = 0 Then
    SavePictureDialog.FileName := Name + '_bg.bmp'
  else
    SavePictureDialog.FileName := Format('%s_%2.2d_%2.2d.bmp', [Name, eAnim.ItemIndex - 1, eFrame.ItemIndex]);
  }
  If not SavePictureDialog.Execute Then Exit;
  MIM.Image.SaveToFile(ChangeFileExt(SavePictureDialog.FileName, '.bmp'));
end;

procedure TMainForm.APrevFileExecute(Sender: TObject);
var SR: TSearchRec; S, Name, Dir: String;
begin
  If FFileName = '' Then Exit;
  Dir := ExtractFilePath(FFileName);
  If FindFirst(Dir + '*.mim', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
  S := ExtractFileName(FFileName);
  repeat
    If S = SR.Name Then
      break;
    Name := SR.Name;
  until FindNext(SR) <> 0;
  FindClose(SR);
  If (Name <> '') and (Name <> S) Then
    Open(Dir + Name);
end;

procedure TMainForm.ASaveTextureExecute(Sender: TObject);
begin
  If FFileName = '' Then Exit;
  SavePictureDialog.FileName := ChangeFileExt(FFileName, '') + '_tex.bmp';
  If not SavePictureDialog.Execute Then Exit;
  MIM.Tiles.SaveToFile(ChangeFileExt(SavePictureDialog.FileName, '.bmp'));
end;


procedure TMainForm.eTextureKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key in [37, 39] Then Key := 0;
end;

procedure TMainForm.ANextFileExecute(Sender: TObject);
var SR: TSearchRec; S, Name, Dir: String; Flag: Boolean;
begin
  If FFileName = '' Then Exit;
  Dir := ExtractFilePath(FFileName);
  If FindFirst(Dir + '*.mim', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
  Flag := False;                    
  S := ExtractFileName(FFileName);
  Name := S;
  repeat
    If Flag Then
    begin           
      Name := SR.Name;
      break;
    end;
    If S = SR.Name Then
      Flag := True;
  until FindNext(SR) <> 0;
  FindClose(SR);
  If (Name <> '') and (Name <> S) Then
    Open(Dir + Name);
end;

procedure TMainForm.eShowAnimClick(Sender: TObject);
begin
  If eAnim.ItemIndex > 0 Then
    Animations[eAnim.ItemIndex - 1].aiShow := eShowAnim.Checked;
end;

procedure TMainForm.ScrollBarHChange(Sender: TObject);
begin
  //If (Sender as TScrollBar).Position mod 16 <> 0 Then
  DrawPicture;
end;

end.
