program SizeFix;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  OLS3Parser;

Procedure SetSlash(var S: String);
begin
  If S = '' Then Exit;
  If S[Length(S)] <> '\' Then S := S + '\';
end;

Function Endian(V: LongWord): LongWord;
begin
  Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24);
end;

Procedure PrintUsage();
begin
  WriteLn('Dante''s Inferno LH2 Size Fix by HoRRoR');
  WriteLn('http://consolgames.ru/');
  WriteLn('Usage: SizeFix <InStreamsDir> <FilesDir> <OutStreamsDir>');
end;

Function EndianW(W: Word): Word;
begin
  Result := (W SHR 8) or (W SHL 8);
end;

Type
  THashData = Record
    Name: String;
    Hash: Integer;
  end;
  TRecHeader = Packed Record
    FormatID:  Integer;
    Version:   Integer;
    FileCount: Word;
    HashCount: Word;
    Unknown:   Integer;
  end;
  TFileRecord = Packed Record
    HashOffset:   Integer;
    Size:         Integer;
    FolderOffset: Integer;
    Reserved:     Integer;
    NamesOffset:  Integer;
  end;
  THashRecord = Packed Record
    Hash:       Integer;
    NameOffset: Integer;
  end;


const
  InHashes: Array[0..1] of Integer = ($16408156, $FA6167C0);
  FileHashes: Array[0..10] of THashData =
  (
    (Name: 'inferno_dialog.en.lh2'; Hash: $0277DF98),
    (Name: 'inferno_global.ll.lh2'; Hash: $99B46188),
    (Name: '';                      Hash: $9ED1A53E),
    (Name: 'inferno_dialog.ll.lh2'; Hash: $AA6683B4),
    (Name: 'inferno_global.fr.lh2'; Hash: $BC18D4B8),
    (Name: 'inferno_global.es.lh2'; Hash: $C1D43D40),
    (Name: 'inferno_dialog.fr.lh2'; Hash: $CCCAF6E4),
    (Name: 'inferno_dialog.es.lh2'; Hash: $D2865F6C),
    (Name: 'inferno_global.ss.lh2'; Hash: $EB56B888),
    (Name: 'inferno_global.en.lh2'; Hash: $F1C5BD6C),
    (Name: 'inferno_dialog.ss.lh2'; Hash: $FC08DAB4)
  );



Function GetHash(var Rec: TFileRecord; Buf: Pointer): Integer;
var HashRec: ^THashRecord;
begin
  HashRec := Pointer(LongWord(Buf) + Endian(Rec.HashOffset));
  Result := HashRec^.Hash;
end;

Function FindHash(Name: String): Integer;
var i: Integer;
begin
  For i := 0 To High(FileHashes) do
  begin
    If FileHashes[i].Name = Name Then
    begin
      Result := Endian(FileHashes[i].Hash);
      Exit;
    end;
  end;
  Result := 0;
end;

var
    Stream: TMemoryStream;
    StreamsDir, FilesDir, OutDir: String;
    SR: TSearchRec;
    Header: ^TRecHeader; Rec: ^TFileRecord;
    i, Hash: Integer;

begin

  If ParamCount < 3 Then
  begin
    PrintUsage();
    Exit;
  end;

  StreamsDir := ParamStr(1);
  FilesDir   := ParamStr(2);
  OutDir     := ParamStr(3);
  SetSlash(StreamsDir);
  SetSlash(FilesDir);
  SetSlash(OutDir);

  WriteLn('Finding files...');
  If FindFirst(FilesDir + '*', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
  Stream := TMemoryStream.Create();
  Stream.LoadFromFile(StreamsDir + IntToHex(InHashes[0], 8) + '.BIN');
  Header := Stream.Memory;
  repeat
    Hash := FindHash(SR.Name);
    If Hash <> 0 Then
    begin
      Rec := Pointer(LongWord(Header) + SizeOf(Header^));
      For i := 0 To EndianW(Header^.FileCount) - 1 do
      begin
        If Hash = GetHash(Rec^, Stream.Memory) Then
        begin
          WriteLn('Update size of ', SR.Name, '...');
          Rec^.Size := Endian(SR.FindData.nFileSizeLow);
          break;
        end;
        Inc(Rec);
      end;
    end;
  until FindNext(SR) <> 0;
  FindClose(SR);

  For i := 0 To High(InHashes) do
    Stream.SaveToFile(OutDir + IntToHex(InHashes[i], 8) + '.BIN'); 

  Stream.Free;
  WriteLn('Done!');


end.
