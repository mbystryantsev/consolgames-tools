unit SH5_Syt;

interface

uses Windows, Dialogs, Forms, SH5_Common, DIB, TBXGraphics, SH5_SYTGFX, Classes,
 SysUtils, ShellApi, targa;

Type
  TSytHeader = Packed Record
    Signature: Array[0..7] of Char; //0x00
    Unknown1:   DWord;              //0x08
    Unknown3:   DWord;              //0x0C
    Unknown4:   DWord;              //0x10
    Unknown5:   DWord;              //0x14
    Unknown6:    DWord;              //0x18
    Width:      DWord;              //0x1C
    Height:     DWord;              //0x20
    Unknown7:   DWord;              //0x24
    Unknown8:   DWord;              //0x28
    Unknown9:   DWord;              //0x2C bpp?
    TexType:    DWord;              //0x30
    TexName:    Array[0..$1F] of Char;
    Width2:     DWord;
    Height2:    DWord;
    Unk:        Array[0..8] of DWord;
  end;

  TTGAHeader = TGA_Header;

  TDDSHeader = Packed Record
    Sign:     Array[0..7] of Char;
    u1:    DWord;
    H,W,Size: Integer;
    u2:       Array[0..14] of DWord;
    TexType:  Array[0..3] of Char;
    u3:       Dword;
    MaskR,
    MaskG,
    MaskB,
    MaskA:    DWord;
    u4:       DWord;
    u5:       Array[0..3]  of DWord;
  end;

  TSYT = Class
    Constructor Create;
    Destructor  Destroy;
  private
    FFileName:    String;
    FOpened:      Boolean;
    FGenerated:   Boolean;
    FDIB:         TDIB;
    FPNG:         TPNGBitmap;
    FTGA:         TTGAHeader;
    FHeader:      TSytHeader;
    FDDSHeader:   TDDSHeader;
    FDDSData:     Pointer;
    FDDSDataSize: Integer;
    FBigEndian:   Boolean;
    FWidth:       Integer;
    FHeight:      Integer;
    FTexType:     Integer;
//  Procedure     LoadPicture(Buf: Pointer);
    Procedure     TGAFlip;
    Procedure     TGASetWH(W,H: Integer);
    Procedure     DDSChangeEndian;
    Procedure     SetBigEndian(Flag: Boolean);
    Procedure     SetTexType(T: Integer);   
    Procedure     DIB2PNG;
    Procedure     TGA2DIB;
    Procedure     DDS2SYT;
    Function      GetTexName: String;
    Procedure     SetTexName(S: String);
  public
    Procedure SwizzleData(var Data: Pointer; Width,Height: Integer; Paste: Boolean = False);
    Function Generate: Boolean;
    property  Width:  Integer read FWidth;
    property  Height: Integer read FHeight;
    property  BMP: TDIB read FDIB;
    property  PNG: TPNGBitmap read FPNG;
    property  DDS: TDDSHeader read FDDSHeader;
    property  TGA: TTGAHeader read FTGA;
    property  SYT: TSYTHeader read FHeader;
    //property  Patfrm:  Integer read FBigEndian;
    property  Generated: Boolean read FGenerated write FGenerated;
    property  BigEndian: Boolean read FBigEndian write SetBigEndian;
    property  TexType: Integer read FTexType write SetTexType;
    Function  LoadFromBuf(Buf: Pointer; Size: Integer):  Boolean;
    Function  LoadFromFile(FileName: String): Boolean;
    Procedure LoadDDS(FileName: String);
    Procedure LoadTGA(FileName: String);
    Procedure SavePNG(FileName: String);
    Procedure SaveDDS(FileName: String);
    Procedure SaveBMP(FileName: String);
    Procedure SaveTGA(FileName: String);
    Procedure SaveSYT(FileName: String);
    Property  TexName: String Read GetTexName Write SetTexName;
    property  SytFileName: String  read FFileName;
    property  Opened:   Boolean read FOpened;
  end;


implementation

const
  cReadDXT = '\Utils\readdxt.exe';
  cNVDXT   = '\Utils\nvdxt.exe';

Constructor TSYT.Create;
begin
  FDIB := TDIB.Create;
  FPNG := TPNGBitmap.Create;
end;

Destructor TSYT.Destroy;
begin
  FDIB.Free;
  FPNG.Free;
end;

Procedure TSYT.SetTexName(S: String);
begin
  FillChar(FHeader.TexName, SizeOf(FHeader.TexName), 0);
  Move(S[1],FHeader.TexName, Length(S));
end;

Function TSYT.GetTexName: String;
begin
  Result := FHeader.TexName;
end;

Procedure TSYT.SetBigEndian(Flag: Boolean);
begin
  Exit;
  If FBigEndian = Flag Then Exit;
  FBigEndian := Flag;
  FGenerated := False;
  {!!!!!!!!!!!!!!!!!!!!!!}
end;

Procedure TSYT.SetTexType(T: Integer);
begin
  If not (T in [0,1,3,5]) Then
  begin
    CreateError(Format('TSYT.SetTexType: Invalid texture type! (%d)',[T]));
    Exit;
  end;
  If T = FTexType Then Exit;
  FTexType   := T;
  FHeader.TexType := GetEndian(T,FBigEndian);

  FGenerated := False;
end;

Procedure TSYT.TGA2DIB;
//var n: Integer;
begin
  FDIB.Width    := FTGA.Width;
  FDIB.Height   := FTGA.Height;
  FDIB.BitCount := 32;
  //For n := FTGA.Height - 1 DownTo 0 do
  //    Move(Pointer(DWord(FTGA.Data) + n * FTGA.Width * 4)^,
  //    FDIB.ScanLine[n]^,FTGA.Width * 4);
  Move(FTGA.Data^,FDIB.ScanLine[FTGA.Height - 1]^,FTGA.Width * FTGA.Height * 4);
end;

Procedure TSYT.DDS2SYT;
begin
end;

Procedure TSYT.LoadTGA(FileName: String);
begin
  If not FileExists(FileName) Then
  begin
    CreateError(Format('TSYT.LoadTGA: File %s does not exists',[FileName]));
    Exit;
  end;
  FTGA := targa.LoadTGA(FileName);
  If FTGA.Data = nil Then
  begin
    CreateError('TSYT.LoadTGA: TGA data == nil!');
    Exit;
  end;
  If FTGA.BPP<>32 Then
  begin 
    CreateError(Format('TSYT.LoadTGA: Invalid TGA BitCount! (%d)',[FTGA.BPP]));
    Exit;
  end;

  FWidth  := FTGA.Width;
  FHeight := FTGA.Height;

  TGA2DIB;
  DIB2PNG;

end;

Procedure TSYT.LoadDDS(FileName: String);
var F: File;
begin
  If not FileExists(FileName) Then
  begin
    CreateError(Format('TSYT.LoadDDS: File %s does not exists',[FileName]));
    Exit;
  end;
  AssignFile(F, FileName);
  Reset(F,1);
  BlockRead(F,FDDSHeader,$80);
  FDDSDataSize := FileSize(F) - $80;
  ReallocMem(FDDSData, FDDSDataSize);
  Seek(F,$80);
  BlockRead(F,FDDSData^,FDDSDataSize);
  CloseFile(F);

  If FDDSHeader.TexType = '' Then
    TexType := 0
  else If FDDSHeader.TexType = 'DXT1' Then
    TexType := 1
  else If FDDSHeader.TexType = 'DXT3' Then
    TexType := 3
  else If FDDSHeader.TexType = 'DXT5' Then
    TexType := 5
  else
  begin
    CreateError(Format('TSYT.LoadDDS: Unknown texture type (%d)',[FTexType]));
    Exit;
  end;

  FWidth  := FDDSHeader.W;
  FHeight := FDDSHeader.H;
  DDS2SYT;
  FGenerated := True;

end;

Function TSYT.Generate(): Boolean;
var S,T: String; Info: _SHELLEXECUTEINFOA;
begin
  Result := False;
  If not FileExists(ExtractFilePath(ParamStr(0)) + cNVDXT) Then
  begin
    CreateError(Format('TSYT.Generate: %s does not exists!',[cNVDXT]));
    Exit;
  end;
  Case FTexType of
    0: T := '-u8888';
    1: T := '-dxt1a';
    3: T := '-dxt3';
    5: T := '-dxt5';
  end;
  SaveTGA(TempDir+'%TEMP%.tga');
  S := Format('-file %%TEMP%%.tga %s',[T]);
  With Info do
  begin
    cbSize       := SizeOf(_SHELLEXECUTEINFOA);
    Wnd          := HInstance;//Application.Handle;
    lpFile       := PChar(ExtractFilePath(ParamStr(0)) + cNVDXT);
    lpDirectory  := PChar(TempDir);
    lpParameters := PChar(S);
    lpVerb       := PChar('OPEN');
    nShow        := 0;
    fMask        := SEE_MASK_DOENVSUBST or SEE_MASK_NOCLOSEPROCESS;
  end;
  try
    Win32check(ShellExecuteEx(@Info));
    while not Application.Terminated and
      (WaitForSingleObject(Info.hProcess, 40)=WAIT_TIMEOUT) do
  finally
    if Info.hProcess <> 0 then CloseHandle(Info.hProcess);
  end;
  If not FileExists(TempDir + '%TEMP%.dds') Then
  begin
    CreateError(Format('TSYT.Generate: Temp fil %s%%TEMP%%.dds does not generated!',[TempDir]));
    Exit;
  end;
  LoadDDS(TempDir + '%TEMP%.dds');
  FGenerated := True;

  DeleteFile(TempDir + '%TEMP%.dds');
  DeleteFile(TempDir + '%TEMP%.tga');
  Result := True;
end;

Function TSYT.LoadFromFile(FileName: String): Boolean;
var Buf: Pointer; Size: Integer;
begin
  If not FileExists(FileName) Then
  begin
    Result := False;
    CreateError(Format('TSYT.LoadFromFile: File does not exist (%s)',[FileName]));
    Exit;
  end;
  Size      := LoadFile(FileName,Buf);
  Result    := LoadFromBuf(Buf, Size);
  FreeMem(Buf);
  FFileName := FileName;
end;

var cSyt0Data: Array[0..25] of DWord = (0,0,0,0,0,0,0,0,0,0,0,0,0,$20,
$41,0,$20,$FF0000,$FF00,$FF,$FF000000,$1000,0,0,0,0);
Function TSYT.LoadFromBuf(Buf: Pointer; Size: Integer): Boolean;
var {Dir,}S: String; F: File; Info: _SHELLEXECUTEINFOA;
begin
  Result     := False;

  If not FileExists(ExtractFilePath(ParamStr(0)) + cReadDXT) Then
  begin
    CreateError(Format('TSYT.LoadFromBuf: %s does not exists!',[cReadDXT]));
    Exit;
  end;

  Move(Buf^,FHeader,SizeOf(TSytHeader));
  FBigEndian := FHeader.Signature = 'X2_SYT';
  FTexType   := GetEndian(FHeader.TexType, FBigEndian);
  If not (FTexType in [0,1,3,5]) Then
  begin
    CreateError(Format('TSYT.LoadFromBuf: Unknown texture type (%d)',[FTexType]));
    Exit;
  end;

  FWidth       := GetEndian(FHeader.Width, FBigEndian);
  FHeight      := GetEndian(FHeader.Height, FBigEndian);
  FDDSDataSize := Size - SizeOf(TDDSHeader);

  FillChar(FDDSHEader,SizeOf(TDDSHeader),0);
  FDDSHeader.Sign      := 'DDS |';
  If FTexType = 0 Then
  begin
    FDDSHeader.u1      := $81007;
    Move(cSyt0Data,FDDSHeader.u2,SizeOf(cSyt0Data));
  end;
  FDDSHeader.Size      := FDDSDataSize;
  If FTexType>0 Then
  begin
    S                  := Format('DXT%.1d',[FTexType]);
    Move(S[1],FDDSHeader.TexType,4);
  end;


  Inc(DWord(Buf),SizeOf(TSytHeader));

  ReallocMem(FDDSData,FDDSDataSize);
  Move(Buf^,FDDSData^,FDDSDataSize);


  If FBigEndian Then
  begin
    DDSChangeEndian;
    If FTexType in [0,3] Then
    begin
      FDDSHeader.W := RoundBy(FWidth,  32);
      FDDSHeader.H := RoundBy(FHeight, 32);
    end;
  end else
  begin
    FDDSHeader.W   := FWidth;
    FDDSHeader.H   := FHeight;
  end;
      //\\
    // - \\
  //  | | \\
 (*)======(*)
 (*)======(*)
 (*)=Œ ÕŒ=(*)
 (*)=Œ ÕŒ=(*)
 (*)======(*)
 //||||||||\\

  //Dir := ExtractFilePath(ParamStr(0));

  AssignFile(F,TempDir + '\%TEMP%.dds');
  Rewrite(F,1);
  BlockWrite(F,FDDSHeader, SizeOf(TDDSHeader));
  BlockWrite(F,FDDSData^,FDDSDataSize);
  CloseFile(F);

  
  S   := '%TEMP%.dds';
  With Info do
  begin
    cbSize       := SizeOf(_SHELLEXECUTEINFOA);
    Wnd          := HInstance;//Application.Handle;
    lpFile       := PChar(ExtractFilePath(ParamStr(0)) + cReadDXT);
    lpParameters := PChar(TempDir+S);
    lpVerb       := PChar('OPEN');
    nShow        := 0;
    fMask        := SEE_MASK_DOENVSUBST or SEE_MASK_NOCLOSEPROCESS;
  end;
  try
    Win32check(ShellExecuteEx(@Info));
    while not Application.Terminated and
      (WaitForSingleObject(Info.hProcess, 40)=WAIT_TIMEOUT) do
      //Application.ProcessMessages;
  finally
    if Info.hProcess <> 0 then CloseHandle(Info.hProcess);
      //Dispose(Info);
      //(Sender as TControl).Enabled := True;
  end;
  //ShellExecute(Application.Handle,nil,PChar('Utils\readdxt.exe'),PChar(Dir + S),PChar(Dir),0);

  FTGA := targa.LoadTGA(Format('%s\%%TEMP%%00.tga',[TempDir]));

  If FTGA.Data = nil Then
  begin
    CreateError(Format('TSYT.LoadFromBuf: TGA data == nil! (Name: %s)',[SYT.TexName]));
    Exit;
  end;

  If FBigEndian and (FTexType = 0) Then
  begin
    TGAFlip;
    //targa.SaveTGA('C:\test360_.tga',FTGA.Width,FTGA.Height,FTGA.Data);
    SwizzleData(FTGA.Data,FTGA.Width,FTGA.Height);
    TGASetWH(FWidth,FHeight);
    TGAFlip;
    //targa.SaveTGA('C:\test360.tga',FTGA.Width,FTGA.Height,FTGA.Data);
  end;

  FDIB.BitCount := FTGA.BPP;
  FDIB.Width    := FTGA.Width;
  FDIB.Height   := FTGA.Height;
  Move(FTGA.Data^, FDIB.ScanLine[FTGA.Height-1]^, FTGA.Width * FTGA.Height * (FTGA.BPP div 8));
  DIB2PNG;

  DeleteFile(TempDir + '%TEMP%00.tga');
  DeleteFile(TempDir + '%TEMP%.dds');

  FOpened    := True;
  FGenerated := True;
  FFileName  := SYT.TexName;

  Result     := True;
end;

Procedure TSYT.DIB2PNG; 
var PixelData: TPixelData32;
begin    
  With FPNG do
  begin
   Transparent := True;
   TDIB32(Addr(DIB)^) := TDIB32.Create;
   DIB.SetSize(FDIB.Width, FDIB.Height);
   PixelData.Bits := BMP.TopPBits;
   PixelData.ContentRect := Bounds(0, 0, Width, Height);
   PixelData.RowStride := -Width;
   DIB.CopyFrom(PixelData, 0, 0, PixelData.ContentRect);
  end;
end;

{Procedure TSYT.LoadPicture(Buf: Pointer);
var PixelData: TPixelData32;
begin
  Case FTexType of
    0: RawToPic32(FDIB,Buf,FWidth,FHeight);
    3: RawToPic2(FDIB,Buf,FWidth,FHeight,FBigEndian);
  end;
  With FPNG do
  begin
   Transparent := True;
   TDIB32(Addr(DIB)^) := TDIB32.Create;
   DIB.SetSize(FDIB.Width, FDIB.Height);
   PixelData.Bits := Bitmap.TopPBits;
   PixelData.ContentRect := Bounds(0, 0, Width, Height);
   PixelData.RowStride := -Width;
   DIB.CopyFrom(PixelData, 0, 0, PixelData.ContentRect);
  end;
end;        }

Procedure TSYT.SavePNG(FileName: String);
begin
  FPNG.SaveToFile(FileName); 
end;

Procedure TSYT.SaveBMP(FileName: String);
begin
  FDIB.SaveToFile(FileName); 
end;

Procedure TSYT.SaveTGA(FileName: String);
begin
  If not targa.SaveTGA(FileName,FTGA.Width,FTGA.Height,FTGA.Data) Then
    ShowMessage('Error saving TGA!');
end;

Procedure TSYT.SaveDDS(FileName: String);
var F: File;
begin
  If not FGenerated Then If not Generate Then Exit;
  Try
    AssignFile(F,FileName);
    Rewrite(F,1);
    BlockWrite(F,FDDSHeader,SizeOf(TDDSHeader));
    BlockWrite(F,FDDSData^,FDDSDataSize);
    CloseFile(F);
  except
    CreateError(Format('TSYT.SaveDDS: Error saving DDS! (%s)',[FileName]));
  end;
end;

Procedure TSYT.SaveSYT(FileName: String);
var F: File;
begin
  If not FGenerated Then If not Generate Then Exit;
  Try
    AssignFile(F,FileName);
    Rewrite(F,1);
    BlockWrite(F,FHeader,SizeOf(TSytHeader));
    BlockWrite(F,FDDSData^,FDDSDataSize);
    CloseFile(F);
    FFileName := FileName;
  except
    CreateError(Format('TSYT.SaveSYT: Error saving SYT! (%s)',[FileName]));
  end;
end;


{Procedure TSYT.SwizzleData();
begin
  Side:=True;
  Incr:=4*W*(TW div 2);
  Len:=W*4;
  For l:=0 To TH-1 do    //4
  begin
    For r:=0 To TW-1 do  //2
    begin
      If ((l*TW+r) AND $1F)=0 Then Side:=not Side;
      For m:=0 To H-1 do
      begin
        WB:=Pointer(DWord(ScanLine(Y+m+l*H))+X*4+r*W*4);
        If Side Then
        begin
          If r<(TW div 2) Then
            MoveP(B^,Pointer(DWord(WB) + Incr)^,Len,Paste)
          else
            MoveP(B^,Pointer(DWord(WB) - Incr)^,Len,Paste);
          end
          else
            MoveP(B^,WB^,Len,Paste);
          Inc(B, W);
        end;
      end;
    end;
end;  }

Procedure TSYT.SwizzleData(var Data: Pointer; Width,Height: Integer; Paste: Boolean = False);
var n,m,l,r: Integer; B,WB: ^{Byte}DWord;  TWc,THc: Integer;
Side: Boolean; X,Y,nn,mm: Integer; pixels: Pointer;
const
  {W  = 4;
  H  = 2;
  TW = 8;
  TH = 16;
  BC = 4;
  WW = W*TW;
  HH = H*TH;
  SZ = WW*HH*BC;
  Incr = BC*W*(TW div 2);
  Len  = W*BC;}

  W  = 4;
  H  = 2;
  TW = 8;
  TH = 16;
  BC = 4;
  WW = W*TW;
  HH = H*TH;
  SZ = WW*HH*BC;
  Incr = BC*W*(TW div 2);
  Len  = W*BC;

  Function ScanLine(Y: Integer): Pointer;
  begin
    Result := Pointer(DWord(pixels) + Y * Width * BC);
  end;
  Procedure MoveP(var src,dest; Len: Integer; Paste: Boolean);
  begin
    If not Paste Then Move(src,dest,Len) Else Move(dest,src,Len);
  end;

begin
  GetMem(pixels, Height * Width * BC);
 // ShowMessage(Format('%f %f',[FDDSDataSize / 4096, (TGA.Height * TGA.Width * 4) / 4096]));
  For mm := 0 To (Height div (H*TH)) - 1 do
  For nn := 0 To (Width  div (W*TW)) - 1 do
  begin
    B := Pointer(DWord(Data) + (mm * (Height div HH) + nn)*SZ);
    X := nn*W*TW;
    Y := mm*H*TH;
    // -------------------------------------
      Side:=True;
      For l:=0 To TH-1 do    //4
      begin
        For r:=0 To TW-1 do  //2
        begin
          If ((l*TW+r) AND $1F)=0 Then Side:=not Side;
          For m:=0 To H-1 do
          begin
            WB:=Pointer(DWord(ScanLine(Y+m+l*H))+X*BC+r*W*BC);
            If Side Then
            begin
              If r<(TW div 2) Then
                MoveP(B^,Pointer(DWord(WB) + Incr)^,Len,Paste)
              else
                MoveP(B^,Pointer(DWord(WB) - Incr)^,Len,Paste);
            end
            else
              MoveP(B^,WB^,Len,Paste);
            Inc(DWord(B), W*BC);
          end;
        end;
      end;
    // -------------------------------------
    //Inc(B,W*TW*H*TH*BC);
  end;
  FreeMem(Data);
  Data := Pixels;
  (*_________*)
  (*         *)
  (*   Ã®ƒ   *)
  (*  “”À’Œ¬ *)
  (*_________*)
  
end;

Procedure TSYT.TGAFlip;
Type
 TCardinalArray = array [0..1] of Cardinal;
 PCardinalArray = ^TCardinalArray;
var
 pixels: pointer;
 Data:   pointer;
 Ar:  PCardinalArray absolute pixels;
 ArT: PCardinalArray absolute Data;
 Y: Integer;
begin
  Data := FTGA.Data;
  GetMem(pixels,FTGA.Width * FTGA.Height * 4);
  For Y := FTGA.Height - 1 downto 0 do
   Move(ArT^[Y * FTGA.Width], Ar^[(FTGA.Height - Y - 1) * FTGA.Width], FTGA.Width * 4);
  FreeMem(FTGA.Data);
  FTGA.Data := pixels;
     /////// |
    ///////  |
   ///////   |
  (*    *|   |
  (*    *|   |
  (* Õ  *|   |
  (* »  *|   |
  (* ∆  *|   |
  (*    *|  /
  (* Œ  *| /
  (*____*)
end;

Procedure TSYT.DDSChangeEndian;
Type
  TDDSDataChain = Packed Record
    W: Array[0..5] of Word;
    I: Array[0..1] of Word;
  end;
var
  Data: ^TDDSDataChain;
  n,m:    Integer;
  DW: ^DWord;
begin
  Case FTexType of
    0:
    begin
      DW := FDDSData;
      For n:=0 To (FDDSDataSize div 4)-1 do
      begin
        DW^:=GetEndian(DW^, True);
        Inc(DW);
      end;
    end;
    3:
    begin
       Data := FDDSData;
       For n:=0 To (FDDSDataSize div 16)-1 do
       begin
         For m:=0 To High(Data^.W) do
         Data^.W[m] := GetEndianW(Data^.W[m], True);
         //Data^.I      := GetEndian(Data^.I,True);
         Inc(Data);
       end;
    end;
  end;
end;

Procedure TSYT.TGASetWH(W,H: Integer);
var pixels: Pointer; n,R,HH: Integer;
begin
  If FTGA.Width = W Then Exit;
  GetMem(pixels, W*H*4);

  If W > FTGA.Width  Then R := W - FTGA.Width
  else                    R := FTGA.Width - W;
  R := R * 4;
  If H < FTGA.Height Then HH := H
  else                    HH := FTGA.Height;
    
  For n:=0 To HH - 1 do
  begin
    If W<FTGA.Width Then
      Move(Pointer(DWord(FTGA.Data) + n*FTGA.Width*4 + R)^, Pointer(DWord(pixels) + n*W*4)^, W*4)  
    else
      Move(Pointer(DWord(FTGA.Data) + n*FTGA.Width*4)^, Pointer(DWord(pixels) + n*W*4 + R)^, W*4);
  end;
  FTGA.Width  := W;
  FTGA.Height := H;
  FreeMem(FTGA.Data);
  FTGA.Data  := pixels;
end;

end.
 