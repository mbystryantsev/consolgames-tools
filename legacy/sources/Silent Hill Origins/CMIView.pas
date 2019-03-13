unit CMIView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Menus, ExtCtrls, ExtDlgs, CMIUnit, PSPRAW, DIB_classic, ComCtrls, StrUtils,
  StdCtrls;
var CMI: TCMI;
type
  TForm1 = class(TForm)
    Img: TImage;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    fOpen: TAction;
    fSave: TAction;
    eSaveBG: TAction;
    eSaveLayer0: TAction;
    eSaveLayer1: TAction;
    eLoadLayer0: TAction;
    eLoadLayer1: TAction;
    File1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    eSaveBG1: TMenuItem;
    eSaveLayer01: TMenuItem;
    eSaveLayer11: TMenuItem;
    eLoadLayer01: TMenuItem;
    eLoadLayer11: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Op: TOpenDialog;
    Sv: TSaveDialog;
    OpP: TOpenPictureDialog;
    Status: TStatusBar;
    SvP: TSavePictureDialog;
    eSaveTiles: TAction;
    eSaveTiles1: TMenuItem;
    View1: TMenuItem;
    Layer01: TMenuItem;
    Layer11: TMenuItem;
    BG1: TMenuItem;
    iles1: TMenuItem;
    All1: TMenuItem;
    aSaveAs: TAction;
    N2: TMenuItem;
    MaxLevel01: TMenuItem;
    MaxLevel11: TMenuItem;
    eMaxLV0: TAction;
    eMaxLV1: TAction;
    eSetGrid: TAction;
    aAbout: TAction;
    Method1: TMenuItem;
    ePMAbstract: TAction;
    ePMGrid: TAction;
    ePMColumns: TAction;
    Abstract1: TMenuItem;
    Columns1: TMenuItem;
    Columns2: TMenuItem;
    Rows1: TMenuItem;
    ePMRows: TAction;
    eClearPM: TAction;
    ePMColRow: TAction;
    ePMColRow1: TMenuItem;
    SaveDialog: TSaveDialog;
    procedure fOpenExecute(Sender: TObject);
    procedure ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure eSaveLayer0Execute(Sender: TObject);
    procedure eSaveLayer1Execute(Sender: TObject);
    procedure eSaveBGExecute(Sender: TObject);
    procedure fSaveExecute(Sender: TObject);
    procedure eSaveTilesExecute(Sender: TObject);
    procedure iles1Click(Sender: TObject);
    procedure BG1Click(Sender: TObject);
    procedure Layer11Click(Sender: TObject);
    procedure Layer01Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure eLoadLayer0Execute(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure All1Click(Sender: TObject);
    procedure aSaveAsExecute(Sender: TObject);
    procedure eMaxLV0Execute(Sender: TObject);
    procedure eMaxLV1Execute(Sender: TObject);
    procedure eLoadLayer1Execute(Sender: TObject);
    procedure eSetGridExecute(Sender: TObject);
    procedure aAboutExecute(Sender: TObject);
    procedure ePMAbstractExecute(Sender: TObject);
    procedure ePMGridExecute(Sender: TObject);
    procedure ePMColumnsExecute(Sender: TObject);
    procedure ImgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImgClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ePMRowsExecute(Sender: TObject);
    procedure eClearPMExecute(Sender: TObject);
    procedure ePMColRowExecute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
 
var Layer0, Layer1, BG, Tiles, pMap: TDIB; OpenedFile: String;  OptTiles: TDIB;
Method: TPackingMethod = pmColRow;//pmAbstract;

implementation

uses PrForm;
var LClick: Boolean=False;
    ClickX,ClickY: Integer;

{$R *.dfm}
{Procedure Progress(I,M: Integer);
begin
  Form1.Caption:=Format('%d/%d',[I,M]);
  Application.ProcessMessages;
end;}

procedure TForm1.fOpenExecute(Sender: TObject);
var Head: TCMIHeader; Pal: Array[0..2,0..15] of DWord; F: File;
begin
  If not (Op.Execute and FileExists(Op.FileName)) Then Exit;
  CMI.LoadFromFile(Op.FileName);
  OpenedFile:=Op.FileName;
  CMI.GetLayers(BG,Tiles,Layer0,Layer1);
  CMI.BuildMap(pMap,Layer0,Layer1,BG);
  SetPallete(OPtTiles,CMI.Pal[0]);
  Img.Picture.Graphic:=pMap;

  aSaveAs.Enabled := True;
  fSave.Enabled := True;
  eSaveBG.Enabled := True;
  eSaveLayer0.Enabled := True;
  eSaveLayer1.Enabled := True;
  eSaveTiles.Enabled := True;
  eLoadLayer0.Enabled := True;
  eLoadLayer1.Enabled := True;
  All1.Enabled := True;
  Layer01.Enabled := True;
  Layer11.Enabled := True;
  BG1.Enabled := True;
  iles1.Enabled := True;


end;

procedure TForm1.ImgMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
//  Status.Panels.Items[0].Text:=Format('X: %d',[X]);
//  Status.Panels.Items[1].Text:=Format('Y: %d',[Y]);
//  Form1.Caption:=Format('X: %d; Y: %d',[X,Y]);
//  If ClickX+X<=1920 Then Form1.HorzScrollBar.Position := ClickX+X;
end;

procedure TForm1.eSaveLayer0Execute(Sender: TObject);
begin
  SvP.FileName:=ExtractFileName(OpenedFile);
  SvP.FileName:=LeftStr(SvP.FileName,Length(SvP.FileName)-4)+'_0.bmp';
  If SvP.Execute Then
  begin
    Layer0.SaveToFile(SvP.FileName);
  end;
end;

procedure TForm1.eSaveLayer1Execute(Sender: TObject);
begin
  SvP.FileName:=ExtractFileName(OpenedFile);
  SvP.FileName:=LeftStr(SvP.FileName,Length(SvP.FileName)-4)+'_1.bmp';
  If SvP.Execute Then
  begin
    Layer1.SaveToFile(SvP.FileName);
  end;
end;

procedure TForm1.eSaveBGExecute(Sender: TObject);
begin
  SvP.FileName:=ExtractFileName(OpenedFile);
  SvP.FileName:=LeftStr(SvP.FileName,Length(SvP.FileName)-4)+'_BG.bmp';
  If SvP.Execute Then
  begin
    BG.SaveToFile(SvP.FileName);
  end;
end;

Procedure OptProgress(ID,Layer: Integer);
begin
  Form1.Caption := Format('[%.3d%%; Layer %d, ID: %d/%d]',[100*((ID div High(Layer))),Layer,ID,High(CMI.Layer0)]);
  //CMI.LayerToDib(OptTiles,2);
  Form1.Img.Picture.Graphic := OptTiles;
  Application.ProcessMessages;
end;

procedure TForm1.fSaveExecute(Sender: TObject);
var P: TDIB; C: ^TRGBQuads; I,Bad,l0,l1: Integer;
begin
  If not CMI.Optimized Then
  begin
    SetPal(pT,CMI.Pal[1]);
    pT.ColorTable[255].rgbGreen := 255;
    pT.ColorTable[255].rgbRed   := 0;
    pT.ColorTable[255].rgbBlue :=  0;
    pT.UpdatePalette;

    ProgressForm.eLevel0.Max := 8160;
    ProgressForm.eLevel1.Max := 2040;
    ProgressForm.eLevel0.Min := 1;
    ProgressForm.eLevel1.Min := 1;

    @CMI.OptimizeProgress := @ShowProgress;//@OptProgress;
    ProgressForm.Show;
    If eMaxLV0.Checked Then l0:=8160 else l0:=1;
    If eMaxLV1.Checked Then l1:=2040 else l1:=1;
    CMI.Optimize(Layer0,Layer1,Method,l0,l1);
  end;
  CMI.SaveToFile(Op.FileName);
end;

procedure TForm1.eSaveTilesExecute(Sender: TObject);
begin
  SvP.FileName:=ExtractFileName(OpenedFile);
  SvP.FileName:=LeftStr(SvP.FileName,Length(SvP.FileName)-4)+'_Tiles.bmp';
  If SvP.Execute Then
  begin
    Tiles.SaveToFile(SvP.FileName);
  end;
end;

procedure TForm1.iles1Click(Sender: TObject);
begin
  Img.Width:=Tiles.Width;
  Img.Height:=Tiles.Height;
  Img.Picture.Graphic:=Tiles;
end;

procedure TForm1.BG1Click(Sender: TObject);
begin
  Img.Width:=BG.Width;
  Img.Height:=BG.Height;
  Img.Picture.Graphic:=BG;
end;

procedure TForm1.Layer11Click(Sender: TObject);
begin
  Img.Width:=Layer1.Width;
  Img.Height:=Layer1.Height;
  Img.Picture.Graphic:=Layer1;
end;

procedure TForm1.Layer01Click(Sender: TObject);
begin
  Img.Width:= Layer0.Width;
  Img.Height:=Layer0.Height;
  Img.Picture.Graphic:=Layer0;
  
end;

procedure TForm1.Button2Click(Sender: TObject);
var P: TDIB; B: ^Byte; n,m: Integer;
begin


end;

procedure TForm1.eLoadLayer0Execute(Sender: TObject);
var n: Integer;
begin
  If OpP.Execute And FileExists(OpP.FileName) Then
  begin
    Layer0.LoadFromFile(OpP.FileName);
    Img.Picture.Graphic:=Layer0;
    CMI.Optimized := False;
    GetPal(Layer0,CMI.Pal[1]);
    CMI.BuildMap(pMap,Layer0,Layer1,BG);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var Pic: TDIB;
begin

end;

procedure TForm1.All1Click(Sender: TObject);
begin
  Img.Width:= pMap.Width;
  Img.Height:=pMap.Height;
  Img.Picture.Graphic:=pMap;
end;

procedure TForm1.aSaveAsExecute(Sender: TObject);
begin
  SaveDialog.FileName:=ExtractFileName(Op.FileName);
  If SaveDialog.Execute Then
  begin
    Op.FileName := SaveDialog.FileName;
    fSaveExecute(Sender);
  end;
end;

procedure TForm1.eMaxLV0Execute(Sender: TObject);
begin
  eMaxLV0.Checked := not eMaxLV0.Checked;
end;

procedure TForm1.eMaxLV1Execute(Sender: TObject);
begin
  eMaxLV1.Checked := not eMaxLV1.Checked;
end;

procedure TForm1.eLoadLayer1Execute(Sender: TObject);
begin
  If OpP.Execute And FileExists(OpP.FileName) Then
  begin
    Layer1.LoadFromFile(OpP.FileName);
    Img.Picture.Graphic:=Layer1;
    CMI.Optimized := False;
    CMI.BuildMap(pMap,Layer0,Layer1,BG);
  end;
end;

procedure TForm1.eSetGridExecute(Sender: TObject);
begin
  eSetGrid.Checked := not eSetGrid.Checked;
end;

procedure TForm1.aAboutExecute(Sender: TObject);
begin
  ShowMessage('CMIViewer 1.0 by HoRRoR <ho-rr-or@mail.ru>'#13#10+
  'http://consolgames.ru/');
end;

procedure TForm1.ePMAbstractExecute(Sender: TObject);
begin
  eClearPMExecute(Sender);
  ePMAbstract.Checked := True;
  Method := pmAbstract;
end;

procedure TForm1.ePMGridExecute(Sender: TObject);
begin  
  eClearPMExecute(Sender);
  ePMGrid.Checked := True;
  Method := pmGrid;
end;

procedure TForm1.ePMColumnsExecute(Sender: TObject);
begin       
  eClearPMExecute(Sender);
  ePMColumns.Checked := True;
  Method := pmColumns;
end;

procedure TForm1.ImgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//  LClick:=True;
//  ClickX:=X; ClickY:=Y;
end;

procedure TForm1.ImgMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//  LClick:=False;
end;

procedure TForm1.ImgClick(Sender: TObject);
begin
  LClick:=False;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  LClick:=True;
  ClickX:=X; ClickY:=Y;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  LClick:=False;
end;

procedure TForm1.ePMRowsExecute(Sender: TObject);
begin
  eClearPMExecute(Sender);
  ePMRows.Checked := True;
  Method := pmRows;
end;

procedure TForm1.eClearPMExecute(Sender: TObject);
begin
  ePMAbstract.Checked := False;
  ePMGrid.Checked     := False;
  ePMColumns.Checked  := False;
  ePMRows.Checked     := False;
  ePMColRow.Checked   := False;
end;

procedure TForm1.ePMColRowExecute(Sender: TObject);
begin
  eClearPMExecute(Sender);
  ePMColRow.Checked := True;
  Method := pmColRow;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;

Initialization
  CMI:=TCMI.Create;
  OptTiles:=TDIB.Create;
  CMI.AssignLayer(OptTiles,512,512,8);
Finalization
  CMI.Free;
  pMap.Free;
  Layer0.Free;
  Layer1.Free;
  Tiles.Free;
end.
