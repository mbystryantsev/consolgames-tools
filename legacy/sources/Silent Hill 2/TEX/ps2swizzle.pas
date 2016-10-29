unit ps2swizzle;

interface

Procedure Unswizzle8(Var Source, Dest; Const Width, Height: Integer);
Procedure Unswizzle4X(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Procedure Unswizzle4(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Procedure Swizzle8(Var Source, Dest; Const Width, Height: Integer);
Procedure Swizzle4X(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Procedure Swizzle4(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Procedure RotatePalette16(Var Palette);
Procedure RotatePalette24(Var Palette);
Procedure RotatePalette(Var Palette);

implementation

Type
 TBytes = Array[Byte] of Byte;

Const
 InterlaceMatrix: Array[0..7] of Byte =
 ($00, $10, $02, $12, $11, $01, $13, $03);
 Matrix: Array[0..3] of Integer = (0, 1, -1, 0);
 TileMatrix: Array[0..1] of Integer = (4, -4);

Procedure Unswizzle8(Var Source, Dest; Const Width, Height: Integer);
Var
 X, Y, XX, YY, I, J, MW: Integer;
 Pixels: TBytes absolute Source;
 NewPixels: TBytes absolute Dest;
begin
 If (Width mod 32 > 0) or (Height mod 16 > 0) then
  Move(Source, Dest, Width * Height) Else
 begin
  MW := Width;
  If MW mod 32 > 0 then MW := (MW div 32) * 32 + 32;
  For Y := 0 to Height - 1 do
  begin
   If Odd(Y) then For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4 + 4] +
    (X * 4) mod 16 + (X div 16) * 32 + ((Y - 1) * MW);
    J := YY * Width + XX;
    NewPixels[J] := Pixels[I];
   end Else
   For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4] +
    (X * 4) mod 16 + (X div 16) * 32 + (Y * MW);
    J := YY * Width + XX;
    NewPixels[J] := Pixels[I];
   end;
  end;
 end;
end;

Procedure Swizzle8(Var Source, Dest; Const Width, Height: Integer);
Var
 X, Y, XX, YY, I, J, MW: Integer;
 Pixels: TBytes absolute Source;
 NewPixels: TBytes absolute Dest;
begin
 If (Width mod 16 > 0) or (Height mod 16 > 0) then
  Move(Source, Dest, Width * Height) Else
 begin
  MW := Width;
  If MW mod 32 > 0 then MW := (MW div 32) * 32 + 32;
  For Y := 0 to Height - 1 do
  begin
   If Odd(Y) then For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4 + 4] +
    (X * 4) mod 16 + (X div 16) * 32 + ((Y - 1) * MW);
    J := YY * Width + XX;
    NewPixels[I] := Pixels[J];
   end Else
   For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4] +
    (X * 4) mod 16 + (X div 16) * 32 + (Y * MW);
    J := YY * Width + XX;
    NewPixels[I] := Pixels[J];
   end;
  end;
 end;
end;

{$O-}
Procedure Unswizzle4X(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Var
 X, Y, XX, YY, I, J, MW: Integer; S, D: ^Byte;
 Pixels, NewPixels: Array of Byte;
begin
 If (Width mod 32 > 0) or (Height mod 16 > 0) then
  Move(Source, Dest, (Width shr 1) * Height) Else
 begin
  SetLength(Pixels, Width * Height);
  SetLength(NewPixels, Width * Height);
  S := Addr(Source);
  D := Addr(Pixels[0]);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(D);
   D^ := S^ shr 4;
   Inc(D);
   Inc(S);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shr 4;
   Inc(D);
   D^ := S^ and 15;
   Inc(D);
   Inc(S);
  end;
  MW := Width;
  If MW mod 32 > 0 then MW := (MW div 32) * 32 + 32;
  For Y := 0 to Height - 1 do
  begin
   If Odd(Y) then For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4 + 4] +
    (X * 4) mod 16 + (X div 16) * 32 + ((Y - 1) * MW);
    J := YY * Width + XX;
    NewPixels[J] := Pixels[I];
   end Else
   For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4] +
    (X * 4) mod 16 + (X div 16) * 32 + (Y * MW);
    J := YY * Width + XX;
    NewPixels[J] := Pixels[I];
   end;
  end;
  S := Addr(NewPixels[0]);
  D := Addr(Dest);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(S);
   D^ := D^ or (S^ shl 4);
   Inc(S);
   Inc(D);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shl 4;
   Inc(S);
   D^ := D^ or (S^ and 15);
   Inc(S);
   Inc(D);
  end;
  Finalize(NewPixels);
  Finalize(Pixels);
 end;
end;
{$O+}

{$O-}
Procedure Swizzle4X(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Var
 X, Y, XX, YY, I, J, MW: Integer; S, D: ^Byte;
 Pixels, NewPixels: Array of Byte;
begin
 If (Width mod 16 > 0) or (Height mod 16 > 0) then
  Move(Source, Dest, (Width shr 1) * Height) Else
 begin
  SetLength(Pixels, Width * Height);
  SetLength(NewPixels, Width * Height);
  S := Addr(Source);
  D := Addr(Pixels[0]);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(D);
   D^ := S^ shr 4;
   Inc(D);
   Inc(S);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shr 4;
   Inc(D);
   D^ := S^ and 15;
   Inc(D);
   Inc(S);
  end;
  MW := Width;
  If MW mod 32 > 0 then MW := (MW div 32) * 32 + 32;
  For Y := 0 to Height - 1 do
  begin
   If Odd(Y) then For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4 + 4] +
    (X * 4) mod 16 + (X div 16) * 32 + ((Y - 1) * MW);
    J := YY * Width + XX;
    NewPixels[I] := Pixels[J];
   end Else
   For X := 0 to Width - 1 do
   begin
    XX := X + Byte(Odd(Y div 4)) * TileMatrix[Byte(Odd(X div 4))];
    YY := Y + Matrix[Y mod 4];
    I := InterlaceMatrix[(X div 4) mod 4] +
    (X * 4) mod 16 + (X div 16) * 32 + (Y * MW);
    J := YY * Width + XX;
    NewPixels[I] := Pixels[J];
   end;
  end;
  S := Addr(NewPixels[0]);
  D := Addr(Dest);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(S);
   D^ := D^ or (S^ shl 4);
   Inc(S);
   Inc(D);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shl 4;
   Inc(S);
   D^ := D^ or (S^ and 15);
   Inc(S);
   Inc(D);
  end;
  Finalize(NewPixels);
  Finalize(Pixels);
 end;
end;
{$O+}

Const columntable4: Array[0..15, 0..31] of Integer = (
//0
($00000000, $00000008, $00000010, $00000018, $00000020, $00000028, $00000030, $00000038,
 $00000002, $0000000A, $00000012, $0000001A, $00000022, $0000002A, $00000032, $0000003A,
 $00000004, $0000000C, $00000014, $0000001C, $00000024, $0000002C, $00000034, $0000003C,
 $00000006, $0000000E, $00000016, $0000001E, $00000026, $0000002E, $00000036, $0000003E),
//1
($00000080, $00000088, $00000090, $00000098, $000000A0, $000000A8, $000000B0, $000000B8,
 $00000082, $0000008A, $00000092, $0000009A, $000000A2, $000000AA, $000000B2, $000000BA,
 $00000084, $0000008C, $00000094, $0000009C, $000000A4, $000000AC, $000000B4, $000000BC,
 $00000086, $0000008E, $00000096, $0000009E, $000000A6, $000000AE, $000000B6, $000000BE),
//2
($00000021, $00000029, $00000031, $00000039, $00000001, $00000009, $00000011, $00000019,
 $00000023, $0000002B, $00000033, $0000003B, $00000003, $0000000B, $00000013, $0000001B,
 $00000025, $0000002D, $00000035, $0000003D, $00000005, $0000000D, $00000015, $0000001D,
 $00000027, $0000002F, $00000037, $0000003F, $00000007, $0000000F, $00000017, $0000001F),
//3
($000000A1, $000000A9, $000000B1, $000000B9, $00000081, $00000089, $00000091, $00000099,
 $000000A3, $000000AB, $000000B3, $000000BB, $00000083, $0000008B, $00000093, $0000009B,
 $000000A5, $000000AD, $000000B5, $000000BD, $00000085, $0000008D, $00000095, $0000009D,
 $000000A7, $000000AF, $000000B7, $000000BF, $00000087, $0000008F, $00000097, $0000009F),
//4
($00000120, $00000128, $00000130, $00000138, $00000100, $00000108, $00000110, $00000118,
 $00000122, $0000012A, $00000132, $0000013A, $00000102, $0000010A, $00000112, $0000011A,
 $00000124, $0000012C, $00000134, $0000013C, $00000104, $0000010C, $00000114, $0000011C,
 $00000126, $0000012E, $00000136, $0000013E, $00000106, $0000010E, $00000116, $0000011E),
//5
($000001A0, $000001A8, $000001B0, $000001B8, $00000180, $00000188, $00000190, $00000198,
 $000001A2, $000001AA, $000001B2, $000001BA, $00000182, $0000018A, $00000192, $0000019A,
 $000001A4, $000001AC, $000001B4, $000001BC, $00000184, $0000018C, $00000194, $0000019C,
 $000001A6, $000001AE, $000001B6, $000001BE, $00000186, $0000018E, $00000196, $0000019E),
//6
($00000101, $00000109, $00000111, $00000119, $00000121, $00000129, $00000131, $00000139,
 $00000103, $0000010B, $00000113, $0000011B, $00000123, $0000012B, $00000133, $0000013B,
 $00000105, $0000010D, $00000115, $0000011D, $00000125, $0000012D, $00000135, $0000013D,
 $00000107, $0000010F, $00000117, $0000011F, $00000127, $0000012F, $00000137, $0000013F),
//7
($00000181, $00000189, $00000191, $00000199, $000001A1, $000001A9, $000001B1, $000001B9,
 $00000183, $0000018B, $00000193, $0000019B, $000001A3, $000001AB, $000001B3, $000001BB,
 $00000185, $0000018D, $00000195, $0000019D, $000001A5, $000001AD, $000001B5, $000001BD,
 $00000187, $0000018F, $00000197, $0000019F, $000001A7, $000001AF, $000001B7, $000001BF),
//8
($00000040, $00000048, $00000050, $00000058, $00000060, $00000068, $00000070, $00000078,
 $00000042, $0000004A, $00000052, $0000005A, $00000062, $0000006A, $00000072, $0000007A,
 $00000044, $0000004C, $00000054, $0000005C, $00000064, $0000006C, $00000074, $0000007C,
 $00000046, $0000004E, $00000056, $0000005E, $00000066, $0000006E, $00000076, $0000007E),
//9
($000000C0, $000000C8, $000000D0, $000000D8, $000000E0, $000000E8, $000000F0, $000000F8,
 $000000C2, $000000CA, $000000D2, $000000DA, $000000E2, $000000EA, $000000F2, $000000FA,
 $000000C4, $000000CC, $000000D4, $000000DC, $000000E4, $000000EC, $000000F4, $000000FC,
 $000000C6, $000000CE, $000000D6, $000000DE, $000000E6, $000000EE, $000000F6, $000000FE),
//10
($00000061, $00000069, $00000071, $00000079, $00000041, $00000049, $00000051, $00000059,
 $00000063, $0000006B, $00000073, $0000007B, $00000043, $0000004B, $00000053, $0000005B,
 $00000065, $0000006D, $00000075, $0000007D, $00000045, $0000004D, $00000055, $0000005D,
 $00000067, $0000006F, $00000077, $0000007F, $00000047, $0000004F, $00000057, $0000005F),
//11
($000000E1, $000000E9, $000000F1, $000000F9, $000000C1, $000000C9, $000000D1, $000000D9,
 $000000E3, $000000EB, $000000F3, $000000FB, $000000C3, $000000CB, $000000D3, $000000DB,
 $000000E5, $000000ED, $000000F5, $000000FD, $000000C5, $000000CD, $000000D5, $000000DD,
 $000000E7, $000000EF, $000000F7, $000000FF, $000000C7, $000000CF, $000000D7, $000000DF),
//12
($00000160, $00000168, $00000170, $00000178, $00000140, $00000148, $00000150, $00000158,
 $00000162, $0000016A, $00000172, $0000017A, $00000142, $0000014A, $00000152, $0000015A,
 $00000164, $0000016C, $00000174, $0000017C, $00000144, $0000014C, $00000154, $0000015C,
 $00000166, $0000016E, $00000176, $0000017E, $00000146, $0000014E, $00000156, $0000015E),
//13
($000001E0, $000001E8, $000001F0, $000001F8, $000001C0, $000001C8, $000001D0, $000001D8,
 $000001E2, $000001EA, $000001F2, $000001FA, $000001C2, $000001CA, $000001D2, $000001DA,
 $000001E4, $000001EC, $000001F4, $000001FC, $000001C4, $000001CC, $000001D4, $000001DC,
 $000001E6, $000001EE, $000001F6, $000001FE, $000001C6, $000001CE, $000001D6, $000001DE),
//14
($00000141, $00000149, $00000151, $00000159, $00000161, $00000169, $00000171, $00000179,
 $00000143, $0000014B, $00000153, $0000015B, $00000163, $0000016B, $00000173, $0000017B,
 $00000145, $0000014D, $00000155, $0000015D, $00000165, $0000016D, $00000175, $0000017D,
 $00000147, $0000014F, $00000157, $0000015F, $00000167, $0000016F, $00000177, $0000017F),
//15
($000001C1, $000001C9, $000001D1, $000001D9, $000001E1, $000001E9, $000001F1, $000001F9,
 $000001C3, $000001CB, $000001D3, $000001DB, $000001E3, $000001EB, $000001F3, $000001FB,
 $000001C5, $000001CD, $000001D5, $000001DD, $000001E5, $000001ED, $000001F5, $000001FD,
 $000001C7, $000001CF, $000001D7, $000001DF, $000001E7, $000001EF, $000001F7, $000001FF)
);

Const
 IncArray: Array[0..15] of Integer = (0, 1, 0, 1, 2, 3, 2, 3, 0, 1, 0, 1, 2, 3, 2, 3);

Procedure Unswizzle4(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Var
 BW, BH, X, Y, XX, YY, MW, MX, MY: Integer;
 S, D: ^Byte; Pixels, NewPixels: Array of Byte;
begin
 If (Width mod 32 > 0) or (Height mod 32 > 0) then
  Move(Source, Dest, (Width shr 1)  * Height) Else
 begin
  SetLength(Pixels, Width * Height);
  SetLength(NewPixels, Width * Height);
  S := Addr(Source);
  D := Addr(Pixels[0]);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(D);
   D^ := S^ shr 4;
   Inc(D);
   Inc(S);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shr 4;
   Inc(D);
   D^ := S^ and 15;
   Inc(D);
   Inc(S);
  end;
  BW := Width div 32 - 1;
  BH := Height div 32 - 1;
  MW := 0;// ZX := 0; ZY := 0;
 // MZY := 0;
  For XX := 0 to BW do
  begin
   For YY := 0 to BH do
   begin
//    MX := (ZX + XX mod 4) * 32;
//    MY := (ZY + MZY) * 32;
    MX := XX * 32;
    MY := YY * 32;
    For Y := 0 to 7 do
     For X := 0 to 31 do
      NewPixels[(Y + MY) * Width + X + MX] := Pixels[columntable4[Y, X] + MW + YY * 128 + IncArray[Y] * (BH * 128)];
    For Y := 8 to 15 do
     For X := 0 to 31 do
      NewPixels[(Y + MY + 8) * Width + X + MX] := Pixels[columntable4[Y, X] + MW + YY * 128 + IncArray[Y] * (BH * 128)];
    For Y := 0 to 7 do
     For X := 0 to 31 do
      NewPixels[(Y + MY + 8) * Width + X + MX] := Pixels[columntable4[Y, X] + 512 + MW + YY * 128 + (IncArray[Y] + 4) * (BH * 128)];
    For Y := 8 to 15 do
     For X := 0 to 31 do
      NewPixels[(Y + MY + 16) * Width + X + MX] := Pixels[columntable4[Y, X] + 512 + MW + YY * 128 + (IncArray[Y] + 4) * (BH * 128)];
{    If ZY = BH then
    begin
     ZY := 0;
     If (XX + 1) mod 4 = 0 then Inc(ZX, 4);
    end Else
    begin
     Inc(ZY);
     If ZY mod 4 = 0 then
     begin
      ZY := 0;
      Inc(ZX, 4);
      If ZX > BW then
      begin
       ZX := 0;
       If (XX + 1) mod 4 = 0 then
       begin
        Inc(MZY, 4);
        If MZY > BH then
         MZY := 0;
       end;
      end;
     end;
    end;}
   end;
   Inc(MW, 32 * Height);
  end;
  S := Addr(NewPixels[0]);
  D := Addr(Dest);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(S);
   D^ := D^ or (S^ shl 4);
   Inc(S);
   Inc(D);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shl 4;
   Inc(S);
   D^ := D^ or (S^ and 15);
   Inc(S);
   Inc(D);
  end;
  Finalize(NewPixels);
  Finalize(Pixels);
 end;
end;

Procedure Swizzle4(Var Source, Dest; Const Width, Height: Integer; Inverted: Boolean = False);
Var
 BW, BH, X, Y, XX, YY, MW,{ ZX, ZY,} MX, MY{, MZY}: Integer;
 S, D: ^Byte; Pixels, NewPixels: Array of Byte;
begin
 If (Width mod 32 > 0) or (Height mod 32 > 0) then
  Move(Source, Dest, (Width shr 1)  * Height) Else
 begin
  SetLength(Pixels, Width * Height);
  SetLength(NewPixels, Width * Height);
  S := Addr(Source);
  D := Addr(Pixels[0]);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(D);
   D^ := S^ shr 4;
   Inc(D);
   Inc(S);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shr 4;
   Inc(D);
   D^ := S^ and 15;
   Inc(D);
   Inc(S);
  end;
  BW := Width div 32 - 1;
  BH := Height div 32 - 1;
  MW := 0; //ZX := 0; ZY := 0;
//  MZY := 0;
  For XX := 0 to BW do
  begin
   For YY := 0 to BH do
   begin
//    MX := (ZX + XX mod 4) * 32;
//    MY := (ZY + MZY) * 32;
    MX := XX * 32;
    MY := YY * 32;
    For Y := 0 to 7 do For X := 0 to 31 do
     NewPixels[columntable4[Y, X] + MW + YY * 128 + IncArray[Y] * (BW * 128)]
     := Pixels[(Y + MY) * Width + X + MX];
    For Y := 8 to 15 do For X := 0 to 31 do
     NewPixels[columntable4[Y, X] + MW + YY * 128 + IncArray[Y] * (BW * 128)]
     := Pixels[(Y + MY + 8) * Width + X + MX];
    For Y := 0 to 7 do For X := 0 to 31 do
     NewPixels[columntable4[Y, X] + 512 + MW + YY * 128 +
     (IncArray[Y] + 4) * (BW * 128)] := Pixels[(Y + MY + 8) * Width + X + MX];
    For Y := 8 to 15 do For X := 0 to 31 do
     NewPixels[columntable4[Y, X] + 512 + MW + YY * 128 +
     (IncArray[Y] + 4) * (BW * 128)] := Pixels[(Y + MY + 16) * Width + X + MX];
{    If ZY = BH then
    begin
     ZY := 0;
     If (XX + 1) mod 4 = 0 then Inc(ZX, 4);
    end Else
    begin
     Inc(ZY);
     If ZY mod 4 = 0 then
     begin
      ZY := 0;
      Inc(ZX, 4);
      If ZX > BW then
      begin
       ZX := 0;
       If (XX + 1) mod 4 = 0 then
       begin
        Inc(MZY, 4);
        If MZY > BH then
         MZY := 0;
       end;
      end;
     end;
    end;}
   end;
   Inc(MW, 32 * Height);
  end;
  S := Addr(NewPixels[0]);
  D := Addr(Dest);
  If not Inverted then
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ and 15;
   Inc(S);
   D^ := D^ or (S^ shl 4);
   Inc(S);
   Inc(D);
  end Else
  For Y := 0 to Height - 1 do For X := 0 to Width shr 1 - 1 do
  begin
   D^ := S^ shl 4;
   Inc(S);
   D^ := D^ or (S^ and 15);
   Inc(S);
   Inc(D);
  end;
  Finalize(NewPixels);
  Finalize(Pixels);
 end;
end;

Procedure RotatePalette16(Var Palette);
Type
 TPalBlock = Array[0..7] of Word;
 TPalette32 = Array[0..31] of TPalBlock;
Var PalBlock: TPalBlock; Pal: ^TPalette32; X: Integer;
begin
 Pal := Addr(Palette);
 X := 1;
 Repeat
  Move(Pal^[X], PalBlock, SizeOf(TPalBlock));
  Move(Pal^[X + 1], Pal^[X], SizeOf(TPalBlock));
  Move(PalBlock, Pal^[X + 1], SizeOf(TPalBlock));
  Inc(X, 4);
 Until X > 29;
end;

Procedure RotatePalette24(Var Palette);
Type
 TPalBlock = Array[0..7] of Packed Record R, G, B: Byte end;
 TPalette32 = Array[0..31] of TPalBlock;
Var PalBlock: TPalBlock; Pal: ^TPalette32; X: Integer;
begin
 Pal := Addr(Palette);
 X := 1;
 Repeat
  Move(Pal^[X], PalBlock, SizeOf(TPalBlock));
  Move(Pal^[X + 1], Pal^[X], SizeOf(TPalBlock));
  Move(PalBlock, Pal^[X + 1], SizeOf(TPalBlock));
  Inc(X, 4);
 Until X > 29;
end;

Procedure RotatePalette(Var Palette);
Type
 TPalBlock = Array[0..7] of Cardinal;
 TPalette32 = Array[0..31] of TPalBlock;
Var PalBlock: TPalBlock; Pal: ^TPalette32; X: Integer;
begin
 Pal := Addr(Palette);
 X := 1;
 Repeat
  Move(Pal^[X], PalBlock, SizeOf(TPalBlock));
  Move(Pal^[X + 1], Pal^[X], SizeOf(TPalBlock));
  Move(PalBlock, Pal^[X + 1], SizeOf(TPalBlock));
  Inc(X, 4);
 Until X > 29;
end;

end.
