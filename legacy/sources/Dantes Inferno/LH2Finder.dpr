program LH2Finder;

{$APPTYPE CONSOLE}



uses
  SysUtils,
  Classes,
  OLS3Parser in 'OLS3Parser.pas',
  Rpak in 'Rpak.pas';

const
  MEGABYTE = 1024 * 1024;

var
  BufferIn:  Array[0..MEGABYTE * 16 - 1] of Byte;
  BufferOut: Array[0..MEGABYTE * 16 - 1] of Byte;

Procedure ExtractFromFile(InFile, OutDir: String);
var Stream, DestStream: TFileStream; Header: TShocRecord;
    Pos: Int64; Data: TSHDRData; Flag: Boolean; Filled: Integer;
begin
  If OutDir[Length(OutDir)] <> '\' Then OutDir := OutDir + '\';
  Stream := TFileStream.Create(InFile, fmOpenRead);
  Flag := False;
  If ParseFirst(Stream, Header, Filled) Then
  begin
    repeat
      If Flag {and (Header.Data = )} Then
      begin
        Pos := Stream.Position;
        Stream.Seek(SizeOf(Header), soCurrent);
        DestStream := TFileStream.Create(OutDir + ExtractFileName(Data.Path), fmCreate);
        If Header.Data = 'Rpak' Then
        begin
          Stream.Read(BufferIn, Header.Size);
          DestStream.Write(BufferOut, RDecompress(@BufferIn, @BufferOut));
        end else
          DestStream.CopyFrom(Stream, Data.Size);
        DestStream.Free;
        Stream.Seek(Pos, soBeginning); 
      end;
      Flag := False;
      If Header.Data = 'SHDR' Then
      begin
        Pos := Stream.Position;
        GetData(Stream, Data, Header.Size);
        Stream.Seek(Pos, soBeginning);
        If Data.Ext = 'LH2' Then
        begin
          Flag := True;
          WriteLn(Data.Path {, ' at position ', Format('%8.8X', [LongWord(Stream.Position)])});
        end;
      end;
    until not ParseNext(Stream, Header, Filled);
  end;
  Stream.Free;
end;

Procedure ExtractFromFiles(InDir, OutDir: String);
var SR: TSearchRec;
begin                                                          
  If InDir[Length(InDir)] <> '\' Then InDir := InDir + '\';
  If OutDir[Length(OutDir)] <> '\' Then OutDir := OutDir + '\';
  If FindFirst(InDir + '*', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
  repeat
    WriteLn('Extracting from ', SR.Name);
    ExtractFromFile(InDir + SR.Name, OutDir);
    WriteLn('');
  until FindNext(SR) <> 0;
  FindClose(SR);

end;

var MStream, OutStream: TMemoryStream; Size: Integer;
const offset = 9; 
begin
  ExtractFromFiles('big0_rebuilded', 'test');
  //ExtractFromFiles('text\big1\', 'text');
  ReadLn;
end.
 