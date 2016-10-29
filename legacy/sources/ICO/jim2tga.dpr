program jim2tga;

{$APPTYPE CONSOLE}

uses
  SysUtils, TARGA;

Const
 TIM2Sign = $324D4954;

Type
 TTIM2Header = Packed Record
  thSignTag: Integer;
  thFormatTag: Byte;
  thAlign128: Boolean;
  thLayersCount: Word;
  thReserved1: Integer;
  thReserved2: Integer;
 end;
 TLayerHeader = Packed Record
  lhLayerSize: Integer;
  lhPaletteSize: Integer;
  lhImageSize: Integer;
  lhHeaderSize: Word;
  lhColorsUsed: Word;
  lh256: Word;
  lhControlByte: Byte;
  lhFormat: Byte;
  lhWidth: Word;
  lhHeight: Word;
  lhTEX0: Array[0..7] of Byte;
  lhTEX1: Array[0..7] of Byte;
  lhTEXA: Array[0..3] of Byte;
  lhTEXCLUT: Array[0..3] of Byte;
 end;
 TRGBA = Packed Record
  R: Byte;
  G: Byte;
  B: Byte;
  A: Byte;
 end;
 TPalBlock = Array[0..7] of Cardinal;
 TPalette32 = Array[0..31] of TPalBlock;

Function Max(A, B: Integer): Integer;
begin
 If B > A then
  Result := B Else
  Result := A;
end;

Var Pixels, P8: Pointer; Header: TTIM2Header; F: File; C: Byte;
    Layer: TLayerHeader; W, H, Z: Integer; R: Integer; FExt, Path: String;
    ColorTable: Array[Byte] of TRGBA; RGB: ^TRGBA; BB: ^Byte;
    SR: TSearchRec; PalBlock: TPalBlock; Pal: ^TPalette32;
    BigBuffer: Array of Integer;
    CurX, CurY, CurI, MaxW, MaxH, MW, OldH, ImInRow: Integer;

Label Finish;
begin
 Path := ExtractFilePath(ParamStr(1));
 ImInRow := StrToInt(ParamStr(2));
 MaxW := StrToInt(ParamStr(3));
 If ParamCount >= 4 then
  FExt := ParamStr(4) Else
  FExt := '.tga';
 If (Path <> '') and (Path[Length(Path)] <> '\') then Path := Path + '\';
 If FindFirst(ParamStr(1), $20, SR) = 0 then
 begin
  Repeat
   Write('Converting: "' + SR.Name + '"... ');
   AssignFile(F, Path + SR.Name);
   Reset(F, 1);
   CurX := 0;
   CurY := 0;
   CurI := 0;
   OldH := 0;
   While True do
   begin
    If FilePos(F) mod 2048 > 0 then
     Seek(F, (FilePos(F) div 2048) * 2048 + 2048);
    BlockRead(F, Header, SizeOf(Header), R);
    If (R = SizeOf(Header)) and (Header.thSignTag = TIM2Sign) and
       (Header.thFormatTag in [3, 4]) and
       (Header.thLayersCount >= 1) then
    begin
     BlockRead(F, Layer, SizeOf(Layer), R);
     If (R = SizeOf(Layer)) and (Layer.lhControlByte in [3, $83]) and
        (Layer.lhFormat = 5) and(Layer.lhPaletteSize = 1024) then
     begin
      W := Layer.lhWidth;
      H := Layer.lhHeight;
      GetMem(P8, W * H);
      BlockRead(F, P8^, W * H, R);
      BlockRead(F, ColorTable, 1024, R);
      RGB := Addr(ColorTable);
      For R := 0 to 255 do
      begin
       With RGB^ do
       begin
        If A >= $7F then A := $FF Else A := A shl 1;
        C := R;
        R := B;
        B := C;
       end;
       Inc(RGB);
      end;
      If Layer.lhControlByte = 3 then
      begin
       Pal := Addr(ColorTable[0]);
       R := 1;
       Repeat
        Move(Pal^[R], PalBlock, SizeOf(TPalBlock));
        Move(Pal^[R + 1], Pal^[R], SizeOf(TPalBlock));
        Move(PalBlock, Pal^[R + 1], SizeOf(TPalBlock));
        Inc(R, 4);
       Until R > 29;
      end;
      GetMem(Pixels, W * 4 * H);
      BB := P8;
      RGB := Pixels;
      For R := 0 to W * H - 1 do
      begin
       RGB^ := ColorTable[BB^];
       Inc(BB);
       Inc(RGB);
      end;
      Goto Finish;
     end Else
     If (Layer.lhControlByte in [$03, $83]) and (Layer.lhFormat = 4) and
        (Layer.lhPaletteSize = 64) then
     begin
      W := Layer.lhWidth;
      H := Layer.lhHeight;
      GetMem(P8, (W shr 1) * H);
      BlockRead(F, P8^, (W shr 1) * H, R);
      BlockRead(F, ColorTable, 64, R);
      RGB := Addr(ColorTable);
      For R := 0 to 255 do
      begin
       With RGB^ do
       begin
        If A >= $7F then A := $FF Else A := A shl 1;
        C := R;
        R := B;
        B := C;
       end;
       Inc(RGB);
      end;
      GetMem(Pixels, W * 4 * H);
      BB := P8;
      RGB := Pixels;
      For R := 0 to ((W * H) shr 1) - 1 do
      begin
       RGB^ := ColorTable[BB^ and 15];
       Inc(RGB);
       RGB^ := ColorTable[BB^ shr 4];
       Inc(RGB);
       Inc(BB);
      end;
     Finish:
      MaxH := Max(OldH, Layer.lhTEX0[2]);
      OldH := Layer.lhTEX0[2];
      Inc(CurI);
      SetLength(BigBuffer, MaxW * (CurY + MaxH));
      BB := Pixels;
      If W * (H div OldH) > MaxW - CurX then
       MW := (MaxW - CurX) Else
       MW := (W * (H div OldH));
      For Z := 0 to (H div OldH) - 1 do
      begin
       RGB := Addr(BigBuffer[MaxW * CurY + CurX + Z * W]);      
       For R := 0 to OldH - 1 do
       begin
        Move(BB^, RGB^, W shl 2);
        Inc(BB, W shl 2);
        Inc(RGB, MaxW);
       end;
      end;
      If CurI = ImInRow then
      begin
       CurI := 0;
       CurX := 0;
       Inc(CurY, MaxH);
      end Else Inc(CurX, MW);
      FreeMem(Pixels);
      FreeMem(P8);
     end Else Break;
    end Else Break;
   end;
   SaveTGA(ChangeFileExt(Path + SR.Name, FExt), MaxW, CurY,
           Addr(BigBuffer[0]), True);
   Writeln('Done.');           
   CloseFile(F);
  Until FindNext(SR) <> 0;
  FindClose(SR);
 end;
end.
