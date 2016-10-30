program VivExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes;

type
  THeader = Packed Record
    Sign: Array[0..3] of Char;
    Size: LongWord;
    FileCount: Integer;
    HeaderSize: Integer;
  end;
  TFileRecord = Packed Record
    Offset:   LongWord;
    Size:     LongWord;
    Hash:     LongWord;
  end;
  PFileRecord = ^TFileRecord;
  TStringArray = Array of String;


const
  Footer: Array[0..7] of Char = 'L283'#$15#$05#0#0;
//var
//  Sectors: Array of Boolean;

Function EndianW(V: Word): Word;
begin
  Result := (V SHR 8) or (V SHL 8);
end;

Function Endian(V: LongWord): LongWord;
begin
  Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24);
end;

Procedure ExtractFile(Stream: TFileStream; Offset, Size: LongWord; const Name: String; Buf: Pointer; BufSize: Integer);
var _size: Integer; DestFile: File;
begin
  Stream.Seek(Offset, soBeginning);
  AssignFile(DestFile, Name);
  Rewrite(DestFile, 1);
  While Size > 0 do
  begin
    _size := Size;
    if _size > BufSize Then _size := BufSize;
    Dec(Size, _size);
    Stream.Read(Buf^, _size);
    BlockWrite(DestFile, Buf^, _size);
  end;
  CloseFile(DestFile);
end;

Procedure SetSlash(var S: String);
begin
  If S = '' Then Exit;
  If S[Length(S)] <> '\' Then S := S + '\';
end;

Function GetPaths(S: String; var P: TStringArray): Integer;
var i, Count: Integer; Flag: Boolean;
begin
  Count := 0;
  Flag  := False;
  For i := 1 To Length(S) do If S[i] = ';' Then S[i] := #0;
  For i := 1 To Length(S) do
  begin
    If (S[i] <> #0) and not Flag Then
    begin
     Flag := True;
     If not DirectoryExists(PChar(@S[i])) Then Continue;
     Inc(Count);
     SetLength(P, Count);
     P[Count - 1] := PChar(@S[i]);
     SetSlash(P[Count - 1]);
    end else If S[i] = #0 Then
     Flag    := False;
  end;
  Result := Count;
end;




Procedure PrintUsage();
begin            
  WriteLn('Usage: ');
  WriteLn('  VivExtractor -e <VivFile> <OutDir> [OutHeaderFile]');
  WriteLn('  VivExtractor -b <VivFile> <InDirs> <InHeaderFile>');
  WriteLn('InDirs: Dir1;Dir2; ... ;DirN');
end;

var
  Stream, InStream: TFileStream;
  FSize: LongWord; Header: THeader;
  FileRecords: Array of TFileRecord;
  n, m: Integer; Buf: Pointer;
  Name, OutDir, VivFile, HeaderFile, InDir: String;
  RecPtrs: Array of PFileRecord;
  Pos: Int64;  Folders: TStringArray;



procedure SortRecords;
var
    i : Integer;
    j , n: Integer;
    Tmp : PFileRecord;
begin
  i := 0;
  N := Length(RecPtrs);
  while i <= N - 1 do
  begin
    j := 0;
    while j <= N - 2 - i do
    begin
      if Endian(RecPtrs[j]^.Offset) > Endian(RecPtrs[j+1]^.Offset) then
      begin
        Tmp := RecPtrs[j];
        RecPtrs[j] := RecPtrs[j+1];
        RecPtrs[j+1] := Tmp;
      end;
    Inc(j);
    end;
  Inc(i);
  end;
end;


const
  BUFFER_SIZE = 1024 * 1024 * 16;
begin
  WriteLn('Viv Archiver by HoRRoR');
  WriteLn('http://consolgames.ru/');
  If ParamCount < 3 Then
  begin
    PrintUsage();
    Exit;
  end;
  VivFile := ParamStr(2);
  If ParamStr(1) = '-e' Then
  begin
    OutDir := ParamStr(3);
    HeaderFile := ParamStr(4);
    If not FileExists(OutDir) and not ForceDirectories(ExpandFileName(OutDir)) Then
    begin
      WriteLn('Can''t create output directory!');
      Exit;
    end;
    WriteLn('Extracting...');
    SetSlash(OutDir);
    Stream := TFileStream.Create(VivFile, fmOpenRead);

    FSize := Stream.Size;
    Stream.Read(Header, SizeOf(Header));
    SetLength(FileRecords, Endian(Header.FileCount));
    Stream.Read(FileRecords[0], Endian(Header.FileCount) * SizeOf(TFileRecord));
    GetMem(Buf, BUFFER_SIZE);
    For n := 0 To Endian(Header.FileCount) - 1 do With FileRecords[n] do
    begin
      Name := OutDir + IntToHex(Endian(Hash), 8) + '.BIN';
      WriteLn(Format('[%d/%d] %8.8X', [n + 1, Endian(Header.FileCount), Endian(Hash)]));
      ExtractFile(Stream, Endian(Offset), Endian(Size), Name, Buf, BUFFER_SIZE);
    end;
    Stream.Free;
    FreeMem(Buf);
    If HeaderFile <> '' Then
    begin
      Stream := TFileStream.Create(HeaderFile, fmCreate);
      Stream.Write(Header, SizeOf(Header));
      Stream.Write(FileRecords[0], Endian(Header.FileCount) * SizeOf(TFileRecord));
      Stream.Size := Stream.Position;
      Stream.Free;
    end;
    WriteLn('Done!');
  end else
  If ParamStr(1) = '-b' Then
  begin
    HeaderFile := ParamStr(4);

    GetPaths(ParamStr(3), Folders);

    Stream := TFileStream.Create(HeaderFile, fmOpenRead);
    Stream.Read(Header, SizeOf(Header));
    SetLength(FileRecords, Endian(Header.FileCount));
    SetLength(RecPtrs,     Endian(Header.FileCount));
    Stream.Read(FileRecords[0], Endian(Header.FileCount) * SizeOf(TFileRecord));
    Stream.Free;

    For n := 0 To High(FileRecords) do
      RecPtrs[n] := @FileRecords[n];
    SortRecords();


    Stream := TFileStream.Create(VivFile, fmCreate);
    Pos := ((SizeOf(Header) + Length(FileRecords) * SizeOf(TFileRecord) + 8 + $800 - 1) div $800) * $800;

    For n := 0 To High(RecPtrs) do
    begin
      Name := IntToHex(Endian(RecPtrs[n]^.Hash), 8) + '.BIN';
      WriteLn(Format('[%d/%d] Adding %s...', [n + 1, Length(RecPtrs), Name]));
      For m := 0 To High(Folders) do
        If FileExists(Folders[m] + Name) Then
          break;
      If m < Length(Folders) Then
      begin
        Name := Folders[m] + Name;
        InStream := TFileStream.Create(Name, fmOpenRead);
        RecPtrs[n]^.Offset := Endian(Pos);
        RecPtrs[n]^.Size   := Endian(InStream.Size);
        Stream.Seek(Pos, soBeginning);
        Stream.CopyFrom(InStream, InStream.Size);
        Pos := ((Stream.Position + $800 - 1) div $800) * $800;
        InStream.Free;
      end else
        WriteLn('***ERROR: File does not exists: ', Name);
    end;
    Stream.Size := Stream.Position;
    Stream.Seek(0, soBeginning);
    Stream.Write(Header, SizeOf(Header));
    Stream.Write(FileRecords[0], Length(FileRecords) * SizeOf(TFileRecord));
    Stream.Write(Footer, SizeOf(Footer));


    Stream.Free;
  end;
end.
