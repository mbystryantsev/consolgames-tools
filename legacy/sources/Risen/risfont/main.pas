unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ActnList, targa, DIB, ComCtrls;

type
  TMainForm = class(TForm)
    FontImage: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    CharsImage: TImage;
    BigImage: TImage;
    ActionList1: TActionList;
    AOpenFile: TAction;
    OpenDialog: TOpenDialog;
    AOpenFile1: TMenuItem;
    ALoadImage: TAction;
    OpenTGADialog: TOpenDialog;
    ALoadImage1: TMenuItem;
    StatusBar: TStatusBar;
    SaveDialog: TSaveDialog;
    ASave: TAction;
    ASaveAs: TAction;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Controls1: TMenuItem;
    procedure AOpenFileExecute(Sender: TObject);
    procedure ALoadImageExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CharsImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FontImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FontImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ASaveExecute(Sender: TObject);
    procedure ASaveAsExecute(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Controls1Click(Sender: TObject);
  private
    procedure SetSelIndex(const Value: Byte);
    { Private declarations }
  public
    FFontLoaded: Boolean;
    FImageLoaded: Boolean;
    FSelIndex:   Byte;
    Property SelIndex: Byte Read FSelIndex Write SetSelIndex;
    Procedure LoadFile(FileName: String);
    Procedure LoadTarga(FileName: String); 
    Procedure RefreshImage;
    Procedure DrawBounds;
    Procedure DrawChars(Update: Boolean = True);
    Procedure DrawChar(Index: Integer; Clear: Boolean = True);
    Procedure DrawBigChar;
  end;

var
  MainForm: TMainForm;
  FontPic:  TDIB;
  //CharsPic: TDIB;

Type
  TFontHeader = Packed Record
    Height: Integer;
    TopBorder: Integer;
    BottomBorder: Integer;
    U1, U2, U3, U4, U5, U6, U7, U8: Integer;
    U9, U10, U11: SmallInt;
    U12: Integer;
    UB:  Byte;
    U13: SmallInt;
    Count: Integer;
  end;
  TCharLink = Packed Record
    Char: WideChar;
    ID:   Word;
  end;
  TCharRecord = Packed Record
    ID: LongWord;
    R:  LongWord;
    U2: LongWord;
    L:  Integer;
    T:  Integer;
    Y2: Integer;
    X1: Integer;
    X2: Integer;
    Y1: Integer;
    U3: Integer;
  end;
  TFontFooter = Packed Record
    U0: TCharRecord;
    U1, U2, U3: Integer;
  end;
  TRisenFont = Class
    FFileName: String;
    FHeader: TFontHeader;
    FFooter: TFontFooter;
    FCount:  Integer;
    FRecCount: Integer;
    FLinks:  Array[Byte] of TCharLink;
    FChars:  Array[Byte] of TCharRecord;    
    FPtrs:   Array[Byte] of ^TCharRecord;
  public
    Procedure LoadFromFile(FileName: String);
    Procedure LoadFromStream(Stream: TStream);
    Procedure SaveToStream(Stream: TStream); 
    Procedure SaveToFile(FileName: String);
  end;

var RisenFont: TRisenFont;

const
  cCharW = 16;
  cCharH = 20;

implementation

{$R *.dfm}


procedure TMainForm.LoadFile(FileName: String);
begin
  RisenFont.LoadFromFile(FileName);
  FFontLoaded := True;   
  FileName := ChangeFileExt(FileName, '_0.tga');
  If FileExists(FileName) Then
    LoadTarga(FileName)
  else
    RefreshImage;
end;

{ TRisenFont }

procedure TRisenFont.LoadFromFile(FileName: String);
var Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  LoadFromStream(Stream);
  Stream.Free;
  FFileName := FileName;       
end;

procedure TRisenFont.LoadFromStream(Stream: TStream);
var n, m: Integer;
begin
  Stream.Read(FHeader, SizeOf(FHeader));
  Stream.Read(FLinks, FHeader.Count * SizeOf(TCharLink));
  Stream.Read(FRecCount, 4);
  Stream.Read(FChars, FRecCount * SizeOf(TCharRecord));
  Stream.Read(FFooter, SizeOf(FFooter));
  FCount := FHeader.Count;
  FillChar(FPtrs, SizeOf(FPtrs), 0);
  For n := 0 To FCount do
  begin
    If FLinks[n].ID = 0 Then Continue;
    For m := 0 To FRecCount - 1 do
      If FLinks[n].ID = FChars[m].ID Then
        Break;
    If m < FRecCount Then
      FPtrs[Byte(FLinks[n].Char)] := @FChars[m];
  end;
end;

procedure TRisenFont.SaveToFile(FileName: String);
var Stream: TMemoryStream; Attr: LongWord;
begin
  Stream := TMemoryStream.Create;
  SaveToStream(Stream);
  Attr := GetFileAttributes(PChar(FileName));
  SetFileAttributes(PChar(FileName), Attr xor FILE_ATTRIBUTE_READONLY);
  Stream.SaveToFile(FileName);
  SetFileAttributes(PChar(FileName), Attr);
  Stream.Free;                
end;

procedure TRisenFont.SaveToStream(Stream: TStream);
begin
  Stream.Write(FHeader, SizeOf(FHeader));
  Stream.Write(FLinks, FHeader.Count * SizeOf(TCharLink));
  Stream.Write(FRecCount, 4);
  Stream.Write(FChars, FRecCount * SizeOf(TCharRecord));
  Stream.Write(FFooter, SizeOf(FFooter));
end;

procedure TMainForm.AOpenFileExecute(Sender: TObject);
begin
  If not OpenDialog.Execute Then Exit;
  LoadFile(OpenDialog.FileName);
end;

procedure TMainForm.LoadTarga(FileName: String);
var Header: TGA_Header; P: PLongWord; B: PByte; X, Y: Integer;
begin
  Header := LoadTGA(FileName);
  P := Header.Data;
  For Y := 255 DownTo 0 do
  begin
    B := FontPic.ScanLine[Y];
    For X := 0 To 255 do
    begin
      B^ := P^ SHR 24;
      Inc(B); Inc(P);      
    end;
  end;
  FreeMem(Header.Data);

  RefreshImage;
  //DrawChars;
end;

var i: Integer;
procedure TMainForm.ALoadImageExecute(Sender: TObject);
begin
  If not OpenTGADialog.Execute Then Exit;
  LoadTarga(OpenTGADialog.FileName);

end;

procedure TMainForm.RefreshImage;
begin
  FontImage.Canvas.CopyRect( FontImage.Canvas.ClipRect, FontPic.Canvas, FontPic.Canvas.ClipRect);
  DrawChars; 
  DrawBigChar;
  DrawBounds;
  If RisenFont.FPtrs[SelIndex] = nil Then
  begin
      StatusBar.Panels[0].Text := Format('C: ''%s''', [Char(SelIndex)]);
  end else
  begin
    With RisenFont.FPtrs[SelIndex]^ do
      StatusBar.Panels[0].Text := Format('ID: %d, C: ''%s'', X: %d, Y: %d, W: %d, H: %d, L: %d, R: %d, T: %d, U2: %d, U3: %d',
                                        [ID, Char(SelIndex), X1, Y1, X2 - X1, Y2 - Y1, L, R - (X2 - X1), T, U2, U3]);
  end;
end;

procedure TMainForm.DrawBounds;
var Rect: TRect;
begin
  If RisenFont.FPtrs[SelIndex] = nil Then Exit;
  With RisenFont.FPtrs[SelIndex]^ do
  begin
    Rect.TopLeft.X := X1 * 2;
    Rect.TopLeft.Y  := Y1 * 2;
    Rect.BottomRight.X := X2 * 2;
    Rect.BottomRight.Y := Y2 * 2;  

    BigImage.Canvas.Pen.Color := clRed;
    BigImage.Canvas.MoveTo(L * 8 + 16, 0);
    BigImage.Canvas.LineTo(L * 8 + 16, BigImage.Height);
    BigImage.Canvas.MoveTo(R * 8 + 16, 0);
    BigImage.Canvas.LineTo(R * 8 + 16, BigImage.Height);
    BigImage.Canvas.MoveTo(0, (RisenFont.FHeader.TopBorder - T) * 8);
    BigImage.Canvas.LineTo(BigImage.Width, (RisenFont.FHeader.TopBorder - T) * 8);
  end;

  FontImage.Canvas.Rectangle(Rect);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FontImage.Canvas.Brush.Style := bsClear;
  FontImage.Canvas.Pen.Style := psSolid;
  FontImage.Canvas.Pen.Color := clRed;
  CharsImage.Canvas.Brush.Style := bsClear;
  CharsImage.Canvas.Pen.Style := psSolid;
  CharsImage.Canvas.Pen.Color := clRed;
  BigImage.Canvas.Brush.Color := clGray;

  FontImage.Canvas.FillRect(FontImage.Canvas.ClipRect);
  CharsImage.Canvas.FillRect(CharsImage.Canvas.ClipRect);
  BigImage.Canvas.FillRect(BigImage.Canvas.ClipRect);
end;

procedure TMainForm.DrawChars;
var X, Y, n: Integer;
begin
  If Update Then
  begin
    CharsImage.Canvas.Brush.Color := clBlack;
    CharsImage.Canvas.FillRect(CharsImage.Canvas.ClipRect);
    For n := 0 To 255 do
        DrawChar(n, False);
  end;
  //CharsImage.Canvas.Draw(0, 0, CharsPic);
  //CharsImage.Canvas.Rectangle(Bounds(SelIndex SHR 4, SelIndex and $F, cCharW, cCharH));
  //CharsPic.SaveToFile('Test.bmp');
  X := (SelIndex and $F) * cCharW;
  Y := (SelIndex shr 4)  * cCharH;
  CharsImage.Canvas.Pen.Color := clRed;
  CharsImage.Canvas.Brush.Style := bsClear;
  CharsImage.Canvas.Rectangle(Bounds(X, Y, cCharW, cCharH));
  //RefreshImage;
end;

procedure TMainForm.DrawChar(Index: Integer; Clear: Boolean = True);
var Rect: TRect; X, Y: Integer;
begin
  X := (Index and $F) * cCharW;
  Y := (Index shr 4)  * cCharH;
  If Clear Then CharsImage.Canvas.FillRect(Bounds(X, Y, cCharW, cCharH));
  If RisenFont.FPtrs[Index] = nil Then Exit;
  With RisenFont.FPtrs[Index]^ do
  begin
    Rect.TopLeft.X := X1;
    Rect.TopLeft.Y  := Y1;
    Rect.BottomRight.X := X2;
    Rect.BottomRight.Y := Y2;
    //CharsPic
    CharsImage.Canvas.CopyRect(Bounds(X, Y, X2 - X1, Y2 - Y1), FontPic.Canvas, Rect);
    //If Rect.Right -
  end;
  {
  If Clear Then
  begin
    CharsImage.Canvas.Draw(0, 0, CharsPic);
    X := (SelIndex and $F) * cCharW;
    Y := (SelIndex shr 4)  * cCharH;
    CharsImage.Canvas.Rectangle(Bounds(X, Y, cCharW, cCharH));
    //Application.ProcessMessages;
  end;
  }
end;

procedure TMainForm.SetSelIndex(const Value: Byte);
begin
  FSelIndex := Value;
  RefreshImage();
end;

procedure TMainForm.CharsImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SelIndex := (X div cCharW) + (Y div cCharH) * 16;
end;

procedure TMainForm.FontImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  If RisenFont.FPtrs[SelIndex] = nil Then Exit;
  With RisenFont.FPtrs[SelIndex]^ do
  begin
    Inc(X2, X div 2 - X1);
    Inc(Y2, Y div 2 - Y1);
    X1 := X div 2;
    Y1 := Y div 2;
  end;
  RefreshImage;
end;

procedure TMainForm.FontImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  If not (ssLeft in Shift) or (RisenFont.FPtrs[SelIndex] = nil) Then Exit;
  With RisenFont.FPtrs[SelIndex]^ do
  begin
    Inc(X2, X div 2 - X1);
    Inc(Y2, Y div 2 - Y1);
    X1 := X div 2;
    Y1 := Y div 2;
  end;
  RefreshImage;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //StatusBar.Panels[0].Text := Format('%d', [Key]);
  If not (ssCtrl in Shift) Then
  begin
    Case Key of
      VK_LEFT:     SelIndex := SelIndex - 1;
      VK_RIGHT:    SelIndex := SelIndex + 1;
      VK_UP:       SelIndex := SelIndex - 16;
      VK_DOWN:     SelIndex := SelIndex + 16;
    end;                                     
    If RisenFont.FPtrs[SelIndex] = nil Then Exit;
    With RisenFont.FPtrs[SelIndex]^ do Case Key of
      VK_SUBTRACT: Dec(X2);
      VK_ADD:      Inc(X2);
      VK_DELETE:   Dec(T);
      VK_INSERT:   Inc(T);
      VK_HOME:     Inc(L);
      VK_END:      Dec(L);
      VK_PRIOR:    Inc(R);
      VK_NEXT:     Dec(R);
    end;
  end else
  begin
    If RisenFont.FPtrs[SelIndex] = nil Then Exit;
    Case Key of
      VK_LEFT:
      begin
        Dec(RisenFont.FPtrs[SelIndex].X1);
        Dec(RisenFont.FPtrs[SelIndex].X2);
      end;
      VK_RIGHT:
      begin
        Inc(RisenFont.FPtrs[SelIndex].X1);
        Inc(RisenFont.FPtrs[SelIndex].X2);
      end;
      VK_UP:
      begin
        Dec(RisenFont.FPtrs[SelIndex].Y1);
        Dec(RisenFont.FPtrs[SelIndex].Y2);
      end;
      VK_DOWN:
      begin
        Inc(RisenFont.FPtrs[SelIndex].Y1);
        Inc(RisenFont.FPtrs[SelIndex].Y2);
      end;
    end;
  end;
  RefreshImage;
end;

procedure TMainForm.DrawBigChar;
var Rect, DestRect: TRect;
begin
  If RisenFont.FPtrs[SelIndex] = nil Then Exit;
  With RisenFont.FPtrs[SelIndex]^ do
  begin
    Rect.TopLeft.X := X1;
    Rect.TopLeft.Y  := Y1;
    Rect.BottomRight.X := X2;
    Rect.BottomRight.Y := Y2;
    DestRect := Bounds(0 + 16, 0 + 16, (X2 - X1) * 8, (Y2 - Y1) * 8);
  end;
  BigImage.Canvas.FillRect(BigImage.Canvas.ClipRect); 
  BigImage.Canvas.CopyRect(DestRect, FontPic.Canvas, Rect); 
end;



procedure TMainForm.ASaveExecute(Sender: TObject);
begin
  RisenFont.SaveToFile(RisenFont.FFileName); 
end;

procedure TMainForm.ASaveAsExecute(Sender: TObject);
begin
  If not SaveDialog.Execute Then Exit;
  RisenFont.SaveToFile(SaveDialog.FileName);
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
MessageBox(0, 'Risen Font Editor by HoRRoR'+#13+#10+'http://consolgames.ru/', 'About...', MB_ICONINFORMATION or MB_OK);
end;

procedure TMainForm.Controls1Click(Sender: TObject);
begin
MessageBox(0, 'Ctrl + Left/Right/Up/Down, mouse click/move - change coordinate'+#13+#10+'+/- - change width'+#13+#10+'Insert/Delete - change top border'+#13+#10+'Home/End - change left border'+#13+#10+'Page Up/Page Down - change right border', 'Controls...', MB_ICONINFORMATION or MB_OK);
end;

Initialization
  RisenFont := TRisenFont.Create;
  FontPic := TDIB.Create;
  FontPic.BitCount := 8;
  FontPic.Width := 256;
  FontPic.Height := 256;
  For i := 0 To 255 do  With FontPic.ColorTable[i] do
  begin
    rgbRed := i;
    rgbGreen := i;
    rgbBlue := i;
  end;
  FontPic.UpdatePalette;
  //CharsPic := TDIB.Create;
  //CharsPic.BitCount := 24;
  //CharsPic.Width := cCharW * 16;
  //CharsPic.Height := cCharH * 16;
  //CharsPic.ColorTable := FontPic.ColorTable;
  //CharsPic.UpdatePalette;
Finalization
  RisenFont.Free;
  FontPic.Free;
  //CharsPic.Free;
end.
