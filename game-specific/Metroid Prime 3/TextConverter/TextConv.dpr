program TextConv;

{$APPTYPE CONSOLE}

uses
  SysUtils, TableText, Windows, StrUtils;


type
  THeader = Packed Record
    Signature:  LongWord;
    Version:    LongWord;
    LangCount:  LongWord;
    Count:      LongWord;
  end;

  TIdHeader = Packed Record
    IdCount:    LongWord;
    IdSize:     LongWord;
  end;

  TLangRec = Packed Record
    LangStr: Array[0..3] of Char;
    Offset: LongWord;
    Size: LongWord;
  end;

  TIdRec = Record
    Str: WideString;
    Num: LongWord;
  end;
  TIdRecArray = Array of TIdRec;

var
  wstrbuf: Array[0..1024*512-1] of WideChar;
  astrbuf: Array[0..1024*1024-1] of Char absolute wstrbuf;


Function Endian(v: LongWord): LongWord;
begin
  Result := ((v SHR 24) OR ((v SHR 8) AND $FF00) OR ((v SHL 8) AND $FF0000) OR (v SHL 24));
end;

Function EndianW(v: Word): Word;
begin
  Result := (v SHR 8) OR (v SHL 8);
end;

Function EndianC(c: WideChar): WideChar;
begin
  Result := WideChar(EndianW(Word(c)));
end;

Procedure FCreateError(S: String; Level: TErrorType = etError);
const cLevelStr: Array[TErrorType] of String = ('***LOG: ','***HINT: ','***WARNING: ','***ERROR: ');
begin
  WriteLn(cLevelStr[Level] + S);
end;

Procedure SetSlash(var S: String);
begin
  If S[Length(S)] <> '\' Then S := S + '\';
end;


Procedure ExtractText(Ptrs, TextPtr: Pointer; Count, LangID: Integer; Text: TGameText; IDs: TIdRecArray; Ver: Integer);
var Ptr, P: PLongWord; i, Len: Integer; S: WideString;
  LangRec: ^TLangRec; W: PWideChar;

  Procedure SetID(var S: WideString; Index: Integer);
  var j: Integer;
  begin
      For j := 0 To High(IDs) do
      begin
        If IDs[j].Num = LongWord(Index) Then
        begin
          S := S + '[ID:' + IDs[j].Str { + ',' + IntToStr(j)} + ']'#$A;
          break;
        end;
      end;
  end;
begin
  If Ver = 3 Then
  begin
    Ptr := Ptrs;
    Inc(Ptr, (Count + 1) * LangID + 1);
    For i := 0 To Count - 1 do
    begin
      Len := Endian(Ptr^);
      P := PLongWord(LongWord(TextPtr) + LongWord(Len));
      Len := Endian(P^);
      Inc(P);
      //Len := WideCharToMultiByte(CP_UTF8, 0, strbuf, Length(strbuf), P, cBufferSize - (LongWord(SPtr) - LongWord(Buf)), nil, nil);
      Len := MultiByteToWideChar(CP_UTF8, 0, PChar(P), Len, @wstrbuf, Length(wstrbuf));
      wstrbuf[Len] := #0;
      S := '';
      SetID(S, i);
      Text.Parent.AddString(S + wstrbuf);
      Inc(Ptr);
    end;
  end else
  If Ver = 1 Then
  begin
    LangRec := Ptrs;
    Inc(LangRec, LangID);
    TextPtr := Pointer(LongWord(TextPtr) + Endian(LangRec^.Offset));
    Ptr := TextPtr;
    For i := 0 To Count - 1 do
    begin
      W := Pointer(LongWord(TextPtr) + Endian(Ptr^));
      Len := 0;
      While W^ <> #0 do
      begin
        wstrbuf[Len] := EndianC(W^);
        Inc(Len);
        Inc(W);
      end;
      wstrbuf[Len] := #0;
      S := '';
      SetID(S, i);  
      Text.Parent.AddString(S + wstrbuf);
      Inc(Ptr);
    end;
  end;
end;

Procedure ExtractFile(FileName: String; LangStr: String; Text: TGameTextSet);
var
  Buf: Pointer; Size: Integer; F: File; Header: ^THeader; IdHeader: ^TIdHeader; IDs: TIdRecArray;
  Ptr: PLongWord; Item: TGameText; i, Len: Integer; Ver: Integer; IdOffset, IdCount: LongWord;
  LangID: Integer;
begin
  LangID := 0;

  if LangStr = 'JAPN' then
    LangId := 1
  else if LangStr = 'GERM' then   
    LangId := 2
  else if LangStr = 'FREN' then
    LangId := 3
  else if LangStr = 'SPAN' then
    LangId := 4
  else if LangStr = 'ITAL' then
    LangId := 5;

  AssignFile(F, FileName);
  Reset(F, 1);
  Size := FileSize(F);
  GetMem(Buf, Size);
  Seek(F, 0);
  BlockRead(F, Buf^, Size);
  CloseFile(F);

  FileName := ExtractFileName(FileName);
  SetLength(FileName, 16);
  Header := Buf;

  Ver := Endian(Header^.Version);

  IdOffset := 0;
  case Ver of
    1:
    begin
      IdHeader := Pointer(LongWord(Buf) + SizeOf(THeader) + SizeOf(TLangRec) * Endian(Header^.LangCount));
      IdOffset := SizeOf(THeader) + SizeOf(TLangRec) * Endian(Header^.LangCount) + SizeOf(TIdHeader);
    end;
    3:
    begin
      IdHeader := Pointer(LongWord(Buf) + SizeOf(THeader));
      Size := Endian(IdHeader^.IdSize) + SizeOf(THeader) + SizeOf(TIdHeader) + Endian(Header^.LangCount) * 4;
      IdOffset := SizeOf(THeader) + SizeOf(TIdHeader);
    end;
  end;

  Item := Text.AddItem(FileName);

  IdCount := Endian(IdHeader^.IdCount);
  If IdCount > 0 Then
  begin
    SetLength(IDs, IdCount);
    Item.UserData := IntToStr(IdCount);
    Ptr := PLongWord(LongWord(Buf) + IdOffset);
    For i := 0 to IdCount - 1 do
    begin
      Len := MultiByteToWideChar(CP_UTF8, 0, PChar(Buf) + IdOffset + Endian(Ptr^), -1, @wstrbuf, Length(wstrbuf));
      wstrbuf[Len] := #0;
      IDs[i].Str := wstrbuf;
      Inc(Ptr);
      IDs[i].Num := Endian(Ptr^);
      Inc(Ptr);
    end;
  end else
    Item.UserData := '0';

  Item.UserData := Item.UserData + ',' + IntToStr(Ver);
  Case Ver of
    1:  ExtractText(PChar(Buf) + SizeOf(THeader), PChar(Buf) + IdOffset + Endian(IdHeader.IdSize), Endian(Header^.Count), LangID, Item, IDs, Ver);
    3:  ExtractText(PChar(Buf) + Size, PChar(Buf) + Size + (Endian(Header^.Count) + 1) * Endian(Header^.LangCount) * 4, Endian(Header^.Count), LangID, Item, IDs, Ver);
  end;

  FreeMem(Buf);
end;

Procedure ExtractDirectory(Dir: String; LangStr: String; Text: TGameTextSet);
var SR: TSearchRec;
begin
  SetSlash(Dir);
  If FindFirst(Dir + '*.STRG', faAnyFile xor faDirectory, SR) = 0 Then
  begin
    repeat
      WriteLn('Extracting: ', SR.Name, '...');
      ExtractFile(Dir + SR.Name, LangStr, Text);
    until FindNext(SR) <> 0;
    SysUtils.FindClose(SR);
  end;

end;

Procedure SortIDs(var IDs: TIdRecArray);
var i, j: Integer; Tmp: TIdRec;
begin
  For i := 0 To High(IDs) do
  begin
    For j := i + 1 To High(IDs) do
    begin
      If CompareStr(IDs[i].Str, IDs[j].Str) > 0 Then
      begin
        Tmp := IDs[i];
        IDs[i] := IDs[j];
        IDs[j] := Tmp;
      end;
    end;
  end;
end;

Function BuildStrings(Text: TGameText; LangString: String; Data: Pointer): Integer;
var
  IdCount: Integer; IDs: TIdRecArray; i, k, j, n, TextLen, Ver, Pos: Integer;
  S: WideString; Ptrs, Lens: Array of LongWord; Len: PLongWord;
  TextSize, LangCount: LongWord; P: PChar; Ptr: PLongWord; LangRec: ^TLangRec;
  Header: THeader; IdHeader: TIdHeader; UserData: String;
begin
  TextLen := 0;

  k := 0;

  UserData := Text.UserData;
  Pos := PosEx(',', UserData, 1);
  If Pos <= 0 Then
    Ver := 3
  else
  begin
    Ver := StrToInt(MidStr(UserData, Pos + 1, Length(UserData) - Pos));
    SetLength(UserData, Pos - 1);
  end;
  IdCount := StrToInt(UserData);

  SetLength(IDs, IdCount);
  SetLength(Ptrs, Text.Count);
  SetLength(Lens, Text.Count); //

  If Ver = 3 Then
    Pos := 0
  else
    Pos := Text.Count * 4;

  
  Header.Signature := $21436587;
  Header.Version   := Endian(Ver);
  LangCount := Length(LangString) div 4;
  Header.LangCount := Endian(LangCount);
  Header.Count     := Endian(Text.Count);
  IdHeader.IdCount   := Endian(IdCount);

  For i := 0 To Text.Count - 1 do
  begin
    S := Text.Items[i].Strr;
    If Length(S) > 8 Then
    begin
      If (CompareMem(@S[1], @(WideString('[ID:')[1]), 8)) Then
      begin
        IDs[k].Num := i;
        j := 5;
        While S[j] <> WideChar(']') do Inc(j);
        Dec(j, 5);
        SetLength(IDs[k].Str, j);
        Move(S[5], IDs[k].Str[1], j * 2);
        Inc(j, 7);
        n := 1;
        While j <= Length(S) do
        begin
          S[n] := S[j];
          Inc(n);
          Inc(j);
        end;
        SetLength(S, n - 1);
        Inc(k);
      end;
    end;
               
    Ptrs[i] := Endian(Pos);
    If Ver = 3 Then
    begin
      For j := 0 To LangCount - 1 do  //
      begin                           //
        Len := @astrbuf[Pos];
        Inc(Pos, 4);
        Len^ := WideCharToMultiByte(CP_UTF8, 0, @S[1], Length(S) + 1, @astrbuf[Pos], Length(astrbuf) - Pos, nil, nil);
        Inc(Pos, Len^);
        If j = 0 Then
        begin
          Inc(TextLen, Len^);
          Lens[i] := Len^;
        end;
        Len^ := Endian(Len^);
      end;                            //
    end else
    begin
      //Move(S[1], astrbuf[Pos], (Length(S) + 1) * 2);
      For j := 1 To Length(S) do
      begin
        PWideChar(@astrbuf[Pos])^ := EndianC(S[j]);
        Inc(Pos, 2);
      end;        
      PWideChar(@astrbuf[Pos])^ := #0;
      Inc(Pos, 2);
      //Inc(Pos, (Length(S) + 1) * 2);
    end;
  end;
  If Ver = 1 Then
    Move(Ptrs[0], astrbuf[0], Length(Ptrs) * 4);

  TextSize := Pos;

  SortIDs(IDs);
  Pos := IdCount * 8;
  P := Data;
  If Ver = 3 Then
    Inc(P, SizeOf(Header) + SizeOf(IdHeader))
  else
    Inc(P, SizeOf(Header) + SizeOf(IdHeader) + LangCount * SizeOf(TLangRec));
  Ptr := PLongWord(P);
  Inc(P, Pos);

  For i := 0 To IdCount - 1 do
  begin
    Ptr^ := Endian(Pos);
    Inc(Ptr);
    Ptr^ := Endian(IDs[i].Num);
    Inc(Ptr);
    n := WideCharToMultiByte(CP_UTF8, 0, @IDs[i].Str[1], Length(IDs[i].Str) + 1, P, Length(IDs[i].Str) * 3 + 1, nil, nil);
    Inc(Pos, n);
    Inc(P, n);
  end;
  IdHeader.IdSize := Endian(Pos);
  Move(Header, Data^, SizeOf(Header));
  If Ver = 3 Then
    Move(IdHeader, Pointer(LongWord(Data) + SizeOf(Header))^, SizeOf(IdHeader))
  else
    Move(IdHeader, Pointer(LongWord(Data) + SizeOf(Header) + LangCount * SizeOf(TLangRec))^, SizeOf(IdHeader));

  If Ver = 3 Then
  begin
    Move(LangString[1], P^, Length(LangString) and $FFFFFFFC);
    Inc(P, Length(LangString) and $FFFFFFFC);
    For i := 0 To LangCount - 1 do
    begin
      PLongWord(P)^ := Endian(TextLen);
      Inc(P, 4);
      Move(Ptrs[0], P^, Length(Ptrs) * 4);
      Inc(P, Length(Ptrs) * 4);
      For j := 0 To High(Ptrs) do
        Ptrs[j] := Endian(Endian(Ptrs[j]) + Lens[j] + 4);
    end;
  end else
  begin
    LangRec := Pointer(LongWord(Data) + SizeOf(Header));
    For i := 0 To LangCount - 1 do
    begin
      Move(LangString[i * 4 + 1], LangRec^.LangStr, 4);
      LangRec^.Offset := 0;
      LangRec^.Size := Endian(TextSize);
      Inc(LangRec);
    end;
  end;

  Move(astrbuf[0], P^, TextSize);
  Result := TextSize + (LongWord(P) - LongWord(Data));
end;

Procedure BuildFiles(Text: TGameTextSet; LangString, OutDir: String);
var Size, i, Offset, Delim: Integer; Buf: Pointer; F: File; Names, FileName: String;
begin
  If OutDir[Length(OutDir)] <> '\' Then OutDir := OutDir + '\';
  GetMem(Buf, 1024 * 1024);
  For i := 0 To Text.Count - 1 do
  begin
    WriteLn('Building ', Text.Items[i].Name, '...');
    Size := BuildStrings(Text.Items[i], LangString, Buf);
    Names := Text.Items[i].Name;

    Offset := 1;
    While Offset < Length(Names) do
    begin
      Delim := PosEx('|', Names, Offset);
      If Delim <= 0 Then Delim := Length(Names) + 1;
      FileName := MidStr(Names, Offset, Delim - Offset);
      Offset := Delim + 1;
      AssignFile(F, OutDir + FileName + '.STRG');
      Rewrite(F, 1);
      BlockWrite(F, Buf^, Size);
      CloseFile(F);
    end;
  end;
  FreeMem(Buf);
end;

Procedure ExtractSame(LangStr, InFile, InDir, OutFile: String);
var Text, OutText: TGameTextSet; i: Integer; FileName: String;
begin
  Text := TGameTextSet.Create(@FCreateError);
  Text.LoadTextFromFile(InFile);
  SetSlash(InDir);

  OutText := TGameTextSet.Create(@FCreateError);
  For i := 0 to Text.Count - 1 do
  begin
    FileName := InDir + Text.Items[i].Name + '.STRG';
    Write(Text.Items[i].Name, '... ');
    If FileExists(FileName) Then
    begin
      ExtractFile(FileName, LangStr, OutText);
      WriteLn('yes');
    end else
      WriteLn('no');
  end;

  OutText.SaveTextToFile(OutFile);
  OutText.Free; 

  Text.Free;
end;

Procedure PrintUsage();
begin
  WriteLn('Metroid Prime 3: Corruption Text Convertor by HoRRoR_X');
  WriteLn('http://consolgames.ru/');
  WriteLn('Usage:');
  WriteLn(' -e <LangID> <InSTRG/Dir> <OutFile> - extract file/directory');
  WriteLn(' -b <InFile> <OutSTRGDir> [LangID] - build files');
  WriteLn(' -d <InDir> <File1> <File2> [File3 ... FileN] - remove/merge dublicate texts');
  WriteLn(' -es <LangID> <InFile> <InSTRGDir> <OutFile> - extract the same as in the input file');
  WriteLn('LangID: ENGL, JAPN, GERM, FREN, SPAN or ITAL.');
  WriteLn('');
end;

Function CompareTexts(const Text1, Text2: TGameText): Boolean;
var i: Integer;
begin
  Result := False;
  If Text1.Count <> Text2.Count Then Exit;
  For i := 0 To Text1.Count - 1 do
    If Text1.Items[i].Strr <> Text2.Items[i].Strr Then
      Exit;
  Result := True;
end;

Function CompareNames(const Name1, Name2: String): Boolean;   
type TStringArr = Array of String;
var Names1, Names2: TStringArr;

Procedure GetNames(const S: String; var Names: TStringArr);
var Offset, Delim: Integer;
begin
  Offset := 1;
    While Offset < Length(S) do
    begin
      Delim := PosEx('|', S, Offset);
      If Delim <= 0 Then Delim := Length(S) + 1;
      SetLength(Names, Length(Names) + 1);
      Names[High(Names)] := MidStr(S, Offset, Delim - Offset);
      Offset := Delim + 1;
    end;
end;

var i, j: Integer;
begin
  Result := True;

  GetNames(Name1, Names1);
  GetNames(Name2, Names2);
  For i := 0 To High(Names1) do
    For j := 0 To High(Names2) do
      If Names1[i] = Names2[j] Then
        Exit;

  Result := False;
end;

var Text, ModText, OrText: TGameTextSet;
  InFile, OutFile, InDir, OutDir, LangStr: String; i, j, n, m, k: Integer;
  TextFiles: Array of TGameTextSet; SR: TSearchRec;
begin

  If (ParamStr(1) = '-e') and (ParamCount >= 4) Then
  begin
    WriteLn('Extracting...');
    LangStr := ParamStr(2);
    InDir := ParamStr(3);
    OutFile := ParamStr(4);
    Text := TGameTextSet.Create(@FCreateError);
    If DirectoryExists(InDir) Then
      ExtractDirectory(InDir, LangStr, Text)
    else If FileExists(InDir) Then
      ExtractFile(InDir, LangStr, Text)
    else
    begin
      WriteLn('No input!');
      Text.Free;
      Exit;
    end;
    Text.SaveTextToFile(OutFile);
    Text.Free;               
    WriteLn('Done!');
  end else
  If (ParamStr(1) = '-b') and (ParamCount >= 3) Then
  begin
    InFile := ParamStr(2);
    OutDir := ParamStr(3);
    LangStr := ParamStr(4);
    If LangStr = '' Then LangStr := 'ENGLJAPNGERMFRENSPANITAL';
    SetSlash(OutDir);
    If not DirectoryExists(OutDir) Then
      ForceDirectories(OutDir);

    If DirectoryExists(InFile) Then
    begin
      InDir := InFile;
      SetSlash(InDir);
  
      If FindFirst(InDir + '*.txt', faAnyFile xor faDirectory, SR) = 0 Then
      begin
        repeat
          WriteLn('Building file: ', SR.Name, '...');
          Text := TGameTextSet.Create(@FCreateError);
          Text.LoadTextFromFile(InDir + SR.Name);
          BuildFiles(Text, LangStr, OutDir);
          Text.Free;
        until FindNext(SR) <> 0;
        SysUtils.FindClose(SR);
      end;
      
    end else
    begin
      Text := TGameTextSet.Create(@FCreateError);
      Text.LoadTextFromFile(InFile);
      BuildFiles(Text, LangStr, OutDir);
      Text.Free;
    end;
  end else
  If (ParamStr(1) = '-es') and (ParamCount >= 5) Then
  begin
    LangStr := ParamStr(2);
    InFile := ParamStr(3);
    InDir := ParamStr(4);
    OutFile := ParamStr(5);
    ExtractSame(LangStr, InFile, InDir, OutFile);
  end else

  // Import difference
  // For example - reformed_new.txt, translated_old.txt and original_old.txt
  // -id reformed_new.txt translated_old.txt original_old.txt
  // reformed_new.txt << translated_old.txt thats difference from original_old.txt
  If (ParamStr(1) = '-id') and (ParamCount >= 4) Then
  begin

    ModText := TGameTextSet.Create(@FCreateError);
    OrText := TGameTextSet.Create(@FCreateError);
    Text := TGameTextSet.Create(@FCreateError);

    Text.LoadTextFromFile(ParamStr(2));
    ModText.LoadTextFromFile(ParamStr(3));
    OrText.LoadTextFromFile(ParamStr(4));

    For i := 0 To Text.Count - 1 do
    begin
      For j := 0 To ModText.Count - 1 do
      begin
        If CompareNames(Text.Items[i].Name, ModText.Items[j].Name)
          and (Text.Items[i].Count = ModText.Items[j].Count) Then
        begin
          For n := 0 To OrText.Count - 1 do
          begin
            If CompareNames(ModText.Items[j].Name, OrText.Items[n].Name) Then
            begin
              If not CompareTexts(ModText.Items[j], OrText.Items[n]) Then
              begin
                For m := 0 To Text.Items[i].Count - 1 do
                  Text.Items[i].Items[m].Strr := ModText.Items[j].Items[m].Strr;
                break;
              end; 
              break;
            end;
          end;
        end;
      end;
    end;

    
    Text.SaveTextToFile(ParamStr(2));   

    ModText.Free;
    OrText.Free;
    Text.Free;

  end else
  If (ParamStr(1) = '-d') and (ParamCount >= 3) Then
  begin
    InDir := ParamStr(2);

    SetLength(TextFiles, ParamCount - 2);
    SetSlash(InDir);
    For i := 0 To High(TextFiles) do
    begin
      TextFiles[i] := TGameTextSet.Create(@FCreateError);
      InFile := ParamStr(i + 3);
      TextFiles[i].LoadTextFromFile(InDir + InFile); 
    end;

    For i := 0 To High(TextFiles) do
    begin
      WriteLn('Checking ', ParamStr(i + 3), '...');
      n := 0;
      While n < TextFiles[i].Count do
      begin
        For j := i To High(TextFiles) do
        begin
          If j = i Then
            m := n + 1
          else
            m := 0;
          While m < TextFiles[j].Count do
          begin
            If CompareNames(TextFiles[i].Items[n].Name, TextFiles[j].Items[m].Name) Then
            begin
              If TextFiles[i].Items[n].Count <> TextFiles[j].Items[m].Count Then
                  WriteLn(TextFiles[i].Items[n].Name, ' - different count in ', ParamStr(i + 3), ' and ', ParamStr(j + 3), '!');
              If TextFiles[i].Items[n].Count < TextFiles[j].Items[m].Count Then
              begin
                TextFiles[i].Items[n].UserData := TextFiles[j].Items[m].UserData;
                TextFiles[i].Items[n].SetCount(TextFiles[j].Items[m].Count);
                For k := 0 To TextFiles[j].Items[m].Count - 1 do
                  TextFiles[i].Items[n].Items[k].Strr := TextFiles[j].Items[m].Items[k].Strr;
              end;
              TextFiles[j].RemoveItem(m);
              Dec(m);
            end else
            If CompareTexts(TextFiles[i].Items[n], TextFiles[j].Items[m])
              and (TextFiles[i].Items[n].UserData = TextFiles[j].Items[m].UserData)
            Then
            begin
              //WriteLn(TextFiles[i].Items[n].Name, ' and ', TextFiles[j].Items[m].Name, ' from ', ParamStr(j + 3), ' merged.');
              TextFiles[i].Items[n].Name := TextFiles[i].Items[n].Name + '|' + TextFiles[j].Items[m].Name;
              TextFiles[j].RemoveItem(m);
              Dec(m);
            end;
            Inc(m);
          end;
        end;
        Inc(n);
      end;
    end;


    For i := 0 To High(TextFiles) do
    begin               
      OutFile := ParamStr(i + 3);
      TextFiles[i].SaveTextToFile(InDir + OutFile);
      TextFiles[i].Free;
    end;

  end else
    PrintUsage();



end.
