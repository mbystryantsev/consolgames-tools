unit WinEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DXDraws, FF7_Window, FF7_Common, FF7_Text, ComCtrls,
  ExtCtrls, ActnList;

type
  TWForm = class(TForm)
    WScreen: TDXDraw;
    weX: TEdit;
    weY: TEdit;
    weW: TEdit;
    weH: TEdit;
    Status: TStatusBar;
    AList: TActionList;
    AOnTopSet: TAction;
    YBar: TScrollBar;
    chOnTop: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure WScreenMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WScreenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure weXChange(Sender: TObject);
    procedure weYChange(Sender: TObject);
    procedure weWChange(Sender: TObject);
    procedure weHChange(Sender: TObject);
    procedure AOnTopSetExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure YBarChange(Sender: TObject);

  private
    { Private declarations }
  public
    ScrW,ScrH: Integer;
    { Public declarations }
  end;

var
  WForm: TWForm;
  weCoord: Boolean;
  
implementation

{$R *.dfm}

uses FF7_TextEditor;

procedure TWForm.Button1Click(Sender: TObject);
begin

  WScreen.Surface.Canvas.Brush.Color:=$00FF0000;
  WScreen.Surface.Canvas.Rectangle(0,0,32,32);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
end;

var Win: TWin; Rs: TResize;

procedure TWForm.Button2Click(Sender: TObject);
var  Rect: TRect;
begin
  WScreen.Surface.Canvas.Brush.Color:=$00666666;
  Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
  WScreen.Surface.Canvas.FillRect(Rect);
  MWin^.X:=StrToInt(weX.Text);
  MWin^.Y:=StrToInt(weY.Text);
  MWin^.W:=StrToInt(weW.Text);
  MWin^.H:=StrToInt(weH.Text);
  DrawWindow(MWin^, WScreen);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
end;





procedure TWForm.WScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var Rect: TRect;
begin
  If not Settings.Opened Then Exit;
  If Rs.ROn Then
  begin
    WScreen.Surface.Canvas.Brush.Color:=$00666666;
    Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
    WScreen.Surface.Canvas.FillRect(Rect);


    Case Rs.RType of
      1:
      begin
        MWin^.X:=Rs.WX+(X-Rs.X);
        MWin^.Y:=Rs.WY+(Y-Rs.Y);
      end;
      2:
      begin
        MWin^.X:=Rs.WX+(X-Rs.X);
        MWin^.W:=Rs.WW-(X-Rs.X);
      end;
      3:
      begin
        MWin^.X:=Rs.WX+(X-Rs.X);
        MWin^.Y:=Rs.WY+(Y-Rs.Y);
        MWin^.W:=Rs.WW-(X-Rs.X);
        MWin^.H:=Rs.WH-(Y-Rs.Y);
      end;
      4:
      begin
        MWin^.Y:=Rs.WY+(Y-Rs.Y);
        MWin^.H:=Rs.WH-(Y-Rs.Y);
      end;
      5:
      begin
        MWin^.Y:=Rs.WY+(Y-Rs.Y);
        MWin^.W:=Rs.WW+(X-Rs.X);
        MWin^.H:=Rs.WH-(Y-Rs.Y);
      end;
      6: MWin^.W:=Rs.WW+(X-Rs.X);
      7:
      begin
        MWin^.W:=Rs.WW+(X-Rs.X);
        MWin^.H:=Rs.WH+(Y-Rs.Y);
      end;
      8:  MWin^.H:=Rs.WH+(Y-Rs.Y);
      9:
      begin
        MWin^.X:=Rs.WX+(X-Rs.X);
        MWin^.W:=Rs.WW-(X-Rs.X);
        MWin^.H:=Rs.WH+(Y-Rs.Y);
      end;
    end;
    //MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
    DrawWindow(MWin^, WScreen);
    WScreen.Surface.Canvas.Release;
    WScreen.Flip;
    //Form1.Caption:=Format('%d::%d',[MWin^.X,MWin^.Y]);
  end else
  begin
    Rs.RType:=CheckWindow(MWin^,X,Y);
    If Rs.RType>0 Then Rs.Mode:=True;
    Case Rs.RType of
      1:  WScreen.Cursor:=crSizeAll;
      2:  WScreen.Cursor:=crSizeWE;
      3:  WScreen.Cursor:=crSizeNWSE;
      4:  WScreen.Cursor:=crSizeNS;
      5:  WScreen.Cursor:=crSizeNESW;
      6:  WScreen.Cursor:=crSizeWE;
      7:  WScreen.Cursor:=crSizeNWSE;
      8:  WScreen.Cursor:=crSizeNS;
      9:  WScreen.Cursor:=crSizeNESW;
      0:
      begin
        If Rs.Mode Then
        begin
          Rs.Mode:=False;
          WScreen.Cursor:=crDefault;
        end;
      end;
    end;
    //Form1.Caption:=Format('%d::%d',[X,Y]);
    Status.Panels.Items[0].Text:=Format('X: %d; Y: %d',[X,Y+YS]);
  end;
end;

procedure TWForm.WScreenMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If not Settings.Opened Then Exit;
  If Rs.RType>0 Then begin Rs.WX:=MWin^.X; Rs.WY:=MWin^.Y; Rs.WW:=MWin^.W; Rs.WH:=MWin^.H; Rs.ROn:=True; Rs.X:=X; Rs.Y:=Y; end;
end;

procedure TWForm.WScreenMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If not Settings.Opened Then Exit;
  Rs.ROn:=False;
  weCoord:=True;
  weX.Text:=IntToStr(MWin^.X);
  weY.Text:=IntToStr(MWin^.Y);
  weW.Text:=IntToStr(MWin^.W);
  weH.Text:=IntToStr(MWin^.H);
  weCoord:=False;
  MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
end;

procedure TWForm.Button3Click(Sender: TObject);
var Buf: Pointer; Size: Integer;
begin
{  Size:=LoadFile('_FF7\INIT\WINDOW.BIN',Buf);
  Size:=ZLibDecompress(Buf);
  SaveFile('_FF7\_LZ\Test\1.tim',Buf,Size);    }
end;

procedure TWForm.Button4Click(Sender: TObject);
var Font: TWFont; Table: TTableArray;
begin
  Font:=TWFont.Create;
  Font.LoadFont('_FF7\_LZ\Font\Font.tim','_FF7\_LZ\Font\W.dat');
  //Font.DrawChar($A9,WScreen,0,0);
  //Font.DrawIDLine('ABCD',WScreen,Win.X+8,Win.Y+6);
  LoadTable('_FF7\Table_En.tbl',Table);
  //Font.DrawLine('“C'+#$27+'mon newcomer.',WScreen,Table,Win.X+8,Win.Y+6);
  //Font.DrawLine('  F<cPurple>oll<cPurple>ow me.”',WScreen,Table,Win.X+8,Win.Y+6+16);
  Font.DrawText('“C'+#$27+'mon newcomer.'+#13#10+'<TAB>Follow me.”',WScreen,Table,Win.X+8,Win.Y+6,0);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
end;

procedure TWForm.weXChange(Sender: TObject);
var Rect: TRect;
begin
  If weCoord Then Exit;
  Try
    MWin^.X:=StrToInt(weX.Text);
  except
    weX.Text:='0';
    MWin^.X:=0;
  end;
    WScreen.Surface.Canvas.Brush.Color:=$00666666;
    Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
    WScreen.Surface.Canvas.FillRect(Rect);
    //DrawWindow(MWin^, WScreen);
    MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
    WScreen.Surface.Canvas.Release;
    WScreen.Flip;
end;

procedure TWForm.weYChange(Sender: TObject);
var Rect: TRect;
begin
  If weCoord Then Exit;
  Try
    MWin^.Y:=StrToInt(weY.Text);
  except
    weY.Text:='0';
    MWin^.Y:=0;
  end;
    WScreen.Surface.Canvas.Brush.Color:=$00666666;
    Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
    WScreen.Surface.Canvas.FillRect(Rect);
    //DrawWindow(MWin^, WScreen);
    MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
    WScreen.Surface.Canvas.Release;
    WScreen.Flip;
end;

procedure TWForm.weWChange(Sender: TObject);
var Rect: TRect;
begin
  If weCoord Then Exit;
  Try
    MWin^.W:=StrToInt(weW.Text);
  except
    weW.Text:='16';
    MWin^.W:=16;
  end;
    WScreen.Surface.Canvas.Brush.Color:=$00666666;
    Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
    WScreen.Surface.Canvas.FillRect(Rect);
    //DrawWindow(MWin^, WScreen);
    MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
    WScreen.Surface.Canvas.Release;
    WScreen.Flip;
end;

procedure TWForm.weHChange(Sender: TObject);
var Rect: TRect;
begin
  If weCoord Then Exit;
  Try
    MWin^.H:=StrToInt(weH.Text);
  except
    weH.Text:='0';
    MWin^.H:=0;
  end;
    WScreen.Surface.Canvas.Brush.Color:=$00666666;
    Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
    WScreen.Surface.Canvas.FillRect(Rect);
    //DrawWindow(MWin^, WScreen);
    MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
    WScreen.Surface.Canvas.Release;
    WScreen.Flip;
end;

procedure TWForm.AOnTopSetExecute(Sender: TObject);
var Rect: TRect;
begin
  FirstRes:=True;
  AOnTopSet.Checked:=not AOnTopSet.Checked;
  If AOnTopSet.Checked Then WForm.FormStyle:=fsStayOnTop
  else WForm.FormStyle:=fsNormal;
  WScreen.Initialize;
  If not Settings.Opened Then Exit;
  WScreen.Surface.Canvas.Brush.Color:=$00666666;
  Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
  WScreen.Surface.Canvas.FillRect(Rect);
  //DrawWindow(MWin^, WScreen);
  MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
  WScreen.Surface.Canvas.Release;
  WScreen.Flip;
  FirstRes:=False;
end;

procedure TWForm.FormCreate(Sender: TObject);
begin
  WForm.ScrW:=WForm.Width-WScreen.Width;
  WForm.ScrH:=WForm.Height-WScreen.Height;
end;


procedure TWForm.FormResize(Sender: TObject);
begin
  If FirstRes Then Exit;
  WScreen.Width:=WForm.Width-WForm.ScrW;
  WScreen.Height:=WForm.Height-WForm.ScrH;
  weW.Left:=WScreen.Width;
  weH.Left:=WScreen.Width+weW.Width;
  weX.Left:=WScreen.Width;
  weY.Left:=WScreen.Width+weX.Width;
  chOnTop.Left:=weX.Left+25;
  YBar.Left:=weW.Left;
  //--
    Rs.ROn:=False;
  weCoord:=True;
  weX.Text:=IntToStr(MWin^.X);
  weY.Text:=IntToStr(MWin^.Y);
  weW.Text:=IntToStr(MWin^.W);
  weH.Text:=IntToStr(MWin^.H);
  weCoord:=False;
  MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
end;

procedure TWForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.AWinEditor.Checked:=False;
end;

procedure TWForm.YBarChange(Sender: TObject);
var Rect: TRect;
begin
    YS:=YBar.Position;
    WScreen.Surface.Canvas.Brush.Color:=$00666666;
    Rect.Left:=0; Rect.Top:=0; Rect.Right:=1024; Rect.Bottom:=768;
    WScreen.Surface.Canvas.FillRect(Rect);
    //DrawWindow(MWin^, WScreen);
    MFont.DrawTextOnWindow(MWText,WScreen,MTable,MWin^);
    WScreen.Surface.Canvas.Release;
    WScreen.Flip;
end;

end.
