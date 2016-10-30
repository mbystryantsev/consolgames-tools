unit OLS3Parser;

interface

uses Classes;

Type
  TShocRecord = Packed Record
    Sign: Array[0..3] of Char;
    Size: LongWord;
    Data: Array[0..3] of Char;
  end;
  TFillRecord = Packed Record
    Sign: Array[0..3] of Char;
    Size: LongWord;
  end;
  TOlsHeader = Packed Record
    Sign: Array[0..3] of Char;
    Unk1: LongWord;
    Unk2: LongWord;
  end;
  TSHDRRecord = Packed Record
    Unk: Array[0..6] of LongWord;
    Size: Integer;
  end;
  TSHDRData = Record
      Size: Integer;
      Name: String;
      Path: String;
      Ext:  String;
  end;


Function ParseFirst(Stream: TStream; var Header: TShocRecord; var Aligned: Integer): Boolean;
Function ParseNext(Stream: TStream; var Header: TShocRecord; var Aligned: Integer): Boolean;
Procedure GetData(Stream: TStream; var Data: TSHDRData; Size: Integer);

implementation     

Function Endian(V: LongWord): LongWord;
begin
  Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24);
end;

Function ParseFirst(Stream: TStream; var Header: TShocRecord; var Aligned: Integer): Boolean;
var OLSHeader: TOlsHeader; Fill: TFillRecord;
begin
  If Stream.Position + SizeOf(OLSHeader) >= Stream.Size Then
  begin
    Result := False;
    Exit;
  end;
  Stream.Read(OLSHeader, SizeOf(OLSHeader));
  If OLSHeader.Sign <> 'ols3' Then
  begin
    Result := False;
    Exit;
  end;
  Stream.Read(Header, SizeOf(Header));
  Header.Size := Endian(Header.Size);
  If Header.Sign = 'FILL' Then
  begin
    //Stream.Seek(Header.Size)
    Result := False;
    Exit;
  end;
  Stream.Seek(Header.Size - SizeOf(Header), soCurrent);
  if Stream.Position >= Stream.Size Then
  begin
    Aligned := 0;
    Stream.Seek(-Header.Size, 1)
  end else
  begin
    Stream.Read(Fill, SizeOf(Fill));
    If Fill.Sign = 'FILL' Then
      Aligned := Endian(Fill.Size)
    else
      Aligned := 0;
    Stream.Seek(-Header.Size - SizeOf(Fill), 1);
  end;
  Result := True;
end;

Procedure GetData(Stream: TStream; var Data: TSHDRData; Size: Integer);
var Buf: Array[0..1023] of Char; Pos: Int64;
begin
  Pos := Stream.Position;
  Stream.Seek($1C + SizeOf(TShocRecord), soCurrent);
  Stream.Read(Data.Size, 4);
  Data.Size := Endian(Data.Size);
  Stream.Read(Buf, Size - $20 - SizeOf(TShocRecord));
  Data.Name := PChar(@Buf[0]);
  Data.Path := PChar(@Buf[Length(Data.Name) + 1]);
  Data.Ext  := PChar(@Buf[Length(Data.Name) + Length(Data.Path) + 2]);
  Stream.Position := Pos;
end;

Function ParseNext(Stream: TStream; var Header: TShocRecord; var Aligned: Integer): Boolean;
var Fill: TFillRecord;
begin
  If Stream.Position >= Stream.Size Then
  begin
    Result := False;
    Exit;
  end;
  Stream.Read(Header, SizeOf(Header));
  Header.Size := Endian(Header.Size);
  Stream.Seek(Header.Size - SizeOf(Header), soCurrent);
  If Stream.Position < Stream.Size Then
  begin
    Stream.Read(Fill, SizeOf(Fill));
    If Fill.Sign = 'FILL' Then
    begin
      Fill.Size := Endian(Fill.Size);
      Stream.Seek(Fill.Size - SizeOf(Fill), soCurrent);
    end else
      Stream.Seek(-SizeOf(Fill), soCurrent);
  end; 
  If Stream.Position + 12 <= Stream.Size Then
  begin
    Stream.Read(Header, SizeOf(Header));
    Stream.Seek(-SizeOf(Header), 1);
    Header.Size := Endian(Header.Size);
    Result := True;
  end else
    Result := False;

  
  Stream.Seek(Header.Size, soCurrent);
  if Stream.Position >= Stream.Size Then
  begin
    Aligned := 0;
    Stream.Seek(-Header.Size, 1)
  end else
  begin
    Stream.Read(Fill, SizeOf(Fill));
    If Fill.Sign = 'FILL' Then
      Aligned := Endian(Fill.Size)
    else
      Aligned := 0;
    Stream.Seek(-Header.Size - SizeOf(Fill), 1);
  end;

end;

end.
