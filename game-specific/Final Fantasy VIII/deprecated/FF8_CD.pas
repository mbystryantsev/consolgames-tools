unit FF8_CD;

interface

uses edc, ecc, Windows, SysUtils;

{
CD:
  8050 - sector count, little endian
  8054 - sector count, big endian
  832D, 833E - date of creation / changing YYYYMMDDhhMMssgg$
  80AE, B012, B042, B072, B0B0, B0EC:
  1      number of years since 1900
  1      month, where 1=January, 2=February, etc.
  1      day of month, in the range from 1 to 31
  1      hour, in the range from 0 to 23
  1      minute, in the range from 0 to 59
  1      second, in the range from 0 to 59
                 (for DOS this is always an even number)
  1      offset from Greenwich Mean Time, in 15-minute intervals,
                 as a twos complement signed number, positive for time
                 zones east of Greenwich, and negative for time zones
                 west of Greenwich (DOS ignores this field)
  B06A - Size / Size big endian
  B088 - DISC Number, ASCII
}

const
  cLicenseText: String = '          Licensed  by          ' +
                         'Sony Computer Entertainment Amer' +
                         '  ica ';
  cSystemCNF: String   = 'BOOT = cdrom:\SLUS_008.92;1'#13#10 +
                 'TCB = 4'#13#10 +
                 'EVENT = 16'#13#10 +
                 'STACK = 80200000'#13#10;
  cSlusNames: Array[1..4, 0..10] of Char = (
    'SLUS_008.92', 'SLUS_009.08', 'SLUS_009.09', 'SLUS_009.10'
  );

  cSectorHeader: array[0..11] of byte = (
	  $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00
  );


Type
  TMode2Sector = Array[0..2352-1] of Byte;
  TISODate = Packed Record
    Y, M, D, H, Min, Sec, G: Byte;
  end;

  TPrimarySectors = Array[0..826-1] of TMode2Sector;



Procedure ReadSectorsData(const F: File; Sector: Integer; Data: Pointer; Size: Integer; Offset: Integer = 0);
procedure WritePrimarySectors(const F: File; CD, IMGSize: Integer; SLUSName: String);
Function ReadToSectors(var F: File; Data: Pointer; Size: Integer): Integer; overload;
procedure ConvertSector(Data: Pointer; LBA: Integer; ModeData: Integer = $80000);
Function ReadToSectors(Memory, Data: Pointer; Size: Integer): Integer; overload;
implementation

{$INCLUDE FF8_Img_sectors.pas}


Function bin2bcd(P: Integer): Byte;
begin
  Result := ((p div 10) SHL 4) or (p mod 10);
end;

Procedure BuildAdress(LBA: Integer; var Dest);
var P: PByte; Sec: Integer;
begin
  Inc(LBA, 75 * 2); // 2 seconds
  P := @Dest;
  P^ := bin2bcd(LBA div (60*75));     Inc(P);
	P^ := bin2bcd((LBA div 75) mod 60); Inc(P);
	P^ := bin2bcd(LBA mod 75);          Inc(P);
  P^ := 2;  
end;


Procedure ReadSectorsData(const F: File; Sector: Integer; Data: Pointer; Size: Integer; Offset: Integer = 0);
begin
  If Offset > Size Then Exit;
  Inc(Sector, Offset - (Offset mod 2048));
  Dec(Size,   Offset - (Offset mod 2048));
  Offset := Offset mod 2048;
  While Size > 0 do
  begin
    Seek(F, Sector * $930 + $18 + Offset);
    If Size >= 2048 - Offset Then
      BlockRead(F, Data^, 2048 - Offset)
    else
      BlockRead(F, Data^, Size - Offset);
    Dec(Size, 2048 - Offset);
    Inc(LongWord(Data), 2048 - Offset); 
    Offset := 0;
    Inc(Sector);
  end;
end;

Function ReadToSectors(var F: File; Data: Pointer; Size: Integer): Integer;
var Sector: PByte;
begin
  Sector := Data;
  Inc(Sector, $18);
  Result := (Size div 2048) + Integer(Size mod 2048 <> 0);
  While Size > 0 do
  begin
    If Size >= 2048 Then
      BlockRead(F, Sector^, 2048)
    else
    begin
      FillChar(Sector^, 2048, 0);
      BlockRead(F, Sector^, Size);
    end;
    Inc(Sector, 2352);
    Dec(Size, 2048);
  end;
end;

Function ReadToSectors(FileName: String; Data: Pointer; Size: Integer = 0): Integer; overload;
var F: File;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  If (Size = 0) or (Size > FileSize(F)) Then
    Size := FileSize(F);
  Result := Size;
  ReadToSectors(F, Data, Size);
  CloseFile(F);
end;


Function ReadToSectors(Memory, Data: Pointer; Size: Integer): Integer;
var Sector: PByte;
begin
  Sector := Data;
  Inc(Sector, $18);
  Result := (Size div 2048) + Integer(Size mod 2048 <> 0);
  While Size > 0 do
  begin
    If Size >= 2048 Then
      Move(Memory^, Sector^, 2048)
    else
    begin
      FillChar(Sector^, 2048, 0);
      Move(Memory^, Sector^, Size);
    end;
    Inc(Sector, 2352);
    Inc(LongWord(Memory), 2048);
    Dec(Size, 2048);
  end;
end;

procedure ConvertSector(Data: Pointer; LBA: Integer; ModeData: Integer = $80000);
var Sector: ^TMode2Sector; edc: Integer;
//const tag8: Integer = $80000;
begin
  Sector := Data;
  Move(cSectorHeader, Sector^[0], 12);
  FillChar(Sector^[12], 4, 0);
  Move(ModeData, Sector^[16], 4);
  Move(ModeData, Sector^[20], 4);
  edc := build_edc(@Sector^[16], 2048 + 8);
  Move(edc, Sector^[2072], 4);
  encode_L2_P(@Sector^[12]);
  encode_L2_Q(@Sector^[12]);
  BuildAdress(LBA, Sector^[12]);
end;

Function BuildDate(const Time: _SYSTEMTIME): TISODate;
begin
  Result.Y := Time.wYear - 1900;
  Result.M := Time.wMonth;
  Result.D := Time.wDay;
  Result.H := Time.wHour;
  Result.Min := Time.wMinute;
  Result.Sec := Time.wSecond;
  Result.G := 0;
end;

Function BuildStringDate(const Time: _SYSTEMTIME): String;
begin
  With Time do
    Result := Format('%4.4d%2.2d%2.2d%2.2d%2.2d%2.2d00$',
        [wYear, wMonth, wDay, wHour, wMinute, wSecond]);
end;

procedure WritePrimarySectors(const F: File; CD, IMGSize: Integer; SLUSName: String);
var
  Sectors: ^TPrimarySectors; SystemTime: _SYSTEMTIME; Time: TISODate; STime: String;
  n, SecCount, SecCountBE, IMGSizeBE: Integer; ModeCode: Integer;
begin
  GetMem(Sectors, SizeOf(TPrimarySectors));

  GetSystemTime(SystemTime);
  Time := BuildDate(SystemTime);
  STime := BuildStringDate(SystemTime);
  FillChar(Sectors^, SizeOf(Sectors^), 0);


  Move(cLicenseText[1], Sectors^[4, $18], Length(cLicenseText));

  For n := 0 To 6 do
    Move(cSector5[2048 * n], Sectors^[n + 5, $18], 2048);
  Move(cSector16, Sectors^[16, $18], SizeOf(cSector16));
  Move(cSector17, Sectors^[17, $18], SizeOf(cSector17));
  Move(cSector18, Sectors^[18, $18], SizeOf(cSector18));
  Move(cSector19, Sectors^[19, $18], SizeOf(cSector19));
  Move(cSector20, Sectors^[20, $18], SizeOf(cSector20));
  Move(cSector21, Sectors^[21, $18], SizeOf(cSector21));
  Move(cSector22, Sectors^[22, $18], SizeOf(cSector22));

  SecCount := (IMGSize div 2048) + Integer(IMGSize mod 2048 <> 0) + 826 + 150; // Security?
  SecCountBE := (SecCount SHL 24) or ((SecCount SHL 8) AND $FF0000) or
                (SecCount SHR 24) or ((SecCount SHR 8) and $00FF00);
  IMGSizeBE  := (IMGSize SHL 24) or ((IMGSize SHL 8) AND $FF0000) or
                (IMGSize SHR 24) or ((IMGSize SHR 8) and $00FF00);

  Move(SecCount,   Sectors^[16, $50 + $18], 4);
  Move(SecCountBE, Sectors^[16, $54 + $18], 4);

  Move(STime[1], Sectors^[16, $32D + $18], Length(STime));
  Move(STime[1], Sectors^[16, $33E + $18], Length(STime));

  Move(Time, Sectors^[16, $AE + $18], SizeOf(Time));
  Move(Time, Sectors^[22, $12 + $18], SizeOf(Time));
  Move(Time, Sectors^[22, $42 + $18], SizeOf(Time));
  Move(Time, Sectors^[22, $72 + $18], SizeOf(Time));
  Move(Time, Sectors^[22, $B0 + $18], SizeOf(Time));
  Move(Time, Sectors^[22, $EC + $18], SizeOf(Time));

  Move(IMGSize,   Sectors^[22, $6A + $18], 4);
  Move(IMGSizeBE, Sectors^[22, $6E + $18], 4);
  Move(cSLUSNames[CD], Sectors^[22, $BF + $18], Length(cSLUSNames[CD]));
  Sectors^[22, $88 + $18] := $30 + CD;

  ReadToSectors(SLUSName, @Sectors^[24]);
  Move(cSystemCNF[1], Sectors^[23, $18], Length(cSystemCNF));
  Move(cSLUSNames[CD], Sectors^[23, $18 + 14], Length(cSLUSNames[CD]));

  For n := 0 To High(Sectors^) do
  begin
    case n of
      12..15: ModeCode := $200000;
      16:     ModeCode := $90000;
      17..23: ModeCode := $890000;
      825:    ModeCode := $890000;
    else
      ModeCode := $80000;
    end;
    ConvertSector(@Sectors^[n], n);
  end;

  Seek(F, 0);
  BlockWrite(F, Sectors^, SizeOf(Sectors^));

  FreeMem(Sectors);
end;

end.
