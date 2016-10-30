program VivExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes;

type
  TFileRecord = Packed Record
    Hash:     LongWord;
    Offset:   LongWord;
    Size:     LongWord;
  end;
  PFileRecord = ^TFileRecord;
  TStringArray = Array of String;


const
  Footer: Array[0..7] of Char = 'L283'#$15#$05#0#0;
//var
//  Sectors: Array of Boolean;

var XBOX: Boolean = False;

Function EndianW(V: Word): Word;
begin
  If XBOX Then
    Result := (V SHR 8) or (V SHL 8)
  else
    Result := V;
end;

Function Endian(V: LongWord): LongWord;
begin
  If XBOX Then
    Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24)
  else
    Result := V;
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
  WriteLn('  VivExtractor -e <TabFile> <ArcFile> <OutDir>');
  WriteLn('  VivExtractor -b <TabFile> <ArcFile> <InDirs>');
  WriteLn('InDirs: Dir1;Dir2; ... ;DirN');
end;

var
  Stream, InStream: TFileStream;
  FSize: LongWord;
  FileRecords: Array of TFileRecord;
  n, m: Integer; Buf: Pointer;
  Name, OutDir, ArcFile, TabFile, InDir: String;
  Pos: Int64;  Folders: TStringArray;

  PageSize: LongWord;
  FileCount: Integer;



const
  BUFFER_SIZE = 1024 * 1024 * 16;

Procedure LoadTab();
begin 
    Stream := TFileStream.Create(TabFile, fmOpenRead);
    Stream.Read(PageSize, SizeOf(PageSize));
    XBOX := PageSize >= $10000;
    PageSize := Endian(PageSize);
    FileCount := (Stream.Size - 4) div SizeOf(TFileRecord);
    SetLength(FileRecords, FileCount);
    Stream.Read(FileRecords[0], FileCount * SizeOf(TFileRecord));
    Stream.Free;
end;

begin
  WriteLn('Just Clause 2 Arc Tool by HoRRoR');
  WriteLn('http://consolgames.ru/');
  If ParamCount < 4 Then
  begin
    PrintUsage();
    Exit;
  end;
  TabFile := ParamStr(2);
  ArcFile := ParamStr(3);
  If ParamStr(1) = '-e' Then
  begin
    OutDir := ParamStr(4);
    If not FileExists(OutDir) and not ForceDirectories(ExpandFileName(OutDir)) Then
    begin
      WriteLn('Can''t create output directory!');
      Exit;
    end;
    WriteLn('Extracting...');
    SetSlash(OutDir);

    LoadTab();

    Stream := TFileStream.Create(ArcFile, fmOpenRead);
    GetMem(Buf, BUFFER_SIZE);
    For n := 0 To FileCount - 1 do With FileRecords[n] do
    begin
      Name := OutDir + IntToHex(Endian(Hash), 8) + '.BIN';
      WriteLn(Format('[%d/%d] %8.8X', [n + 1, FileCount, Endian(Hash)]));
      ExtractFile(Stream, Endian(Offset), Endian(Size), Name, Buf, BUFFER_SIZE);
    end;
    Stream.Free;
    FreeMem(Buf);
    WriteLn('Done!');
  end else
  If ParamStr(1) = '-b' Then
  begin
    GetPaths(ParamStr(4), Folders);
    LoadTab();
    Stream := TFileStream.Create(ArcFile, fmCreate);
    Pos     := 0;

    For n := 0 To High(FileRecords) do
    begin
      Name := IntToHex(Endian(FileRecords[n].Hash), 8) + '.BIN';
      WriteLn(Format('[%d/%d] Adding %s...', [n + 1, Length(FileRecords), Name]));
      For m := 0 To High(Folders) do
        If FileExists(Folders[m] + Name) Then
          break;
      If m < Length(Folders) Then
      begin
        Name := Folders[m] + Name;
        InStream := TFileStream.Create(Name, fmOpenRead);
        FileRecords[n].Offset := Endian(Pos);
        FileRecords[n].Size   := Endian(InStream.Size);
        Stream.Seek(Pos, soBeginning);
        Stream.CopyFrom(InStream, InStream.Size);
        Pos := ((Stream.Position + PageSize - 1) div PageSize) * PageSize;
        InStream.Free;
      end else
        WriteLn('***ERROR: File does not exists: ', Name);
    end;
    Stream.Size := Stream.Position;

    PageSize := Endian(PageSize);
    Stream := Stream.Create(TabFile, fmOpenReadWrite);
    Stream.Write(PageSize, 4);
    Stream.Write(FileRecords[0], Length(FileRecords) * SizeOf(FileRecords));
    Stream.Free;   

  end;
end.
