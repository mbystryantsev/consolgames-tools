program OLSRebuild;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, Rpak, OLS3Parser;

Procedure SetSlash(var S: String);
begin
  If S = '' Then Exit;
  If S[Length(S)] <> '\' Then S := S + '\';
end;

Procedure PrintUsage();
begin
  WriteLn('OLS3 Streams Rebuilder by HoRRoR');
  WriteLn('http://consolgames.ru/');
  WriteLn('Usage: olsrebuild <InStreamsDir> <FilesDir> <OutStreamsDir>');
end;

Function Endian(V: LongWord): LongWord;
begin
  Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24);
end;

//{$O-}
Procedure FillStream(Stream: TStream; FillPos: Integer);
var Fill: TFillRecord; FillSize: Integer;
begin
  If Stream.Position > FillPos Then
  begin
    WriteLn('**********************************');
    WriteLn('***ERROR: Too big size of files :(');
    WriteLn('');
    FillPos := Stream.Position + ($800 - (Stream.Position mod $800));
  end;
  Fill.Sign := 'FILL';
  FillSize := FillPos - Stream.Position;
  Fill.Size := Endian(FillSize);
  Stream.Write(Fill, SizeOf(Fill));
  Stream.Position := Stream.Position + FillSize - SizeOf(Fill);
end;
//{$O+}

Procedure Progress(i, size: Integer); stdcall;
begin
  Write(Format('[%.0f%%] %d/%d'#13, [(i / size) * 100, i, size]));
end;

Function GetMaxAndAligned(a, b: Integer): Integer;
begin
  If b > a Then a := b;
  Result := ((a + 3) div 4) * 4;
end;

var FileStream, InStream, OutStream: TFileStream;
    StreamsDir, FilesDir, OutDir, ReplaceFile: String;
    SR: TSearchRec; Header, InHeader: TSHOCRecord; {First, }Replace: Boolean;
    Data: TSHDRData; InBuf, OutBuf: Pointer; Pos, SHDRPos: Int64; Filled, Temp: Integer;
label brk;
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

  SHDRPos := -1;


  If FindFirst(StreamsDir + '*', faAnyFile xor faDirectory, SR) <> 0 Then
  begin
    Exit;
  end;

  If not DirectoryExists(OutDir) Then
    ForceDirectories(ExpandFileName(OutDir));

  GetMem(InBuf,  1024 * 1024 * 16);
  GetMem(OutBuf, 1024 * 1024 * 16);

  //Fill.Sign := 'FILL';
  WriteLn('Finding and rebuilding streams...');
  repeat
    Write('Stream ', SR.Name, '...'#13);
    OutStream := nil;
    InStream := TFileStream.Create(StreamsDir + SR.Name, fmOpenRead);
    If ParseFirst(InStream, Header, Filled) Then
    begin
      //First := True;
      Replace := False;
      repeat
        InHeader := Header;      
        If not Replace and (OutStream <> nil) Then
        begin
          Pos := InStream.Position;
          SHDRPos := OutStream.Position;
          OutStream.CopyFrom(InStream, Header.Size);
          InStream.Position := Pos;
          If Filled > 0 Then
            FillStream(OutStream, InStream.Position + InHeader.Size + Filled);
        end;
        If Replace Then
        begin
          Replace := False;
          If OutStream = nil Then
          begin
            WriteLn('Rebuilding stream ', SR.Name, '...');
            OutStream := TFileStream.Create(OutDir + SR.Name, fmCreate);
            Pos := InStream.Position;
            InStream.Seek(0, 0);
            OutStream.CopyFrom(InStream, Pos);
            InStream.Position := Pos;
          end;
          FileStream := TFileStream.Create(ReplaceFile, fmOpenRead);

          Pos := OutStream.Position;
          OutStream.Seek(SHDRPos + SizeOf(TShocRecord) + $1C, soBeginning);
          Temp := Endian(FileStream.Size);
          OutStream.Write(Temp, 4);
          OutStream.Seek(Pos, soBeginning);

          If Header.Data = 'Rpak' Then
          begin
            WriteLn('--> Compressing and replacing file ', ExtractFileName(ReplaceFile), '...');
            FillChar(OutBuf^, Header.Size, 0);
            FileStream.Read(InBuf^, FileStream.Size);
            Temp := FileStream.Size;
            Temp := RCompress(InBuf, Temp, OutBuf, @Progress);
            //Temp := SizeOf(Header) + ((Temp + 3) div 4) * 4;
            If Temp > Header.Size - SizeOf(Header) + Filled Then
            begin
              WriteLn('*** ERROR: File ', ExtractFileName(ReplaceFile), ' too large (out of ', (Temp  + SizeOf(Header)) - Header.Size, ' bytes)');
              goto brk;
            end;
            Header.Size := Endian(GetMaxAndAligned(Header.Size, Temp + SizeOf(Header)));
            OutStream.Write(Header, SizeOf(Header));
            Header.Size := Endian(Header.Size);
            OutStream.Write(OutBuf^, Header.Size - SizeOf(Header));
          end else
          begin
            WriteLn('--> Replacing file ', ExtractFileName(ReplaceFile), '...');
            //Header.Size := SizeOf(Header) + ((FileStream.Size + 3) div 4) * 4;
            If FileStream.Size > Header.Size - SizeOf(Header) + Filled Then
            begin
              WriteLn('*** ERROR: File ', ExtractFileName(ReplaceFile), ' too large (out of ', (FileStream.Size + SizeOf(Header)) - Header.Size, ' bytes)');
              goto brk;
            end;
            Header.Size := Endian(GetMaxAndAligned(Header.Size, FileStream.Size + SizeOf(Header)));
            OutStream.Write(Header, SizeOf(Header));
            Header.Size := Endian(Header.Size);
            OutStream.CopyFrom(FileStream, FileStream.Size);
            FillChar(OutBuf^, Header.Size - FileStream.Size, 0);
            OutStream.Write(OutBuf^, Header.Size - FileStream.Size - SizeOf(Header));
            //OutStream.Position := ((OutStream.Position + 3) div 4) * 4;
          end;
brk:
          FileStream.Free;  
          If Filled > 0 Then
            FillStream(OutStream, InStream.Position + InHeader.Size + Filled);
        end else
        If Header.Data = 'SHDR' Then
        begin                                   
          If OutStream = nil Then
            SHDRPos := InStream.Position;
          GetData(InStream, Data, Header.Size);
          If FileExists(FilesDir + ExtractFileName(Data.Path)) Then
          begin
            Replace := True;
            ReplaceFile := FilesDir + ExtractFileName(Data.Path);
          end;
        end;
      until not ParseNext(InStream, Header, Filled);
    end;
    InStream.Free;
    If OutStream <> nil Then
    begin
      OutStream.Size := OutStream.Position;
      OutStream.Free;
    end;
  until FindNext(SR) <> 0;
  FreeMem(InBuf);
  FreeMem(OutBuf);
  WriteLn('Streams rebuilded!                  ');
end.
