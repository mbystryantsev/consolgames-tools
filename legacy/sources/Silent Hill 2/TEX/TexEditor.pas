unit TexEditor;

interface

{$INCLUDE config.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SH2_Tex, StdCtrls, ActnList, Menus, ExtCtrls, ExtDlgs, ComCtrls,
  ToolWin, ImgList, XPMan, Spin;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    ActionList: TActionList;
    aOpen: TAction;
    OpenTexDialog: TOpenDialog;
    Open1: TMenuItem;
    SaveBitmapDialog: TSavePictureDialog;
    aExportImage: TAction;
    SaveBitmap1: TMenuItem;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ImageList: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    aNext: TAction;
    StatusBar: TStatusBar;
    aPrev: TAction;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    NextFile1: TMenuItem;
    PreviousFile1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    aExit: TAction;
    Exit1: TMenuItem;
    ToolButton6: TToolButton;
    aAlpha: TAction;
    ToolButton7: TToolButton;
    View1: TMenuItem;
    ShowAlpha1: TMenuItem;
    ToolButton8: TToolButton;
    aChecker: TAction;
    ShowChecker1: TMenuItem;
    XPManifest1: TXPManifest;
    aImportImage: TAction;
    ToolButton9: TToolButton;
    OpenPictureDialog: TOpenDialog;
    N3: TMenuItem;
    ExportImage1: TMenuItem;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    aSave: TAction;
    aSaveAs: TAction;
    SaveTexDialog: TSaveDialog;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    aPrevPal: TAction;
    aNextPal: TAction;
    Image: TImage;
    ePalNum: TSpinEdit;
    Label1: TLabel;
    aNextMap: TAction;
    aPrevMap: TAction;
    procedure aOpenExecute(Sender: TObject);
    procedure aExportImageExecute(Sender: TObject);
    procedure aNextExecute(Sender: TObject);
    procedure aPrevExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure aExitExecute(Sender: TObject);
    procedure aAlphaExecute(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure aCheckerExecute(Sender: TObject);
    procedure aImportImageExecute(Sender: TObject);
    procedure aSaveAsExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure ePalNumChange(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure aNextMapExecute(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private             
    FFileName: String;
    FMapFileName: String;
    FTextureIndex: Integer;
    FTextureCount: Integer;
    FMapOpened: Boolean;
    FSelRect: TRect;
  published
    procedure OpenTex(FileName: String);
    Function  OpenMap(FileName: String; Index: Integer = 0; Silent: Boolean = False): Boolean;
    procedure ShowImage;
    procedure DrawChecker;
    procedure UpdateInterface;
    procedure DrawSelRect;
  end;

var
  MainForm: TMainForm;
  Tex: TTex;

implementation

{$R *.dfm}



procedure TMainForm.aOpenExecute(Sender: TObject);
begin
  If not OpenTexDialog.Execute Then Exit;
  Case OpenTexDialog.FilterIndex of
    1: OpenTex(OpenTexDialog.FileName);
    2: OpenMap(OpenTexDialog.FileName);
  end;
end;

procedure TMainForm.aExportImageExecute(Sender: TObject);
var Name: String;
const Exts: Array[0..2{$IFDEF PNG}+1{$ENDIF}] of String = ('.bmp', '.tga', '.tm2'{$IFDEF PNG}, '.png'{$ENDIF});
begin
  If not SaveBitmapDialog.Execute Then Exit;
  Name := ChangeFileExt(SaveBitmapDialog.FileName, Exts[SaveBitmapDialog.FilterIndex-1]);
  Case SaveBitmapDialog.FilterIndex of
    1: Tex.Bitmap.SaveToFile(Name);
    2: Tex.SaveToTGA(Name);
    3: Tex.SaveToTIM2(Name);
    {$IFDEF PNG}
    4: Tex.PNG.SaveToFile(Name);
    {$ENDIF}
  end;
end;

procedure TMainForm.aNextExecute(Sender: TObject);
var SR: TSearchRec; S, Name, Dir: String; Flag: Boolean;
begin
  If FMapOpened Then
  begin
    If FTextureIndex < FTextureCount - 1 Then
      OpenMap(FFileName, FTextureIndex + 1);
    Exit;
  end;
  If FFileName = '' Then Exit;
  Dir := ExtractFilePath(FFileName);
  If FindFirst(Dir + '*.tex', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
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
    OpenTex(Dir + Name);
end;

procedure TMainForm.OpenTex(FileName: String);
begin
  Tex.LoadFromFile(FileName);
  SaveBitmapDialog.FileName := ChangeFileExt(FileName, '.bmp');
  FMapOpened := False;
  FFileName := FileName;
  ShowImage;
  UpdateInterface;
end;

Function TMainForm.OpenMap(FileName: String; Index: Integer = 0; Silent: Boolean = False): Boolean;
var Count: Integer;
begin
  Result := False;
  Count := Tex.ImportFromMap(FileName, Index);
  If Count <> 0 Then
  begin
    FTextureCount := Count;
    FMapOpened := True;
    FTextureIndex := Index;
    FFileName := FileName;
    ShowImage;
    UpdateInterface;
    Result := True;
  end else
    If not Silent Then
      MessageDlg('File contain no textures!', mtInformation, [mbOK], 0);
end;


procedure TMainForm.aPrevExecute(Sender: TObject);
var SR: TSearchRec; S, Name, Dir: String;
begin
  If FMapOpened Then
  begin
    If FTextureIndex > 0 Then
      OpenMap(FFileName, FTextureIndex - 1);
    Exit;
  end;
  If FFileName = '' Then Exit;
  Dir := ExtractFilePath(FFileName);
  If FindFirst(Dir + '*.tex', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
  S := ExtractFileName(FFileName);
  repeat
    If S = SR.Name Then
      break;
    Name := SR.Name;
  until FindNext(SR) <> 0;
  FindClose(SR);
  If (Name <> '') and (Name <> S) Then
    OpenTex(Dir + Name);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  {$IFDEF PNG}
  SaveBitmapDialog.Filter := SaveBitmapDialog.Filter + '|PNG Bitmap (*.png)|*.png';
  {$ELSE}
  aAlpha.Visible := False;
  aChecker.Visible := False;
  {$ENDIF}
end;

procedure TMainForm.aExitExecute(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.aAlphaExecute(Sender: TObject);
begin
  {$IFDEF PNG}
  TAction(Sender).Checked := not TAction(Sender).Checked;
  ShowImage;
  {$ENDIF}
end;

procedure TMainForm.ShowImage;
begin
{$IFNDEF PNG}
  Image.Picture.Graphic := Tex.Bitmap;
{$ELSE}
  If aAlpha.Checked Then
    Image.Picture.Graphic := Tex.PNG
  else
    Image.Picture.Graphic := Tex.Bitmap;
{$ENDIF}           
  StatusBar.Panels[0].Text := Format('%dbpp', [Tex.BitCount]);
  StatusBar.Panels[1].Text := Format('%dx%d, ID: %d', [Tex.Width, Tex.Height, Tex.FLayerHeader.lhTexID]);
  If Tex.BitCount = 32 Then
    StatusBar.Panels[2].Text := ''
  else
    StatusBar.Panels[2].Text := Format('Pal: %d/%d', [ePalNum.Value, Tex.PalCount - 1]);
  If FMapOpened Then                      
    StatusBar.Panels[4].Text := Format('Tex: %d/%d, %s:%d', [FTextureIndex, FTextureCount - 1, FFileName, FTextureIndex])
  else
    StatusBar.Panels[4].Text := FFileName;
end;

procedure TMainForm.DrawChecker;
var XX, YY, X, Y, W, H: Integer; YC, C: Boolean;
const
  Size = 16;
  Color: Array[Boolean] of Integer = ($999999, $BABABA);
begin
  YC := False;
  XX := Image.Left;
  YY := Image.Top;
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psSolid;
  For Y := 0 To (Tex.Height div Size) - 1 do
  begin
    C := YC;
    YC := not YC;
    For X := 0 To (Tex.Width div Size) - 1 do
    begin
      Canvas.Brush.Color := Color[C];
      Canvas.Pen.Color := Color[C];
      C := not C;
      Canvas.Rectangle(Bounds(XX + X * Size, YY + Y * Size, Size, Size));
    end;
  end;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  If aChecker.Checked and aAlpha.Checked Then
    DrawChecker;
end;

procedure TMainForm.aCheckerExecute(Sender: TObject);
begin  
  {$IFDEF PNG}
  TAction(Sender).Checked := not TAction(Sender).Checked;
  ShowImage;
  {$ENDIF}
end;

procedure TMainForm.aImportImageExecute(Sender: TObject);
begin
  If not OpenPictureDialog.Execute Then Exit;
  Tex.ImportFromFile(OpenPictureDialog.FileName);
  ShowImage; 
end;

procedure TMainForm.aSaveAsExecute(Sender: TObject);
begin
  If not SaveTexDialog.Execute Then Exit;
  Tex.SaveToFile(SaveTexDialog.FileName);
end;

procedure TMainForm.aSaveExecute(Sender: TObject);
begin
  If FFileName <> '' Then
    Tex.SaveToFile(FFileName);
end;

procedure TMainForm.ePalNumChange(Sender: TObject);
begin
  If ePalNum.MaxValue = 0 Then Exit;
  If ePalNum.Value < 0 Then
    ePalNum.Value := 0
  else If ePalNum.Value > ePalNum.MaxValue Then
    ePalNum.Value := ePalNum.MaxValue;
  Tex.LoadTexPalette(ePalNum.Value);
  {$IFDEF PNG}
  Tex.DIB2PNG;
  {$ENDIF}
  ShowImage;
end;

procedure TMainForm.UpdateInterface;
begin
  aNext.Enabled        := True;
  aPrev.Enabled        := True;
  aExportImage.Enabled := True;
  aImportImage.Enabled := True;
  aSave.Enabled        := True;
  aSaveAs.Enabled      := True;
  If (Tex.BitCount = 32) or (Tex.PalCount = 1) Then
  begin
    ePalNum.Value := 0;      
    ePalNum.Enabled := False;
  end else
  begin
    //ePalMax.Caption  := Format(' /%d', [Tex.PalCount - 1]);
    ePalNum.MinValue := 0;
    ePalNum.MaxValue := Tex.PalCount - 1;
    ePalNum.Value := 0;
    ePalNum.Enabled := True;
  end;
end;

procedure TMainForm.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var OldRect: TRect;
begin
  StatusBar.Panels[3].Text := Format('X: %d; Y: %d', [X, Y]);
  If ssLeft in Shift Then
  begin
    OldRect := FSelRect;
    If (X >= Tex.Width)  Then X := Tex.Width  - 1;
    If (Y >= Tex.Height) Then Y := Tex.Height - 1;
    
  end;
end;

procedure TMainForm.aNextMapExecute(Sender: TObject);  
var SR: TSearchRec; S, Name, Dir: String; Flag: Boolean;
begin
  If not FMapOpened Then Exit;
  If FFileName = '' Then Exit;
  Dir := ExtractFilePath(FFileName);
  If FindFirst(Dir + '*.map', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
  Flag := False;                    
  S := ExtractFileName(FFileName);
  Name := S;
  repeat
    If Flag Then
    begin           
      Name := SR.Name;
      If OpenMap(Dir + Name, 0, True) Then
        break;
    end;
    If S = SR.Name Then
      Flag := True;
  until FindNext(SR) <> 0;
  FindClose(SR);
end;

procedure TMainForm.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FSelRect := Bounds(X, Y, 8, 8);
  DrawSelRect;
end;

procedure TMainForm.DrawSelRect;
begin
  Image.Repaint;
  With Canvas  do
  begin
    Brush.Style := bsClear;
    Pen.Style := psSolid;
    Pen.Color := clRed;
    With FSelRect do
      Rectangle(Left + Image.Left, Top + Image.Top, Right + Image.Left, Bottom + Image.Top);
  end;
end;

Initialization
  Tex := TTex.Create;
Finalization
  Tex.Free;
end.
