unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, Menus, ExtCtrls, ActnList, ToolWin, ImgList, DIB,
  ExtDlgs, ClipBrd, StdCtrls, StrUtils, FontProporties, AtlasBuilder;

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
    OpenTexDialog: TOpenDialog;
    ExportFontDialog: TSaveDialog;
    ImportDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    OpenBmpDialog: TOpenPictureDialog;
    SaveBmpDialog: TSavePictureDialog;
    OpenActDialog: TOpenDialog;
    SaveActDialog: TSaveDialog;
    EditSaveAllToBitmap: TAction;
    EditLoadAllFromBitmap: TAction;
    EditSaveAllToBitmap1: TMenuItem;
    EditLoadAllFromBitmap1: TMenuItem;
    ToolButton20: TToolButton;
    FileSaveTableAction: TAction;
    ScrollBar: TScrollBar;
    Help1: TMenuItem;
    About1: TMenuItem;
    FileImportFontAction: TAction;
    N5: TMenuItem;
    ImportfromFF12ROM1: TMenuItem;
    FileExportFontAction: TAction;
    FileExportFontAction1: TMenuItem;
    EditFontProportiesAction: TAction;
    SaveWidthsAction: TAction;
    DefaultPalette1: TMenuItem;
    N6: TMenuItem;
    AddChar1: TMenuItem;
    EditAddCharAction: TAction;
    EditCharPropertiesAction: TAction;
    OpenDialog: TOpenDialog;
    EditKerningAction: TAction;
    EditKerningAction1: TMenuItem;
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
    procedure ScrollBarChange(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure About1Click(Sender: TObject);
    procedure EditFontProportiesActionExecute(Sender: TObject);
    procedure FileNewActionExecute(Sender: TObject);
    procedure DefaultPalette1Click(Sender: TObject);
    procedure EditAddCharActionExecute(Sender: TObject);
    procedure EditCharPropertiesActionExecute(Sender: TObject);
    procedure CharsImageDblClick(Sender: TObject);
    procedure FileImportFontActionExecute(Sender: TObject);
    procedure FileExportFontActionExecute(Sender: TObject);
    procedure EditKerningActionExecute(Sender: TObject);
  private
    FFileName: String;
    FSaved: Boolean;
    FImported: Boolean;
    Function GetNamed: Boolean;
    Procedure SetSaved(Value: Boolean);
  public
    function CheckSaved: Boolean;
    procedure DrawPalette;
    procedure DrawChars;
    procedure DrawChar;
    procedure DrawPanelText;
    property Saved: Boolean read FSaved write SetSaved;
    property Named: Boolean read GetNamed;
    property FileName: String read FFileName write FFileName;
    procedure UpdateDIBPalette;
    Function LoadFont(const FileName: String; TexName: String = ''): Boolean;
    Function ExportFont(const FileName: String; TexName: String = ''): Boolean;
    procedure Open(const FileName: String; TexName: String = '');
    Procedure Save(const FileName: String);
    Procedure FontInit;
  end;

  EFontError = Class(Exception);

const
  cCharWidth  = 64;
  cCharHeight = 64;
  //cFontHeight = 12;
  //cFontWidth  = 12;

Type
 TPalette = Array[0..15] of TColor;
 TTile = Array[0..cCharHeight-1, 0..cCharWidth-1] of Byte;
 TCharacter = Packed Record
  Ch: TTile;
 end;
 TChars = Array of TCharacter;
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

  TFloatRect = Packed Record
    Left, Top, Right, Bottom: Single;
  end;

  TCharRecord = Packed Record
    Code:     WideChar;
    Rect:     TFloatRect;
    Layer:    Byte;
    L, W, R, WW, HH, Y: ShortInt;
    InfoIndex: Word;
  end;
 

 TFontHeader  = Packed Record
  Signature: Array[0..3] of Char;

  Unk0, Width, Unk2, Height, Unk4, Unk5: Integer;
  Unk6: SmallInt;
  Unk7: Integer;
 end;
 PCharRecord = ^TCharRecord;

  TTexHeader = Packed Record
 	  Signature: LongWord;
	  Width, Height: Word;
	  Unk: Array[0..10] of LongWord;
  end;
  THash = Array[0..7] of Byte;

  TKerningData = Packed Record
    a, b: WideChar;
    c: Integer;
  end;

 TCLUT = Array[0..15] of Word;
 TFontData = Packed Record
  FontHeader: TFontHeader;
  TexHeader: TTexHeader;
  Hash: THash;
  ColorCount: LongWord;   
  Count: Integer;
  KerningCount: Integer;
  Name: String;
  CharData: Array of TCharRecord;
  KerningData: Array of TKerningData;
 end;
 {
 TCharInfo = Packed Record
    W: Byte;
    P: Byte;
 end;
 }

var
 FontData:                 TFontData;
 MainForm:                 TMainForm;
 Palette:                  TPalette;
 BufChar:                  TCharacter;
 BufCharData:              TCharRecord;
 CurCol:                   Byte;
 CurChar:                  Integer;
 CurChars:                 Integer;
 CharWidth, CharHeight:    Byte;
 Chars:                    TChars;
 DataPos, PalPos, CodePos: Integer;
 DIB1, DIB2:               TDIB;

implementation

Uses GbaUnit, CharProperties, Kerning;

{$R *.dfm}


Function Endian(var v): LongWord;
begin
  Result := ((LongWord(V) SHR 24) OR ((LongWord(V) SHR 8) AND $FF00) OR ((LongWord(V) SHL 8) AND $FF0000) OR (LongWord(V) SHL 24))
end;

Function EndianF(var v): Single;
var L: LongWord;
begin
  L := ((LongWord(V) SHR 24) OR ((LongWord(V) SHR 8) AND $FF00) OR ((LongWord(V) SHL 8) AND $FF0000) OR (LongWord(V) SHL 24));
  Result := PSingle(@L)^;
end;

Function EndianW(V: Word): Word;
begin
  Result := ((v SHR 8) OR (V SHL 8));
end;

Procedure EndianChar(var C: TCharRecord);
begin
  PWord(@C.Code)^ := EndianW(PWord(@C.Code)^);
  C.Rect.Left := EndianF(C.Rect.Left);
  C.Rect.Top := EndianF(C.Rect.Top);
  C.Rect.Right := EndianF(C.Rect.Right);
  C.Rect.Bottom := EndianF(C.Rect.Bottom);
  C.InfoIndex := EndianW(C.InfoIndex);
end;

Procedure EndianKerning(var Info: TKerningData);
begin
  PWord(@Info.a)^ := EndianW(PWord(@Info.a)^);
  PWord(@Info.b)^ := EndianW(PWord(@Info.b)^);
  Info.c := Endian(Info.c);

end;

Procedure EndianFontHeader(var H: TFontHeader);
begin

  With H do
  begin
    Width := Endian(Width);
    Unk0 := Endian(Unk0);
    Unk2 := Endian(Unk2);
    Height := Endian(Height);
    Unk4 := Endian(Unk4);
    Unk5 := Endian(Unk5);
	Unk6 := EndianW(Unk6);
    Unk7 := Endian(Unk7);
  end;
end;

Procedure EndianTexHeader(var H: TTexHeader);
var i: Integer;
begin
  H.Width := EndianW(H.Width);
  H.Height := EndianW(H.Height);
  For i := 0 To 10 do
    H.Unk[i] := Endian(H.Unk[i]);
end;

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

Function GetCode(N: Word): Word;
begin
  Result := $8000 or ((N SHL 2) and $1F00) or (N and $3F);
end;

(*
Function GetChar(var Char: TCharacter; P: Pointer; RowStride: Integer; Put: Boolean = False): Integer;
//var X,Y: Integer; B: ^Byte;
begin
   Result := 0;
end;
*)

Procedure SaveLayersToBitmap(const FileName: String; FontPixels: Pointer; LayerCount: Integer);
var DIB: TDIB; n: Integer;
begin
  DIB := TDIB.Create;
  DIB.BitCount := 8;
  DIB.Width := FontData.TexHeader.Width;
  DIB.Height := FontData.TexHeader.Height * LayerCount;
  Integer(DIB.ColorTable[0]) := Palette[0];
  Integer(DIB.ColorTable[1]) := Palette[1];
  Integer(DIB.ColorTable[2]) := Palette[2];
  DIB.UpdatePalette;
  For n := 0 To FontData.TexHeader.Height * LayerCount - 1 do
  begin
    Move(Pointer(LongWord(FontPixels) + LongWord(FontData.TexHeader.Width * n))^, DIB.ScanLine[n]^, FontData.TexHeader.Width);
  end;
  DIB.SaveToFile(FileName);
  DIB.Free;
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
    Pic.Height := CharHeight* (RoundBy(Length(Chars),16) div 16);
    FillChar(Pic.ScanLine[Pic.Height - 1]^, Pic.WidthBytes * Pic.Height, 0);
    For n:=0 To 15 do
    begin
      Pic.ColorTable[n].rgbBlue  := (Palette[n] SHR 16) AND $FF;
      Pic.ColorTable[n].rgbGreen := (Palette[n] SHR 8)  AND $FF;
      Pic.ColorTable[n].rgbRed   :=  Palette[n]         AND $FF;
    end;
    For n := 16 To 255 do
      Integer(Pic.ColorTable[n]) := 1;
    Pic.UpdatePalette;
  end;
  For l:=0 To High(Chars) do
  begin
    For m:=0 To CharHeight-1 do
    begin
      B:=Pic.ScanLine[Y+m];
      Inc(B,X);
      If From Then
        Move(B^,Chars[l].Ch[m,0],CharHeight)
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

{$WARN FOR_LOOP_VAR_UNDEF OFF}

Function GetLeft(Tile: TTile): Integer;   // Парам-пам-пам
var n: Integer;
begin
  For Result := 0 To 15 do
    For n := 0 To 15 do if Tile[n, Result] <> 0 Then Exit;
end;

Function GetRBound(C: TTile): Integer;
var m: Integer;
begin
  For Result := CharWidth - 1 downto 0 do
    For m := 0 To CharHeight - 1 do If C[m,Result]>0 Then Exit;
end;

Function GetUBound(C: TTile): Integer;
var m: Integer;
begin
  For Result := 0 to FontData.FontHeader.Height - 1 do
    For m := 0 To CharWidth - 1 do If C[Result, m] > 0 Then Exit;
end;

Function GetDBound(C: TTile): Integer;
var m: Integer;
begin
  For Result := CharHeight - 1 downto 0 do
    For m := 0 To CharWidth - 1 do If C[Result, m] > 0 Then Exit;
end;

{$WARN FOR_LOOP_VAR_UNDEF ON}

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



Procedure TMainForm.Save(const FileName: String);
var Stream: TFileStream; i: Integer;
begin
  Try
    Stream := TFileStream.Create(FileName, fmCreate);
    Stream.Write(FontData.FontHeader, SizeOf(TFontHeader));
    Stream.Write(FontData.TexHeader, SizeOf(TTexHeader));
    Stream.Write(FontData.Hash, SizeOf(THash));
    Stream.Write(FontData.ColorCount, 4);
    Stream.Write(FontData.Count, 4);
    Stream.Write(FontData.KerningCount, 4);
    i := Length(FontData.Name);
    Stream.Write(i, 4);
    Stream.Write(FontData.Name[1], i);
    Stream.Write(FontData.CharData[0], SizeOf(TCharRecord) * FontData.Count);
    Stream.Write(FontData.KerningData[0], SizeOf(TKerningData) * FontData.KerningCount);
    Stream.Write(Chars[0], SizeOf(TCharacter) * FontData.Count);
    Stream.Free;
    Saved := True;
  except
    MessageDlg('Error!', mtError, [mbOK], 0);
  end;
  FImported := False;

end;

procedure TMainForm.FileSaveActionExecute(Sender: TObject);
begin
 If not Named or FImported then
 begin
  FileSaveAsActionExecute(Sender);
  Exit;
 end;
 Save(FFileName);
end;


procedure TMainForm.FileSaveAsActionExecute(Sender: TObject);
begin
 SaveDialog.FileName := FFileName;
 If SaveDialog.Execute then
 begin
  FFileName := SaveDialog.FileName;
  FImported := False;
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
 BufChar := Chars[CurChar];
 BufCharData := FontData.CharData[CurChar];
end;

procedure TMainForm.EditPasteActionExecute(Sender: TObject);
begin
 Chars[CurChar] := BufChar;
 FontData.CharData[CurChar] := BufCharData;
 DrawChars;
 DrawChar;
 Saved := False;
end;

procedure TMainForm.EditClearActionExecute(Sender: TObject);
begin
 FillChar(Chars[CurChar], SizeOf(TCharacter), 0);
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
   B := Addr(Chars[CurChar].Ch);
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
  FontData.CharData[CurChar].W := CharWidth;
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
   B := Addr(Chars[CurChar].Ch);
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
  FontData.CharData[CurChar].W := CharWidth;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditFlipHorisontalActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
 begin
  WW := FontData.CharData[CurChar].W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
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
 With Chars[CurChar] do
 begin
  WW := FontData.CharData[CurChar].W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
  If WW < 1 then Exit;
  Move(Ch, Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to WW do
    Ch[(CharWidth - 1) - Y, X] := Tile[Y, X];
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveUpActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With Chars[CurChar] do
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
 With Chars[CurChar] do
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
 With Chars[CurChar] do
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
 With Chars[CurChar] do
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
begin


 //ShowMessage(IntToStr(SizeOf(ShortInt)));
 FSaved := True;
 CharWidth := cCharWidth;
 CharHeight := cCharHeight;

 //Palette[$0] := //$448844;
 FillChar(Palette, SizeOf(Palette), 1);
 Palette[$0] := $00FF00;
 Palette[$1] := $FFFFFF;
 Palette[$2] := $888888;
 Palette[$3] := $333333;
 Palette[$4] := $444444;
 Palette[$5] := $555555;
 Palette[$6] := $666666;
 Palette[$7] := $777777;
 Palette[$8] := $888888;
 Palette[$9] := $999999;
 Palette[$A] := $AAAAAA;
 Palette[$B] := $BBBBBB;
 Palette[$C] := $CCCCCC;
 Palette[$D] := $DDDDDD;
 Palette[$E] := $EEEEEE;
 Palette[$F] := $FFFFFF;

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

Procedure TMainForm.DrawPanelText();
var S, C: String;
begin              
 If CurChar > High(Chars) Then Exit;
 S := Format('$%.2x',[CurChar]);
 StatusBar.Panels[0].Text := Char(CurChar);
 StatusBar.Panels[1].Text := '$' + IntToHex(CurChar, 2);
 StatusBar.Panels[2].Text := '#' + IntToStr(CurChar);
 C := FontData.CharData[CurChar].Code;
 With Chars[CurChar] do StatusBar.Panels[3].Text :=
  Format('W: %d; %s; C: ''%s'' (%4.4x)',[FontData.CharData[CurChar].W,S,C, Word(FontData.CharData[CurChar].Code)]);
 With FontData.CharData[CurChar] do StatusBar.Panels[4].Text :=
  Format('L: %d, W: %d, R: %d, WW: %d, HH: %d, Y: %d, %f, %f',[L, W, R, WW, HH, Y, Rect.Left, Rect.Right]);
end;

procedure TMainForm.DrawChars;
Var I, YY, XX, Y, ZX, ZY: Integer; B, BB: ^Byte; PM: TPenMode;
 W, H: Integer;
begin
  W := CharWidth div 2;
  H := CharHeight div 2;
 If CurChar > High(Chars) Then CurChar := High(Chars);
 If (CurChar < CurChars) or (CurChar - CurChars > 256) Then
  CurChar := CurChars;
 With DIB1 do
 begin
  I := CurChars;
  ZX := 16 * W; ZY := 16 * H;
  For YY := 0 to 15 do
  begin
   B := ScanLine[YY * H];
   For XX := 0 to 15 do With Chars[I] do
   begin
    BB := B;
    Inc(BB, XX * W);

    For Y := 0 To H - 1 do
    begin
     If I > High(Chars) Then
       FillChar(BB^, W, 0)
     else
       Move(Ch[Y, 0], BB^, W);
     Dec(BB, WidthBytes);
    end;

    If I = CurChar then
    begin
     ZX := XX * 16;
     ZY := YY * 16;
    end;
    Inc(I);
   end;
  end;
 end;
 With CharsImage.Canvas do
 begin
  StretchDraw({ClipRect}Bounds(0,0,256,256), DIB1);
  PM := Pen.Mode;
  Brush.Style := bsClear;
  Pen.Color := $FFFFFF;
  Pen.Mode := pmCopy;
  Pen.Width := 1;
  Rectangle(Bounds(ZX, ZY, 16, 16));
  Pen.Width := 1;
  Pen.Mode := PM;
  Brush.Style := bsSolid;
  {
  For I := CurChars To CurChars + 256 do
  begin
    If (I < Length(Chars)) and Chars[I].N Then
    begin
      Brush.Color := clRed;
      Pen.Color   := clRed;
      YY := ((I - CurChars) div 16);
      XX := ((I - CurChars) - YY*16);
      MoveTo(XX*16 + 1,  YY*16 + 1);
      LineTo(XX*16 + 15, YY*16 + 15);
      MoveTo(XX*16 + 15, YY*16 + 1);
      LineTo(XX*16 + 1,  YY*16 + 15);
    end;
  end;
  }
 end;
 DrawPanelText;
end;

procedure TMainForm.DrawChar;
Var Y, H, W, WW: Integer; B: ^Byte; PM: TPenMode;
begin        
 If CurChar > High(Chars) Then Exit;
 With DIB2 do
 begin
  B := Addr(Chars[CurChar].Ch);
  H := CharHeight; If H > Height then H := Height;
  W := CharWidth;  If W > Width then W := Width;
  If H > cCharHeight then H := cCharHeight;
  If W > cCharWidth then W := cCharWidth;
  For Y := 0 to H - 1 do
  begin
   Move(B^, ScanLine[Y]^, W);
   Inc(B, cCharHeight{16});
  end;
 end;
 With CharImage.Canvas do
 begin
  StretchDraw(ClipRect, DIB2);
  PM := Pen.Mode;
  Pen.Color := $FF00FF;
  Pen.Mode := pmMaskPenNot;
  Pen.Width := 2;
  WW := (256 div CharWidth);
  Pen.Width := 1;
  MoveTo(FontData.CharData[CurChar].W * WW, 0);
  LineTo(FontData.CharData[CurChar].W * WW, 256);
  MoveTo(-FontData.CharData[CurChar].L * WW, 0);
  LineTo(-FontData.CharData[CurChar].L * WW, 256);
  //Rectangle(Bounds(W * WW, 0, WW, 256));
  //Pen.Color := $00FF00;
  //Rectangle(Bounds(W * WW, 0, WW, 256));
  Pen.Color := $0000FF;
  Rectangle(Bounds((FontData.CharData[CurChar].W + FontData.CharData[CurChar].R) * WW, 0, WW, 256));
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
//var SelChar: Integer;
begin
 If Button = mbLeft then
 begin
  X := X div 16;
  Y := Y div 16;
  CurChar := Y * 16 + X + CurChars;
  DrawChars;
  DrawChar;
 end else
 If Button = mbRight Then
 begin
//  X := X div 16;
//  Y := Y div 16;
  {
  SelChar := Y * 16 + X + CurChars;
  If SelChar <= High(Chars) Then
    Chars[SelChar].N := not Chars[SelChar].N;
  }
  DrawChars;
  DrawChar;
 end;
end;

procedure TMainForm.CharImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//var WW: Integer;
begin
 If ssCtrl in Shift then With Chars[CurChar] do
 begin
  //WW := FontData.CharData[CurChar].W;
  If X > 256 - 8 then
   FontData.CharData[CurChar].W := CharWidth Else
   FontData.CharData[CurChar].W := X div (256 div CharWidth);
  //Dec(R, W - WW);
  //If FontData.CharData[CurChar].W < 0 Then FontData.CharData[CurChar].W := 0;
  //If FontData.CharData[CurChar].W > 15 Then FontData.CharData[CurChar].W := 15;
  DrawChars;
  DrawChar;
  Saved := False;
 end Else If Button = mbRight then
 begin
  If X < 0 then Exit;
  If Y < 0 then Exit;
  If X >= CharImage.Width then Exit;
  If Y >= CharImage.Height then Exit;
  X := X div (256 div CharWidth); Y := Y div (256 div CharHeight);
  With Chars[CurChar] do CurCol := Ch[Y, X];
  DrawPalette;
 end Else CharImageMouseMove(Sender, Shift, X, Y);
end;

procedure TMainForm.CharImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 If X >= CharImage.Width then Exit;
 If Y >= CharImage.Height then Exit;
  X := X div (256 div CharWidth); Y := Y div (256 div CharWidth);
 StatusBar.Panels.Items[4].Text := Format('X: %d; Y: %d',[X,Y]);
 If not (ssLeft in Shift) then Exit;
 If (ssCtrl in Shift) or (ssShift in Shift) then Exit;
 If X < 0 then Exit;
 If Y < 0 then Exit;

 //If (Y >= FontData.Header.Height) Then Exit;
 With Chars[CurChar] do Ch[Y, X] := CurCol;
 DrawChars;
 DrawChar;
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


Function HashToStr(Hash: THash): String;
var i: Integer;
begin
  Result := '';
  For i := 0 To 7 do
    Result := Result + IntToHex(Hash[i], 2);
end;


Type TArr = Array[Word] of Byte;
    PArr = ^TArr;

Procedure DecodeImage(Src, Dest: Pointer; Width, Height: Integer);
var s: PByte; d: PArr absolute Dest; i, j, n, k: Integer;
begin
  s := src;
  d := dest;
  For j := 0 To height div 8 - 1 do
  begin
    For i := 0 To width div 8 - 1 do
    begin
      For n := 0 To 7 do
      begin
        For k := 0 To 3 do
        begin
          d[(j*8+n)*width + i*8 + k*2 + 1] := s^ AND 3;
          d[(j*8+n)*width + i*8 + k*2 + 1 + width * height] := (s^ SHR 2) AND 3;
          d[(j*8+n)*width + i*8 + k*2 + 0] := (s^ SHR 4) AND 3;
          d[(j*8+n)*width + i*8 + k*2 + 0 + width * height] := (s^ SHR 6) AND 3;
          Inc(s);
        end;
      end;
    end;
  end;
end;

Procedure EncodeImage(Src, Dest: Pointer; Width, Height: Integer);
var s: PByte; d: PArr absolute Dest; i, j, n, k: Integer;
begin
  s := dest;
  d := src;
  For j := 0 To height div 8 - 1 do
  begin
    For i := 0 To width div 8 - 1 do
    begin
      For n := 0 To 7 do
      begin
        For k := 0 To 3 do
        begin
          s^ := d[(j*8+n)*width + i*8 + k*2 + 1] AND 3;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 1 + width * height] AND 3) SHL 2;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 0] AND 3) SHL 4;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 0 + width * height] AND 3) SHL 6;
          Inc(s);
        end;
      end;
    end;
  end;
end;

Procedure DecodeImage1bpp(Src, Dest: Pointer; Width, Height: Integer);
var s: PByte; d: PArr absolute Dest; i, j, n, k: Integer;
begin
  s := src;
  d := dest;
  For j := 0 To height div 8 - 1 do
  begin
    For i := 0 To width div 8 - 1 do
    begin
      For n := 0 To 7 do
      begin
        For k := 0 To 3 do
        begin
          d[(j*8+n)*width + i*8 + k*2 + 1] := s^ AND 1;
          d[(j*8+n)*width + i*8 + k*2 + 1 + width * height * 1] := (s^ SHR 1) AND 1;
          d[(j*8+n)*width + i*8 + k*2 + 1 + width * height * 2] := (s^ SHR 2) AND 1;
          d[(j*8+n)*width + i*8 + k*2 + 1 + width * height * 3] := (s^ SHR 3) AND 1;
          d[(j*8+n)*width + i*8 + k*2 + 0] := (s^ SHR 4) AND 1;
          d[(j*8+n)*width + i*8 + k*2 + 0 + width * height * 1] := (s^ SHR 5) AND 1;
          d[(j*8+n)*width + i*8 + k*2 + 0 + width * height * 2] := (s^ SHR 6) AND 1;
          d[(j*8+n)*width + i*8 + k*2 + 0 + width * height * 3] := (s^ SHR 7) AND 1;
          Inc(s);
        end;
      end;
    end;
  end;
end;

Procedure EncodeImage1bpp(Src, Dest: Pointer; Width, Height: Integer);
var s: PByte; d: PArr absolute Dest; i, j, n, k: Integer;
begin
  s := dest;
  d := src;
  For j := 0 To height div 8 - 1 do
  begin
    For i := 0 To width div 8 - 1 do
    begin
      For n := 0 To 7 do
      begin
        For k := 0 To 3 do
        begin
          s^ := d[(j*8+n)*width + i*8 + k*2 + 1] AND 1;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 1 + width * height * 1] AND 1) SHL 1;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 1 + width * height * 2] AND 1) SHL 2;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 1 + width * height * 3] AND 1) SHL 3;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 0] AND 1) SHL 4;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 0 + width * height * 1] AND 1) SHL 5;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 0 + width * height * 2] AND 1) SHL 6;
          s^ := s^ or (d[(j*8+n)*width + i*8 + k*2 + 0 + width * height * 3] AND 1) SHL 7;
          Inc(s);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.Open(const FileName: String; TexName: String = '');
var Stream: TFileStream; i: Integer;
begin

  try
    Stream := TFileStream.Create(FileName, fmOpenRead);
    Stream.Read(FontData.FontHeader, SizeOf(TFontHeader));
    Stream.Read(FontData.TexHeader, SizeOf(TTexHeader));
    Stream.Read(FontData.Hash, SizeOf(THash));
    Stream.Read(FontData.ColorCount, 4);
    Stream.Read(FontData.Count, 4);
    Stream.Read(FontData.KerningCount, 4);
    Stream.Read(i, 4);
    SetLength(FontData.Name, i);
    SetLength(FontData.CharData, FontData.Count);
    SetLength(Chars, FontData.Count);
    SetLength(FontData.KerningData, FontData.KerningCount);
    Stream.Read(FontData.Name[1], i);
    Stream.Read(FontData.CharData[0], SizeOf(TCharRecord) * FontData.Count);
    Stream.Read(FontData.KerningData[0], SizeOf(TKerningData) * FontData.KerningCount);
    Stream.Read(Chars[0], SizeOf(TCharacter) * FontData.Count);
    Stream.Free;
  except
    //Stream.Free;
    ShowMessage('Error!');
  end;
  FontInit();
  DrawChars;
  DrawChar;
  FFileName := FileName;
  Saved := True;
  FImported := False;

end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Caption:=IntToHex(Key,4);
  Case Key of
    VK_NEXT:
         If ScrollBar.Position + 16 > ScrollBar.Max Then
           ScrollBar.Position := ScrollBar.Max
         else
         begin
           Inc(CurChar, 256);
           ScrollBar.Position := ScrollBar.Position + 16;
         end;
    VK_PRIOR:
         If ScrollBar.Position - 16 < 0 Then
           ScrollBar.Position := 0
         else
         begin          
           Dec(CurChar, 256);
           ScrollBar.Position := ScrollBar.Position - 16;
         end;
    VK_LEFT: Dec(CurChar);
    VK_UP: Dec(CurChar,16);
    VK_RIGHT: Inc(CurChar);
    VK_DOWN: Inc(CurChar,16);
    VK_RETURN: EditCharPropertiesActionExecute(nil);
  end;
  If Key in [$25..$28] Then
  begin
    If CurChar < 0 Then CurChar := High(Chars) else
    If CurChar > High(Chars) Then CurChar := 0;
    If (abs((CurChar+1) div 16 - ScrollBar.Position) >= 15)
    or (ScrollBar.Position > CurChar div 16) Then
      ScrollBar.Position := RoundBy((CurChar+1) - 256, 16) div 16;
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
  CharsToDIB(Chars,Pic);
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
  CharsToDIB(Chars,Pic,True);
  Pic.Free;                           
  Saved := False;
  DrawChars;
  DrawChar;
 end;
end;

procedure TMainForm.ScrollBarChange(Sender: TObject);
begin
  CurChars := ScrollBar.Position * 16;
  DrawChars;
  DrawChar;
end;

procedure TMainForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  If (ssCtrl in Shift) and (ssShift in Shift) Then
  begin
    Inc(FontData.CharData[CurChar].L);
    Saved := False;
    DrawChars;
    DrawChar;
  end else
  If ssCtrl in Shift Then
  begin
    Dec(FontData.CharData[CurChar].W);
    If FontData.CharData[CurChar].W < 0 Then
      FontData.CharData[CurChar].W := 0
    else
      Saved := False;
    DrawChars;
    DrawChar;
  end else   
  If ssShift in Shift Then
  begin 
    Dec(FontData.CharData[CurChar].R);
    Saved := False;
    DrawChars;
    DrawChar;    
  end else
  If ScrollBar.Position > 0 Then
    ScrollBar.Position := ScrollBar.Position - 1;
end;

procedure TMainForm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin      
  If (ssCtrl in Shift) and (ssShift in Shift) Then
  begin
    Dec(FontData.CharData[CurChar].L);
    Saved := False;
    DrawChars;
    DrawChar;
  end else
  If ssCtrl in Shift Then
  begin
    Inc(FontData.CharData[CurChar].W);
    Saved := False;
    DrawChars;
    DrawChar;
  end else
  If ssShift in Shift Then
  begin 
    Inc(FontData.CharData[CurChar].R);
    Saved := False;
    DrawChars;
    DrawChar;    
  end else
  If ScrollBar.Position < ScrollBar.Max Then
    ScrollBar.Position := ScrollBar.Position + 1;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  //MessageDlg('GUI Engine by Djinn'#9#9'http://magicteam.net/'#13#10'Editor Engine by HoRRoR'#9'http://consolgames.ru/', mtInformation, [mbOK], 0);
  MessageDlg('GUI Engine by Djinn		http://magicteam.net/'+#13+#10+'Editor Engine by HoRRoR	http://consolgames.ru/'+#13+#10+''+#13+#10+'RightClick 		- disable/enable char'+#13+#10+'Ctrl+LeftClick/Wheel 	- change width', mtInformation, [mbOK], 0);
end;

procedure TMainForm.EditFontProportiesActionExecute(Sender: TObject);
begin

  If PropForm.Show(@FontData.FontHeader.Height, @FontData.Count) Then
  begin
    SetLength(Chars, FontData.Count);
    SetLength(FontData.CharData, FontData.Count);
    FontInit;
    If CurChar > High(Chars) Then
      CurChar := High(Chars);
    If CurChars > High(Chars) Then
      CurChars := RoundBy(High(Chars),16) div 16 - 16;
    If CurChars < 0 Then CurChars := 0;
    DrawChars;
    DrawChar;
  end;

end;

Function Max(a, b: Integer): Integer;
begin
  If a > b Then
    Result := a
  else
    Result := b;
end;

procedure TMainForm.FontInit;
var WH: Integer;
begin

   Case Max(FontData.FontHeader.Height, FontData.FontHeader.Width)  of
    01..07: WH:=8;
    08..15: WH:=16;
    16..31: WH:=32;
    32..64: WH:=64;
    else
      WH := 0;
   end;

  //WH := 32;
   CharWidth := WH;
   CharHeight := WH;
   DIB2.Width := CharWidth;
   DIB2.Height := CharHeight;
   DIB1.Width := CharWidth * 16 div 2;
   DIB1.Height := CharHeight * 16 div 2;
   //DIB2.Width := CharWidth;
   //DIB2.Height := CharHeight;
   If Length(Chars) > 256 Then
     ScrollBar.Max := RoundBy(Length(Chars) - 256, 16) div 16
   else
     ScrollBar.Max := 0;
end;

procedure TMainForm.FileNewActionExecute(Sender: TObject);
//var H,B: Byte; C: Word;
begin
{
  If not CheckSaved Then Exit;
  H := FontData.Height;
  B := FontData.BitCount;
  C := FontData.Count;
  If PropForm.Show(@H, @B, @C) Then
  begin
    FillChar(FontData, SizeOf(FontData), 0);
    FontData.Count := C;
    FontData.Height := H;
    FontData.BitCount := B;
    SetLength(Chars, FontData.Count);
    FillChar(Chars[0], SizeOf(TCharacter)*Length(Chars), 0);
    FontInit;
    If CurChar > High(Chars) Then
      CurChar := High(Chars);
    If CurChars > High(Chars) Then
      CurChars := RoundBy(High(Chars),16) div 16 - 16;
    If CurChars < 0 Then CurChars := 0;
    Saved := False;
    DrawChars;
    DrawChar;
  end;
  }
end;

Function FmtToStr(S: String): String;
var n: Integer;
begin
  Result := '';
  n := 1;
  While n <= Length(S) do
  begin
    If S[n] = '\' Then
    begin
      Inc(n);
      If n>Length(S) Then
      begin
        EFontError.CreateFmt('Missing terminating character: %s', [S]);
        Exit;
      end;
      Case S[n] of
        '\': Result := Result + '\';
        'n': Result := Result + #$0D#$0A;
        'r': Result := Result + #$0D;
        't': Result := Result + #$09;
        'f': Result := Result + #$0C;
        'a': Result := Result + #$07;
        'e': Result := Result + #$1B;
        '0': Result := Result + #0;
        else
          Result := Result + S[n];
      end;
    end else
      Result := Result + S[n];
    Inc(n);
  end;
end;


procedure TMainForm.DefaultPalette1Click(Sender: TObject);
begin
 ZeroMemory(@Palette, SizeOf(Palette));
 Palette[0] := 0;
 Palette[1] := $FFFFFF;
 Palette[2] := $A0A0A0;
 Palette[3] := $808080;
 UpdateDIBPalette;
 DrawPalette;
 //DrawChar;
 //DrawChars;
end;

procedure TMainForm.EditAddCharActionExecute(Sender: TObject);
begin
  Inc(FontData.Count);
  SetLength(FontData.CharData, FontData.Count);
  With FontData.CharData[FontData.Count - 1] do
  begin
    Code := WideChar('?');
    W := 0;
    //Unk2 := $41;
  end;
  If not CharPropForm.Show(FontData.CharData[FontData.Count - 1]) Then
  begin
    Dec(FontData.Count);
    SetLength(FontData.CharData, FontData.Count);
  end else
  begin
    Saved := False;
    CurChar := FontData.Count - 1;
    SetLength(Chars, FontData.Count);
    FillChar(Chars[CurChar], SizeOf(TCharacter), 0);
    DrawChars;
    DrawChar;
  end;
end;

procedure TMainForm.EditCharPropertiesActionExecute(Sender: TObject);
begin
  If CharPropForm.Show(FontData.CharData[CurChar]) Then
    Saved := False;
end;

procedure TMainForm.CharsImageDblClick(Sender: TObject);
begin
  If CurChar >= 0 Then
    EditCharPropertiesActionExecute(nil);
end;

Function ShowRect(Rect: TRect): TRect;
begin
  ShowMessage(Format('%d %d %d %d', [Rect.Left, Rect.Top, Rect.Right, Rect.Bottom]));
  Result := Rect;
end;

procedure TMainForm.FileImportFontActionExecute(Sender: TObject);
begin
 If not CheckSaved then Exit;
 If ImportDialog.Execute then LoadFont(ImportDialog.FileName);
end;

function TMainForm.ExportFont(const FileName: String; TexName: String): Boolean;
Type
  TCharRec = Record
    Char: ^TCharRecord;
    Index, W, H, Y, Layer: Integer;
    Skip: Boolean;
    Rect: TRect;
  end;
var CharList: Array of TCharRec; CharData: Array of TCharRecord; KerningData: Array of TKerningData;

  procedure SortCharList();
  var i, j: Integer; Tmp: TCharRec;
  begin
    For i := 0 To High(CharList) do
    begin
      For j := i + 1 To High(CharList) do
      begin
        If CharList[j].W * CharList[j].H > CharList[i].W * CharList[i].H Then
        begin
          Tmp := CharList[j];
          CharList[j] := CharList[i];
          CharList[i] := Tmp;
        end;
      end;
    end;
  end;
  procedure SortKerningData();
  var i, j: Integer; Tmp: TKerningData;
  begin   
    For i := 0 To High(KerningData) do
    begin
      For j := i + 1 To High(KerningData) do
      begin
        If (KerningData[j].a < KerningData[i].a) and (KerningData[j].b < KerningData[i].b) Then
        begin
          Tmp := KerningData[j];
          KerningData[j] := KerningData[i];
          KerningData[i] := Tmp;
        end;
      end;
    end;
  end;
  procedure SortCharData();
  var i, j: Integer; Tmp: TCharRecord;
  begin   
    For i := 0 To High(CharData) do
    begin
      For j := i + 1 To High(CharData) do
      begin
        If CharData[j].Code < CharData[i].Code Then
        begin
          Tmp := CharData[j];
          CharData[j] := CharData[i];
          CharData[i] := Tmp;
        end;
      end;
    end;
  end;
var  i, j, l, x, y, LayerCount: Integer; Trees: Array of TAtlasTree; Node: TNode;
  Pixels, ImageData: PByte; SkipChar: Boolean;
  FontHeader: TFontHeader; TexHeader: TTexHeader;
  Stream: TFileStream;
begin
  If TexName = '' Then
    TexName := ExtractFilePath(FileName) + HashToStr(FontData.Hash) + '.TXTR';

  SetLength(CharList, FontData.Count);
  For i := 0 To High(CharList) do
  begin
    j := GetRBound(Chars[i].Ch);
    If j >= 0 Then
      FontData.CharData[i].WW := j + 1;
    j := GetUBound(Chars[i].Ch);
    y := j;
    If j >= 0 Then
      FontData.CharData[i].Y := FontData.FontHeader.Height - j;
    j := GetDBound(Chars[i].Ch);
    If j >= 0 Then
      FontData.CharData[i].HH := j - y + 1;

    CharList[i].W := FontData.CharData[i].WW + 1;
    CharList[i].H := FontData.CharData[i].HH + 1;
    CharList[i].Y := FontData.FontHeader.Height - FontData.CharData[i].Y;
    CharList[i].Char := @FontData.CharData[i];
    CharList[i].Index := i;
    CharList[i].Skip := False;
  end;
  SortCharList();
  If FontData.ColorCount > 2 Then
    LayerCount := 2
  else
    LayerCount := 4;

  SetLength(Trees, LayerCount);
  For i := 0 To High(Trees) do
    Trees[i] := TAtlasTree.Create(FontData.TexHeader.Width, FontData.TexHeader.Height); 

  l := 0;
  For i := 0 To High(CharList) do
  begin

    SkipChar := False;
    For j := 0 To i - 1 do
    begin
      If (CharList[i].W = CharList[j].W) and (CharList[i].H = CharList[j].H) and CompareMem(@Chars[CharList[i].Index].Ch, @Chars[CharList[j].Index].Ch, SizeOf(TTile)) Then
      begin
        CharList[i].Rect := CharList[j].Rect;
        CharList[i].Layer := CharList[j].Layer;
        CharList[i].Skip := True;
        SkipChar := True;
      end;
    end;
    If SkipChar Then Continue;

    Node := nil;
    For j := l To LayerCount - 1 do
    begin
      Node := Trees[j].Insert(CharList[i].W, CharList[i].H);
      If Node <> nil Then break;
    end;
    If Node = nil Then
    begin
      For j := 0 To l - 1 do
      begin
        Node := Trees[j].Insert(CharList[i].W, CharList[i].H);
        If Node <> nil Then break;
      end;
    end;
    If Node = nil Then break;
    CharList[i].Rect := Node.Rect;
    CharList[i].Layer := j;

    Inc(l);
    If l >= LayerCount Then l := 0;
  end;            
  If i < FontData.Count Then MessageDlg('Fuuuuuuck!', mtError, [mbOK], 0);
  For i := 0 To High(Trees) do
    Trees[i].Free;

  GetMem(Pixels, FontData.TexHeader.Width * FontData.TexHeader.Height * LayerCount);
  FillChar(Pixels^, FontData.TexHeader.Width * FontData.TexHeader.Height * LayerCount, 0);
  For i := 0 To High(CharList) do
  begin
    If CharList[i].Skip Then Continue;
    For j := 0 To CharList[i].H - 1 do With FontData.TexHeader do
      Move(Chars[CharList[i].Index].Ch[CharList[i].Y + j, 0],
        Pointer(LongWord(Pixels) + LongWord(Width * Height * CharList[i].Layer + Width * CharList[i].Rect.Top + Width * j + CharList[i].Rect.Left))^,
        CharList[i].W);
  end;
  //SaveLayersToBitmap('Test.bmp', Pixels, LayerCount);
  GetMem(ImageData, FontData.TexHeader.Width * FontData.TexHeader.Height * LayerCount div 4);
  If FontData.ColorCount > 2 Then
    EncodeImage(Pixels, ImageData, FontData.TexHeader.Width, FontData.TexHeader.Height)
  else
    EncodeImage1bpp(Pixels, ImageData, FontData.TexHeader.Width, FontData.TexHeader.Height);
  FreeMem(Pixels);
                  
  SetLength(KerningData, FontData.KerningCount);
  For i := 0 To High(KerningData) do
    KerningData[i] := FontData.KerningData[i];
  SortKerningData();

  For i := 0 To High(CharList) do
  begin
    CharList[i].Char^.Rect.Left := CharList[i].Rect.Left / FontData.TexHeader.Width;
    CharList[i].Char^.Rect.Top := CharList[i].Rect.Top / FontData.TexHeader.Height;
    CharList[i].Char^.Rect.Right := CharList[i].Rect.Right / FontData.TexHeader.Width;
    CharList[i].Char^.Rect.Bottom := CharList[i].Rect.Bottom / FontData.TexHeader.Height;
    CharList[i].Char^.Layer := CharList[i].Layer;

    CharList[i].Char^.WW := CharList[i].Rect.Right - CharList[i].Rect.Left;
  end;
  For i := 0 To FontData.Count - 1 do
  begin
    For j := 0 To FontData.KerningCount - 1 do
      If KerningData[j].a = FontData.CharData[i].Code Then
        break;
    FontData.CharData[i].InfoIndex := j;
  end;

  FontHeader := FontData.FontHeader;
  TexHeader := FontData.TexHeader;
  EndianFontHeader(FontHeader);
  EndianTexHeader(TexHeader);

  SetLength(CharData, FontData.Count);
  For i := 0 To High(CharData) do
    CharData[i] := FontData.CharData[i];
  SortCharData();
  For i := 0 To High(CharData) do
    EndianChar(CharData[i]);

  SetLength(KerningData, FontData.KerningCount);
  For i := 0 To High(KerningData) do
    EndianKerning(KerningData[i]);


  Stream := TFileStream.Create(FileName, fmCreate);
  Stream.Write(FontHeader, SizeOf(FontHeader));
  Stream.Write(FontData.Name[1], Length(FontData.Name));
  i := 0;
  Stream.Write(i, 1);
  Stream.Write(FontData.Hash, SizeOf(THash));

  i := Endian(FontData.ColorCount);
  Stream.Write(i, 4);
  i := Endian(FontData.Count);
  Stream.Write(i, 4);
  Stream.Write(CharData[0], FontData.Count * SizeOf(TCharRecord));
  i := Endian(FontData.KerningCount);
  Stream.Write(i, 4);
  Stream.Write(KerningData[0], FontData.KerningCount * SizeOf(TKerningData));
  Stream.Free;

  Stream := TFileStream.Create(TexName, fmCreate);
  Stream.Write(TexHeader, SizeOf(TexHeader));
  Stream.Write(ImageData^, FontData.TexHeader.Width * FontData.TexHeader.Height * LayerCount div 4);
  Stream.Free;

  Finalize(CharData);
  Finalize(KerningData);

  FreeMem(ImageData);
end;




function TMainForm.LoadFont(const FileName: String; TexName: String = ''): Boolean;
Var
 n, y, w{, Size}: Integer;
// Buf: Pointer;
// CharData: Array of Byte;
 //Ptrs:     Array of DWord;
// Pos:      DWord;
 //WidthPos, ImagePos,
// Count: Integer;
 Stream:  TMemoryStream;
// Widths: Array of Byte;
 C: Char;
 //S1, S2: String;
  Pixels, FontPixels: Pointer;
  Rect: TRect;
//  F: Single;
//  List: TStringList;
//  DIB: TDIB;
 LayerCount: Integer;
begin
  Result := False;

  try
    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(FileName);
    Stream.Read(FontData.FontHeader, SizeOf(TFontHeader));
    EndianFontHeader(FontData.FontHeader);

    FontData.Name := '';
    While True Do
    begin
      Stream.Read(C, 1);
      if(C = #0) Then break;
      FontData.Name := FontData.Name + C;
    end;
    Stream.Read(FontData.Hash, SizeOf(THash));
    Stream.Read(FontData.ColorCount, 4);
    FontData.ColorCount := Endian(FontData.ColorCount);
    LayerCount := 2;
    Case FontData.ColorCount of
      3..4: LayerCount := 2;
      1..2: LayerCount := 4;
    end;
    Stream.Read(FontData.Count, 4);
    FontData.Count := Endian(FontData.Count);
    SetLength(FontData.CharData, FontData.Count);
    Stream.Read(FontData.CharData[0], SizeOf(TCharRecord) * FontData.Count);
    For n := 0 To FontData.Count - 1 do
      EndianChar(FontData.CharData[n]);

    //ShowMessage(IntToHex(SizeOf(TCharRecord), 8));
    //ShowMessage(IntToHex(Stream.Position, 8));

    Stream.Read(FontData.KerningCount, 4);
    FontData.KerningCount := Endian(FontData.KerningCount);
    SetLength(FontData.KerningData, FontData.KerningCount);
    Stream.Read(FontData.KerningData[0], SizeOf(TKerningData) * FontData.KerningCount);

    //List := TStringList.Create;
    For n := 0 To FontData.KerningCount - 1 do// With FontData.KerningData[n] do
    begin
      EndianKerning(FontData.KerningData[n]);
      //PWord(@a)^ := EndianW(PWord(@a)^);
      //PWord(@b)^ := EndianW(PWord(@b)^);
      //FontData.KerningData[n].c := Endian(FontData.KerningData[n].c);
      //S1 := a;
      //S2 := b;
      //List.Add(Format('%s %s %d', [S1, S2, c]));
    end;
    //List.SaveToFile('Test.txt');
    //List.Free; 

    Stream.Free;

    If TexName = '' Then
    begin
      TexName := ExtractFilePath(FileName) + HashToStr(FontData.Hash) + '.TXTR';
      If not FileExists(TexName) Then
      begin
        If not OpenTexDialog.Execute Then Exit;
        TexName := OpenTexDialog.FileName;
      end;
    end;

    
    SetLength(Chars, FontData.Count);

    Stream := TMemoryStream.Create;
    Stream.LoadFromFile(TexName);

    Stream.Read(FontData.TexHeader, SizeOf(TTexHeader));
    EndianTexHeader(FontData.TexHeader);

    GetMem(Pixels, FontData.TexHeader.Width * FontData.TexHeader.Height * LayerCount div 4);
    GetMem(FontPixels, FontData.TexHeader.Width * FontData.TexHeader.Height * LayerCount);
    Stream.Read(Pixels^,  FontData.TexHeader.Width * FontData.TexHeader.Height div 2);
    Stream.Free;

    /////
    //DecodeImage
    Case FontData.ColorCount of
      1,2: DecodeImage1bpp(Pixels, FontPixels, FontData.TexHeader.Width, FontData.TexHeader.Height);
      3,4: DecodeImage(Pixels, FontPixels, FontData.TexHeader.Width, FontData.TexHeader.Height);
    end;
    FreeMem(Pixels);
    For n := 0 To FontData.Count - 1 do
    begin
      Rect.Left := Round(FontData.CharData[n].Rect.Left * FontData.TexHeader.Width);
      Rect.Top := Round(FontData.CharData[n].Rect.Top * FontData.TexHeader.Height);
      Rect.Right := Round(FontData.CharData[n].Rect.Right * FontData.TexHeader.Width);
      Rect.Bottom := Round(FontData.CharData[n].Rect.Bottom * FontData.TexHeader.Height);
      If Rect.Right >= FontData.TexHeader.Width Then Rect.Right := FontData.TexHeader.Width - 1;
      If Rect.Bottom >= FontData.TexHeader.Height Then Rect.Bottom := FontData.TexHeader.Height - 1;
      w := Rect.Right - Rect.Left + 1;

      FillChar(Chars[n], SizeOf(TCharacter), 0);
      For y := Rect.Top To Rect.Bottom do
        Move(Pointer(LongWord(FontPixels) + LongWord(y * FontData.TexHeader.Width + Rect.Left +
        FontData.TexHeader.Width * FontData.TexHeader.Height * FontData.CharData[n].Layer))^,
        Chars[n].Ch[y - Rect.Top + (FontData.FontHeader.Height - FontData.CharData[n].Y), 0], w);
    end;

    FreeMem(FontPixels);

    FontInit;
    FFileName := ChangeFileExt(FileName, '.mtf');
    Saved := True;

    DrawChars;
    DrawChar;
  except
    ShowMessage('Error!');
  end;
  FImported := True;
  Result := True;
end;


procedure TMainForm.FileExportFontActionExecute(Sender: TObject);
begin
  ExportFontDialog.FileName := ChangeFileExt(ExtractFileName(FFileName), '.FONT');
  If not ExportFontDialog.Execute Then Exit;
  ExportFont(ExportFontDialog.FileName);
  //ExportFont('TEST.FONT');
end;

procedure TMainForm.EditKerningActionExecute(Sender: TObject);
begin
  KerningForm.Show();
end;

end.
