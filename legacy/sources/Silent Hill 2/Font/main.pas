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
    ScrollBar: TScrollBar;
    Help1: TMenuItem;
    About1: TMenuItem;
    N5: TMenuItem;
    SaveWidthsAction: TAction;
    SaveWidthsDialog: TSaveDialog;
    SaveWidths1: TMenuItem;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    EditSelFont0: TAction;
    EditSelFont1: TAction;
    OpenExeDialog: TOpenDialog;
    N4: TMenuItem;
    N6: TMenuItem;
    Importfromfile1: TMenuItem;
    OpenRawDialog: TOpenDialog;
    ImportFromFileAction: TAction;
    FileExportToFileAction: TAction;
    SaveRawDialog: TSaveDialog;
    FileExportToFileAction1: TMenuItem;
    ToolButton23: TToolButton;
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
    procedure FileNewActionExecute(Sender: TObject);
    procedure SaveWidthsActionExecute(Sender: TObject);
    procedure EditSelFont0Execute(Sender: TObject);
    procedure EditSelFont1Execute(Sender: TObject);
    procedure ImportFromFileActionExecute(Sender: TObject);
    procedure FileExportToFileActionExecute(Sender: TObject);
    procedure ToolButton23Click(Sender: TObject);
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
    Procedure Save(const FileName: String);
    Procedure FontInit;
  end;

const
  cCharWidth  = 32;
  cCharHeight = 32;
  cPointer1 = $1E49A8;
  cPointer2 = $1E49AC;
  cPCPointer1 = $4038A0;
  cPCPointer2 = $4038A4;
  cCharCount = $1D9C; //$3B38 div 2;
  cPtrDef = $FF800;
  cPCPtrDef = $400000;

Type
 TPalette = Array[0..15] of TColor;
 TTile = Array[0..cCharHeight-1, 0..cCharWidth-1] of Byte;
 TCharacter = Packed Record
  W: Byte;
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

 TFontFileLink = Packed Record
  Offset: DWord;
  Size:   DWord;
 end;
 TFontFileHeader = Packed Record
  Sign: Array[0..3] of Char;
  Null: Array[0..2] of DWord;
  Font0:  TFontFileLink;
  Font1:  TFontFileLink;
  Reserved: Array[0..15] of Byte;
 end;



 TFontHeader = Packed Record
   Unk:        DWord;
   null:       Array[0..11]  of Byte;
   WidthData:  Array[0..$DF] of Byte;
   Pointers:   Array[0..cCharCount - 1] of Word;
 end;

 TFontData = Packed Record
   Hlam:      Array[0..$F] of Byte;
   Widths:    Array[0..$DF] of Byte;
   Ptrs:      Array[0..cCharCount - 1] of Word;
   Height:    Integer;
   Chars:     Array[0..cCharCount-1] of TTile;
 end;

 TArray = Array[Word] of Byte;
 PArray = ^TArray;

var
 FontData:                Array[0..1] of TFontData;
 //FontData:                 TFontData;
 MainForm:                 TMainForm;
 Palette:                  TPalette;
 BufChar:                  TTile;//TCharacter;
 BufWidth:                 Integer;
 CurCol:                   Byte;
 CurChar:                  Integer = 0;
 CurFont:                  Integer = 0;
 CurChars:                 Integer;
 CharWidth, CharHeight:    Byte;
 //Chars:                    TChars;
 DataPos, PalPos, CodePos: Integer;
 DIB1, DIB2:               TDIB;

const
  TestData: array[0..31] of byte = (
	  $07, $90, $A4, $7A, $68, $3D, $B4, $1E, $3A, $0F, $7D, $C9, $97, $7C, $C9, $97,
	  $7A, $89, $1F, $3F, $7E, $3B, $3A, $E7, $A1, $F5, $8C, $B9, $74, $00, $05, $00
  );

  cJapWidth: Array[0..1] of Integer = (20, 16);
  cFontHeight: Array[0..1] of Integer = (30, 24);

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

Procedure DecodeChar(Src, Dest: Pointer; Size: Integer);
var Bits, Bits2, Bits3: Byte; wZeroSpace, num: Word;
CharData: PArray; CharIndex, BitOffset: Integer; PBitDWord: ^DWord;

  Function GetBits: Byte;
  begin
    if (BitOffset = 24) Then
    begin
      Inc(DWord(PBitDWord), 3);
      BitOffset := 0;
    end;
    Result := (PBitDWord^ SHR BitOffset) AND 7;
    Inc(BitOffset, 3);
  end;

begin
  CharData := Dest;
  CharIndex := 0;
  BitOffset := 0;
  PBitDWord := Src;

  // 111 xxx | +1                                       : 2..8
  // 111 000 xxx + 7 | +1                               : 9..14
  // 111 000 000 xxx + 14 | +1                          : 15..21
  // 111 000 000 000 xxx xxx + 21 | +1                  : 22..84
  // 111 000 000 000 000 000 xxx xxx xxx + 84 | +1      : 85..595

  //wSizeSymb = 3;  // Изначально всегда считываются 3 байта
  while (CharIndex < Size) do
  begin
    Bits := GetBits;
    if (Bits = $07) Then
    begin
      wZeroSpace := 0;
      Bits := GetBits;
      if (Bits = 0) Then
      begin
        Bits := GetBits;
        if (Bits = 0) Then
        begin
          Bits := GetBits;
          if (Bits = 0) Then
          begin
            Bits2 := GetBits;
            Bits := GetBits;
            if (Bits = 0) and (Bits2 = 0) Then
            begin
              Bits3 := GetBits;
              Bits2 := GetBits;
              Bits := GetBits;

              num := Word((Bits SHL 6) OR (Bits2 SHL 3) OR Bits3);
              wZeroSpace := wZeroSpace + num + 84;
            end else
            begin
              num := Word((Bits SHL 3) OR Bits2);
              wZeroSpace := wZeroSpace + num + 21;
            end;
          end else
            wZeroSpace := wZeroSpace + Bits + 14;

        end else
          wZeroSpace := wZeroSpace + Bits + 7;
      end else
        wZeroSpace := Bits;
      Inc(wZeroSpace);
      FillChar(CharData^[CharIndex], wZeroSpace, 0);
      Inc(CharIndex, wZeroSpace);
    end else
    begin
      CharData^[CharIndex] := Bits;
      Inc(CharIndex);
    end;
  end;
end;

Function EncodeChar(Src, Dest: Pointer; Size: Integer): Integer;
var BitOffset: DWord; PBitDWord: ^DWord; Data: PArray; Space, Index: Integer;
  Procedure WriteBits(BitData: Byte);
  begin
    if (BitOffset = 24) Then
    begin
      Inc(DWord(PBitDWord), 3);
      BitOffset := 0;
    end;
    If (BitOffset = 0) Then
      PBitDWord^ := 0;

    PBitDWord^ := PBitDWord^ OR ((BitData AND 7) SHL BitOffset);
    Inc(BitOffset, 3);
  end;

  Procedure WriteSpaces;
  var n: Integer;
  begin
    While Space > 0 do
    begin
      If Space > 1 Then
        WriteBits(7);
      If Space > 596 Then
      begin
        For n := 0 To 5 do
          WriteBits(0);
        For n := 0 To 2 do
          WriteBits(7);
        Dec(Space, 595);
      end else
      begin
        Case Space of
          1:      WriteBits(0);
          2..8:   WriteBits(Space - 1);
          9..15:
          begin
            WriteBits(0);
            WriteBits(Space - 7 - 1);
          end;
          16..22:
          begin
            WriteBits(0);
            WriteBits(0);
            WriteBits(Space - 14 - 1);
          end;
          23..85:
          begin
            For n := 0 To 2 do
              WriteBits(0);
            WriteBits(Space - 21 - 1);
            WriteBits((Space - 21 - 1) SHR 3);
          end;
          86..596:
          begin
            For n := 0 To 4 do
              WriteBits(0);
            WriteBits(Space - 84 - 1);
            WriteBits((Space - 84 - 1) SHR 3);
            WriteBits((Space - 84 - 1) SHR 6);
          end;
        end;
        Space := 0;
        Exit;
      end;
    end;
  end;

begin
  Space := 0;
  Index := 0;
  BitOffset := 0;
  PBitDWord := Dest;
  Data := Src;
  While Index < Size do
  begin
    If Data^[Index] = 0 Then
      Inc(Space)
    else
    begin
      WriteSpaces;
      WriteBits(Data[Index]);
    end;
    Inc(Index);
  end;
  If Space > 0 Then
    WriteSpaces;
  Result := DWord(PBitDWord) - DWord(Dest) + 1;
  Inc(Result, RoundBy(BitOffset, 8) div 8);
  {
  Case BitOffset of
    3..6:       Inc(Result);
    9..15:      Inc(Result, 2);
    18..24:     Inc(Result, 3);
  end;
  }

  // 111 xxx + 1                                   : 2..8
  // 111 000 xxx + 7                               : 9..14
  // 111 000 000 xxx + 14                          : 15..21
  // 111 000 000 000 xxx xxx + 21                  : 22..84
  // 111 000 000 000 000 000 xxx xxx xxx + 84      : 85..595
end;

Procedure DataToTile(Data: PByte; var Tile: TTile; Width, Height: Integer; Rev: Boolean = False);
var n, m: Integer;
begin
  For m := 0 To Height - 1 do
  begin
    For n := 0 To Width - 1 do
    begin
      If Rev Then
        Data^ := Tile[m, n]
      else
        Tile[m, n] := Data^;
      Inc(Data);
    end;
  end;
end;

Function SaveFontToBuf(Ptr: Pointer; var Font: TFontData; Index: Integer): Integer;
var
  CharPtr, HdrSize: DWord; EmptyTile: TTile; n, Size: Integer;
  CharData: Array[0..64*64-1] of Byte; DestPtr: Word; NULL: Boolean;
begin


  FillChar(EmptyTile, SizeOf(TTile), 0);
  HdrSize := SizeOf(TFontData) - cCharCount * SizeOf(TTile) - 4;
  CharPtr := HdrSize;
  For n := 0 To cCharCount - 1 do With Font do
  begin
    If n <= $DF Then
      NULL := Widths[n] = 0
    else
      NULL := CompareMem(@Chars[n], @EmptyTile, SizeOf(TTile));
    If NULL Then
    begin
      Ptrs[n] := 0;
      Continue;
    end;
    DestPtr := Word(CharPtr div 4);
    If DestPtr = 0 Then
    begin
      Inc(DestPtr);
      Inc(CharPtr, 4);
    end;
    Ptrs[n] := DestPtr;

    If n <= $DF Then
    begin
      DataToTile(@CharData, Chars[n], Widths[n], cFontHeight[Index], True);
      Size := cFontHeight[Index] * Widths[n];
    end else
    begin
      DataToTile(@CharData, Chars[n], cJapWidth[Index], cFontHeight[Index], True);
      Size := cFontHeight[Index] * cJapWidth[Index];
    end;
    Inc(CharPtr, RoundBy(EncodeChar(@CharData, Pointer(DWord(Ptr) + CharPtr), Size), 4));
  end;
  Move(Font, Ptr^, HdrSize);
  Result := CharPtr;
end;

Procedure LoadFontFromBuf(Ptr: Pointer; var Font: TFontData; Index: Integer);
var HdrSize, n: Integer; CharPtr: DWord;
PtrIncr, LastPtr: DWord; CharData: Array[0..64*64-1] of Byte;
begin
  FillChar(Font, SizeOf(TFontData), 0);
  HdrSize := SizeOf(TFontData) - cCharCount * SizeOf(TTile) - 4;
  Font.Height := cFontHeight[Index];
  Move(Ptr^, Font, HdrSize);
  PtrIncr := 0;
  LastPtr := 0;
  For n := 0 To cCharCount - 1 do With Font do
  begin
    If (LastPtr > 0) and (Ptrs[n] <> 0) and (Ptrs[n] < LastPtr) Then
    begin
      Inc(PtrIncr, $10000);
    end;
    If Ptrs[n] > 0 Then
    begin
      LastPtr := Ptrs[n];
      CharPtr := (Ptrs[n] + PtrIncr) * 4;
      If n <= $DF Then
      begin
        DecodeChar(Pointer(DWord(Ptr) + CharPtr), @CharData, Font.Widths[n] * Height);
        DataToTile(PByte(@CharData), Font.Chars[n], Font.Widths[n], cFontHeight[Index]);
      end else
      begin
        DecodeChar(Pointer(DWord(Ptr) + CharPtr), @CharData, cJapWidth[Index] * cFontHeight[Index]);
        DataToTile(PByte(@CharData), Font.Chars[n], cJapWidth[Index], cFontHeight[Index]);
      end;
    end;    
  end;
end;

Function GetChar(var Char: TCharacter; H: Integer; P: Pointer; Put: Boolean = False; FFROM: Boolean = False): Integer;
var n, m, Cur: Integer; Buf: Array[0..1023] of Byte;
begin
  If not Put Then
  begin
    DecodeChar(P, @Buf, Char.W * H);
    Cur := 0;
    For m := 0 To H - 1 do
    For n := 0 To Char.W - 1 do
    begin
      Char.Ch[m, n] := Buf[Cur];
      Inc(Cur);
    end;
  end;
end;

Procedure CharsToDIB(var Font: TFontData; var Pic: TDIB; From: Boolean = False);
var n,m,l,X,Y: Integer; B: ^Byte;
begin
  X:=0; Y:=0;
  If not Assigned(Pic) Then
  begin
    Pic:=TDIB.Create;
    Pic.BitCount := 8;
    Pic.Width := CharWidth*16;
    Pic.Height := CharHeight* (RoundBy(Length(Font.Chars),16) div 16);
    For n:=0 To 15 do
    begin
      Pic.ColorTable[n].rgbBlue  := (Palette[n] SHR 16) AND $FF;
      Pic.ColorTable[n].rgbGreen := (Palette[n] SHR 8)  AND $FF;
      Pic.ColorTable[n].rgbRed   :=  Palette[n]         AND $FF;
    end;
    Pic.UpdatePalette;
  end;
  For l:=0 To High(Font.Chars) do
  begin
    For m:=0 To CharHeight-1 do
    begin
      B:=Pic.ScanLine[Y+m];
      Inc(B,X);
      If From Then
        Move(B^,Font.Chars[l][m,0],CharHeight)
      else
        Move(Font.Chars[l][m,0],B^,CharWidth);
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

Procedure TMainForm.Save(const FileName: String);
var F: File; Buf: Pointer; Header: TFontFileHeader;
begin
  AssignFile(F, FileName);
  Rewrite(F, 1);

  GetMem(Buf, 1024*1024);
  ZeroMemory(@Header, SizeOf(Header));
  Header.Sign := 'SH2F';
  Seek(F, SizeOf(Header));
  BlockWrite(F, Palette, SizeOf(Palette));
         
  ZeroMemory(Buf, 1024*1024);
  Seek(F, RoundBy(FilePos(F), 16));
  Header.Font0.Offset := FilePos(F);
  Header.Font0.Size   := SaveFontToBuf(Buf, FontData[0], 0);
  BlockWrite(F, Buf^, Header.Font0.Size);
                                   
  ZeroMemory(Buf, 1024*1024);
  Seek(F, RoundBy(FilePos(F), 16));
  Header.Font1.Offset := FilePos(F);
  Header.Font1.Size   := SaveFontToBuf(Buf, FontData[1], 1);
  BlockWrite(F, Buf^, Header.Font1.Size);

  Seek(F, 0);
  BlockWrite(F, Header, SizeOf(Header));

//  BlockWrite(F, FontData, SizeOf(FontData));
  CloseFile(F);

  FreeMem(Buf);
  Saved := True;
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
 BufChar := FontData[CurFont].Chars[CurChar];
 If CurChar < $DF Then BufWidth := FontData[CurFont].Widths[CurChar]
 else BufWidth := cJapWidth[CurFont];
end;

procedure TMainForm.EditPasteActionExecute(Sender: TObject);
begin
 FontData[CurFont].Chars[CurChar] := BufChar;
 If CurChar <= $DF Then
   FontData[CurFont].Widths[CurChar] := BufWidth;
 DrawChars;
 DrawChar;
 Saved := False;
end;

procedure TMainForm.EditClearActionExecute(Sender: TObject);
begin
 FillChar(FontData[CurFont].Chars[CurChar], SizeOf(TTile), 0);
 If CurChar <= $DF Then
   FontData[CurFont].Widths[CurChar] := 0;
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
   B := Addr(FontData[CurFont].Chars[CurChar]);
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
  If CurChar <= $DF Then
    FontData[CurFont].Widths[CurChar] := CharWidth;
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
   B := Addr(FontData[CurFont].Chars[CurChar]);
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
  If CurChar <= $DF Then
    FontData[CurFont].Widths[CurChar] := CharWidth;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditFlipHorisontalActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile; W: Byte;
begin
 If CurChar <= $DF Then
   W := FontData[CurFont].Widths[CurChar]
 else
   W := cJapWidth[CurFont];
 With FontData[CurFont] do
 begin
  WW := W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
  If WW < 1 then Exit;
  Move(Chars[CurChar], Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to WW do
    Chars[CurChar][Y, WW - X] := Tile[Y, X];
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditFlipVerticalActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile; W: Byte;
begin
 If CurChar <= $DF Then
   W := FontData[CurFont].Widths[CurChar]
 else
   W := cJapWidth[CurFont];
 With FontData[CurFont] do
 begin
  WW := W - 1; If WW > CharWidth - 1 then WW := CharWidth - 1;
  If WW < 1 then Exit;
  Move(Chars[CurChar], Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to WW do
    Chars[CurChar][(CharWidth - 1) - Y, X] := Tile[Y, X];
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveUpActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With FontData[CurFont] do
 begin
  Move(Chars[CurChar], Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
  begin
   WW := Y - 1; If WW < 0 then WW := CharHeight - 1;
   For X := 0 to CharWidth - 1 do
    Chars[CurChar][WW, X] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveDownActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With FontData[CurFont] do
 begin
  Move(Chars[CurChar], Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
  begin
   WW := Y + 1; If WW = CharHeight then WW := 0;
   For X := 0 to CharWidth - 1 do
    Chars[CurChar][WW, X] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveLeftActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With FontData[CurFont] do
 begin
  Move(Chars[CurChar], Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to CharWidth - 1 do
   begin
    WW := X - 1; If WW < 0 then WW := CharWidth - 1;
    Chars[CurChar][Y, WW] := Tile[Y, X];
  end;
  DrawChars;
  DrawChar;
  Saved := False;
 end;
end;

procedure TMainForm.EditMoveRightActionExecute(Sender: TObject);
Var WW, X, Y: Integer; Tile: TTile;
begin
 With FontData[CurFont] do
 begin
  Move(Chars[CurChar], Tile, SizeOf(TTile));
  For Y := 0 to CharHeight - 1 do
   For X := 0 to CharWidth - 1 do
   begin
    WW := X + 1; If WW = CharWidth then WW := 0;
    Chars[CurChar][Y, WW] := Tile[Y, X];
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
//var n: Integer;
begin


 //ShowMessage(IntToStr(SizeOf(ShortInt)));
 FillChar(FontData, SizeOf(FontData), 0);
 //FontData.Signature := 'FONT';
 //FontData.Height := 64;
 //FontData.BitCount := 2;
 //FontData.Count := 256;
 //SetLength(Chars, 256);
 FSaved := True;
 CharWidth := cCharWidth;
 CharHeight := cCharHeight;

 Palette[0] := 0;
 Palette[1] := $5F5F5F;
 Palette[2] := $7F7F7F;
 Palette[3] := $9F9F9F;
 Palette[4] := $BFBFBF;
 Palette[5] := $DFDFDF;
 Palette[6] := $FFFFFF;
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
 FontInit;
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
 If CurChar > High(FontData[CurFont].Chars) Then CurChar := High(FontData[CurFont].Chars);
 If (CurChar < CurChars) or (CurChar - CurChars > 256) Then
  CurChar := CurChars;
 With DIB1 do
 begin
  I := CurChars;
  ZX := 16*CharWidth; ZY := 16*CharHeight;
  For YY := 0 to 15 do
  begin
   B := ScanLine[YY * CharHeight];
   For XX := 0 to 15 do With FontData[CurFont] do
   begin
    BB := B;
    Inc(BB, XX * CharWidth);
    For Y := 0 to Integer(CharHeight) - 1 do
    begin
     If I > High(Chars) Then
       FillChar(BB^, CharWidth, 0)
     else
       Move(Chars[I][Y, 0], BB^, CharWidth);
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
 end;
 If CurChar > High(FontData[CurFont].Chars) Then Exit;
 If CurChar >= $80 Then
   S := Format('$%.4x', [GetCode(CurChar)])
   //S := Format('$%.2x%.2x',
   //  [$82 + (CurChar - $80) div $80,((CurChar - $80) div $80) + CurChar])
 else
   S := Format('$%.2x',[CurChar]);
 StatusBar.Panels[0].Text := Char(CurChar);
 StatusBar.Panels[1].Text := '$' + IntToHex(CurChar, 2);
 StatusBar.Panels[2].Text := '#' + IntToStr(CurChar);
 If CurChar <= $DF Then
   StatusBar.Panels[3].Text := Format('W: %d;', [FontData[CurFont].Widths[CurChar]])
 else
   StatusBar.Panels[3].Text := Format('W: %d;', [cJapWidth[CurFont]]);

 //With FontData[CurFont].Chars[CurChar] do StatusBar.Panels[3].Text :=
 // Format('W: %d; P: %d; %s',[W,P,S]);
end;

procedure TMainForm.DrawChar;
Var Y, H, W, WW: Integer; B: ^Byte; PM: TPenMode;
begin        
 If CurChar > High(FontData[CurFont].Chars) Then Exit;
 With DIB2 do
 begin
  B := Addr(FontData[CurFont].Chars[CurChar]);
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

 With CharImage.Canvas, FontData[CurFont] do
 begin
  StretchDraw(ClipRect, DIB2);
  If CurChar > $DF Then Exit;
  W := Widths[CurChar];
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
 (* X := X div 16;
  Y := Y div 16;
  SelChar := Y * 16 + X + CurChars;
  If SelChar <= High(FontData[CurFont].Chars) Then
    FontData[CurFont].Chars[SelChar].N := not Chars[SelChar].N;
  DrawChars;
  DrawChar; *)
 end;
end;

procedure TMainForm.CharImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
//var WW: Integer;
begin
 If ssCtrl in Shift then With FontData[CurFont] do
 begin
  If CurChar > $DF Then Exit;
//  WW := FontData[CurFont].Widths[CurChar];
  If X > 256 - 8 then
   Widths[CurChar] := CharWidth Else
   Widths[CurChar] := X div (256 div CharWidth);
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
  X := X div (256 div CharWidth); Y := Y div (256 div CharWidth);
  With FontData[CurFont] do CurCol := Chars[CurChar][Y, X];
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
 With FontData[CurFont] do Chars[CurChar][Y, X] := CurCol;     
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


procedure TMainForm.Open(const FileName: String);
Var F: File; Header: TFontFileHeader; Buf: Pointer;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, Header, SizeOf(Header));
  BlockRead(F, Palette, SizeOf(Palette));

  Seek(F, Header.Font0.Offset);
  GetMem(Buf, Header.Font0.Size);
  BlockRead(F, Buf^, Header.Font0.Size);
  LoadFontFromBuf(Buf, FontData[0], 0);

  Seek(F, Header.Font1.Offset);
  ReallocMem(Buf, Header.Font1.Size);
  BlockRead(F, Buf^, Header.Font1.Size);
  LoadFontFromBuf(Buf, FontData[1], 1);

  FreeMem(Buf);


  //BlockRead(F, FontData, SizeOf(FontData));
  CloseFile(F);
  
  Self.FileName := FileName;
  Saved := True; 
  DrawPalette;
  DrawChar;
  DrawChars;
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
    If CurChar < 0 Then CurChar := High(FontData[CurFont].Chars) else
    If CurChar > High(FontData[CurFont].Chars) Then CurChar := 0;
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
  CharsToDIB(FontData[CurFont],Pic);
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
  CharsToDIB(FontData[CurFont],Pic,True);
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
  If ssCtrl in Shift Then
  begin
    If CurChar > $DF Then Exit;
    Dec(FontData[CurFont].Widths[CurChar]);
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
    If CurChar > $DF Then Exit;
    Inc(FontData[CurFont].Widths[CurChar]);
    Saved := False;
    DrawChars;
    DrawChar;
  end else
  If ScrollBar.Position < ScrollBar.Max Then
    ScrollBar.Position := ScrollBar.Position + 1;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  MessageDlg('GUI Engine by Djinn'#9#9'http://magicteam.net/'#13#10'Editor Engine by HoRRoR'#9'http://consolgames.ru/'#13#10'Special thanks to Dencraft for font research', mtInformation, [mbOK], 0);
end;

procedure TMainForm.FontInit;   
var WH: Integer;
begin
   (*Case FontData.Height of
    01..08: WH:=8;
    09..16: WH:=16;
    17..32: WH:=32;
    33..64: WH:=64;
   end;*)
   WH := 32;
   CharWidth := WH;
   CharHeight := WH;
   DIB2.Width := CharWidth;
   DIB2.Height := CharHeight;
   DIB1.Width := CharWidth * 16;
   DIB1.Height := CharHeight * 16;
   DIB2.Width := CharWidth;
   DIB2.Height := CharHeight;
   If cCharCount > 256 Then
     ScrollBar.Max := RoundBy(cCharCount - 256, 16) div 16
   else
     ScrollBar.Max := 0;
end;

procedure TMainForm.FileNewActionExecute(Sender: TObject);
var Buf: Pointer; F: File; IPtr1, IPtr2: DWord; Ptr1, Ptr2: Pointer;
    Info: TImportInfo;
begin

  If not CheckSaved Then Exit;

//  If not PropForm.Show(Info) Then Exit;

  If not OpenExeDialog.Execute Then Exit;
  AssignFile(F, OpenExeDialog.FileName);
  Reset(F, 1);
  GetMem(Buf, FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  CloseFile(F);

  If DWord(Buf^) = $905A4D Then
  begin
    Case DWord(Pointer(DWord(Buf) + $3C)^) of
      $110:
      begin
        IPtr1 := DWord(Pointer(DWord(Buf) + cPCPointer1)^) - cPCPtrDef;
        IPtr2 := DWord(Pointer(DWord(Buf) + cPCPointer2)^) - cPCPtrDef;
      end;
      $118:
      begin
        IPtr1 := DWord(Pointer(DWord(Buf) + $406488)^) - cPCPtrDef;
        IPtr2 := DWord(Pointer(DWord(Buf) + $406488)^) - cPCPtrDef;
      end;
      else
      begin
        ShowMessage('Unsupported version!');
        FreeMem(Buf);
        Exit;
      end;
    end;
  end else
  If DWord(Buf^) = $464C457F Then
  begin
    IPtr1 := DWord(Pointer(DWord(Buf) + cPointer1)^) - cPtrDef;
    IPtr2 := DWord(Pointer(DWord(Buf) + cPointer2)^) - cPtrDef;
  end else
  begin
    ShowMessage('File is not PC/PS2 executable!');
    FreeMem(Buf);
    Exit;
  end;
  Ptr1 := Pointer(DWord(Buf) + IPtr1);
  Ptr2 := Pointer(DWord(Buf) + IPtr2);
  LoadFontFromBuf(Ptr1, FontData[0], 0);
  LoadFontFromBuf(Ptr2, FontData[1], 1);
  FreeMem(Buf);
  DrawChar;
  DrawChars;

end;

procedure TMainForm.SaveWidthsActionExecute(Sender: TObject);
var List: TStringList; n: Integer;
begin
 If SaveWidthsDialog.Execute then
 begin
   List := TStringList.Create;
   For n := 0 To $DF do
     List.Add(IntToStr(FontData[CurFont].Widths[n]));
   List.SaveToFile(SaveWidthsDialog.FileName);
   List.Free;
 end;
end;


procedure TMainForm.EditSelFont0Execute(Sender: TObject);
begin
  EditSelFont1.Checked := False;
  EditSelFont0.Checked := True;
  CurFont := 0;
  DrawChars;
  DrawChar;
end;

procedure TMainForm.EditSelFont1Execute(Sender: TObject);
begin
  EditSelFont0.Checked := False;
  EditSelFont1.Checked := True;
  CurFont := 1;
  DrawChars;
  DrawChar;
end;

procedure TMainForm.ImportFromFileActionExecute(Sender: TObject);
var F: File; Buf: Pointer;
begin
  If not OpenRawDialog.Execute Then Exit;
  AssignFile(F, OpenRawDialog.FileName);
  Reset(F, 1);
  GetMem(Buf, FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  CloseFile(F);

  LoadFontFromBuf(Buf, FontData[CurFont], CurFont);

  FreeMem(Buf);
  DrawChar;
  DrawChars;
end;

procedure TMainForm.FileExportToFileActionExecute(Sender: TObject);
var Buf: Pointer; F: File; Size: Integer;
begin
  If not SaveRawDialog.Execute Then Exit;
  GetMem(Buf, 1024*1024);
  Size := SaveFontToBuf(Buf, FontData[CurFont], CurFont);
  AssignFile(F, SaveRawDialog.FileName);
  Rewrite(F, 1);
  BlockWrite(F, Buf^, Size);
  CloseFile(F);
  FreeMem(Buf);
end;

procedure TMainForm.ToolButton23Click(Sender: TObject);
var F: File;
begin
 If not OpenDialog.Execute then Exit;
 AssignFile(F, OpenDialog.FileName);
 Reset(F, 1);
 BlockRead(F, FontData, SizeOf(FontData));
 CloseFile(F);
 DrawChar;
 DrawChars;
end;

end.
