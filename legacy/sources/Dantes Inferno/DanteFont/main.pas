unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, ActnList, targa, DIB, ComCtrls, FontUnit;

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
    ALoadTG4D: TAction;
    ASaveTG4D: TAction;
    ASaveImage: TAction;
    DOpenDialog: TOpenDialog;
    ALoadTG4D1: TMenuItem;
    ACopy: TAction;
    APaste: TAction;
    Edit1: TMenuItem;
    C1: TMenuItem;
    Paste1: TMenuItem;
    DSaveDialog: TSaveDialog;
    ASaveTG4D1: TMenuItem;
    PicSaveDialog: TSaveDialog;
    ASaveImage1: TMenuItem;
    N1: TMenuItem;
    Exchangedebug1: TMenuItem;
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
    procedure ALoadTG4DExecute(Sender: TObject);
    procedure ACopyExecute(Sender: TObject);
    procedure APasteExecute(Sender: TObject);
    procedure ASaveTG4DExecute(Sender: TObject);
    procedure ASaveImageExecute(Sender: TObject);
    procedure Exchangedebug1Click(Sender: TObject);
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
    Procedure LoadTG4D(FileName: String);
    Procedure SaveTG4D(FileName: String);
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
  TDanteFont = Class
    FFileName: String;
    FHeader: TFontHeader;
    FCount:  Integer;
    FRecCount: Integer;
    FChars:  Array of TCharRecord;
    FPtrs:   Array[Byte] of PCharRecord;
    FData:   PByte; 
    Constructor Create;
    Destructor  Destroy;
  public
    Procedure LoadFromFile(FileName: String);
    Procedure LoadFromStream(Stream: TStream);
    Procedure SaveToStream(Stream: TStream); 
    Procedure SaveToFile(FileName: String);
  end;

var DanteFont: TDanteFont;
    CopyChar: TCharRecord;

const
  cCharW = 16;
  cCharH = 20;

implementation

{$R *.dfm}


procedure TMainForm.LoadFile(FileName: String);
begin
  DanteFont.LoadFromFile(FileName);
  FFontLoaded := True;   
  FileName := ChangeFileExt(FileName, '.tga');
  If FileExists(FileName) Then
    LoadTarga(FileName)
  else
  begin
    FileName := ChangeFileExt(FileName, '.tg4d');
    If FileExists(FileName) Then
      LoadTG4D(FileName);
  end;

  RefreshImage;
end;

Procedure EndianWP(var W: Word);
begin
  W := EndianW(W);
end;

Procedure ConvertChar(var C: TCharRecord);
begin
  EndianWP(C.Width);
  EndianWP(C.Height);
  EndianWP(C.U1);
  EndianWP(Word(C.Left));
  EndianWP(Word(C.Right));
  C.Rect.Left   := EndianW(C.Rect.Left);  // SHR 4;
  C.Rect.Top    := EndianW(C.Rect.Top);  //  SHR 4;
  C.Rect.Right  := EndianW(C.Rect.Right);  // SHR 4;
  C.Rect.Bottom := EndianW(C.Rect.Bottom);
end;

{ TRisenFont }

constructor TDanteFont.Create;
begin
  FData := nil;
end;

destructor TDanteFont.Destroy;
begin
  If FData <> nil Then FreeMem(FData);
end;

procedure TDanteFont.LoadFromFile(FileName: String);
var Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  LoadFromStream(Stream);
  Stream.Free;
  FFileName := FileName;
end;

procedure TDanteFont.LoadFromStream(Stream: TStream);
var n, m: Integer; P: PByte;
begin
  Stream.Read(FHeader, SizeOf(FHeader));
  FCount := EndianW(FHeader.CharCount);
  SetLength(FChars, FCount);
  If FData <> nil Then FreeMem(FData);
  GetMem(FData, Endian(FHeader.FileSize));
  Stream.Seek(0, soBeginning);
  Stream.Read(FData^, Endian(FHeader.FileSize));
  //Stream.Read(FChars[0], FCount * SizeOf(TCharRecord));
  P := FData;
  Inc(P, Endian(FHeader.CharOffset));
  Move(P^, FChars[0], FCount * SizeOf(TCharRecord));
  FillChar(FPtrs, SizeOf(FPtrs), 0);
  For n := 0 To FCount - 1 do
  begin
    If Word(FChars[n].Code) < 256 Then
      FPtrs[Word(FChars[n].Code)] := @FChars[n];
    ConvertChar(FChars[n]);
  end;
end;

procedure TDanteFont.SaveToFile(FileName: String);
var Stream: TMemoryStream; Attr: LongWord;
begin
  Stream := TMemoryStream.Create;
  SaveToStream(Stream);
  Stream.SaveToFile(FileName);
  Stream.Free;
end;

procedure TDanteFont.SaveToStream(Stream: TStream);
var P: PByte; R: PCharRecord; n: Integer;
begin
  P := FData;
  Inc(P, Endian(FHeader.CharOffset));
  Move(FChars[0], P^, FCount * SizeOf(TCharRecord));
  R := Pointer(P);
  For n :=  0 To FCount - 1 do
  begin
    ConvertChar(R^);
    Inc(R);
  end;
  Stream.Write(FData^, Endian(FHeader.FileSize));
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
    For X := 0 To 511 do
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
  FontPic.LoadFromFile(OpenTGADialog.FileName);
  //LoadTarga(OpenTGADialog.FileName);

end;

procedure TMainForm.RefreshImage;
begin
  FontImage.Canvas.CopyRect(FontPic.Canvas.ClipRect, FontPic.Canvas, FontPic.Canvas.ClipRect);
  DrawChars; 
  DrawBigChar;
  DrawBounds;
  If DanteFont.FPtrs[SelIndex] = nil Then With DanteFont.FPtrs[SelIndex]^ do
  begin
    StatusBar.Panels[0].Text := Format('C: ''%s''', [Char(SelIndex)]);
  end else
  begin
    With DanteFont.FPtrs[SelIndex]^ do
      StatusBar.Panels[0].Text := Format('C: ''%s'', W: %d, L: %d, R: %d, H: %d, U: %d',
             [Char(SelIndex), Width, Left, Right, Height, U1]);
  end;
end;

procedure TMainForm.DrawBounds;
var Rect: TRect;
begin
  If DanteFont.FPtrs[SelIndex] = nil Then Exit;
  With DanteFont.FPtrs[SelIndex]^.Rect do
  begin
    Rect.Left   := Left   div 16;
    Rect.Top    := Top    div 16;
    Rect.Right  := Right  div 16;
    Rect.Bottom := Bottom div 16;
  end;
  With DanteFont.FPtrs[SelIndex]^ do
  begin
    BigImage.Canvas.Pen.Color := clRed;
    BigImage.Canvas.MoveTo(-Left * 8 + 16, 0);
    BigImage.Canvas.LineTo(-Left * 8 + 16, BigImage.Height);
    BigImage.Canvas.MoveTo(Right * 8 + 16, 0);
    BigImage.Canvas.LineTo(Right * 8 + 16, BigImage.Height);
    BigImage.Canvas.MoveTo(0, (Endian(DanteFont.FHeader.Height) - U1) * 8 + 16);
    BigImage.Canvas.LineTo(BigImage.Width, (Endian(DanteFont.FHeader.Height) - U1) * 8 + 16);

    //BigImage.Canvas.MoveTo(0, (RisenFont.FHeader.TopBorder - ) * 8);
    //BigImage.Canvas.LineTo(BigImage.Width, (RisenFont.FHeader.TopBorder - T) * 8);
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
  If DanteFont.FPtrs[Index] = nil Then Exit;
  With DanteFont.FPtrs[Index]^.Rect do
  begin
    Rect.Left   := Left   div 16;
    Rect.Top    := Top    div 16;
    Rect.Right  := Right  div 16;
    Rect.Bottom := Bottom div 16;
    CharsImage.Canvas.CopyRect(Bounds(X, Y, (Right - Left) div 16, (Bottom - Top) div 16),
      FontPic.Canvas, Rect);
  end;
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
  If DanteFont.FPtrs[SelIndex] = nil Then Exit;
  With DanteFont.FPtrs[SelIndex]^.Rect do
  begin
    Inc(Right,  X * 16 - Left);
    Inc(Bottom, Y * 16 - Top);
    Left := X * 16;
    Top  := Y * 16;
  end;
  RefreshImage;
end;

procedure TMainForm.FontImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  If not (ssLeft in Shift) or (DanteFont.FPtrs[SelIndex] = nil) Then Exit;
  With DanteFont.FPtrs[SelIndex]^.Rect do
  begin
    Inc(Right,  X * 16 - Left);
    Inc(Bottom, Y * 16 - Top);
    Left := X * 16;
    Top  := Y * 16;
  end;          
  RefreshImage;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //StatusBar.Panels[0].Text := Format('%d', [Key]);
  If not (ssCtrl in Shift) and not (ssShift in Shift) Then
  begin
    Case Key of
      VK_LEFT:     SelIndex := SelIndex - 1;
      VK_RIGHT:    SelIndex := SelIndex + 1;
      VK_UP:       SelIndex := SelIndex - 16;
      VK_DOWN:     SelIndex := SelIndex + 16;
    end;                                     
    If DanteFont.FPtrs[SelIndex] = nil Then Exit;
    With DanteFont.FPtrs[SelIndex]^ do Case Key of
      //VK_SUBTRACT: Dec(Rect.Right, 16);
      //VK_ADD:      Inc(Rect.Right, 16);
      VK_DELETE:   Dec(U1);
      VK_INSERT:   Inc(U1);
      VK_HOME:     Inc(Left);
      VK_END:      Dec(Left);
      VK_PRIOR:    Inc(Right);
      VK_NEXT:     Dec(Right);
    end;   
    With DanteFont.FPtrs[SelIndex]^ do
    begin
      Width  := (Rect.Right  - Rect.Left) div 16;
      Height := (Rect.Bottom - Rect.Top ) div 16;
    end;
  end else
  If (ssCtrl in Shift) Then
  begin
    If DanteFont.FPtrs[SelIndex] = nil Then Exit;
    Case Key of
      VK_LEFT:
      begin
        Dec(DanteFont.FPtrs[SelIndex]^.Rect.Left,  16);
        Dec(DanteFont.FPtrs[SelIndex]^.Rect.Right, 16);
      end;
      VK_RIGHT:
      begin
        Inc(DanteFont.FPtrs[SelIndex]^.Rect.Left,  16);
        Inc(DanteFont.FPtrs[SelIndex]^.Rect.Right, 16);
      end;
      VK_UP:
      begin
        Dec(DanteFont.FPtrs[SelIndex]^.Rect.Top,    16);
        Dec(DanteFont.FPtrs[SelIndex]^.Rect.Bottom, 16);
      end;
      VK_DOWN:
      begin
        Inc(DanteFont.FPtrs[SelIndex]^.Rect.Top,    16);
        Inc(DanteFont.FPtrs[SelIndex]^.Rect.Bottom, 16);
      end;
    end;
  end else
  If (ssShift in Shift) Then
  begin     
    If DanteFont.FPtrs[SelIndex] = nil Then Exit;
    Case Key of
      VK_LEFT:  Dec(DanteFont.FPtrs[SelIndex]^.Rect.Right, 16);
      VK_RIGHT: Inc(DanteFont.FPtrs[SelIndex]^.Rect.Right, 16);
      VK_UP:    Dec(DanteFont.FPtrs[SelIndex]^.Rect.Bottom, 16);
      VK_DOWN:  Inc(DanteFont.FPtrs[SelIndex]^.Rect.Bottom, 16);
    end;
    With DanteFont.FPtrs[SelIndex]^ do
    begin
      Width  := (Rect.Right  - Rect.Left) div 16;
      Height := (Rect.Bottom - Rect.Top ) div 16;
    end;
  end;
RefreshImage;
end;

procedure TMainForm.DrawBigChar;
var Rect, DestRect: TRect;
begin
  If DanteFont.FPtrs[SelIndex] = nil Then Exit;
  With DanteFont.FPtrs[SelIndex]^.Rect do
  begin
    Rect.Left   := Left   div 16;
    Rect.Top    := Top    div 16;
    Rect.Right  := Right  div 16;
    Rect.Bottom := Bottom div 16;
    DestRect := Bounds(0 + 16, 0 + 16, (Right - Left) div 2, (Bottom - Top) div 2);
  end;
  BigImage.Canvas.FillRect(BigImage.Canvas.ClipRect); 
  BigImage.Canvas.CopyRect(DestRect, FontPic.Canvas, Rect); 
end;



procedure TMainForm.ASaveExecute(Sender: TObject);
begin
  DanteFont.SaveToFile(DanteFont.FFileName);
end;

procedure TMainForm.ASaveAsExecute(Sender: TObject);
begin
  If not SaveDialog.Execute Then Exit;
  DanteFont.SaveToFile(SaveDialog.FileName);
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
MessageBox(0, 'Dante''s Inferno Font Editor by HoRRoR'+#13+#10+'http://consolgames.ru/', 'About...', MB_ICONINFORMATION or MB_OK);
end;

procedure TMainForm.Controls1Click(Sender: TObject);
begin
MessageBox(0, 'Ctrl + Left/Right/Up/Down, mouse click/move - change coordinate'+#13+#10+'+/- - change width'+#13+#10+'Insert/Delete - change top border'+#13+#10+'Home/End - change left border'+#13+#10+'Page Up/Page Down - change right border', 'Controls...', MB_ICONINFORMATION or MB_OK);
end;

procedure TMainForm.LoadTG4D(FileName: String);
var Stream: TMemoryStream; n: Integer;
begin
  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(FileName);
  For n := 0 To 255 do
    Move(Pointer(LongWord(Stream.Memory) + n * 512)^, FontPic.ScanLine[n]^, 512);
  Stream.Free;
  RefreshImage();
end;

procedure TMainForm.ALoadTG4DExecute(Sender: TObject);
begin
  If not DOpenDialog.Execute Then Exit;
  LoadTG4D(DOpenDialog.FileName);
end;

procedure TMainForm.ACopyExecute(Sender: TObject);
begin    
  If DanteFont.FPtrs[SelIndex] = nil Then Exit;
  CopyChar := DanteFont.FPtrs[SelIndex]^;
end;

procedure TMainForm.APasteExecute(Sender: TObject);
begin
  If DanteFont.FPtrs[SelIndex] = nil Then Exit;
  DanteFont.FPtrs[SelIndex]^ := CopyChar;
  Word(DanteFont.FPtrs[SelIndex]^.Code)  := SelIndex;
  DrawChars;
  DrawBigChar;
  DrawBounds;
end;

procedure TMainForm.SaveTG4D(FileName: String);
var Stream: TMemoryStream; n: Integer;
begin
  Stream := TMemoryStream.Create;
  Stream.SetSize(512 * 256);
  For n := 0 To 255 do
    Move(FontPic.ScanLine[n]^, Pointer(LongWord(Stream.Memory) + n * 512)^, 512);
  Stream.SaveToFile(FileName);
  Stream.Free;
end;

procedure TMainForm.ASaveTG4DExecute(Sender: TObject);
begin
  If not DSaveDialog.Execute Then Exit;
  SaveTG4D(DSaveDialog.FileName);
end;

procedure TMainForm.ASaveImageExecute(Sender: TObject);
begin
  If not PicSaveDialog.Execute Then Exit;
  FontPic.SaveToFile(PicSaveDialog.FileName); 
end;

procedure TMainForm.Exchangedebug1Click(Sender: TObject);
var n: Integer;
begin
  For n := 0 To DanteFont.FCount - 1 do
  begin
    Case Word(DanteFont.FChars[n].Code) of
      $40..$7F: Inc(DanteFont.FChars[n].Code, $80);
      $C0..$FF: Dec(DanteFont.FChars[n].Code, $80);
    end;
  end;
end;

Initialization
  DanteFont := TDanteFont.Create;
  FontPic := TDIB.Create;
  FontPic.BitCount := 8;
  FontPic.Width := 512;
  FontPic.Height := 512;
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
  DanteFont.Free;
  FontPic.Free;
  //CharsPic.Free;
end.
