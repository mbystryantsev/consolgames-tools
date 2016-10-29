unit FF8_Txt;

interface

uses TableText, Windows, SysUtils, FF8_Compression;

Type
  TProgressFunc = Function(Cur, Max: Integer; S: String): Boolean;

Procedure FF8_ExtractBattle(TableFile, SrcDir, OutPath: String; Progress: TProgressFunc = nil);
procedure FF8_ExtractFieldText(TableFile, SrcDir, OutPath: String; OneFile, Optimize: Boolean; Progress: TProgressFunc = nil);
procedure FF8_ExtractKernelText(TableFile, KernelFile, TextFile: String);
procedure FF8_BuildKernelText(TableFile, KernelFile, TextFile, OutKernel: String);
implementation

var
  ErrorProc: TCreateError = nil;

Type
  TKernelFile = Record
    BinID, TextID, Step, Count: Integer;
    Name: String;
  end;

const
  cKernelText: Array[0..24] of TKernelFile = (
    (BinID: 00; TextID: 31; Step: $08; Count: 2; Name: ''),
    (BinID: 01; TextID: 32; Step: $3C; Count: 2; Name: ''),
    (BinID: 02; TextID: 33; Step: $84; Count: 2; Name: ''),
    (BinID: 03; TextID: 34; Step: $14; Count: 1; Name: ''),
    (BinID: 04; TextID: 35; Step: $0C; Count: 1; Name: ''),
    (BinID: 05; TextID: 36; Step: $18; Count: 2; Name: ''),
    (BinID: 06; TextID: 37; Step: $24; Count: 1; Name: ''),
    (BinID: 07; TextID: 38; Step: $18; Count: 2; Name: ''),
    (BinID: 08; TextID: 39; Step: $18; Count: 2; Name: ''),
    (BinID: 09; TextID: 40; Step: $14; Count: 1; Name: ''),
    (BinID: 11; TextID: 41; Step: $08; Count: 2; Name: ''),
    (BinID: 12; TextID: 42; Step: $08; Count: 2; Name: ''),
    (BinID: 13; TextID: 43; Step: $08; Count: 2; Name: ''),
    (BinID: 14; TextID: 44; Step: $08; Count: 2; Name: ''),
    (BinID: 15; TextID: 45; Step: $08; Count: 2; Name: ''),
    (BinID: 16; TextID: 46; Step: $08; Count: 2; Name: ''),
    (BinID: 17; TextID: 47; Step: $08; Count: 2; Name: ''),
    (BinID: 18; TextID: 48; Step: $18; Count: 2; Name: ''),
    (BinID: 19; TextID: 49; Step: $10; Count: 2; Name: ''),
    (BinID: 21; TextID: 50; Step: $18; Count: 2; Name: ''),
    (BinID: 22; TextID: 51; Step: $20; Count: 2; Name: ''),
    (BinID: 24; TextID: 52; Step: $08; Count: 2; Name: ''),
    (BinID: 25; TextID: 53; Step: $14; Count: 1; Name: ''),
    (BinID: 28; TextID: 54; Step: $0C; Count: 1; Name: ''),
    (BinID: 30; TextID: 55; Step: $02; Count: 1; Name: '')
  );

procedure SetSlash(var S: String);
begin
  If (S <> '') and (S[Length(S)] <> '\') Then
    S := S + '\';
end;

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If R = 0 Then Exit;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;

Procedure LoadKernelText(Bin, Buf: Pointer; var Text: TGameTextSet;
  TextSize, BinSize: Integer; Step: Integer = 2; MsgCnt: Integer = 1);
var W: ^Word; n, m: Integer;
begin
  For m := 0 To (BinSize div Step) - 1 do
  begin
    W := Pointer(DWord(Bin) + (m * Step));
    For n := 0 To MsgCnt - 1 do
    begin
      If W^ = $FFFF Then
        Text.AddString('{NONE}')
      else
        Text.AddString(Pointer(DWord(Buf) + W^), TextSize - W^, [$00..$1F]);
      Inc(W);
    end;
  end;
end;

Function BuildKernelText(Bin, Buf: Pointer; var Text: TGameTextSet; ItemIndex: Integer;
  BinSize: Integer; Step: Integer = 2; MsgCnt: Integer = 1; Optimize: Boolean = True): Integer;
var
  W, WW: ^Word; n, m, i, Index: Integer; P: PByte; S: PWideString; Optimized: Boolean;
begin
  P := Buf;
  Index := 0;
  For m := 0 To (BinSize div Step) - 1 do
  begin
    W := Pointer(DWord(Bin) + (m * Step));
    For n := 0 To MsgCnt - 1 do
    begin
      S := @Text.Items[ItemIndex].Items[Index].Strr;
      If S^ = '{NONE}' Then
        W^ := $FFFF
      else
      begin
        Optimized := False;
        If Optimize Then
        begin
          i := -1;
          For i := 0 To Index - 1 do With Text.Items[ItemIndex].Items[i] do
            If S^ = Strr Then
              break;
          If (i > -1) and (i < Index) Then
          begin
            WW := Pointer(DWord(Bin) + (i div MsgCnt) * Step + (i mod MsgCnt) * 2);
            W^ := WW^;
            Optimized := True;
          end;
        end;
        If not Optimized Then
        begin                            
          W^ := DWord(P) - DWord(Buf);
          Text.ExportString(P, S^, True);
        end;
      end;
      Inc(W);
      Inc(Index);
    end;
  end;
  Result := DWord(P) - DWord(Buf);
end;
                                                                
Type
  TWordArray = Array[Word] of Integer;
procedure FF8_ExtractKernelText(TableFile, KernelFile, TextFile: String);
var
  F: File; A: ^TWordArray; n, _FileSize: Integer;
  CountPtr: ^Integer; Text: TGameTextSet; Buf: Pointer;
  Function GetSize(Index: Integer): Integer;
  begin
    If Index = CountPtr^ - 1 Then
      Result := _FileSize - A^[Index]
    else
      Result := A^[Index + 1] - A^[Index];
  end;
begin
  Text := TGameTextSet.Create(ErrorProc);
  Text.LoadTable(TableFile);
  AssignFile(F, KernelFile);
  Reset(F, 1);
  _FileSize := FileSize(F);
  GetMem(Buf, _FileSize);
  BlockRead(F, Buf^, _FileSize);
  CloseFile(F);
  A := Pointer(DWord(Buf) + 4);
  CountPtr := Buf;

  For n := 0 To High(cKernelText) do With cKernelText[n] do
  begin
    Text.AddItem('Kernel' + IntToStr(n));
    LoadKernelText(Pointer(DWord(Buf) + A^[BinID]), Pointer(DWord(Buf) + A^[TextID]),
      Text, GetSize(TextID), GetSize(BinID), Step, Count);
  end;
  FreeMem(Buf);
  //Text.OptimizeText(nil);
  Text.SaveTextToFile(TextFile);
  //Text.SaveOptimDataToFile(ChangeFileExt(TextFile, '.idx')); 
  Text.Free;
end;

procedure FF8_BuildKernelText(TableFile, KernelFile, TextFile, OutKernel: String);
var
  F: File; A: ^TWordArray; H: Array of Integer; n, Cur, Pos, _FileSize: Integer;
  CountPtr: ^Integer; Text: TGameTextSet; Buf: Pointer; P: PByte;
  TextBuf, BinBuf: Pointer; T: Array[0..55 - 21] of Pointer;
  Function GetSize(Index: Integer): Integer;
  begin
    If Index = CountPtr^ - 1 Then
      Result := _FileSize - A^[Index]
    else
      Result := A^[Index + 1] - A^[Index];
  end;
  procedure WriteFiles(Index: Integer);
  var n: Integer;
  begin
    n := Cur;
    For n := Cur To Index do
    begin
      H[n] := Pos;
      Seek(F, Pos);
      BlockWrite(F, Pointer(DWord(Buf) + A^[n])^, GetSize(n));
      Inc(Pos, RoundBy(GetSize(n), 4));
    end;
    Cur := n;
  end;
begin
  Text := TGameTextSet.Create(ErrorProc);
  Text.LoadTable(TableFile);
  Text.LoadTextFromFile(TextFile); 
  AssignFile(F, KernelFile);
  Reset(F, 1);
  _FileSize := FileSize(F);
  GetMem(Buf, _FileSize);
  BlockRead(F, Buf^, _FileSize);
  CloseFile(F);
  A := Pointer(DWord(Buf) + 4);
  CountPtr := Buf;
  Cur := 0;
  SetLength(H, CountPtr^);
  Pos := Length(H) * 4 + 4;

  AssignFile(F, OutKernel);
  Rewrite(F, 1);

  GetMem(TextBuf, 64 * 1024);
  FillChar(TextBuf^, 1024 * 64, 0);
  P := TextBuf;
  //GetMem(BinBuf, 64 * 1024);
  For n := 0 To High(cKernelText) do With cKernelText[n] do
  begin
    T[n] := P;
    Inc(P, RoundBy(BuildKernelText(Pointer(DWord(Buf) + A^[BinID]), P, Text, n,
      GetSize(BinID), Step, Count {}), 4));
    WriteFiles(BinID);
  end;
  WriteFiles(31 - 1);
  For n := 31 To 55 do
  begin
    H[n] := Pos;
    If n = 55 Then
      _FileSize := DWord(P) - DWord(T[n - 31])
    else
      _FileSize := DWord(T[n - 31 + 1]) - DWord(T[n - 31]);
    Inc(Pos, _FileSize);
    BlockWrite(F, T[n - 31]^, _FileSize);
    Seek(F, Pos);
  end;
  Seek(F, 0);
  BlockWrite(F, CountPtr^, 4);
  BlockWrite(F, H[0], Length(H) * 4);
  FreeMem(TextBuf);
  //FreeMem(BinBuf);
  FreeMem(Buf);
  //Text.OptimizeText(nil);
  //Text.SaveTextToFile(OutFile);
  //Text.SaveOptimDataToFile(ChangeFileExt(TextFile, '.idx')); 
  Text.Free;
end;
Procedure FF8_LoadText(Buf: Pointer; var Text: TGameTextSet; Size: Integer;
  BinHeader: Pointer = nil; HdrCount: Boolean = False; IntPtrs: Boolean = True);
var n, Count: Integer; Ptr: ^DWord; PtrAnd: DWord; P: Pointer; _Size, Step: Integer;
begin    
  If BinHeader <> nil Then
    P := BinHeader
  else
    P := Buf;
  Ptr := P;
  If IntPtrs Then
  begin
    Step := 4;
    PtrAnd := $FFFFFFFF;
  end else     
  begin         
    Step := 2;
    PtrAnd := $FFFF;
  end;
  If HdrCount Then
  begin
    Count := Ptr^ and $FFFF;
    Inc(DWord(Ptr), 2);
  end else
  begin
    If BinHeader <> nil Then
      Count := Size div Step
    else
      Count := (Ptr^ and PtrAnd) div Step;
  end;
  For n:=0 To Count - 1 do
  begin
    If BinHeader <> nil Then
      _Size := 0
    else
      _Size := Size - (Ptr^ and PtrAnd);
    Text.AddString(Pointer(DWord(Buf) + (Ptr^ and PtrAnd)), _Size, [3..6,9]);
    Inc(DWord(Ptr), Step);
  end;
end;

Type
  TDatData = Array[0..11] of DWord;
Function FF8_ExtractFieldFile(Folder: String; var Text: TGameTextSet; P: TProgressFunc = NIL): Integer;
var
  SR: TSearchRec; {DAT: TFF8Dat;} n: Integer; Cancel, Compressed: Boolean;
  Buf, tBuf: Pointer; F: File; Size, Offset: Integer; Data: ^TDatData;
const
  cIgnore: Array[0..19] of String = (
    'test8', 'testbl13', 'testmv', 'testno', 'gdsand2', 'glclub3',  // hlam
    'laguna01', 'laguna02', 'laguna03', 'laguna04', 'laguna05', 'laguna06',
    'laguna07', 'laguna08', 'laguna09', 'laguna10', 'laguna11', 'laguna12',
    'laguna13', 'laguna14'//,
    //'bghoke_2' // hz o_O
  );
  TextIndex = 8;

  Function InBad(Name: String): Boolean;
  var n: Integer;
  begin
    Result:=True;
    For n:=0 To High(cIgnore) do If cIgnore[n] + '.dat' = Name Then Exit;
    Result:=False;
  end;

begin
  //Dat:=TFF8DAT.Create;
  Cancel := False;
  n := 0;
  If FindFirst(Folder+'\*.dat',  faAnyFile, SR) = 0 then
  begin
    GetMem(Buf, 512 * 1024);
    GetMem(tBuf, 64 * 1024);
    Repeat
      If (@P <> NIL) and P(n + 1, -1, SR.Name) Then Break;
      Inc(n);
      If InBad(SR.Name) Then continue;
      AssignFile(F, Folder + SR.Name);
      Reset(F, 1);
      //Size := FileSize(F);
      BlockRead(F, Size, 4);
      If Size <> FileSize(F) - 4 Then
      begin
        Seek(F, 0);
        BlockRead(F, Buf^, FileSize(F));
        //Compressed := False;
      end else
      begin
        BlockRead(F, tBuf^, Size);
        lzs_decompress(tBuf, Size, Buf, Size);
        //Compressed := True;
      end;
      CloseFile(F);
      Data := Buf;
      If Data^[0] and $FF000000 <> $80000000 Then Continue;
      If Data^[TextIndex] = Data^[TextIndex + 1] Then Continue;
      Offset := Data^[TextIndex] - Data^[0] + $30;
        Text.AddItem(ChangeFileExt(SR.Name, ''));
      FF8_LoadText(Pointer(DWord(Buf) + Offset), Text, Data^[TextIndex + 1] - Data^[TextIndex]);
    Until (FindNext(SR) <> 0);
    FindClose(SR);
  end;
  //Dat.Free;
end;

Procedure CreateError(const S: string; Level: TErrorType = etError);
begin
  WriteLn(S);
  ReadLn;
end;

procedure FF8_ExtractBattleFile(var Text: TGameTextSet; FileName: String);
var
  F: File; HdrBuf, Buf: Pointer;
  Count, NamePos, HeaderPos, TextPos, LastPos, FileType: Integer;
begin
  GetMem(Buf, 1024 * 128);
  AssignFile(F, FileName);
  Reset(F, 1);
  BlockRead(F, FileType, 4);
  If FileType <> 2 Then
  begin
    Seek(F, $1C);
    BlockRead(F, NamePos, 4);
    BlockRead(F, TextPos, 4);
    BlockRead(F, LastPos, 4);
    If TextPos > NamePos Then
    begin
      Seek(F, NamePos);
      BlockRead(F, Buf^, $18);
      Text.AddString(Buf, $18, [0..$1F]);
    end else
      Text.AddString('{NONE}');
    If LastPos > NamePos Then
    begin
      Seek(F, TextPos);
      BlockRead(F, Count, 4);
      If Count >= 3 Then
      begin
        Seek(F, TextPos + 8);
        BlockRead(F, HeaderPos, 4);
        BlockRead(F, NamePos,   4);
        If NamePos > HeaderPos Then
        begin
          GetMem(HdrBuf, 1024);
          Seek(F, TextPos + HeaderPos);
          BlockRead(F, HdrBuf^, NamePos - HeaderPos);
          BlockRead(F, Buf^,    LastPos - TextPos - NamePos);
          If Word(Pointer(DWord(HdrBuf) + (NamePos - HeaderPos) - 2)^) = 0 Then
            Dec(NamePos);
          FF8_LoadText(Buf, Text, NamePos - HeaderPos, HdrBuf, False, False);
          FreeMem(HdrBuf);
        end;
      end;
    end;
  end else
  begin
    BlockRead(F, NamePos, 4);
    Seek(F, NamePos);
    BlockRead(F, Buf^, 18);
    Text.AddString(Buf, $18, [0..$1F]); 
  end;
  //If LastPos > TextPos Then

  CloseFile(F);
  FreeMem(Buf);  
end;

Procedure FF8_ExtractBattle(TableFile, SrcDir, OutPath: String; Progress: TProgressFunc = nil);
var
  Text: TGameTextSet;
  SR:   TSearchRec;
begin
  Text := TGameTextSet.Create(@CreateError);
  Text.LoadTable(TableFile);
  SetSlash(SrcDir);
  If FindFirst(SrcDir + '\c0m???.dat',  faAnyFile xor faDirectory, SR) = 0 then
  begin
    Repeat
      If @Progress <> nil Then
        Progress(-1, -1, SR.Name);
      Text.AddItem(SR.Name); 
      FF8_ExtractBattleFile(Text, SrcDir + SR.Name);
    Until (FindNext(SR) <> 0);
    FindClose(SR);
  end;
  Text.SaveTextToFile(OutPath);
  Text.Free; 
end;

procedure FF8_ExtractFieldText(TableFile, SrcDir, OutPath: String; OneFile, Optimize: Boolean; Progress: TProgressFunc = nil);
var
  Text: TGameTextSet;
  SR: TSearchRec;
begin
  Text := TGameTextSet.Create(@CreateError);
  Text.LoadTable(TableFile);
  SetSlash(SrcDir);
  If not OneFile Then
    SetSlash(OutPath);


  If FindFirst(SrcDir + '\*',  faDirectory, SR) = 0 then
  begin
    Repeat
      If (SR.Name = '.') or (SR.Name = '..') Then Continue;
      If SR.Attr and faDirectory = 0 Then Continue;
      If (@Progress <> NIL) and Progress(-1, -1, SR.Name + '\') Then
        break;
      Try
        FF8_ExtractFieldFile(SrcDir + SR.Name + '\', Text, @Progress);
      except
        break;
      end;
      If not OneFile Then
      begin
        If Optimize Then
        begin
          If (@Progress <> NIL) Then Progress(-1, -1, 'Optimizing...');
          Text.OptimizeText();
          Text.SaveOptimDataToFile(OutPath + SR.Name + '.idx');
        end;
        Text.SaveTextToFile(OutPath + SR.Name + '.txt');
        Text.Clear;
      end;
    Until (FindNext(SR) <> 0);
    FindClose(SR);
  end;
  If OneFile Then
  begin
    If Optimize Then
    begin                      
      If (@Progress <> NIL) Then Progress(-1, -1, 'Optimizing...');
      Text.OptimizeText();
      Text.SaveOptimDataToFile(ChangeFileExt(OutPath, '.idx'));
    end;                                                       
    Text.SaveTextToFile(OutPath);
  end;

  Text.Free;
end;

{
Function FF8_InsertText(Text: TGameTextSet; ID: Integer; Buf: Pointer): Integer;
var n: Integer; Ptr: PSDWordArray; Pos: Word; B: PByte;
begin
  Ptr := Buf;
  Pos := Text.Items[ID].Count * 4;
  B := Buf;
  Inc(B, Pos);
  For n:=0 To Text.Items[ID].Count -1 do
  begin
    Ptr^[n] := Pos;
    Inc(Pos, Text.ExportString(B, Text.Strings(ID, n), True));
  end;
  Result:=Pos;
end;
}

end.