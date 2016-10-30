unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, Menus, ExtCtrls, ActnList, ToolWin, ImgList, DIB,
  ExtDlgs, ClipBrd;

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
    Help1: TMenuItem;
    About1: TMenuItem;
    procedure PaletteSaveActionExecute(Sender: TObject);
    procedure FileOpenActionExecute(Sender: TObject);
    procedure FileSaveActionExecute(Sender: TObject);
    procedure FileSaveAsActionExecute(Sender: TObject);
    procedure FileExitActionExecute(Sender: TObject);
    procedure FileNewActionExecute(Sender: TObject);
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
    procedure EditInsertToRomActionExecute(Sender: TObject);
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
    procedure EditSaveAllToBitmapExecute(Sender: TObject);
    procedure EditLoadAllFromBitmapExecute(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
    procedure Open(const FileName: String);
  end;

Type
 TPalette = Array[0..15] of TColor;
 TTile = Array[0..15, 0..15] of Byte;
 TCharacter = Packed Record
  L,W: Byte;
  Ch: TTile;
 end;
 TChars = Array[Byte] of TCharacter;
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


 TObj = Packed Record
  XW,YH: Byte;
 end;
 TObjArray = Array of TObj;
 TPtr = Packed Record B1,B2: Byte; End;
 TFontData = Packed Record
  Ptrs: Array[0..$60-1] of TPtr;
  Data: Array[0..$440-1] of byte;
 end;
 TExObj = Packed Record
  X,W,Y,H: Byte;
  NahuiNado: Boolean; // Хорошо живёт на свете Винни-Пух...
 end;
 TExObjArray = Array of TExObj;
 {TFont = Class
 private
  Font: Array[0..1] of TFontData;
 public
  Property X: read GetX(ID: Integer) write SetX(;
 end;                }

var
 FontData: Array[0..1] of TFontData;
 MainForm: TMainForm;
 Palette: TPalette;
 BufChar: TCharacter;
 CurCol: Byte;
 CurChar: Byte;
 CharWidth, CharHeight: Byte;
 Chars: TChars;
 DataPos, PalPos, CodePos: Integer;
 DIB1, DIB2: TDIB;


Procedure DrawTile(var Tile: TTile; P: Pointer); overload;
Procedure DrawTile(var Tile: TTile; X,W,Y,H: Integer); overload;
implementation

Uses GbaUnit, HexUnit, SEF;

{$R *.dfm}

Procedure CharsToDIB(var Chars: TChars; var Pic: TDIB; From: Boolean = False);
var n,m,l,X,Y: Integer; B: ^Byte;
begin
  X:=0; Y:=0;
  If not Assigned(Pic) Then
  begin
    Pic:=TDIB.Create;
    Pic.BitCount := 8;
    Pic.Width := 256;
    Pic.Height := 256;
    DWord(Pic.ColorTable[0]):=0;
    DWord(Pic.ColorTable[1]):=clWhite;
    Pic.UpdatePalette;
  end;
  For l:=0 To 255 do
  begin
    For m:=0 To 15 do
    begin
      B:=Pic.ScanLine[Y+m];
      Inc(B,X);
      If From Then
        Move(B^,Chars[l].Ch[m,0],16)
      else
        Move(Chars[l].Ch[m,0],B^,16);
    end;
    Inc(X,16);
    If X>=256 Then
    begin
      X:=0; Inc(Y,16);
    end;
  end;
  
end;

Procedure DrawTile(var Tile: TTile; P: Pointer); overload;
var X,Y,W,H: Byte; B: ^Byte;  n,m: Integer;
begin
  B:=P;
  X:=B^ SHR 4;
  W:=B^ AND $F; Inc(B);
  Y:=B^ SHR 4;
  H:=B^ AND $F;
  For m:=Y To Y+H-1 do
    For n:=X To X+W-1 do
      Tile[m,n]:=1;
end;

Procedure DrawTile(var Tile: TTile; X,W,Y,H: Integer); overload;
var n,m: Integer;
begin
  For m:=Y To Y+H-1 do
    For n:=X To X+W-1 do
      Tile[m,n]:=1;
end;

Function GetLeft(Tile: TTile): Integer;   // Парам-пам-пам
var n: Integer;
begin
  For Result:=0 To 15 do
    For n:=0 To 15 do if Tile[n,Result]<>0 Then Exit;
end;

Function CheckForObject(Tile: TTile; X,Y,W,H: Integer): Boolean;
var n,m: Integer;
begin
  Result:=False;
  For m:=Y To Y+H do
  For n:=X To X+W do
    If Tile[m,n]=0 Then Exit;
  Result:=True;
end;

Function CheckForIn(Obj1,Obj2: TExObj): Boolean;
begin
  Result:=False;
  If (Obj1.X<Obj2.X) or (Obj1.Y<Obj2.Y) or
     (Obj1.X+Obj1.W>Obj2.X+Obj2.W) or
     (Obj1.Y+Obj1.H>Obj2.Y+Obj2.H) Then Exit;
  Result:=True;
end;

Function GetObjects(Tile: TTile; var Left{, James Left}: Integer): TObjArray; // Пух, Винни-Пух
var W,H,X,Y,Count: Integer; // Весёлые байтята
Obj: TExObjArray; ID: Array of Integer; T: TTile;
begin  // Жил да был Агент Винни-Пух под псевдонимом Джеймс Лефт
  Finalize(Result);
  Left:=GetLeft(Tile); // Получил он своё прозвище от агента Тайла
  If Left=16 Then Exit;// Когда ему исполнилось 16, он сбежал из дома
  Count:=0;            // И не платили ему зарплату
  For W:=0 {down}to 15 do // И вдруг однажды на него напали даун ван, даун ту...
  For H:=0 {down}to 15 do
  For Y:=0 to 15-H do
  For X:=0 To 15-W do
  begin // Беги, Джеймс, беги..
    If CheckForObject(Tile,X,Y,W,H) Then
    begin
      SetLength(Obj,Count+1);
      Obj[Count].X:=X;
      Obj[Count].Y:=Y;
      Obj[Count].W:=W;
      Obj[Count].H:=H;
      Obj[Count].NahuiNado := True;
      Inc(Count);
    end;
  end;
  For Y:=0 To High(Obj) do
  begin
    For X:=Y+1 To High(Obj) do
    begin
      If CheckForIn(Obj[Y],Obj[X]) Then
      begin
        Obj[Y].NahuiNado := False;
        break;
      end;
    end;
  end;
  Count:=0;
  For X:=0 To High(Obj) do If Obj[X].NahuiNado Then Inc(Count);
  SetLength(ID,Count);
  Y:=0;
  For X:=0 To High(Obj) do If Obj[X].NahuiNado Then
  begin
    ID[Y]:=X;
    Inc(Y);
  end;
  For Y:=0 To High(ID) do
  begin
    If Obj[ID[Y]].NahuiNado Then
    begin
      FillChar(T,256,0);
      For X:=0 To High(ID) do If X<>Y Then
      begin
        If Obj[ID[X]].NahuiNado Then DrawTile(T,Obj[ID[X]].X,Obj[ID[X]].W+1,Obj[ID[X]].Y,Obj[ID[X]].H+1);
      end;
      If CheckForObject(T,Obj[ID[Y]].X,Obj[ID[Y]].Y,Obj[ID[Y]].W,Obj[ID[Y]].H) Then
      begin
        Dec(Count);
        Obj[ID[Y]].NahuiNado := False;
      end;
    end;
  end;
  SetLength(Result,Count);
  Count:=0;
  For X:=0 To High(Obj) do
  begin
    If Obj[X].NahuiNado Then
    begin
      Result[Count].XW := ((Obj[X].X{-Left}) SHL 4) or (Obj[X].W AND $F +1);
      Result[Count].YH := (Obj[X].Y SHL 4) or (Obj[X].H AND $F +1);
      Inc(Count);
    end;
  end;
end;

procedure TMainForm.PaletteSaveActionExecute(Sender: TObject);
Var F: File; I: Byte; Pal: Array[Byte] of TRGB;
begin
 If SaveActDialog.Execute then
 begin
  FillChar(Pal, SizeOf(Pal), 0);
  For I := 0 to 15 do
  begin
   Pal[I].R := TRGBA(Palette[I]).R;
   Pal[I].G := TRGBA(Palette[I]).G;
   Pal[I].B := TRGBA(Palette[I]).B;
  end;
  AssignFile(F, SaveActDialog.FileName);
  Rewrite(F, 1);
  BlockWrite(F, Pal, SizeOf(Pal));
  CloseFile(F);
 end;
end;

procedure TMainForm.FileOpenActionExecute(Sender: TObject);
begin
 If not CheckSaved then Exit;
 If OpenDialog.Execute then Open(OpenDialog.FileName);
end;


procedure TMainForm.FileSaveActionExecute(Sender: TObject);
Var Obj: TObjArray; n,m,l,Left,Big: Integer; Pos: ^Byte; F: File;
Ptr: Integer; P1,P2: Integer; NSet: Packed Record S: Boolean; B1,B2: Byte; end; Skip: Boolean;
begin
 If not Named then
 begin
  FileSaveAsActionExecute(Sender);
  Exit;
 end;
 //ShowMessage(IntToStr(SizeOf(FontData)));
 
 FillChar(FontData[0],$500,0);
 FillChar(FontData[1],$500,0);
 For m:=0 To 1 do
 begin
 Pos:=@FontData[m].Data;
 NSet.S := False;
  For n:=0 To $60-1 do
  begin
    Skip:=False;
    For l := 0 To n - 1 do
    begin
      If CompareMem(@Chars[m*$60+n], @Chars[m*$60+l], SizeOf(TCharacter)) Then
      begin
        FontData[m].Ptrs[n].B1 := FontData[m].Ptrs[l].B1;
        FontData[m].Ptrs[n].B2 := FontData[m].Ptrs[l].B2;
        Skip := True;
      end;
    end;
    If not Skip Then
    begin
      Obj:=GetObjects(Chars[m*$60+n].Ch, Left);
      Ptr:=DWord(Pos)-DWord(@FontData[m].Ptrs);
      FontData[m].Ptrs[n].B1:=Ptr div $80;
      FontData[m].Ptrs[n].B2:=Ptr-FontData[m].Ptrs[n].B1*$80;
      Pos^:=Length(Obj); Inc(Pos);
      Pos^:=Left SHL 4; Pos^:=Pos^ or ((Chars[m*$60+n].W - Left) and $F); Inc(Pos);
      Move(Obj[0],Pos^,Length(Obj)*2);
      Inc(Pos,Length(Obj)*2);
    end;
    //ShowMessage(Format('%2.2x: %4.4x',[n,DWord(Pos)-DWord(@FontData[m].Ptrs)]));
  end;
  If DWord(Pos)-DWord(@FontData[m].Ptrs)>$500 Then
  begin
    Big:=(DWord(Pos)-DWord(@FontData[m].Ptrs))-$500;
    ShowMessage(Format('Part %d of 2 too big :( [%d bytes (%d objects)]',[m+1,Big,Big div 2]));
    Exit;
  end;
 end;
 AssignFile(F,FFileName);
 FileMode:=fmOpenWrite;
 Rewrite(F,1);
 Seek(F,0);
 BlockWrite(F,FontData[0], $500);
 Seek(F,$500);
 BlockWrite(F,FontData[1], $500 {(DWord(Pos)-DWord(@FontData[1].Ptrs))+1});
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
{
Const
 FontInfo: Array[False..True] of TFontInfo =
 (
 (Width: 1; Height: 1; ChrAddr1: $348D8; ChrAddr2: $4718C;
  LetCntAddr1: $348A4; LetCntAddr2: $47134;
  WidthTblAddr1: $348D4; WidthTblAddr2: $47188;
  LetTblAddr1: $348DC; LetTblAddr2: $47190),
 (Width: 2; Height: 2; ChrAddr1: $34A54; ChrAddr2: $470AC;
  LetCntAddr1: $34A20; LetCntAddr2: $47058;
  WidthTblAddr1: $34A50; WidthTblAddr2: $470A8;
  LetTblAddr1: $34A58; LetTblAddr2: $470B0)
 );     }


Procedure LoadData(var C: TCharacter; P: Pointer);
var n,m: Integer; B: ^Byte; Count: Byte;
begin
  B:=P;
  Count:=B^; Inc(B);
  C.L:=B^ SHR 4;
  C.W:=B^ AND $F + C.L; Inc(B);
  For n:=0 To Count-1 do
  begin
    DrawTile(C.Ch,B);
    Inc(B,2);
  end;
end;

procedure TMainForm.FileNewActionExecute(Sender: TObject);
begin
  If not CheckSaved Then Exit;
  FillChar(FontData, SizeOf(FontData), 0);
  FillChar(Chars, SizeOf(TCharacter)*Length(Chars), 0);
  DrawChars;
  DrawChar;
end;


procedure TMainForm.PaletteLoadActionExecute(Sender: TObject);
Type
 TPalX = Array[0..15] of TRGB;
Var F: File; PalX: TPalX; TX: Integer; R: DWord; Col: TRGBA;
begin
 If OpenActDialog.Execute then
 begin
  AssignFile(F, OpenActDialog.FileName);
  Reset(F, 1);
  BlockRead(F, PalX, SizeOf(TPalX), R);
  For TX := 0 to 15 do With PalX[TX] do
  begin
   Col.R := R;
   Col.G := G;
   Col.B := B;
   Col.A := 0;
   Palette[TX] := TColor(Col);
  end;
  Saved := False;
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

procedure TMainForm.EditInsertToRomActionExecute(Sender: TObject);
Var
 F: TMemoryStream; n,m: Integer; Ptrs: Array[0..255] of DWord; Pos: DWord;
 B: ^Byte; DW: ^DWord;
begin
{  If SaveRomDialog.Execute then
 begin
  try
   F := TMemoryStream.Create;
   F.LoadFromFile(SaveRomDialog.FileName);
   If not SeForm.NewExecute('Graphics position','Type in',$132180) then Exit;
   Pos:=SeForm.ResultNumber;
   For n:=0 To 255 do
   begin
    FillChar(m,4,0);
    For m:=0 To n-1 do
    begin
      If CompareMem(Addr(Chars[n].Ch),Addr(Chars[m].Ch),SizeOf(TTile)) Then
      begin
        Ptrs[n]:=Ptrs[m];
        Break;
      end;
    end;
    If m=n Then
    begin
      Ptrs[n]:=Pos;
      LoadData(Chars[n].Ch,Pointer(DWord(F.Memory)+Pos),Chars[n].W,True);
      Inc(Pos,((Chars[n].W+1) div 2)*16);
    end;
   end;
   B:=Pointer(DWord(F.Memory)+DataPos+256*4);
   DW:=Pointer(DWord(F.Memory)+DataPos);
   For n:=0 To 255 do
   begin
    B^:=Chars[n].W;
    DW^:=Ptrs[n]+$08000000;
    Inc(B); Inc(DW);
   end;
   F.SaveToFile(SaveRomDialog.FileName);
   F.Free;
  except
  end;
 end;        }

{ If SaveRomDialog.Execute then
 begin
  try
   F := TFileStream.Create(SaveRomDialog.FileName, fmOpenWrite);
   If SeForm.NewExecute('Position', 'Type in', InsertPos) then
   With FontInfo[BigFont] do
   begin
    InsertPos := SeForm.ResultNumber;
    D := InsertPos;
    Cnt := 0;
    For I := 0 to 255 do With Chars[I] do
    begin
     If W > 0 then
     begin
      Inc(Cnt);
      SetLength(Letters, Cnt);
      SetLength(Tiles, Cnt * (Width * Height));
      SetLength(Widths, Cnt);
      Widths[Cnt - 1] := W;
      Letters[Cnt - 1] := I;
      Tile := Addr(Tiles[(Cnt - 1) * (Width * Height)]);
      For YY := 0 to Height - 1 do
       For XX := 0 to Width - 1 do
       begin
        For Y := 0 to 7 do For X := 0 to 7 do If not Odd(X) then
         Tile^[Y, X shr 1] := Ch[YY shl 3 + Y, XX shl 3 + X] and 15 Else
         Tile^[Y, X shr 1] := Tile^[Y, X shr 1] or
         ((Ch[YY shl 3 + Y, XX shl 3 + X] and 15) shl 4);
        Inc(Tile);
       end;
     end;
    end;
    GetMem(CTiles, Length(Tiles) * SizeOf(TGbaTile) * 2);
    F.Position := ChrAddr1;
    F.Write(D, 3);
    F.Position := ChrAddr2;
    F.Write(D, 3);
    F.Position := D;
    F.Write(CTiles^, LZ77Compress(Tiles[0], CTiles^,
                     Length(Tiles) * SizeOf(TGbaTile), True));
    D := F.Position;
    While D mod 4 > 0 do Inc(D);
    FreeMem(CTiles);
    F.Position := LetCntAddr1;
    F.Write(Cnt, 1);
    F.Position := LetCntAddr2;
    F.Write(Cnt, 1);
    F.Position := LetTblAddr1;
    F.Write(D, 3);
    F.Position := LetTblAddr2;
    F.Write(D, 3);
    F.Position := D;
    F.Write(Letters[0], Cnt);
    I := 0;
    F.Write(I, 1);
    D := F.Position;
    While D mod 4 > 0 do Inc(D);
    F.Position := WidthTblAddr1;
    F.Write(D, 3);
    F.Position := WidthTblAddr2;
    F.Write(D, 3);
    F.Position := D;
    F.Write(Widths[0], Cnt * 8);
    I := $8008;
    F.Position := $34C62;
    F.Write(I, 2);
    I := $8804;
    F.Position := $391F6;
    F.Write(I, 2);
    I := $8802;
    F.Position := $21814;
    F.Write(I, 2);
    F.Position := $219B0;
    F.Write(I, 2);
    F.Position := $21B76;
    F.Write(I, 2);
    F.Position := $21BA8;
    F.Write(I, 2);
    F.Position := $20C04;
    F.Write(I, 2);
    Dec(I);
    F.Position := $219A8;
    F.Write(I, 2);
    F.Position := $21B6E;
    F.Write(I, 2);
    F.Position := $20C0E;
    F.Write(I, 2);
    F.Position := $20C3C;
    F.Write(I, 2);
    ShowMessage('Done!');
   end;
   F.Free;
  except
   ShowMessage('Cannot open file for write!');
  end;
 end;  }
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := CheckSaved;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var n: Integer;
begin
 FSaved := True;
 CharWidth := 16;
 CharHeight := 16;
 Palette[0] := 0;
 For n:=1 To High(Palette) do Palette[n]:=clWhite;
 {Palette[1] := clWhite;
 Palette[2] := 0;//clGray;
 Palette[3] := $0;}
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
Var I, YY, XX, Y, ZX, ZY: Integer; B, BB: ^Byte; PM: TPenMode;
begin
 With DIB1 do
 begin
  I := 0; ZX := 0; ZY := 0;
  For YY := 0 to 15 do
  begin
   B := ScanLine[YY * CharHeight];
   For XX := 0 to 15 do With Chars[I] do
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
     ZY := YY * 16;
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
  Pen.Color := $FFFFFF;
  Pen.Mode := pmCopy;
  Pen.Width := 1;
  Rectangle(Bounds(ZX, ZY, 16, 16));
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
  B := Addr(Chars[CurChar].Ch);
  H := CharHeight; If H > Height then H := Height;
  W := CharWidth;  If W > Width then W := Width;
  If H > 16 then H := 16;
  If W > 16 then W := 16;
  For Y := 0 to H - 1 do
  begin
   Move(B^, ScanLine[Y]^, W);
   Inc(B, 16);
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
    [Application.Title, ExtractFileName(FFileName), SavedConst[Value]]) Else
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
  Saved := False;
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
  Y := Y div 16;
  CurChar := Y * 16 + X;
  If CurChar >= $C0 Then CurChar := $BF;
  DrawChars;
  DrawChar;
 end;
end;

procedure TMainForm.CharImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 If ssCtrl in Shift then With Chars[CurChar] do
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
  X := X div (256 div CharWidth); Y := Y div (256 div CharWidth);
  With Chars[CurChar] do CurCol := Ch[Y, X];
  DrawPalette;
 end Else CharImageMouseMove(Sender, Shift, X, Y);
end;

procedure TMainForm.CharImageMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
 If not (ssLeft in Shift) then Exit;
 If (ssCtrl in Shift) or (ssShift in Shift) then Exit;
 If X < 0 then Exit;
 If Y < 0 then Exit;
 If X >= CharImage.Width then Exit;
 If Y >= CharImage.Height then Exit;
  X := X div (256 div CharWidth); Y := Y div (256 div CharWidth);
 With Chars[CurChar] do Ch[Y, X] := CurCol;
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


procedure TMainForm.Open(const FileName: String);
Var
 F: File;
 n: Integer;
 P: Pointer;

Label BadData;
begin
  try
   FillChar(FontData[0],$500,0);
   FillChar(FontData[1],$500,0);
   FillChar(Chars,SizeOf(TCharacter)*256,0);
   AssignFile(F,FileName);
   FileMode:=fmOpenRead;
   Reset(F,1);   
   If FileSize(F)>$500*3 Then Exit;
   Seek(F,0);
   BlockRead(F,FontData[0],$500);
   Seek(F,$500);
   BlockRead(F,FontData[1],FileSize(F)-$500);
   CloseFile(F);
   CharWidth := 16;
   CharHeight := 16;
   DIB2.Width := CharWidth;
   DIB2.Height := CharHeight;
   DIB1.Width := CharWidth * 16;
   DIB1.Height := CharHeight * 16;
   DIB2.Width := CharWidth;
   DIB2.Height := CharHeight;
   With FontData[0] do
   begin
    For n:=0 To $60-1 do
    begin
      P:=@FontData[0];
      Inc(DWord(P),Ptrs[n].B1*$80+Ptrs[n].B2);
      LoadData(Chars[n],P);
    end;
   end;
    For n:=0 To $60-1 do
    begin
      P:=@FontData[1];
      Inc(DWord(P),FontData[1].Ptrs[n].B1*$80+FontData[1].Ptrs[n].B2);
      LoadData(Chars[n+$60],P);
    end;
   Palette[0]:=0;
   Palette[1]:=$FFFFFF;
   UpdateDIBPalette;
   DrawPalette;
   FFileName := {''}FileName;
   Saved := True;
  except
    ShowMessage('Error!');
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
    If CurChar>=$FF Then
      CurChar := $BF
    else
    If CurChar>=$C0 Then
      CurChar := 0;
    DrawChars;
    DrawChar;
  end;
end;

procedure TMainForm.EditSaveAllToBitmapExecute(Sender: TObject);
var Pic: TDIB;
begin
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
  DrawChars;
  DrawChar;
 end;
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
  end;
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
  end;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  MessageDlg('GUI Engine by Djinn'#9#9'http://magicteam.net/'#13#10'Editor Engine by HoRRoR'#9'http://consolgames.ru/', mtInformation, [mbOK], 0);
end;

end.
