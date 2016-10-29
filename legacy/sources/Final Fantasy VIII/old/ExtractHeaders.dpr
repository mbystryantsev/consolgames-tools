program ExtractHeaders;

{$APPTYPE CONSOLE}

uses
  SysUtils;

const
  StartSector = 826;
  SectorSize  = 2048;
  BufSize     = 16 * 1024 * 1024;

Type
  THeaderRecord = Packed Record
    Offset: Integer;
    Size:   Integer;
  end;
  THeader = Array[0..($428 div 8) - 1] of THeaderRecord;

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

var
  Header: THeader;
  Buf:    Pointer;
  n:      Integer;
  F, WF:  File;
  OutDir: String;
  Sectors: Array of Boolean;
  Flag: Boolean = False;
  OpenSector: Integer;
  FreeSectors: Integer = 0;
begin
  AssignFile(F, ParamStr(1));
  OutDir := ParamStr(2);
  If OutDir[Length(OutDir)] <> '\' Then OutDir := OutDir + '\';
  If not DirectoryExists(OutDir) Then
    ForceDirectories(OutDir);
  Reset(F, 1);
  BlockRead(F, Header, SizeOf(Header));
  SetLength(Sectors, FileSize(F) div SectorSize);
  FillChar(Sectors[0], Length(Sectors), 0);
  Sectors[0] := True;
  GetMem(Buf, BufSize);
  For n := 0 To High(Header) do
  begin
    FillChar(Sectors[Header[n].Offset - StartSector], RoundBy(Header[n].Size, SectorSize) div SectorSize, 1);

    Seek(F, (Header[n].Offset - StartSector) * SectorSize);
    BlockRead(F, Buf^, Header[n].Size);
    AssignFile(WF, OutDir + Format('file%3.3d', [n]));
    Rewrite(WF, 1);
    BlockWrite(WF, Buf^, Header[n].Size);
    CloseFile(WF);

  end;
  CloseFile(F);

  For n := 0 To High(Sectors) do
  begin
    If not Sectors[n] and not Flag Then
    begin
      Flag := True;
      OpenSector := n;
      Write(n,'-');
    end else If Sectors[n] and Flag Then
    begin
      Flag := False;
      Inc(FreeSectors, n - OpenSector);
      Write(n - 1,', ');
    end;
  end;
  If Flag Then
  begin
    Write(High(Sectors));
    Inc(FreeSectors, Length(Sectors) - OpenSector);
  end;
  WriteLn;
  WriteLn(Format('Total free sectors: %d (%d bytes)', [FreeSectors, FreeSectors * SectorSize]));
  ReadLn;
  FreeMem(Buf);
  { TODO -oUser -cConsole Main : Insert code here }
end.
