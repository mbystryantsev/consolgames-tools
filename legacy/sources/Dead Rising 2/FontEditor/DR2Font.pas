unit DR2Font;

interface

uses Classes, Types, AtlasBuilder, DIB;

Type
  TFloatRect = Packed Record
    Left, Top, Right, Bottom: Single;
  end;
  TCharRecord = Packed Record
    Code:     LongWord;
    case byte of
    0: (
    Rect:     TFloatRect;
    W:        Integer;
    L, Y:     SmallInt;
    );
    1: (i_r: TRect);
  end;
  PCharRecord = ^TCharRecord;

  TFontHeader  = Packed Record
    Count: Integer;
    Unk:   Integer;
  end;
  TTexHeader = Packed Record
    Magic: Array[0..3] of Byte;
    Width, Height: Word;
    Unk: Array[0..3] of Byte;
    Unk2: LongWord;
    Unk3, Unk4: LongWord;
    HeaderSize: LongWord;
    DataSize: LongWord;
    CommonSize: LongWord;
    Unk5: Array[0..2] of LongWord;
  end;

  TFileHeader = Packed Record
    Magic: Array[0..3] of Byte; // 04 03 02 01 or 06 05 04 03
    HeaderSize: Integer;
    FileSize: Integer;
    SectionCount, Unk1: Integer;
    NamesOffset: LongWord;
  end;

  TKerningHeader = Packed Record
    Count: Integer;
    Unk: Integer;
  end;

  TSectionHeader = Packed Record
    NamePos:LongWord;
    Size:   LongWord;
    Offset: LongWord;
    Unk1 {Flags?}, NameEnd: LongWord;
  end;

  TSectionHeaderAlt = Packed Record
    NamePos:LongWord;
    Unk:    LongWord;
    Size, Size2:   LongWord;
    Offset: LongWord;
    Unk1 {Flags?}, NameEnd: LongWord;
  end;
  PSectionHeader = ^TSectionHeader;

  TKerningData = Packed Record
    a: LongWord;
    b: LongWord;
    c: Integer;
  end;

  TDR2Font = class
  private
    FLoaded: Boolean;
    Image: PByte;                 
    //BigEndian: Boolean;
    //MaxSize: Integer;
    FileHeader: TFileHeader;
    FontHeader: TFontHeader;
    TexHeader:  TTexHeader;
    KerningHeader: TKerningHeader;
    Sections:     Array of TSectionHeader;
    SectionsAlt:  Array of TSectionHeaderAlt;
    SectionNames: Array of String;
    CharData:     Array of TCharRecord;
    KerningData:  Array of TKerningData;
    Function FindSection(const Name: String): PSectionHeader;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadFont(const FileName: String): Boolean; overload;
    function LoadFont(const Stream: TStream): Boolean; overload;
    function SaveForXBOX360(const Stream: TStream; Width, Height: Integer; Mirror, ForceAlt: Boolean): Boolean; overload;
    function SaveForXBOX360(const FileName: String; Width, Height: Integer; Mirror, ForceAlt: Boolean): Boolean; overload;
  end;


implementation

const
  cTextureStr       = '_TEXTURE_'   ;
  cFontHeaderStr    = '_FONTHEADER_';
  cFontDataStr      = '_FONTDATA_'  ;
  cKerningHeaderStr = '_KERNINGHEADER_';
  cKerningDataStr   = '_KERNINGDATA_'  ;

Function Endian(var v): LongWord;
begin
  Result := ((LongWord(V) SHR 24) OR ((LongWord(V) SHR 8) AND $FF00) OR ((LongWord(V) SHL 8) AND $FF0000) OR (LongWord(V) SHL 24))
end;

Procedure EndianF(var v);
//var L: LongWord;
begin
  //L := ((LongWord(V) SHR 24) OR ((LongWord(V) SHR 8) AND $FF00) OR ((LongWord(V) SHL 8) AND $FF0000) OR (LongWord(V) SHL 24));
  //Result := PSingle(@L)^;
  LongWord(v) := Endian(LongWord(v));
  //PLongWord(@Result)^ := L;
end;

Function EndianW(V: Word): Word;
begin
  Result := ((v SHR 8) OR (V SHL 8));
end;

Procedure EndianChar(var C: TCharRecord);
begin
  C.Code := Endian(C.Code);
  //EndianF(C.Rect.Left);
  //EndianF(C.Rect.Top);
  //EndianF(C.Rect.Right);
  //EndianF(C.Rect.Bottom);

  C.i_r.Left := Endian(C.i_r.Left);
  C.i_r.Top := Endian(C.i_r.Top);
  C.i_r.Right := Endian(C.i_r.Right);
  C.i_r.Bottom := Endian(C.i_r.Bottom);

  PLongWord(@C.W)^ := Endian(PLongWord(@C.W)^);
  PWord(@C.L)^ := EndianW(PWord(@C.L)^);
  PWord(@C.Y)^ := EndianW(PWord(@C.Y)^);
  //C.InfoIndex := EndianW(C.InfoIndex);
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
    Count := Endian(Count);
    Unk := Endian(Unk);
  end;
end;

Procedure EndianKerningHeader(var H: TKerningHeader);
begin
  With H do
  begin
    Count := Endian(Count);
    Unk := Endian(Unk);
  end;
end;


Procedure EndianTexHeader(var H: TTexHeader);
var i: Integer;
begin
  H.Width := EndianW(H.Width);
  H.Height := EndianW(H.Height);
  //H.Unk1 := EndianW(H.Unk1);
  H.Unk2 := Endian(H.Unk2);
  H.Unk3 := Endian(H.Unk3);
  For i := 0 To High(H.Unk5) do
    H.Unk5[i] := Endian(H.Unk5[i]);
  H.HeaderSize := Endian(H.HeaderSize);
  H.DataSize := Endian(H.DataSize);
  H.CommonSize := Endian(H.CommonSize);
  //For i := 0 To 10 do
  //  H.Unk[i] := Endian(H.Unk[i]);
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If R=0 Then
 begin
  //ShowMessage(Format('Division by zero! (%d/%d)',[Value,R]));
  Exit;
 end;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Procedure SaveImage(const FileName: String; Data: Pointer; Width, Height: Integer);
var Pic: TDIB; i: Integer;
begin
  Pic := TDIB.Create;
  Pic.BitCount := 8;
  Pic.Width := Width;
  Pic.Height := Height;
  For i := 0 To 255 do
  begin
    Pic.ColorTable[i].rgbBlue := i;
    Pic.ColorTable[i].rgbGreen := i;
    Pic.ColorTable[i].rgbRed := i;
    Pic.ColorTable[i].rgbReserved := 255;
  end;
  Pic.UpdatePalette;
  For i := 0 To Height - 1 do
  begin
    Move(Pointer(LongWord(Data) + i * Width)^, Pic.ScanLine[i]^, Width);
  end;
  Pic.SaveToFile(FileName);
  Pic.Free;


  
end;


const l_matrix: Array[0..7] of Integer = (0, 2, 1, 3, 4, 6, 5, 7);
const t_matrix: Array[0..7] of Integer = (0, 1, 2, 3, 6, 7, 4, 5);

Procedure UpdateCoord(var x, y: Integer; const w: Integer);
begin
  Inc(x, 32);
  If x >= w Then
  begin
    x := 0;
    Inc(y, 32); 
  end;
end;

Procedure EncodeImage(Src, Dest: Pointer; Width, Height: Integer);
var Image, p, sp: ^Byte; Count, w, h, t, th, x, y, x1, x2, y1, y2, xx, yy, index: Integer;
begin
  w := RoundBy(Width, 32);
  h := RoundBy(Height, 32);
  x1 := 0;
  x2 := 0;
  y1 := 0;
  y2 := 16;
  index := 0;
  Count := RoundBy((w div 32) * (h div 16), 8);
  GetMem(Image, w * h);
  FillChar(Image^, w * h, 0);
  FillChar(Dest^, RoundBy(W * H, $1000), 0);

  p := Image;
  sp := Src;
  For y := 0 To Height - 1 do
  begin
    Move(sp^, p^, Width);
    Inc(p, w);
    Inc(sp, Width);
  end;


  p := Dest;

  While Count > 0 do
  begin
    If index < 4 Then
    begin
      x := x1;
      y := y1;
      UpdateCoord(x1, y1, w);
    end else
    begin
      x := x2;
      y := y2;
      UpdateCoord(x2, y2, w);
    end;
    Inc(index);
    if Index >= 8 Then Index := 0;

    Dec(Count);
    If y >= h Then continue;

    For t := 0 To 7 do
    begin

      If t_matrix[t] < 4 Then
        th := 0
      else
        th := 8;
        
      For yy := 0 To 7 do
      begin
        For xx := 0 To 7 do
        begin
          p^ := PByte(LongWord(Image) + (y + l_matrix[yy] + th) * w + x + xx + ((t_matrix[t] mod 4) * 8))^;
          Inc(p);
        end;
      end;
    end;
  end;

  //Move(Image^, Dest^, w * h);
  FreeMem(Image);
end;


{ TDR2Font }

constructor TDR2Font.Create;
begin
  Image := nil;
  FLoaded := False;
end;

destructor TDR2Font.Destroy;
var i: Integer;
begin
  If Image <> nil Then FreeMem(Image);
  Finalize(Sections);
  Finalize(SectionsAlt);
  For i := 0 To High(SectionNames) do
    Finalize(SectionNames[i]);
  Finalize(SectionNames);
  Finalize(CharData);
  Finalize(KerningData);
end;

Function TDR2Font.FindSection(const Name: String): PSectionHeader;
var i: Integer;
begin
  Result := nil;
  For i := 0 To FileHeader.SectionCount - 1 do
  begin
    If SectionNames[i] = Name Then
    begin
      Result := @Sections[i];
      Exit;
    end;
  end;
end;

function TDR2Font.LoadFont(const Stream: TStream): Boolean;
Var
  i, n, y, w, s: Integer;
  C: Char;
  Pixels, FontPixels: Pointer;
  Rect: TRect;
  Section: PSectionHeader;
begin

  Result := False;
  try
    Stream.Read(FileHeader, SizeOf(TFileHeader));
    SetLength(Sections, FileHeader.SectionCount);
    SetLength(SectionNames, FileHeader.SectionCount);
    If Integer(FileHeader.Magic) = $03040506 Then
    begin
      SetLength(SectionsAlt, FileHeader.SectionCount);
      Stream.Read(SectionsAlt[0], SizeOf(TSectionHeaderAlt) * FileHeader.SectionCount);
      For i := 0 To FileHeader.SectionCount - 1 do
      begin
        Sections[i].NamePos := SectionsAlt[i].NamePos;
        Sections[i].Size := SectionsAlt[i].Size;
        Sections[i].Offset := SectionsAlt[i].Offset;
      end;
    end else
      Stream.Read(Sections[0], SizeOf(TSectionHeader) * FileHeader.SectionCount);
    For i := 0 To FileHeader.SectionCount - 1 do
    begin
      Stream.Seek(Sections[i].NamePos, 0);
      SectionNames[i] := '';
      While True Do
      begin
        Stream.Read(C, 1);
        if(C = #0) Then break;
        SectionNames[i] := SectionNames[i] + C;
      end;
    end;

    Section := FindSection('_FONTHEADER_');
    Stream.Seek(Section^.Offset, 0);
    Stream.Read(FontHeader, SizeOf(TFontHeader));
    //!!EndianFontHeader(FontHeader);

    SetLength(CharData, FontHeader.Count);
    Section := FindSection('_FONTDATA_');
    Stream.Seek(Section^.Offset, 0);
    Stream.Read(CharData[0], SizeOf(TCharRecord) * FontHeader.Count);
    //!!For i := 0 To FontHeader.Count - 1 do
      //!!EndianChar(CharData[i]);
    

    Section := FindSection('_TEXTURE_');
    Stream.Seek(Section^.Offset, 0);

    Stream.Read(TexHeader, SizeOf(TTexHeader));
    //!!EndianTexHeader(TexHeader);


    //SetLength(Chars, FontHeader.Count);
    //GetMem(Pixels, TexHeader.DataSize);
    //GetMem(Pixels, RoundBy(TexHeader.Width, 32) * RoundBy(TexHeader.Height, 32));
    //GetMem(FontPixels, TexHeader.Width * TexHeader.Height);

    If Image <> nil Then FreeMem(Image);
    GetMem(Image, TexHeader.Width * TexHeader.Height);

    //Stream.Read(Pixels^,  TexHeader.DataSize);
    Stream.Read(Image^,  TexHeader.Width * TexHeader.Height);
    //DecodeImage(Pixels, FontPixels, TexHeader.Width, TexHeader.Height);
    //FreeMem(Pixels);

    (*
    MaxSize := 0;

    For n := 0 To FontHeader.Count - 1 do
    begin
      Rect.Left := Round(CharData[n].Rect.Left * TexHeader.Width);
      Rect.Top := Round(CharData[n].Rect.Top * TexHeader.Height);
      Rect.Right := Round(CharData[n].Rect.Right * TexHeader.Width);
      Rect.Bottom := Round(CharData[n].Rect.Bottom * TexHeader.Height);
      If Rect.Right >= TexHeader.Width Then Rect.Right := TexHeader.Width - 1;
      If Rect.Bottom >= TexHeader.Height Then Rect.Bottom := TexHeader.Height - 1;
      w := Rect.Right - Rect.Left + 1;
      s := Rect.Bottom - Rect.Top + CharData[n].Y + 1;
      If w > s Then
        s := w;
      If s > MaxSize Then
        MaxSize := s;


      FillChar(Chars[n], SizeOf(TCharacter), 0);
      For y := Rect.Top To Rect.Bottom do
        Move(Pointer(LongWord(FontPixels) + y * TexHeader.Width + Rect.Left)^,
        Chars[n].Ch[y - Rect.Top + CharData[n].Y, 0], w);
    end;

    FreeMem(FontPixels);
    *)

    Section := FindSection('_KERNINGHEADER_');
    Stream.Seek(Section^.Offset, 0);       
    Stream.Read(KerningHeader, SizeOf(TKerningHeader));
    //!!EndianKerningHeader(KerningHeader);


    SetLength(KerningData, KerningHeader.Count);
    Section := FindSection('_KERNINGDATA_');
    Stream.Read(KerningData[0], SizeOf(TKerningData) * KerningHeader.Count);

    //!!For n := 0 To KerningHeader.Count - 1 do
      //!!EndianKerning(KerningData[n]);
  except
    //ShowMessage('Error!');
  end;
  FLoaded := True;
  Result := True;
end;

function TDR2Font.LoadFont(const FileName: String): Boolean;
var Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.LoadFromFile(FileName);
  except
    Result := False;
    Stream.Free;
    Exit;
  end;
  Result := LoadFont(Stream);
  Stream.Free;
end;

Function CompareRects(const X1, Y1, X2, Y2, W, H: Integer; const Data1, Data2: PByte; const Width1, Height1, Width2, Height2: Integer): Boolean;
var i, j: Integer; a, b: PByte;
begin
  Result := False;
  If (Y1 + H > Height1) or (Y2 + H > Height2) or (X1 + W > Width1) or (X2 + W > Width2) Then Exit;
  For i := 0 To H - 1 do
  begin
    a := Data1;
    Inc(a, (Y1 + i) * Width1 + X1);
    b := Data2;
    Inc(b, (Y2 + i) * Width2 + X2);
    For j := 0 To W - 1 do
    begin
      If a^ <> b^ Then Exit;
      Inc(a);
      Inc(b);
    end;
  end;            
  Result := True;
end;

const LatChars: set of Byte = [
  $41, $42, $43, $45, $48, $4B, $4D, $4F, $50, $54, $58,
  $61, $63, $65, $6F, $78
  ];

function TDR2Font.SaveForXBOX360(const Stream: TStream; Width, Height: Integer; Mirror, ForceAlt: Boolean): Boolean;
var 
    FontHeader: TFontHeader;
    TexHeader:  TTexHeader;
    KerningHeader: TKerningHeader;
    KerningData: TKerningData;   
    FileHeader: TFileHeader;
    SectionHeaders: Array[0..4] of TSectionHeader;
    SectionHeader: TSectionHeader;
    SectionHeaderAlt: TSectionHeaderAlt;
    CharData: TCharRecord;
    Image, EncodedImage: Pointer;
    Size, SectionsSize: LongWord;
    i, j: Integer;
    Alt: Boolean;
    C: Char;
    Chars: Array of TCharRecord;
    Atlas: TAtlasTree;
    X, Y, X1, Y1, X2, Y2: Integer;
    RW, RH: Real;
    Src, Dest: PByte;
    Node: TAtlasNode;
    Rects: Array of TRect;
const SecId: Array[0..4] of LongWord = ($C72B2EFF, $2A195DEC, $1DF37703, $538DB12D, $B252CF02);
begin
  //!!
  //Width := Self.TexHeader.Width;
  //Height := Self.TexHeader.Height;

  For i := 0 To Self.FontHeader.Count - 1 do
  begin
    If not ((Self.CharData[i].Code >= $81) and (Self.CharData[i].Code <= $BF)
        and not (Self.CharData[i].Code in [$A9, $AE]))
    and not (Self.CharData[i].Code in [$23, $24, $26, $3C, $3D, $3E, $5B, $5C, $5D, $5E, $7B, $7C, $7D, $60, $7E, $7F, $80, $22])
  Then
	begin
		SetLength(Chars, Length(Chars) + 1);
		Chars[High(Chars)] := Self.CharData[i];
	end;
  end;

  Result := False;
  C := #0;
  
  Alt := Integer(Self.FileHeader.Magic) = $03040506;
  If ForceAlt Then
    Alt := not Alt;

  If Alt Then
    SectionsSize := SizeOf(TSectionHeaderAlt) * 5
  else
    SectionsSize := SizeOf(TSectionHeader) * 5;

  Size :=   SectionsSize +
            Length(cTextureStr) + Length(cFontHeaderStr) +
            Length(cFontDataStr) + Length(cKerningHeaderStr) +
            Length(cKerningDataStr) + 5 + SizeOf(TFileHeader);
  Size := RoundBy(Size, 16);
  //Stream.Seek(Size, soBeginning);
  For i := 0 To Size - 1 do
    Stream.Write(C, 1);



  SectionHeaders[0].Offset := Stream.Position;

  TexHeader := Self.TexHeader;

  TexHeader.Width := Width;
  TexHeader.Height := Height;
  TexHeader.HeaderSize := SizeOf(TTexHeader);
  TexHeader.DataSize := RoundBy(RoundBy(TexHeader.Width, 32) * RoundBy(TexHeader.Height, 32), $1000);
  TexHeader.CommonSize := TexHeader.HeaderSize + TexHeader.DataSize;
  Size := TexHeader.DataSize;


  GetMem(Image, Width * Height);
  FillChar(Image^, Width * Height, 0);
  Atlas := TAtlasTree.Create(Width, Height);
  SetLength(Rects, Length(Chars));
  For i := 0 To High(Chars) do
  begin      
    If Mirror and (Chars[i].Code in LatChars) Then
      Continue;
    X1 := Round(Chars[i].Rect.Left * Self.TexHeader.Width);
    X2 := Round(Chars[i].Rect.Right * Self.TexHeader.Width);
    Y1 := Round(Chars[i].Rect.Top * Self.TexHeader.Height);
    Y2 := Round(Chars[i].Rect.Bottom * Self.TexHeader.Height);
    RW := (Chars[i].Rect.Right - Chars[i].Rect.Left) * Self.TexHeader.Width;
    RH := (Chars[i].Rect.Bottom - Chars[i].Rect.Top) * Self.TexHeader.Height;
    For j := 0 To i - 1 do
    begin
      If (Rects[j].Right - Rects[j].Left = X2 - X1) and (Rects[j].Bottom - Rects[j].Top = Y2 - Y1) Then
      begin
        If CompareRects(X1, Y1, Rects[j].Left, Rects[j].Top, X2 - X1, Y2 - Y1, Self.Image, Image, Self.TexHeader.Width, Self.TexHeader.Height, Width, Height) Then
        begin
          Chars[i].Rect := Chars[j].Rect;
          Rects[i] := Rects[j];
          continue;
        end;
      end;
    end;

    Node := Atlas.Insert(X2 - X1 + 1, Y2 - Y1 + 1);
    If Node = nil Then
    begin
      //WriteLn(i);
      FreeMem(Image);
      Atlas.Free;
      Exit;
    end;
    Rects[i] := Node.Rect;
    
    Chars[i].Rect.Left   := Node.Rect.Left / Width;
    Chars[i].Rect.Top    := Node.Rect.Top / Height;
    Chars[i].Rect.Right  := {(Node.Rect.Right + 1)} Chars[i].Rect.Left + RW / Width;
    Chars[i].Rect.Bottom := {(Node.Rect.Bottom + 1)}Chars[i].Rect.Top + RH / Width;

    For Y := 0 to Y2 - Y1 - 1 do
    begin
      Src := Self.Image;
      Inc(Src, (Y1 + Y) * Self.TexHeader.Width + X1);
      Dest := Image;
      Inc(Dest, (Node.Rect.Top + Y) * Width + Node.Rect.Left);
      For X := X1 to X2 - 1 do
      begin
        Dest^ := Src^;
        Inc(Dest);
        Inc(Src);
      end;
    end;

  end;
  Atlas.Free;


  //!!
  If Mirror Then
  begin
    For i := 0 To High(Chars) do
    begin
      If Chars[i].Code in LatChars Then
      begin
        Case Chars[i].Code of
          $41: X := $C0;
          $42: X := $C2;
          $43: X := $D1;
          $45: X := $C5;
          $48: X := $CD;
          $4B: X := $CA;
          $4D: X := $CC;
          $4F: X := $CE;
          $50: X := $D0;
          $54: X := $D2;
          $58: X := $D5;

          $61: X := $E0;
          $63: X := $F1;
          $65: X := $E5;
          $6F: X := $EE;
          $78: X := $F5;
          else X := 0;
        end;
        If X > 0 Then
        begin
          For j := 0 To High(Chars) do
          begin
            If Chars[j].Code = X Then
            begin
              Chars[i].Rect := Chars[j].Rect;
              break;
            end;
          end;
        end else
        begin
          Chars[i].Rect.Left := 0;
          Chars[i].Rect.Top := 0;
          Chars[i].Rect.Right := 1;
          Chars[i].Rect.Bottom := 1;
        end;
      end;
    end;
  end;
  //!!
  //SaveImage('Test.bmp', Image, Width, Height);
  //SaveImage('Test.bmp', Self.Image, Self.TexHeader.Width, Self.TexHeader.Height);


  GetMem(EncodedImage, TexHeader.DataSize);
  EncodeImage(Image, EncodedImage, TexHeader.Width, TexHeader.Height);
  //EncodeImage(Self.Image, EncodedImage, TexHeader.Width, TexHeader.Height);
  FreeMem(Image);
  SectionHeaders[0].Size := TexHeader.CommonSize;

  EndianTexHeader(TexHeader);
  TexHeader.Magic[0] := $05;
  TexHeader.Magic[1] := $01;
  TexHeader.Magic[2] := $01;
  TexHeader.Magic[3] := $06;
  If Alt Then
    TexHeader.Unk[1] := $23
  else
    TexHeader.Unk[1] := $22;
  Stream.Write(TexHeader, SizeOf(TTexHeader));
  Stream.Write(EncodedImage^, Size);
  FreeMem(EncodedImage);

  // _FONTHEADER_

  SectionHeaders[1].Offset := Stream.Position;
  SectionHeaders[1].Size := SizeOf(TFontHeader);
  FontHeader := Self.FontHeader;
  FontHeader.Count := Length(Chars);
  EndianFontHeader(FontHeader);
  Stream.Write(FontHeader, SizeOf(TFontHeader));

  // _FONTDATA_

  //WriteLn(Length(Chars));

  SectionHeaders[2].Offset := Stream.Position;
  SectionHeaders[2].Size := SizeOf(TCharRecord) * Self.FontHeader.Count;
  For i := 0 To High(Chars) do
  begin
    CharData := Chars[i];
    EndianChar(CharData);
    Stream.Write(CharData, SizeOf(TCharRecord));
  end;

  // _KERNINGHEADER_


  SectionHeaders[3].Offset := Stream.Position;
  SectionHeaders[3].Size := SizeOf(TKerningHeader);
  KerningHeader := Self.KerningHeader;
  EndianKerningHeader(KerningHeader);
  Stream.Write(KerningHeader, SizeOf(TKerningHeader));

  // _KERNINGDATA_
                      
  SectionHeaders[4].Offset := Stream.Position;
  SectionHeaders[4].Size := SizeOf(TKerningData) * Self.KerningHeader.Count;
  For i := 0 To Self.KerningHeader.Count - 1 do
  begin
    KerningData := Self.KerningData[i];
    EndianKerning(KerningData);
    Stream.Write(KerningData, SizeOf(TKerningData));
  end;

  
  FileHeader := Self.FileHeader;
  If Alt Then
    Integer(FileHeader.Magic) := $03040506
  else
    Integer(FileHeader.Magic) := $01020304;
  FileHeader.FileSize := Stream.Position;
  FileHeader.SectionCount := 5;                   
  FileHeader.NamesOffset := SizeOf(TFileHeader) + SectionsSize;

  Stream.Seek(FileHeader.NamesOffset, soBeginning);

  For i := 0 To 5 - 1 do
  begin
    SectionHeaders[i].NamePos := Stream.Position;
    SectionHeaders[i].NameEnd := SectionHeaders[i].NamePos + Length(SectionNames[i]) + 1;
    Stream.Write(SectionNames[i,1], Length(SectionNames[i]));
    Stream.Write(C, 1);
  end;

  FileHeader.HeaderSize := Stream.Position;

  Stream.Seek(0, soBeginning);

  Stream.Write(FileHeader, SizeOf(TFileHeader));
  For i := 0 To 5 - 1 do
  begin
    If Alt Then
    begin
      If not ForceAlt Then
        SectionHeaderAlt := Self.SectionsAlt[i];
      SectionHeaderAlt.Offset := SectionHeaders[i].Offset;
      SectionHeaderAlt.Size := SectionHeaders[i].Size;
      SectionHeaderAlt.Size2 := SectionHeaderAlt.Size;
      SectionHeaderAlt.NamePos := SectionHeaders[i].NamePos;
      SectionHeaderAlt.NameEnd := 0;//SectionHeaders[i].NameEnd;
      SectionHeaderAlt.Unk := SecId[i];
      If i = 0 Then
        SectionHeaderAlt.Unk1 := 16
      else
        SectionHeaderAlt.Unk1 := 4;
      Stream.Write(SectionHeaderAlt, SizeOf(TSectionHeaderAlt));
    end else
    begin
      SectionHeader := Self.Sections[i];
      SectionHeader.Offset := SectionHeaders[i].Offset;
      SectionHeader.Size := SectionHeaders[i].Size;
      SectionHeader.NamePos := SectionHeaders[i].NamePos;
      SectionHeader.NameEnd := 0;//SectionHeaders[i].NameEnd;  
      If i = 0 Then
        SectionHeader.Unk1  := 16
      else
        SectionHeader.Unk1 := 4;
      Stream.Write(SectionHeader, SizeOf(TSectionHeader));
    end;
  end;

  Result := True;
end;

function TDR2Font.SaveForXBOX360(const FileName: String; Width, Height: Integer; Mirror, ForceAlt: Boolean): Boolean;
var Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  Result := SaveForXBOX360(Stream, Width, Height, Mirror, ForceAlt);
  If not Result Then Exit;
  try
    Stream.SaveToFile(FileName);
  except
    Result := False;
  end;
  Stream.Free;
end;

end.
