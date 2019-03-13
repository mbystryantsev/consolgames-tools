program SHTextConv;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes//,
  {TntClasses};

Type
 TPtrRec = Packed Record
  ID: Cardinal;
  Ptr: Integer;
 end;

Function CompareStrings(S1, S2: PWideChar): Boolean;
begin
  Result := False;
  While S1^ = S2^ do
  begin
    If (Word(S1^) = 0) and (Word(S2^) = 0) Then
    begin
      Result := True;
      Exit;
    end;
    Inc(S1);
    Inc(S2);
  end;
end;

Var
 //F: TFileStream;
 F: TMemoryStream;
 List: {TTnt}TStringList; WS: WideString; WC: WideChar;
 I, FileID, Cnt, n, SPos: Integer; PtrList, CmpList: Array of TPtrRec;
 InFile, OutFile, CmpFile, S: String; Cmp, StrCmp: Boolean; FF: File;
 CmpBuf, CmpBuf2: PWideChar;
begin
  WriteLn('Silent Hill 0rigins Text Converter v1.0 by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');
  If ParamCount<2 Then
  begin
    WriteLn('Usage:');
    WriteLn('SHTextConv [Keys] <StringsFile> <TextFile>');
    WriteLn('Keys:');
    WriteLn(' -cFILE: Extract only strings with different hash');
    WriteLn(' -s: Extract different strings');

    Exit;
  end;
  Cmp := False;
  StrCmp := False;

  For n := 1 To ParamCount do
  begin
    S := ParamStr(n);
    If S[1] <> '-' Then Break;
    Case S[2] of
      'c':
      begin
        SetLength(CmpFile, Length(S) - 2);
        Move(S[3], CmpFile[1], Length(CmpFile));
        Cmp := True;
      end;
      's': StrCmp := True;
    end;
  end;
  InFile := ParamStr(n);
  OutFile := ParamStr(n + 1);

  If not FileExists(InFile) Then
  begin
    WriteLn('Input file not exists!');
    Exit;
  end;

  If Cmp Then
  begin
    AssignFile(FF, CmpFile);
    Reset(FF, 1);
    Seek(FF, 4);
    BlockRead(FF, n, 4);
    SetLength(CmpList, n);
    BlockRead(FF, CmpList[0], n * SizeOf(TPtrRec));
    If StrCmp Then
    begin
      GetMem(CmpBuf, FileSize(FF) - n * SizeOf(TPtrRec) - 8);
      BlockRead(FF, CmpBuf^, FileSize(FF) - n * SizeOf(TPtrRec) - 8);
    end;
    CloseFile(FF);
  end;

 //F := TFileStream.Create(InFile, fmOpenRead);
 F := TMemoryStream.Create;
 F.LoadFromFile(InFile); 
 List := TStringList.Create;
 F.Read(FileID, 4);
 If FileID = 2 then
 begin
  F.Read(Cnt, 4);
  SetLength(PtrList, Cnt);
  If StrCmp Then
    CmpBuf2 := PWideChar(LongWord(F.Memory) + Cnt * SizeOf(TPtrRec) + 8);
  F.Read(PtrList[0], Cnt * 8);
  SPos := F.Position;
  For I := 0 to Cnt - 1 do With PtrList[I] do
  begin
   If Cmp Then
   begin
    For n := 0 To High(CmpList) do
      If CmpList[n].ID = PtrList[i].ID Then
        Break;
    If n < Length(CmpList) Then
    begin
      If StrCmp Then
      begin
        If CompareStrings(@CmpBuf[CmpList[n].Ptr], @CmpBuf2[PtrList[i].Ptr]) Then
          Continue;
      end else
        Continue;
    end;
   end;
   List.Add('[' + IntToHex(ID,8) + ']');
   F.Position := SPos + Ptr * 2;
   WS := '';
   While True do
   begin
    F.Read(WC, 2);
    If WC = #0 then Break;
    If WC = #1 then
    begin
     F.Read(WC, 2);
     WS := WS + '<c=' + IntToStr(Word(WC)) + '>';
    end Else
    If WC = #3 then
    begin
     F.Read(WC, 2);
     WS := WS + '<b=' + IntToStr(Word(WC)) + '>';
    end Else
    If WC = #4 then
    begin
     F.Read(WC, 2);
     WS := WS + '<w=' + IntToStr(Word(WC))+'>';
    end Else
    If WC = #2 then
    begin
     //F.Read(WC, 2);
     WS := WS + '<p>' + WC;
    end Else
     WS := WS + WC;
   end;
   List.Add(WS);
   List.Add('');
  end;
 end;
 If StrCmp Then FreeMem(CmpBuf);
 List.SaveToFile(OutFile);
 List.Free;
 F.Free;
 WriteLn('Done!');
end.
