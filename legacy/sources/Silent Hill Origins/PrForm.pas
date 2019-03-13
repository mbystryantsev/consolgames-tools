unit PrForm;

interface

uses
  CMIUnit, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DXDraws,CMIView, DIB_classic, PSPRAW, StdCtrls, ComCtrls, ExtCtrls;

type
  TProgressForm = class(TForm)
    Screen: TDXDraw;
    Button1: TButton;
    ProgressBar: TProgressBar;
    eLevel0: TTrackBar;
    eLevel1: TTrackBar;
    Timer1: TTimer;
    procedure ScreenInitialize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure eLevel0Change(Sender: TObject);
    procedure eLevel1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    //Procedure ShowProgress(Count,ID,LimX,LimY: Integer);
  end;

var
  ProgressForm: TProgressForm;
  pT: TDIB;
  sec: Integer;
  bTime,cTime: TSYSTEMTIME;



Procedure ShowProgress(Count,ID,LimX,LimY,T0,T1: Integer);
implementation

{$R *.dfm}
{$R BG.RES}

var pL0,pL1,pBG: TDIB;
Procedure ShowProgress(Count,ID,LimX,LimY,T0,T1: Integer);
var n,m: Integer; B,WB: ^Byte;
const cL0X = 525; cL0Y = 6; cL1X = 525; cL1Y = 149; cTX = 6;
cTY = 6; cL0S = 2; cL1S = 4; cTS = 1; cCount = 10200;
begin

  pT.ColorTable[255].rgbGreen := 255;
  pT.UpdatePalette;
  ProgressForm.eLevel0.Max := T0;
  ProgressForm.eLevel1.Max := T1;
  ProgressForm.eLevel0.Position := CMI.vLevel0;
  ProgressForm.eLevel1.Position := CMI.vLevel1;

  For n:=0 to 67 do
    Move(CMI.F0[n*120],pL0.ScanLine[n]^,120);
  For n:=0 to 33 do
    Move(CMI.F1[n*60],pL1.ScanLine[n]^,60);
  For m:=0 To 511 do
    Move(CMI.T[m,0],pT.ScanLine[m]^,512);
  ProgressForm.ProgressBar.Position := Count;
  With ProgressForm.Screen, Surface.Canvas do
  begin
    Draw(0,0,pBG);
    CopyRect(Bounds(cL0X,cL0Y,120*cL0S,68*cL0S),pL0.Canvas,Bounds(0,0,120,68));
    CopyRect(Bounds(cL1X,cL1Y, 60*cL1S,34*cL1S),pL1.Canvas,Bounds(0,0,60,34));
    Draw(cTX,cTY,pT);
    Rectangle(cTX-1,cTY-1,cTX+LimX+2,cTY+LimY+2);
    Rectangle(cTX-2,cTY-2,cTX+LimX+3,cTY+LimY+3);
    GetLocalTime(cTime);
    sec:=(cTime.wSecond+cTime.wMinute*60+cTime.wHour*3600)-
    (bTime.wSecond+bTime.wMinute*60+bTime.wHour*3600);
    If sec<0 Then Inc(sec,24*3600);
    With ProgressForm, ProgressBar do
    begin
      TextOut(525+2,300,Format('[%d%%] %d/%d; Last ID: %d; Tiles: %d',
      [Round((((Count-Min)/(cCount-Min))*100)),Count,cCount,ID,cCount-Count]));
      TextOut(525+2,300+16,Format('Level0: %d/%d; Level1: %d/%d',
      [eLevel0.Position,T0,eLevel1.Position,T1]));
      TextOut(525+2,300+32,Format('Time: %.2d:%.2d:%.2d',
      [sec div 3600, (sec-(sec div 3600)*3600) div 60, sec-(sec div 60)*60]));
    end;
    Release;
    Flip;
  end;

  Application.ProcessMessages;
end;

var C: TCMI; Pal: Array[0..1] of DWord = (0,$FF00);
procedure TProgressForm.ScreenInitialize(Sender: TObject);
begin
    Screen.Surface.Canvas.Pen.Color := clRed;
    Screen.Surface.Canvas.Pen.Style := psSolid;//bsClear;
    Screen.Surface.Canvas.Brush.Style := bsClear;//bsClear;
end;

procedure TProgressForm.Button1Click(Sender: TObject);
begin
  bCancel := True;
end;

procedure TProgressForm.eLevel0Change(Sender: TObject);
begin
  CMI.vLevel0 := eLevel0.Position;
end;

procedure TProgressForm.eLevel1Change(Sender: TObject);
begin
  CMI.vLevel1 := eLevel1.Position;
end;

procedure TProgressForm.Timer1Timer(Sender: TObject);
begin
  Application.ProcessMessages;
end;

//var Str: TResourceStream;
Initialization
  C.AssignLayer(pL0,120,68,8);
  C.AssignLayer(pL1,60,34,8);
  C.AssignLayer(pT,512,512,8);
  //Str := TResourceStream.Create(hInstance, 'PROGRESS_BG', PChar('BITMAP'));
  pBG:=TDIB.Create;
  //pBG.LoadFromStream(Str);
  //Str.Free;
  pBG.LoadFromResourceName(hInstance,'PROGRESS_BG');
  SetPallete(pL0,Pal);
  SetPallete(pL1,Pal);

Finalization
  pL0.Free;
  pL1.Free;
  pT.Free;
end.
