program StreamsCheck;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes,
  OLS3Parser;

Function Endian(V: LongWord): LongWord;
begin
  Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24);
end;

var SR: TSearchRec; Stream, CheckStream: TFileStream;
    InDir, CheckDir: String; Header, CheckHeader: TShocRecord;
    Parsed: Boolean; Data, CheckData: TSHDRData;
    Filled, Count: Integer;
begin
    CheckDir := 'big0_rebuilded\';
    InDir := 'bigfile0\';


    If FindFirst(CheckDir + '*', faAnyFile xor faDirectory, SR) <> 0 Then Exit;
    repeat
      CheckStream := TFileStream.Create(CheckDir + SR.Name, fmOpenRead);
      Stream      := TFileStream.Create(InDir    + SR.Name, fmOpenRead);

      WriteLn('...checking ', SR.Name, ', sz = ', Stream.Size, ' chsz = ', CheckStream.Size);
      If ParseFirst(CheckStream, CheckHeader, Filled) and ParseFirst(Stream, Header, Filled) Then
      begin
        Count := 1;
        While(True) do
        begin
          If (Header.Sign <> CheckHeader.Sign) or (Header.Data <> CheckHeader.Data) Then
            WriteLn('Bad: ', SR.Name);

          If Header.Data = 'SHDR' Then
          begin
            GetData(Stream, Data, Endian(Header.Size));
            GetData(CheckStream, CheckData, Endian(CheckHeader.Size));
            If Data.Path <> CheckData.Path Then
              WriteLn('Bad: ', SR.Name);
          end;
          Parsed := ParseNext(Stream, Header, Filled);
          If Parsed <> ParseNext(CheckStream, CheckHeader, Filled) Then
          begin
            WriteLn('Bad: ', SR.Name);
            Break;
          end;
          If not Parsed Then Break;
          Inc(Count);
        end;
        WriteLn('Count: ', Count);
      end else
        WriteLn('Bad: ', SR.Name);
      CheckStream.Free;
      Stream.Free;
    until FindNext(SR) <> 0;
    WriteLn('Done!');
    ReadLn;

end.
 