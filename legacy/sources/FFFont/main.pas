unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, Menus, ExtCtrls, ActnList, ToolWin, ImgList, DIB,
  ExtDlgs, ClipBrd, StdCtrls, StrUtils, FontProporties;

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
    OpenRomDialog: TOpenDialog;
    SaveTableDialog: TSaveDialog;
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
    ToolButton20: TToolButton;
    FileSaveTableAction: TAction;
    N4: TMenuItem;
    SaveASCITable1: TMenuItem;
    ScrollBar: TScrollBar;
    Help1: TMenuItem;
    About1: TMenuItem;
    FileImportFromRomAction: TAction;
    N5: TMenuItem;
    ImportfromFF12ROM1: TMenuItem;
    FileExportToRomAction: TAction;
    FileExportToRomAction1: TMenuItem;
    EditFontProportiesAction: TAction;
    SaveWidthsAction: TAction;
    SaveWidthsDialog: TSaveDialog;
    SaveWidths1: TMenuItem;
    DefaultPalette1: TMenuItem;
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
    procedure FileSaveTableActionExecute(Sender: TObject);
    procedure ScrollBarChange(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure About1Click(Sender: TObject);
    procedure FileImportFromRomActionExecute(Sender: TObject);
    procedure FileExportToRomActionExecute(Sender: TObject);
    procedure EditFontProportiesActionExecute(Sender: TObject);
    procedure FileNewActionExecute(Sender: TObject);
    procedure SaveWidthsActionExecute(Sender: TObject);
    procedure DefaultPalette1Click(Sender: TObject);
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
    property Saved: Boolean read FSaved write SetSaved;
    property Named: Boolean read GetNamed;
    property FileName: String read FFileName write FFileName;
    procedure UpdateDIBPalette;
    procedure Open(const FileName: String; FFROM: Boolean = False; Offset: DWord = 0);
    Procedure Save(const FileName: String; FFROM: Boolean = False; Offset: DWord = 0);
    Procedure FontInit;
  end;

  EFontError = Class(Exception);

const
  cCharWidth  = 64;
  cCharHeight = 64;

Type
 TPalette = Array[0..15] of TColor;
 TTile = Array[0..cCharHeight-1, 0..cCharWidth-1] of Byte;
 TCharacter = Packed Record
  W: Byte;
  P: Byte;
  N: Boolean;
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

 TSizeData = Packed Record
  L: ShortInt;
  W: Byte;
  R: ShortInt;
 end;

 TFontData = Packed Record
  Nulls:      Array[0..3] of Char;
  Signature:  Array[0..3] of Char;
  Height:     Byte;
  BitCount:   Byte;
  Count:      Word;
  Case Byte of
    0: (ASCI:       Array[0..127] of SmallInt);
    1: (Hz:  Word);
 end;
 TCharInfo = Packed Record
    W: Byte;
    P: Byte;
 end;

var
 FontData:                 TFontData;
 MainForm:                 TMainForm;
 Palette:                  TPalette;
 BufChar:                  TCharacter;
 CurCol:                   Byte;
 CurChar:                  Integer;
 CurChars:                 Integer;
 CharWidth, CharHeight:    Byte;
 Chars:                    TChars;
 DataPos, PalPos, CodePos: Integer;
 DIB1, DIB2:               TDIB;

implementation

Uses GbaUnit;

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

Function GetCode(N: Word): Word;
begin
  Result := $8000 or ((N SHL 2) and $1F00) or (N and $3F);
end;

Function GetChar(var Char: TCharacter; H: Integer; P: Pointer; Put: Boolean = False; FFROM: Boolean = False): Integer;
var X,Y,W: Integer; B: ^Byte; BB: Byte;
const PW = 4;
begin
  //H:=RoundBy(H,8);
  W := Char.P * PW;//PW;
  Result:=(W*H) div 4;
  B:=P;
  For Y:=0 To H-1 do
  begin
    For X:=0 To (W div PW)-1 do
    begin
      If Put Then
      begin
        B^ := Char.Ch[Y,X*PW+3] SHL 6;
        B^ := B^ OR ((Char.Ch[Y,X*PW+2] AND 3) SHL 4);
        B^ := B^ OR ((Char.Ch[Y,X*PW+1] AND 3) SHL 2);
        B^ := B^ OR (Char.Ch[Y,X*PW+0] AND 3);
        If FFROM Then
          B^ := (B^ XOR $AE) - $3D;
      end else
      begin
        If FFROM Then
          BB := (B^ + $3D) XOR $AE
        else
          BB := B^;
        Char.Ch[Y,X*PW+3] := BB SHR 6;
        Char.Ch[Y,X*PW+2] := (BB SHR 4) AND 3;
        Char.Ch[Y,X*PW+1] := (BB SHR 2) AND 3;
        Char.Ch[Y,X*PW+0] := BB AND 3;
      end;
      Inc(B);
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
    Pic.Height := CharHeight* (RoundBy(Length(Chars),16) div 16);
    For n:=0 To 15 do
    begin
      Pic.ColorTable[n].rgbBlue  := (Palette[n] SHR 16) AND $FF;
      Pic.ColorTable[n].rgbGreen := (Palette[n] SHR 8)  AND $FF;
      Pic.ColorTable[n].rgbRed   :=  Palette[n]         AND $FF;
    end;
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

Function GetRBound(C: TTile): Integer;
var m: Integer;
begin
  Result := 0;
  For Result := CharWidth - 1 downto 0 do
    For m := 0 To CharHeight do If C[m,Result]>0 Then Exit;
end;

Procedure TMainForm.Save(const FileName: String; FFROM: Boolean = False; Offset: DWord = 0);
var F: File; n,m,Pos, Size: Integer; Ptrs: Array of DWord;
CharData: Array of Byte;
begin
 SetLength(CharData,FontData.Height*(RoundBy(FontData.Height,4) div 4)*Length(Chars) + Length(Chars)*2);
 //ShowMessage(IntToStr(Length(CharData)));
 FillChar(CharData[0],Length(CharData),0);
 Pos:=0;
 SetLength(Ptrs, FontData.Count);
 FillChar(Ptrs[0], Length(Ptrs)*4, 0);
 For n:=0 To High(Chars) do With FontData do 
 begin
  If Chars[n].N Then
    Continue;
  For m:=0 To n-1 do
    If not Chars[m].N and CompareMem(@Chars[n].Ch,@Chars[m].Ch,SizeOf(TTile)) and
    (Chars[n].W = Chars[m].W) Then Break;
  If m<n Then
  begin
    Ptrs[n]:=Ptrs[m];
    Continue;
  end;
  If FFROM Then
    Ptrs[n] := Pos + Length(Ptrs)*4 + 4
  else
    Ptrs[n] := Pos + SizeOf(TFontData) + Length(Ptrs)*4;
  Chars[n].P := RoundBy(Chars[n].W,4) div 4;
  //If Chars[n].P <= 0 Then Chars[n].P := 1;
  CharData[Pos] := Chars[n].W;
  CharData[Pos+1] := Chars[n].P;
  Inc(Pos,2);
  Inc(Pos,GetChar(Chars[n],FontData.Height,@CharData[Pos],True, FFROM));
 end;
 Size := Pos;

 AssignFile(F,FileName);
 If FFROM Then
 begin
  FileMode:=fmOpenReadWrite;
  Reset(F, 1);
  Seek(F, Offset);
  BlockWrite(F, FontData.Height, 4);
 end else
 begin
  FileMode:=fmOpenWrite;
  Rewrite(F,1);
  BlockWrite(F,FontData,SizeOf(TFontData));
 end;
 BlockWrite(F,Ptrs[0],Length(Ptrs)*4);
 BlockWrite(F,CharData[0],Pos);
 CloseFile(F);
 Saved:=True;
end;

procedure TMainForm.FileSaveActionExecute(Sender: TObject);
begin
 If not Named then
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
end;

procedure TMainForm.EditPasteActionExecute(Sender: TObject);
begin
 Chars[CurChar] := BufChar;
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
  Chars[CurChar].W := CharWidth;
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
  Chars[CurChar].W := CharWidth;
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
 With Chars[CurChar] do
 begin
  WW := W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
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
var n: Integer;
begin


 //ShowMessage(IntToStr(SizeOf(ShortInt)));
 FillChar(FontData, SizeOf(FontData), 256);
 FontData.Signature := 'FONT';
 FontData.Height := 64;
 FontData.BitCount := 2;
 FontData.Count := 256;
 SetLength(Chars, 256);
 FSaved := True;
 CharWidth := cCharWidth;
 CharHeight := cCharHeight;

 Palette[0] := 0;
 Palette[1] := $FFFFFF;
 Palette[2] := $A0A0A0;
 Palette[3] := $808080;
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

procedure TMainForm.DrawChars;
Var I, YY, XX, Y, ZX, ZY: Integer; B, BB: ^Byte; PM: TPenMode; S: String;
begin
 If CurChar > High(Chars) Then CurChar := High(Chars);
 If (CurChar < CurChars) or (CurChar - CurChars > 256) Then
  CurChar := CurChars;
 With DIB1 do
 begin
  I := CurChars;
  ZX := 16*CharWidth; ZY := 16*CharHeight;
  For YY := 0 to 15 do
  begin
   B := ScanLine[YY * CharHeight];
   For XX := 0 to 15 do With Chars[I] do
   begin
    BB := B;
    Inc(BB, XX * CharWidth);
    For Y := 0 to Integer(CharHeight) - 1 do
    begin
     If I > High(Chars) Then
       FillChar(BB^, CharWidth, 0)
     else
       Move(Ch[Y, 0], BB^, CharWidth);
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
 end;
 If CurChar > High(Chars) Then Exit;
 If CurChar >= $80 Then
   S := Format('$%.4x', [GetCode(CurChar)])
   //S := Format('$%.2x%.2x',
   //  [$82 + (CurChar - $80) div $80,((CurChar - $80) div $80) + CurChar])
 else
   S := Format('$%.2x',[CurChar]);
 StatusBar.Panels[0].Text := Char(CurChar);
 StatusBar.Panels[1].Text := '$' + IntToHex(CurChar, 2);
 StatusBar.Panels[2].Text := '#' + IntToStr(CurChar);
 With Chars[CurChar] do StatusBar.Panels[3].Text :=
  Format('W: %d; P: %d; %s',[W,P,S]);
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
 With CharImage.Canvas, Chars[CurChar] do
 begin
  StretchDraw(ClipRect, DIB2);
  PM := Pen.Mode;
  Pen.Color := $FF00FF;
  Pen.Mode := pmMaskPenNot;
  Pen.Width := 2;
  WW := (256 div CharWidth);
  Rectangle(Bounds(W * WW, 0, WW, 256));
  Pen.Color := $00FF00;
  Rectangle(Bounds(W * WW, 0, WW, 256));
  Pen.Color := $0000FF;
  Rectangle(Bounds(W * WW, 0, WW, 256));
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
var SelChar: Integer;
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
  X := X div 16;
  Y := Y div 16;
  SelChar := Y * 16 + X + CurChars;
  If SelChar <= High(Chars) Then
    Chars[SelChar].N := not Chars[SelChar].N;
  DrawChars;
  DrawChar;
 end;
end;

procedure TMainForm.CharImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var WW: Integer;
begin
 If ssCtrl in Shift then With Chars[CurChar] do
 begin
  WW := W;
  If X > 256 - 8 then
   W := CharWidth Else
   W := X div (256 div CharWidth);
  //Dec(R, W - WW);  
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

 If (Y >= FontData.Height) Then Exit;
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


procedure TMainForm.Open(const FileName: String; FFROM: Boolean = False; Offset: DWord = 0);
Var
 F: File;
 n: Integer;
 Max: Integer;
 CharData: Array of Byte;
 Ptrs:     Array of DWord;
 Pos:      DWord;
begin
  try
   AssignFile(F,FileName);
   FileMode:=fmOpenRead;
   Reset(F,1);
   If FFROM Then
   begin
    FillChar(FontData, SizeOf(FontData), 0);
    FontData.Signature := 'FONT';

    Seek(F, Offset);
    Pos := Offset;

    BlockRead(F, FontData.Height, 4); 
    SetLength(Ptrs, FontData.Count);
    BlockRead(F, Ptrs[0], Length(Ptrs) * SizeOf(DWord));
    SetLength(CharData, FileSize(F) - (Pos + FontData.Count * 4 + 4));
   end else
   begin
    BlockRead(F,FontData,SizeOf(TFontData));
    SetLength(Ptrs, FontData.Count);
    BlockRead(F, Ptrs[0], Length(Ptrs) * SizeOf(DWord));
    Pos := SizeOf(TFontData) + Length(Ptrs) * SizeOf(DWord);
    SetLength(CharData, FileSize(F) - Pos);
   end;
   //ShowMessage(IntToHex(FilePos(F),8));
   BlockRead(F,CharData[0], Length(CharData));
   CloseFile(F);
   If FFROM Then
   //begin
    //For n := 0 To High(CharData) do
    //  CharData[n] := ((CharData[n] + $3D) XOR $AE) AND $FF;
    Pos := FontData.Count * 4 + 4;
   //end;

   SetLength(Chars, FontData.Count);
   FillChar(Chars[0],SizeOf(TCharacter)*Length(Chars),0);

   For n:=0 To High(Chars) do
   begin
    If Ptrs[n] > 0 Then
    begin
      Move(CharData[Ptrs[n] - Pos], Chars[n], 2);
      GetChar(Chars[n],FontData.Height, @(CharData[Ptrs[n] - Pos + 2]), False, FFROM);
    end else
      Chars[n].N := True;
   end;

   FontInit;

   If FFROM Then
    FFileName := ''
   else
    FFileName := {''}FileName;
   Saved := True;

   DrawChars;
   DrawChar;
  except
    ShowMessage('Error!');
  end;
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Caption:=IntToHex(Key,4);
  Case Key of
    $22: If ScrollBar.Position + 16 > ScrollBar.Max Then
           ScrollBar.Position := ScrollBar.Max
         else
         begin           
           Inc(CurChar, 256);
           ScrollBar.Position := ScrollBar.Position + 16;
         end;
    $21: If ScrollBar.Position - 16 < 0 Then
           ScrollBar.Position := 0
         else
         begin          
           Dec(CurChar, 256);
           ScrollBar.Position := ScrollBar.Position - 16;
         end;
    $25: Dec(CurChar);
    $26: Dec(CurChar,16);
    $27: Inc(CurChar);
    $28: Inc(CurChar,16);
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

procedure TMainForm.FileSaveTableActionExecute(Sender: TObject);
var n: ShortInt; List: TStringList; A: Integer;
begin
  If not SaveTableDialog.Execute Then Exit;
  List := TStringList.Create;

  For n := $20 To $7F do With FontData do
  begin
  A := (Byte(FontData.ASCI[n]>=$80) + 1) * 2;
    If ASCI[n] = -1 Then Continue;
    If ASCI[n]>=$80 Then
      List.Add(Format('%.4x=%s',[GetCode(ASCI[n]), Char(n)]))
    else
      List.Add(Format('%.2x=%s',[ASCI[n], Char(n)]));
  end;
  List.SaveToFile(ChangeFileExt(SaveTableDialog.FileName, '.tbl'));
  List.Free;
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
  If ssCtrl in Shift Then
  begin
    Dec(Chars[CurChar].W);
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
  If ssCtrl in Shift Then
  begin
    Inc(Chars[CurChar].W);
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

var FFROMOffset: DWord = $2B4684;
procedure TMainForm.FileImportFromRomActionExecute(Sender: TObject);
var V: DWord; Code: Integer;
begin
  If not CheckSaved Then Exit;
  If not OpenROMDialog.Execute Then Exit;
  Val(InputBox('Font Position', 'Please input font offset:', '0x' + IntToHex(FFROMOffset, 8)), V, Code);
  If Code <> 0 Then
  begin
    ShowMessage('Invalid offset!');
    Exit;
  end;
  FFROMOffset := V;
  Open(OpenRomDialog.FileName, True, FFROMOffset);
end;

procedure TMainForm.FileExportToRomActionExecute(Sender: TObject);
var V: DWord; Code: Integer;
begin
  If not OpenROMDialog.Execute Then Exit;
  Val(InputBox('Font Position', 'Please input font offset:', '0x2B4684'), V, Code);
  If Code <> 0 Then
  begin
    ShowMessage('Invalid offset!');
    Exit;
  end;
  Save(OpenRomDialog.FileName, True, V);
end;

procedure TMainForm.EditFontProportiesActionExecute(Sender: TObject);
begin
  If PropForm.Show(@FontData.Height, @FontData.BitCount, @FontData.Count) Then
  begin
    SetLength(Chars, FontData.Count);
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

procedure TMainForm.FontInit;   
var WH: Integer;
begin
   Case FontData.Height of
    01..08: WH:=8;
    09..16: WH:=16;
    17..32: WH:=32;
    33..64: WH:=64;
   end;
   CharWidth := WH;
   CharHeight := WH;
   DIB2.Width := CharWidth;
   DIB2.Height := CharHeight;
   DIB1.Width := CharWidth * 16;
   DIB1.Height := CharHeight * 16;
   DIB2.Width := CharWidth;
   DIB2.Height := CharHeight;
   If Length(Chars) > 256 Then
     ScrollBar.Max := RoundBy(Length(Chars) - 256, 16) div 16
   else
     ScrollBar.Max := 0;
end;

procedure TMainForm.FileNewActionExecute(Sender: TObject);
var H,B: Byte; C: Word;
begin
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

var FormatString: String = '%d\n';
procedure TMainForm.SaveWidthsActionExecute(Sender: TObject);
var List: TStringList; S: String; n: Integer;
begin
 S := '';
 S := InputBox('Width Format', 'Input format string', FormatString);
 If S = '' Then Exit;
 FormatString := S;
 S := FmtToStr(FormatString);
 If SaveWidthsDialog.Execute then
 begin
   List := TStringList.Create;
   For n := 0 To High(Chars) do
     List.Text := List.Text + Format(S, [Chars[n].W]);
   List.SaveToFile(ChangeFileExt(SaveWidthsDialog.FileName, '.txt'));
   List.Free;
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

end.
