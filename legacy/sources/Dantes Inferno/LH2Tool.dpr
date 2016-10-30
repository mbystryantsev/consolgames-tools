program LH2Tool;

{$APPTYPE CONSOLE}

uses
  SysUtils, TntClasses, Classes, Windows;

Type
  THeader = Packed Record
      Sign:       Array[0..3] of Char; // '2HCL'
      Size:       Integer;
      Unk0:       Integer; // 40 00 00 01
      Unk1:       Integer;
      Count:      Integer;
      LangCount:  Integer;
      Reserved0:  Integer; // 0, 0
      Reserved1:  Integer;
  end;

  TStringRecord = Record
    Data: PChar;
    Hash: LongWord;
    Offset: LongWord;
  end;

Type
  TLongWordArray = Array[Word] of LongWord;

Function Endian(V: Cardinal): Cardinal;
begin
  Result := (V SHR 24) or ((V SHR 8) AND $FF00 ) or ((V SHL 8) AND $FF0000 ) or (V SHL 24);
end;

Procedure PrintUsage();
begin       
    WriteLn('Usage:');
    WriteLn('  LH2Tool -e input.lh2 output.txt');
    WriteLn('  LH2Tool -b input.txt output.lh2');

end;

var InFile, OutFile: String;
Ptrs, Hashes: ^TLongWordArray;
F: File; Buf: Pointer; Size, n, m, Count: Integer; List: TStringList; Header: ^THeader;
Start, First: Boolean; S: String; LineCount: Integer; Hash: LongWord; SPtr: PChar;
Records: Array of TStringRecord; LangCount, Pos, i, Len: Integer;
Stream: TMemoryStream;

SS: WideString; WideList: TTntStringList;

Procedure CheckOutFile(Ext: String);
begin
  If OutFile = '' Then
    OutFile := ChangeFileExt(InFile, Ext)
  Else If DirectoryExists(OutFile) Then
  begin
    OutFile := OutFile + ChangeFileExt(ExtractFileName(InFile), Ext);
  end;
  If not DirectoryExists(ExtractFilePath(ExpandFileName(OutFile))) Then
    ForceDirectories(ExtractFilePath(ExpandFileName(OutFile)));
end;

Function IsHashString(S: String): Boolean;
var Code: Integer;
begin
  S := Trim(S);
  If (Length(S) <> 10) or (S[1] <> '[') or (S[10] <> ']') Then
  begin
    Result := False;
    Exit;
  end;
  S[1] := '$';
  SetLength(S, 9);
  Val(S, Hash, Code);
  Result := Code = 0;
end;

const LANG_STRING: String = 'LANGUAGES=';
      NULL: Integer = 0;

Procedure GetLangCount(S: String);
var Code: Integer;
begin
  S := Trim(S);
  If (S[1] = '{') and (S[Length(S)] = '}') Then
  begin
    If CompareMem(@S[2], PChar(LANG_STRING), Length(LANG_STRING)) Then
    begin
      S := PChar(@S[Length(LANG_STRING) + 2]);
      SetLength(S, Length(S) - 1);
      Val(S, LangCount, Code);
      If Code <> 0 Then LangCount := 1;
    end;
  end;
end;


const
  cBufferSize = 1024 * 1024;

begin
  WriteLn('LH2 Tool by HoRRoR');
  WriteLn('http://consolgames.ru/');
  if ParamCount < 3 Then
  begin
    PrintUsage;
    Exit;
  end;
  InFile := ParamStr(2);
  OutFile := ParamStr(3);




  If ParamStr(1) = '-e' Then
  begin
      CheckOutFile('.txt');
      Write('Converting ', ExtractFileName(InFile), '... ');
      AssignFile(F, InFile);
      Reset(F, 1);
      Size := FileSize(F);
      GetMem(Buf, Size);
      BlockRead(F, Buf^, Size);
      CloseFile(F);

      Header := Buf;

      Count := Endian(Header^.Count);
      Hashes := Pointer(LongWord(Buf) + SizeOf(THeader));
      Ptrs  := Pointer(LongWord(Hashes) + Count * 4);
      List := TStringList.Create;
      If Endian(Header.LangCount) > 1 Then
      begin
        List.Add(Format('{%s%d}', [LANG_STRING, Endian(Header.LangCount)]));
        List.Add(''); 
      end;
      For n := 0 To Count - 1 do
      begin
        List.Add(Format('[%8.8X]', [Endian(Hashes^[n])]));
        List.Add(PChar(LongWord(Buf) + Endian(Ptrs^[n])));
        List.Add(''); 
      end;
      FreeMem(Buf);
      List.SaveToFile(OutFile);
      List.Free;
      WriteLn('Done!');
  end else
  If ParamStr(1) = '-b' Then
  begin

  //  Len := WideCharToMultiByte(CP_UTF8, 0, PWideChar(S), Length(S), StrData, cBufferSize - (LongWord(NodeData) - LongWord(NodeBuf)), nil, nil);
      CheckOutFile('.lh2');
      Write('Converting... ');
      WideList := TTntStringList.Create;
      try
        WideList.LoadFromFile(InFile);
      except
        WriteLn('');
        WriteLn('Unable to open input file!');
        WideList.Free;
        Exit;
      end;                    
      LangCount := 1;
      Start := False;
      Count := 0;
      GetLangCount(WideList.Strings[0]);
      GetMem(Buf, cBufferSize);
      SPtr := Buf;
      For n := 0 To WideList.Count - 1 do
      begin
        SS := WideList.Strings[n];
        If IsHashString(SS) Then
        begin
          If Start Then
          begin  
            While LineCount > 1 do
            begin
              SPtr^ := '\'; Inc(SPtr);
              SPtr^ := 'n'; Inc(SPtr);
              Dec(LineCount);
            end;
            SPtr^ := #0;
            Inc(SPtr);
          end;
          LineCount := 0;
          First := True;
          SetLength(Records, Count + 1);
          Records[Count].Data := SPtr;
          Records[Count].Hash := Endian(Hash);
          //Records[Count].Offset := LongWord(SPtr) - LongWord(Buf);
          Inc(Count);
          Start := True;
        end else
        If Start and (SS <> '') Then
        begin
          If Start Then
          begin
            While LineCount > 0 do
            begin
              SPtr^ := '\'; Inc(SPtr);
              SPtr^ := 'n'; Inc(SPtr);
              Dec(LineCount);
            end;
          end;
          If First Then
            First := False
          else
          begin
            SPtr^ := '\'; Inc(SPtr);
            SPtr^ := 'n'; Inc(SPtr);
          end;
          For i := 1 To Length(SS) do
          begin
            Case Word(SS[i]) of
              $0040..$007F: Inc(Word(SS[i]), $0080);
              $0410..$044F: Dec(Word(SS[i]), $03D0);
              //$0401: Word(SS[i]) := $00A8;
              //$0451: Word(SS[i]) := $00B8;
            end;
          end;
          Len := WideCharToMultiByte(CP_UTF8, 0, PWideChar(SS), Length(SS), SPtr, cBufferSize - (LongWord(SPtr) - LongWord(Buf)), nil, nil);
          Inc(SPtr, Len);
        end else
        If Start Then
          Inc(LineCount);
      end;
      If Start Then
      begin
        SPtr^ := #0;
        Inc(SPtr);
      end;
      WideList.Free;

      Try
        Stream := TMemoryStream.Create;
        //Stream.SetSize(1024 * 1024); 
        Stream.Seek(SizeOf(THeader), soBeginning);
        For n := 0 To Count - 1 do
          Stream.Write(Records[n].Hash, 4);
        Stream.Seek(Count * LangCount * 4, soCurrent);
        Pos := Stream.Position;
        Stream.Write(Buf^, LongWord(SPtr) - LongWord(Buf));

        Stream.Seek(SizeOf(THeader) + Count * 4, soBeginning);
        For n := 0 To Count - 1 do
          Records[n].Offset := LongWord(Records[n].Data) - LongWord(Buf) + Pos;
        For m := 0 To LangCount - 1 do
          For n := 0 To Count - 1 do
            Stream.Write(Records[n].Offset, 4);
        Header := Stream.Memory;
        Header^.Sign := '2HCL';
        Header^.Unk0 := $01000040;
        Header^.Unk1 := 0;
        Header^.Count := Endian(Count);
        Header^.LangCount := Endian(LangCount);
        Header^.Reserved0 := 0;
        Header^.Reserved1 := 0;
        Header^.Size := Endian(LongWord(Stream.Size));
        Stream.SaveToFile(OutFile);
        Stream.Free;
      except
        Stream.Free;
        WriteLn('');
        WriteLn('Error! ', n);
        FreeMem(Buf);
        Exit;

      end;                    
      FreeMem(Buf);
      WriteLn('Done!');
  end;
end.
