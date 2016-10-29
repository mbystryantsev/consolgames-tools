unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, Menus, ExtCtrls, ActnList, ToolWin, ImgList, DIB,
  ExtDlgs, ClipBrd, StdCtrls, StrUtils;

type
  TMainForm = class(TForm)
    CharsImage: TImage;
    CharImage: TImage;
    PaletteImage: TImage;
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    StatusBar: TStatusBar;
    FileNewMenuItem: TMenuItem;
    FileOpenMenuItem: TMenuItem;
    FileSaveMenuItem: TMenuItem;
    FileSaveAsMenuItem: TMenuItem;
    FileSeparator: TMenuItem;
    FileExitMenuItem: TMenuItem;
    EditMenu: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    N1: TMenuItem;
    ClearCharacter1: TMenuItem;
    Copytobitmap1: TMenuItem;
    Pastefrombitmap1: TMenuItem;
    Saveasbitmap1: TMenuItem;
    LoadFromBitmap1: TMenuItem;
    N2: TMenuItem;
    ActionList: TActionList;
    FileNewAction: TAction;
    FileOpenAction: TAction;
    FileSaveAction: TAction;
    FileSaveAsAction: TAction;
    FileExitAction: TAction;
    EditCopyAction: TAction;
    EditPasteAction: TAction;
    EditClearAction: TAction;
    EditCopyToBitmapAction: TAction;
    EditPasteFromBitmapAction: TAction;
    EditSaveToBitmapAction: TAction;
    EditLoadFromBitmapAction: TAction;
    EditFlipHorisontalAction: TAction;
    EditFlipVerticalAction: TAction;
    EditMoveUpAction: TAction;
    EditMoveDownAction: TAction;
    EditMoveLeftAction: TAction;
    EditMoveRightAction: TAction;
    FlipHorisontal1: TMenuItem;
    FlipVertical1: TMenuItem;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    MoveLeft1: TMenuItem;
    MoveRight1: TMenuItem;
    N3: TMenuItem;
    EditInsertToRomAction: TAction;
    InsertToRom1: TMenuItem;
    PaletteMenu: TMenuItem;
    PaletteLoadAction: TAction;
    PaletteSaveAction: TAction;
    Load1: TMenuItem;
    Save1: TMenuItem;
    ImageList: TImageList;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ColorDialog: TColorDialog;
    ToolButton7: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    OpenRomDialog: TOpenDialog;
    SaveRomDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    OpenBmpDialog: TOpenPictureDialog;
    SaveBmpDialog: TSavePictureDialog;
    OpenActDialog: TOpenDialog;
    SaveActDialog: TSaveDialog;
    EditSaveAllToBitmap: TAction;
    EditLoadAllFromBitmap: TAction;
    EditSaveAllToBitmap1: TMenuItem;
    EditLoadAllFromBitmap1: TMenuItem;
    EditLoadFromRomAction: TAction;
    Clear1: TMenuItem;
    Sq0: TImage;
    Sq1: TImage;
    Sq2: TImage;
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure PaletteSaveActionExecute(Sender: TObject);
    procedure FileOpenActionExecute(Sender: TObject);
    procedure FileSaveActionExecute(Sender: TObject);
    procedure FileSaveAsActionExecute(Sender: TObject);
    procedure FileExitActionExecute(Sender: TObject);
    procedure PaletteLoadActionExecute(Sender: TObject);
    procedure EditCopyActionExecute(Sender: TObject);
    procedure EditPasteActionExecute(Sender: TObject);
    procedure EditClearActionExecute(Sender: TObject);
    procedure EditCopyToBitmapActionExecute(Sender: TObject);
    procedure EditPasteFromBitmapActionExecute(Sender: TObject);
    procedure EditSaveToBitmapActionExecute(Sender: TObject);
    procedure EditLoadFromBitmapActionExecute(Sender: TObject);
    procedure EditFlipHorisontalActionExecute(Sender: TObject);
    procedure EditFlipVerticalActionExecute(Sender: TObject);
    procedure EditMoveUpActionExecute(Sender: TObject);
    procedure EditMoveDownActionExecute(Sender: TObject);
    procedure EditMoveLeftActionExecute(Sender: TObject);
    procedure EditMoveRightActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure PaletteImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaletteImageDblClick(Sender: TObject);
    procedure CharsImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CharImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CharImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSaveAllToBitmapExecute(Sender: TObject);
    procedure EditLoadAllFromBitmapExecute(Sender: TObject);
    procedure EditLoadFromRomActionExecute(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure Sq0Click(Sender: TObject);
    procedure Sq1Click(Sender: TObject);
    procedure Sq2Click(Sender: TObject);
    procedure FileNewActionExecute(Sender: TObject);
    procedure EditInsertToRomActionExecute(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure About1Click(Sender: TObject);
  private
    FFileName: String;
    FSaved: Boolean;
    Function GetNamed: Boolean;
    Procedure SetSaved(Value: Boolean);
  public
    function CheckSaved: Boolean;
    procedure DrawPalette;
    procedure DrawChars;
    procedure DrawChar;
    procedure DrawSquares;
    property Saved: Boolean read FSaved write SetSaved;
    property Named: Boolean read GetNamed;
    property FileName: String read FFileName write FFileName;
    procedure UpdateDIBPalette;
    procedure Open(const FileName: String);
  end;

const
  cCharWidth  = 8;
  cCharHeight = 12;

Type
 TPalette = Array[0..15] of TColor;
 TTile = Array[0..cCharHeight-1, 0..cCharWidth-1] of Byte;
 TCharacter = Packed Record
  W: Byte;
  Ch: TTile;
 end;
 TChars = Array[Byte] of TCharacter;
 TFonts = Array[0..2] of TChars;
 TSymb = Array[0..23] of Byte;

 TRGBA = Packed Record
  R: Byte;
  G: Byte;
  B: Byte;
  A: Byte;
 end;
 TRGB = Packed Record
  R: Byte;
  G: Byte;
  B: Byte;
 end;

 TSizeData = Packed Record
  L: ShortInt;
  W: Byte;
  R: ShortInt;
 end;
 TSizeDataArray = Array[0..255] of TSizeData;
 TPointerArray = Array[0..255] of DWord;
 TSmallPointerArray = Array[0..255] of Word;
 TSignature = Array[0..3] of Char;

 TFontData = Packed Record
  Signature:  TSignature;
  PSize:      Word;     
  Height:     Word;
  SizeData:   TSizeDataArray;
  Ptrs:       TPointerArray;
  DSize:      DWord;
 end;

var
 Cur:   Integer = 0;
 Fonts: TFonts;
 //FontData:                 TFontData;
 //CharData:                 Array of Byte;
 MainForm:                 TMainForm;
 Palette:                  TPalette = (clWhite, clBlack, clRed, $D0C8D8, 0,0,0,0,0,0,0,0,0,0,0,0);
 BufChar:                  TCharacter;
 CurCol:                   Byte;
 CurChar:                  Byte;
 CharWidth, CharHeight:    Byte;
 //Chars:                    TChars;
 DataPos, PalPos, CodePos: Integer;
 DIB1, DIB2:               TDIB;

Function  LoadFont(FileName: String): Boolean;
procedure LoadFontFromRom(FileName: String; Save: Boolean = False);
procedure ProcessFontData(Buf: Pointer; Save: Boolean = False);
implementation

{$R *.dfm}

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If R=0 Then
 begin
  ShowMessage(Format('Division by zero! (%d/%d)',[Value,R]));
  Exit;
 end;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Function GetR(V: Word): Byte;
begin
 Result := (V and $1F) shl 3;
end;

Function GetG(V: Word): Byte;
begin
 Result := ((V and $3FF) shr 5) shl 3;
end;

Function GetB(V: Word): Byte;
begin
 Result := ((V and $7FFF) shr 10) shl 3;
end;

Function Color2GBA(Color: DWord): Word;
Type
 TBGRZ = Packed Record R, G, B, Z: Byte end;
begin
 With TBGRZ(Color) do Result := (B shr 3) shl 10 + (G shr 3) shl 5 + R shr 3;
end;

Function GBA2Color(Color: Word): DWord;
begin
 Result := GetB(Color) shl 16 + GetG(Color) shl 8 + GetR(Color);
end;

Function LoadFile(Name: String; var Pos: Pointer): Integer;
var F: File;
begin
  FileMode := fmOpenRead;
  Result:=-1;
  If not FileExists(Name) Then Exit;
  AssignFile(F,Name);
  Reset(F,1);
  Result:=FileSize(F);
  GetMem(Pos, Result);
  BlockRead(F, Pos^, Result);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
var F: File;
begin
  FileMode := fmOpenWrite;
  AssignFile(F,Name);
  Rewrite(F,1);
  BlockWrite(F, Pos^, Size);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Procedure GetGBApalette(Var Source, Dest; Count: Integer);
Var SP: PWord; DP: PCardinal;
begin
 SP := Addr(Source);
 DP := Addr(Dest);
 While Count > 0 do
 begin
  DP^ := GBA2Color(SP^);
  Inc(DP); Inc(SP);
  Dec(Count);
 end;
end;

Procedure SetGBApalette(Var Source, Dest; Count: Integer);
Var SP: PCardinal; DP: PWord; 
begin
 SP := Addr(Source);
 DP := Addr(Dest);
 While Count > 0 do
 begin
  DP^ := Color2GBA(SP^);
  Inc(DP); Inc(SP);
  Dec(Count);
 end;
end;

Function GetChar(var Char: TCharacter; H: Integer; P: Pointer; Put: Boolean = False): Integer;
var X,Y,W: Integer; B: ^Byte;
begin
  //H:=RoundBy(H,8);
  W:=RoundBy(Char.W,8);
  Result:=(W*H) div 2;
  B:=P;
  For Y:=0 To H-1 do
  begin
    For X:=0 To (W div 2)-1 do
    begin
      If Put Then
      begin 
        B^ := Char.Ch[Y,X*2] SHL 4;
        B^ := Char.Ch[Y,X*2+1] or B^;  Inc(B);
      end else
      begin
        Char.Ch[Y,X*2]   := B^ SHR 4;
        Char.Ch[Y,X*2+1] := B^ AND $F; Inc(B);
      end;
    end;
  end;
end;

Procedure CharsToDIB(var Chars: TChars; var Pic: TDIB; From: Boolean = False);
var n,m,l,X,Y: Integer; B: ^Byte;
begin
  X:=0; Y:=0;
  If not Assigned(Pic) Then
  begin
    Pic:=TDIB.Create;
    Pic.BitCount := 8;
    Pic.Width := CharWidth*16;
    Pic.Height := CharHeight*16;
    For n:=0 To 15 do
    begin
      Pic.ColorTable[n].rgbBlue  := (Palette[n] SHR 16) AND $FF;
      Pic.ColorTable[n].rgbGreen := (Palette[n] SHR 8)  AND $FF;
      Pic.ColorTable[n].rgbRed   :=  Palette[n]         AND $FF;
    end;
    Pic.UpdatePalette;
  end;
  For l:=0 To 255 do
  begin
    For m:=0 To CharHeight-1 do
    begin
      B:=Pic.ScanLine[Y+m];
      Inc(B,X);
      If From Then
        Move(B^,Chars[l].Ch[m,0],CharWidth)
      else
        Move(Chars[l].Ch[m,0],B^,CharWidth);
    end;
    Inc(X,CharWidth);
    If X>=CharWidth*16 Then
    begin
      X:=0; Inc(Y,CharHeight);
    end;
  end;

end;



Function GetLeft(Tile: TTile): Integer;   // Парам-пам-пам
var n: Integer;
begin
  For Result:=0 To 15 do
    For n:=0 To 15 do if Tile[n,Result]<>0 Then Exit;
end;


procedure TMainForm.PaletteSaveActionExecute(Sender: TObject);
Var F: File; I: Byte; Pal: Array[Byte] of TRGB; GBAPal: Array[0..15] of DWord;
const cExt: Array[1..2] of String = ('.act', '.rgb');
begin
 If SaveActDialog.Execute then
 begin
  AssignFile(F, ChangeFileExt(SaveActDialog.FileName, cExt[SaveActDialog.FilterIndex]));
  Rewrite(F, 1);
  If SaveActDialog.FilterIndex = 1 Then
  begin
    FillChar(Pal, SizeOf(Pal), 0);
    For I := 0 to 15 do
    begin
      Pal[I].R := TRGBA(Palette[I]).R;
      Pal[I].G := TRGBA(Palette[I]).G;
      Pal[I].B := TRGBA(Palette[I]).B;
    end;
    BlockWrite(F, Pal, SizeOf(Pal));
  end else
  begin
    SetGBAPalette(Palette, GBAPal, 16);
    BlockWrite(F, GBAPal, 32);
  end;
  CloseFile(F);
 end;
end;

procedure TMainForm.FileOpenActionExecute(Sender: TObject);
begin
 If not CheckSaved then Exit;
 If OpenDialog.Execute then Open(OpenDialog.FileName);
end;

procedure TMainForm.FileSaveActionExecute(Sender: TObject);
var F: File; n,m,Pos: Integer; SPtrs: TSmallPointerArray;
    Data: Array[0..$1884*3 - 1] of Byte;
begin

 If not Named then
 begin
  FileSaveAsActionExecute(Sender);
  Exit;
 end;
 ProcessFontData(@Data, True);
 AssignFile(F,FFileName);
 FileMode:=fmOpenWrite;
 Rewrite(F,1);
 //BlockWrite(F, Fonts, SizeOf(Fonts));
 //BlockWrite(F, Palette, SizeOf(Palette));
 BlockWrite(F, Data, SizeOf(Data));
 CloseFile(F);
 Saved:=True;
end;


procedure TMainForm.FileSaveAsActionExecute(Sender: TObject);
begin
 SaveDialog.FileName := FFileName;
 If SaveDialog.Execute then
 begin
  FFileName := SaveDialog.FileName;
  FileSaveActionExecute(Sender);
 end;
end;

procedure TMainForm.FileExitActionExecute(Sender: TObject);
begin
 Close;
end;

Type
 TFontDataInfo = Packed Record
  Address: Integer;
  Unk1: Word;
  TilesCount: Word;
  MapWidth: Word;
  MapHeight: Word;
  ChrWidth: Word;
  ChrHeight: Word;
  Unk2: Word;
  Unk3: Word;
  PalIndex: Integer;
  Zero: Integer;
 end;
 TFontCodeInfo = Packed Record
  CharsAddress: Integer;
  LensAddress: Integer;
  CharsCount: Integer;
 end;
 TGbaTile = Array[0..7, 0..3] of Byte;



procedure TMainForm.PaletteLoadActionExecute(Sender: TObject);
Type
 TPalX = Array[0..15] of TRGB;
Var F: File; PalX: TPalX; TX: Integer; R: DWord; Col: TRGBA;  GBAPal: Array[0..15] of DWord;
begin
 If OpenActDialog.Execute then
 begin
  AssignFile(F, OpenActDialog.FileName);
  Reset(F, 1);
  If RightStr(OpenActDialog.FileName,3)<>'rgb' Then
  begin
    BlockRead(F, PalX, SizeOf(TPalX), R);
    For TX := 0 to 15 do With PalX[TX] do
    begin
      Col.R := R;
      Col.G := G;
      Col.B := B;
      Col.A := 0;
      Palette[TX] := TColor(Col);
    end;
  end else
  begin
    BlockRead(F, GBAPal, 32);
    GetGBApalette(GBAPal,Palette,16);
  end;
  //Saved := False;
  UpdateDIBPalette;
  DrawPalette;
 end;
end;

procedure TMainForm.EditCopyActionExecute(Sender: TObject);
begin
 BufChar := Fonts[Cur, CurChar];
end;

procedure TMainForm.EditPasteActionExecute(Sender: TObject);
begin
 Fonts[Cur, CurChar] := BufChar;
 DrawChars;
 DrawChar;
 Saved := False;
end;

procedure TMainForm.EditClearActionExecute(Sender: TObject);
begin
 FillChar(Fonts[Cur, CurChar], SizeOf(TCharacter), 0);
 DrawChars;
 DrawChar;
 Saved := False;  
end;

procedure TMainForm.EditCopyToBitmapActionExecute(Sender: TObject);
Var
 AFormat: Word;
 AData: Cardinal;
 APalette: HPALETTE;
begin
 Clipboard.Open;
 try
  DIB2.SaveToClipboardFormat(AFormat, AData, APalette);
  Clipboard.SetAsHandle(AFormat, AData);
 finally
  Clipboard.Close;
 end;
end;

procedure TMainForm.EditPasteFromBitmapActionExecute(Sender: TObject);
Var Bitmap: TDIB; Y, H, W: Integer; B: ^Byte;
begin
 Bitmap := TDIB.Create;
 Clipboard.Open;
 try
  Bitmap.LoadFromClipboardFormat(CF_DIB, Clipboard.GetAsHandle(CF_DIB), 0);
  DIB2.Fill8bit(0);
  DIB2.Canvas.Draw(0, 0, Bitmap);
  With DIB2 do
  begin
   B := Addr(Fonts[Cur, CurChar].Ch);
   H := CharHeight; If H > Height then H := Height;
   W := CharWidth;  If W > Width then W := Width;
   If H > 16 then H := 16;
   If W > 16 then W := 16;
   For Y := 0 to H - 1 do
   begin
    Move(ScanLine[Y]^, B^, W);
    Inc(B, 16);
   end;
  end;
  Fonts[Cur, CurChar].W := CharWidth;
  DrawChars;
  DrawChar;
  Saved := False;
 finally
  Clipboard.Close;
 end;
 Bitmap.Free;
end;

procedure TMainForm.EditSaveToBitmapActionExecute(Sender: TObject);
begin
 If SaveBmpDialog.Execute then
  DIB2.SaveToFile(SaveBmpDialog.FileName);
end;

procedure TMainForm.EditLoadFromBitmapActionExecute(Sender: TObject);
Var Y, H, W: Integer; B: ^Byte; Bmp: TDIB;
begin
 If OpenBmpDialog.Execute then
 begin
  Bmp := TDIB.Create;
  Bmp.LoadFromFile(OpenBmpDialog.FileName);
  DIB2.Fill8bit(0);
  DIB2.Canvas.Draw(0, 0, Bmp);
  Bmp.Free;
  With DIB2 do
  begin
   B := Addr(Fonts[Cur, CurChar].Ch);
   H := CharHeight; If H > Height then H := Height;
   W := CharWidth;  If W > Width then W := Width;
   If H > 16 then H := 16;
   If W > 16 then W := 16;
   For Y := 0 to H - 1 do
   begin
    Move(ScanLine[Y]^, B^, W);
    Inc(B, 16);
   end;
  end;
  Fonts[Cur, CurChar].W := CharWidth;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditFlipHorisontalActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Fonts[Cur, CurChar] do
 begin
  WW := W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
  If WW < 1 then Exit;
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to WW do
    Ch[Y, WW - X] := Tile[Y, X];
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditFlipVerticalActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Fonts[Cur, CurChar] do
 begin
  WW := W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
  If WW < 1 then Exit;
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to WW do
    Ch[(CharHeight - 1) - Y, X] := Tile[Y, X];
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveUpActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Fonts[Cur, CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
  begin
   WW := Y - 1; If WW < 0 then WW := CharHeight - 1;
   For X := 0 to CharWidth - 1 do
    Ch[WW, X] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveDownActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Fonts[Cur, CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
  begin
   WW := Y + 1; If WW = CharHeight then WW := 0;
   For X := 0 to CharWidth - 1 do
    Ch[WW, X] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveLeftActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Fonts[Cur, CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to CharWidth - 1 do
   begin
    WW := X - 1; If WW < 0 then WW := CharWidth - 1;
    Ch[Y, WW] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveRightActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Fonts[Cur, CurChar] do
 begin
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to CharWidth - 1 do
   begin
    WW := X + 1; If WW = CharWidth then WW := 0;
    Ch[Y, WW] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

Var InsertPos: Integer = 0;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := CheckSaved;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var n: Integer;
begin
 FSaved := True;
 CharWidth := cCharWidth;
 CharHeight := cCharHeight;

 DIB1 := TDIB.Create;
 DIB1.PixelFormat := MakeDIBPixelFormat(8, 8, 8);
 DIB1.BitCount := 8;
 DIB1.Width := CharWidth * 16;
 DIB1.Height := CharHeight * 16;
 DIB1.Fill8bit(0);
 DIB2 := TDIB.Create;
 DIB2.PixelFormat := DIB1.PixelFormat;
 DIB2.BitCount := 8;
 DIB2.Width := CharWidth;
 DIB2.Height := CharHeight;
 UpdateDIBPalette;
 DrawPalette;
 DrawSquares;
 If (ParamCount > 0) and FileExists(ParamStr(1)) then Open(ParamStr(1));
end;

procedure TMainForm.DrawPalette;
Var I: Integer; PM: TPenMode;
begin
 With PaletteImage.Canvas do
 begin
  PM := Pen.Mode;
  For I := 0 to 15 do
  begin
   Brush.Color := Palette[I];
   FillRect(Bounds(0, I * 16, 16, 16));
   If I = CurCol then
   begin
    Brush.Style := bsClear;
    Pen.Color := Palette[0];
    Pen.Mode := pmNot;
    Pen.Width := 3;
    Rectangle(Bounds(0, I * 16, 16, 16));
    Pen.Width := 1;
    Pen.Mode := PM;
    Brush.Style := bsSolid;
   end;
  end;
 end;
end;

procedure TMainForm.DrawChars;
Var I, YY, XX, Y, ZX, ZY: Integer; B, BB: ^Byte; PM: TPenMode;
begin
 With DIB1 do
 begin
  I := 0; ZX := 0; ZY := 0;
  For YY := 0 to 15 do
  begin
   B := ScanLine[YY * CharHeight];
   For XX := 0 to 15 do With Fonts[Cur, I] do
   begin
    BB := Addr(B^);
    Inc(BB, XX * CharWidth);
    For Y := 0 to Integer(CharHeight) - 1 do
    begin
     Move(Ch[Y, 0], BB^, CharWidth);
     Dec(BB, WidthBytes);
    end;
    If I = CurChar then
    begin
     ZX := XX * 16;
     ZY := YY * 24;
    end;
    Inc(I);
   end;
  end;
 end;
 With CharsImage.Canvas do
 begin
  StretchDraw(ClipRect, DIB1);
  PM := Pen.Mode;
  Brush.Style := bsClear;
  Pen.Color := clRed;
  Pen.Mode := pmCopy;
  Pen.Width := 1;
  Rectangle(Bounds(ZX, ZY, 16, 24));
  Pen.Width := 1;
  Pen.Mode := PM;
  Brush.Style := bsSolid;
 end;
 StatusBar.Panels[0].Text := Char(CurChar);
 StatusBar.Panels[1].Text := '$' + IntToHex(CurChar, 2);
 StatusBar.Panels[2].Text := '#' + IntToStr(CurChar);
end;

procedure TMainForm.DrawChar;
Var Y, H, W, WW: Integer; B: ^Byte; PM: TPenMode;
begin
 With DIB2 do
 begin
  B := Addr(Fonts[Cur, CurChar].Ch);
  H := CharHeight; If H > Height then H := Height;
  W := CharWidth;  If W > Width then W := Width;
  If H > 24 then H := 24;
  If W > 16 then W := 16;
  For Y := 0 to H - 1 do
  begin
   Move(B^, ScanLine[Y]^, W);
   Inc(B, cCharWidth);
  end;
 end;
 With CharImage.Canvas, Fonts[Cur, CurChar] do
 begin
  StretchDraw(ClipRect, DIB2);
  PM := Pen.Mode;
  Pen.Color := clRed;//$FF00FF;
  Pen.Mode := pmMask;//pmMaskPenNot;
  Pen.Width := 2;
  WW := (256 div CharWidth);
  Rectangle(Bounds(W * WW, 0, WW, 384));
  Pen.Mode := PM;
 end;
end;

Function TMainForm.GetNamed: Boolean;
begin
 Result := FFileName <> '';
end;

Procedure TMainForm.SetSaved(Value: Boolean);
Const
 SavedConst: Array[False..True] of String = ('*', '');
begin
 FSaved := Value;
 If Named then
  Caption := Format('%s - [%s]%s',
    [Application.Title, LeftStr(ExtractFileName(FFileName),24), SavedConst[Value]]) Else
  Caption := Application.Title;
end;

procedure TMainForm.PaletteImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If Button = mbLeft then
 begin
  CurCol := Y div 16;
  DrawPalette;
 end;
end;

procedure TMainForm.PaletteImageDblClick(Sender: TObject);
begin
 ColorDialog.Color := Palette[CurCol];
 If ColorDialog.Execute then
 begin
  Palette[CurCol] := ColorDialog.Color;
  UpdateDIBPalette;
  DrawChars;
  DrawChar;
  DrawPalette;
  //Saved := False;
 end;
end;

procedure TMainForm.UpdateDIBPalette;
Var CT: TRGBQuads; I: Integer;
begin
 FillChar(CT, 1024, 0);
 For I := 0 to 15 do With TRGBA(Palette[I]), CT[I] do
 begin
  rgbRed := R;
  rgbGreen := G;
  rgbBlue := B;
  rgbReserved := A;
 end;
 With DIB1 do
 begin
  ColorTable := CT;
  UpdatePalette;
 end;
 With DIB2 do
 begin
  ColorTable := CT;
  UpdatePalette;
 end;
 DrawChars;
 DrawChar;
end;

procedure TMainForm.CharsImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If Button = mbLeft then
 begin
  X := X div 16;
  Y := Y div 24;
  CurChar := Y * 16 + X;
  DrawChars;
  DrawChar;
 end;
end;

procedure TMainForm.CharImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If ssCtrl in Shift then With Fonts[Cur, CurChar] do
 begin
  If X > 256 - 8 then
   W := CharWidth Else
   W := X div (256 div CharWidth);
  DrawChar;
  DrawChars;
  Saved := False;
 end Else If Button = mbRight then
 begin
  If X < 0 then Exit;
  If Y < 0 then Exit;
  If X >= CharImage.Width then Exit;
  If Y >= CharImage.Height then Exit;
  X := X div (256 div CharWidth); Y := Y div (384 div CharHeight);
  With Fonts[Cur, CurChar] do CurCol := Ch[Y, X];
  DrawPalette;
 end Else CharImageMouseMove(Sender, Shift, X, Y);
end;

procedure TMainForm.CharImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 If X >= CharImage.Width then Exit;
 If Y >= CharImage.Height then Exit;
  X := X div (256 div CharWidth); Y := Y div (384 div CharHeight);
 StatusBar.Panels.Items[4].Text := Format('X: %d; Y: %d',[X,Y]);
 If not (ssLeft in Shift) then Exit;
 If (ssCtrl in Shift) or (ssShift in Shift) then Exit;
 If X < 0 then Exit;
 If Y < 0 then Exit;
 With Fonts[Cur, CurChar] do Ch[Y, X] := CurCol;
 DrawChar;
 DrawChars;
 Saved := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
 DIB1.Free;
 DIB2.Free;
end;

function TMainForm.CheckSaved: Boolean;
begin
 Result := True;
 If not Saved then
 begin
  Case MessageDlg('Font has been modified. Save it?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
   mrYes: FileSaveActionExecute(NIL);
   mrCancel: Result := False;
  end;
 end;
end;


Function LoadFont(FileName: String): Boolean;
Var F: File; n: Integer;
    Data: Array[0..$1884*3 - 1] of Byte;
begin
  Result := False;
  If not FileExists(FileName) Then Exit;
  AssignFile(F,FileName);
  Reset(F, 1);
  If FileSize(F) < SizeOf(Data){SizeOf(Fonts) + SizeOf(Palette)} Then
  begin
    CloseFile(F);
    MessageDlg('Invalid file size!', mtError, [mbOK], 0);
    Exit;
  end;
  Reset(F,1);
  BlockRead(F, Data, SizeOf(Data));
  CloseFile(F);
  ProcessFontData(@Data);
  Result := True;
end;


procedure TMainForm.Open(const FileName: String);
begin
  If not LoadFont(FileName) Then  
    MessageDlg('Invalid font file!', mtError, [mbOk], -1)
  else
  begin
    DrawChar;
    DrawChars;
    FFileName := FileName;
  end;
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Caption:=IntToHex(Key,4);
  Case Key of
    $25: Dec(CurChar);
    $26: Dec(CurChar,16);
    $27: Inc(CurChar);
    $28: Inc(CurChar,16);
  end;
  If Key in [$25..$28] Then
  begin
    DrawChars;
    DrawChar;
  end;
end;

procedure TMainForm.EditSaveAllToBitmapExecute(Sender: TObject);
var Pic: TDIB; S: String;
begin
 If Length(FFileName)>4 Then
 begin
  S:=FFileName;
  SetLength(S,Length(S)-4);
  SaveBmpDialog.FileName := S+'.bmp';
 end;
 If SaveBmpDialog.Execute then
 begin
  CharsToDIB(Fonts[Cur],Pic);
  Pic.SaveToFile(SaveBmpDialog.FileName);
  Pic.Free;
 end;
end;

procedure TMainForm.EditLoadAllFromBitmapExecute(Sender: TObject);
var Pic: TDIB;
begin
 If OpenBmpDialog.Execute then
 begin
  Pic:=TDIB.Create;
  Pic.LoadFromFile(OpenBmpDialog.FileName);
  CharsToDIB(Fonts[Cur],Pic,True);
  Pic.Free;
  DrawChars;
  DrawChar;
 end;
end;

Procedure DrawSymb(var Symb: TSymb; var Ch: TTile; Write: Boolean = False);
var n,m,l,r: Integer; B1,B2,B3: Byte; WB,BB1,BB2: ^Byte;  c: Byte;
begin
  If Write Then
  begin
    For n:=0 To 23 do Symb[n]:=0;
  end;
  c:=0;
  For r:=0 To 2 do
  For l:=0 To 1 do
  begin
    For n:=0 To 3 do
    begin                  
      If (n div 2)*2=n Then
      begin
        If Write Then
        begin
          BB1:=Addr(Symb[r*8+l*2+(n div 2)]);
          BB2:=Addr(Symb[r*8+l*2+(n div 2)+4]);
        end else
        begin
          B1:=Symb[r*8+l*2+(n div 2)];
          B2:=Symb[r*8+l*2+(n div 2)+4];
        end;
      end;
      For m:=0 To 3 do
      begin
        WB := @Ch[m+4*r, n+l*4];
        If Write Then
        begin
          BB1^:=BB1^ or ((WB^ and 1) SHL C);
          BB2^:=BB2^ or (((WB^ and 2) SHR 1) SHL C);
          Inc(C); If C>7 Then C:=0;
        end else
        begin
          WB^:=((B1 and 1) Or (B2 SHL 1)) and 3;
          B1:=B1 SHR 1;
          B2:=B2 SHR 1;
        end;
      end;
    end;
  end;     
end;


procedure ProcessFontData(Buf: Pointer; Save: Boolean = False);
var S: ^TSymb; n,m, Num: Integer; B: ^Byte;
const
      cStep    = $1884;
      //1884, 18
begin
  For Num := 0 To 2 do
  begin                   
    S := Buf;
    Inc(DWord(S), cStep * Num + $80);
    For n:=0 To 255 do
    begin
      DrawSymb(S^, Fonts[Num, n].Ch, Save);
      Inc(S);
    end;
    B := Buf;
    Inc(B, cStep * Num);
    For n := 0 To 127 do
    begin
      If Save Then
      begin
        B^ := Fonts[Num, n*2].W and $F;
        B^ := B^ or (Fonts[Num, n*2+1].W SHL 4);
      end else
      begin
        Fonts[Num, n*2].W   := B^ AND $F;
        Fonts[Num, n*2+1].W := B^ SHR 4;
      end;
      Inc(B);
    end;
  end;
end;


procedure LoadFontFromRom(FileName: String; Save: Boolean = False);
const
  cFontPos = $51B098 - $80;
var
  Buf: Pointer;  Size: Integer;
begin
  Size := LoadFile(FileName, Buf);
  ProcessFontData(Pointer(LongWord(Buf) + cFontPos), Save);
  If Save Then
    SaveFile(FileName, Buf, Size);
end;

procedure TMainForm.EditLoadFromRomActionExecute(Sender: TObject);
begin
  If not OpenRomDialog.Execute Then Exit;
  LoadFontFromRom(OpenRomDialog.FileName);
  DrawChar;
  DrawChars;
  Saved := False;
end;

procedure TMainForm.RadioButton1Click(Sender: TObject);
begin
  Cur := 0; 
  DrawChar;
  DrawChars;
end;

procedure TMainForm.RadioButton2Click(Sender: TObject);
begin
  Cur := 1;   
  DrawChar;
  DrawChars;
end;

procedure TMainForm.RadioButton3Click(Sender: TObject);
begin
  Cur := 2;
  DrawChar;
  DrawChars;  
  DrawChar;
  DrawChars;
end;

procedure TMainForm.DrawSquares;
begin
  Sq0.Canvas.FillRect(Sq0.Canvas.ClipRect);
  Sq1.Canvas.FillRect(Sq0.Canvas.ClipRect);
  Sq2.Canvas.FillRect(Sq0.Canvas.ClipRect);
  Case Cur of
    0: Sq0.Canvas.TextOut(4,2,'1');
    1: Sq1.Canvas.TextOut(4,2,'2');
    2: Sq2.Canvas.TextOut(4,2,'3');
  end;
end;

procedure TMainForm.Sq0Click(Sender: TObject);
begin
  Cur := 0;
  DrawChar;
  DrawChars;
  DrawSquares;
end;

procedure TMainForm.Sq1Click(Sender: TObject);
begin
  Cur := 1;
  DrawChar;
  DrawChars;
  DrawSquares;
end;

procedure TMainForm.Sq2Click(Sender: TObject);
begin
  Cur := 2;
  DrawChar;
  DrawChars;
  DrawSquares;
end;

procedure TMainForm.FileNewActionExecute(Sender: TObject);
begin
  If not CheckSaved then Exit;
  FillChar(Fonts, SizeOf(Fonts), 0);
  DrawChar;
  DrawChars;
end;

procedure TMainForm.EditInsertToRomActionExecute(Sender: TObject);
begin
  If not SaveRomDialog.Execute Then Exit;
  LoadFontFromRom(SaveRomDialog.FileName, True);
end;

procedure TMainForm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  If ssCtrl in Shift Then
  begin
    Inc(Fonts[Cur, CurChar].W);
    Saved := False;
    DrawChars;
    DrawChar;
  end;
end;

procedure TMainForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  If ssCtrl in Shift Then
  begin
    Dec(Fonts[Cur, CurChar].W);
    Saved := False;
    DrawChars;
    DrawChar;
  end;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  MessageDlg('GUI Engine by Djinn'#9#9'http://magicteam.net/'#13#10'Editor Engine by HoRRoR'#9'http://consolgames.ru/', mtInformation, [mbOK], 0);
end;

end.
