program SH2Text;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  TntClasses,
  TableText in '..\FFText\TableText.pas';

Type
  DWord = LongWord;
  TWordArray = Array[Word] of Word;
  PWordArray = ^TWordArray;

Procedure FCreateError(S: String; Level: TErrorType = etError);
const cLevelStr: Array[TErrorType] of String = ('***LOG: ','***HINT: ','***WARNING: ','***ERROR: ');
begin
  WriteLn(cLevelStr[Level] + S);
end;

Function OptimizeProgress(Cur, Max: Integer; S: String): Boolean;
begin
  WriteLn(Format('[%d/%d] %s', [Cur+1,Max,S]));
end;



Procedure ExtractText(Text: TGameTextSet; Buf: Pointer; Size: Integer);
var n: Integer; Ptrs: PWordArray; Count: Word; P: ^Word; Str: ^WideString;
begin
  Count := Word(Buf^);
  Ptrs := Pointer(DWord(Buf) + 2);
  For n := 0 To Count - 1 do
  begin
    P := Pointer((Ptrs^[n] SHL 1) + DWord(Buf));
    If (P^ = $8000) Then
      Inc(P)
    else
      ReadLn;


    Inc(DWord(P), Text.AddString(Pointer(P), Size - (Ptrs^[n] SHL 1){, [$E0..$FF]}));
    Str := @Text.Items[Text.Count - 1].Items[Text.Items[Text.Count - 1].Count - 1].Strr;
    If (DWord(P) - DWord(Buf)) mod 2 <> 0 Then Inc(DWord(P), 1);
    While P^ = $1000 do
    begin
      Inc(P, 2);
      Str^ := Str^ + #13#10'-'#13#10;
      Inc(DWord(P), Text.ExtractString(P, Str^, Size - (Ptrs^[n] SHL 1)));
      If (DWord(P) - DWord(Buf)) mod 2 <> 0 Then Inc(DWord(P));
    end;
    Case P^ of
      $8000: Text.Items[Text.Count - 1].UserData := Text.Items[Text.Count - 1].UserData + 'X';
      $9000: Text.Items[Text.Count - 1].UserData := Text.Items[Text.Count - 1].UserData + 'E';
      else
        Text.Items[Text.Count - 1].UserData := Text.Items[Text.Count - 1].UserData + '?';
    end;
  end;
end;


function ExportString(const Table: TTable; X: WideChar; var P: PByte; Text: WideString; AutoStop: Boolean = False): Integer;
var Len, DL, SL: Integer; C: PWideChar; SP: PByte;
const DEL: WideString = #10'-'#10;
begin
  Result := 0;
  If P = nil Then Exit;
  SP := P;

  Len := Length(Text);
  C   := @Text[1];

  While Len > 0 do
  begin
    If Len >= 3 Then
    begin
      If CompareMem(C, @DEL[1], 6) Then
      begin
        Word(Pointer(P)^) := $FFFF;
        Inc(P, 2);
        If (DWord(P) - DWord(SP)) mod 2 <> 0 Then
        begin
          P^ := 0;
          Inc(P);
        end;
        Word(Pointer(P)^) := $1000;
        Inc(P, 2);
        Word(Pointer(P)^) := $8000;
        Inc(P, 2);
        Dec(Len, 3);
        Inc(C, 3);

        Continue;
      end;
    end;

    SL := Table.GetElementData(C, P, Len, DL);
    Dec(Len, SL);
    If SL = 0 Then
    begin
      DL := Length(Table.NEData);
      If DL > 0 Then
        Move(Table.NEData[0], P^, DL);
      Inc(P, DL);
      FCreateError(Format('Unknown char: ''%s'' (wchar code: 0x%4.4x)',
         [WideCharLenToString(C, 1), Word(C)]), etWarning);
      Inc(C);
      Dec(Len);
    end;
    Inc(Result, DL);
  end;
  Word(Pointer(P)^) := $FFFF;
  Inc(P, 2); 
  If (DWord(P) - DWord(SP)) mod 2 <> 0 Then
  begin
    P^ := 0;
    Inc(P);
  end;
  Case X of
    'X': Word(Pointer(P)^) := $8000;
    'E': Word(Pointer(P)^) := $9000;
  else
    FCreateError(X + ': - unknown code!');
  end;
  Inc(P, 2);
end;

Function BuildText(Text: TGameTextSet; Buf: Pointer; ID: Integer): Integer;
var n: Integer; Ptrs: PWordArray; P: PByte;
begin
  Ptrs := Pointer(DWord(Buf) + 2);
  P := @Ptrs^[0];
  Inc(P, Text.Items[ID].Count * 2);

  Word(Buf^) := Text.Items[ID].Count;

  For n := 0 To Text.Items[ID].Count - 1 do
  begin
    Ptrs^[n] := (DWord(P) - DWord(Buf)) SHR 1;  
    Word(Pointer(P)^) := $8000;
    Inc(P, 2);
    ExportString(Text, Text.Items[ID].UserData[n + 1],  P, Text.Strings(ID,n), True);
    If (DWord(P) - DWord(Buf)) mod 2 <> 0 Then
    begin
      P^ := 0;
      Inc(P);
    end;
    //Word(Pointer(P)^) := $9000;
    //Inc(P, 2);
  end;
  Result := DWord(P) - DWord(Buf);
end;

Function IsInteger(const S: String): Boolean;
var n: Integer;
begin
  Result := False;
  If S = '' Then Exit;
  For n := 1 To Length(S) do
    If not (S[n] in ['0'..'9']) Then
      Exit;
  Result := True;
end;


const SLangID = 'e';

var MText, DText: TGameTextSet; SR: TSearchRec; Buf: Pointer; n,Size: Integer; F: File;
    List: TTntStringList; S: WideString; B: Byte; L, CL, DL, Code: Integer; P: PByte;
    A: Array[Byte] of Byte; C: PWideChar;
    MsgDir, TableFile, TextFile, OptFile: String;
//const
  //MsgDir       = 'Chrono\msg_original\big\';
  //ChMsgDir     = 'Chrono\rom_data\data\msg\big\';
  //TableFile    = 'Chrono\big.tbl';
  //RusTableFile = 'Chrono\big_rus.tbl';
  //OutputFile   = 'Chrono\big.txt';
  //DataFile     = 'Chrono\big_data.txt';
begin
//      0       1   2    3     4    5
// TextExtract key dir table text [opt]
// -b rom_data\data\msg\big\ big.tbl big.txt big.idx
// -e arc\data\etc\message tables\english.tbl test.txt

  MsgDir    := ParamStr(2);
  TableFile := ParamStr(3);
  TextFile  := ParamStr(4);
  OptFile   := ParamStr(5);

  If (MsgDir <> '') and (MsgDir[Length(MsgDir)] <> '\') Then
    MsgDir := MsgDir + '\';

  WriteLn('Silent Hill 2 text extractor/paster by HoRRoR <horror.cg@gmail.com>');
  WriteLn('http://consolgames.ru/');
  If (ParamStr(1) = '-b') and (ParamCount >= 4) Then
  begin
    MText := TGameTextSet.Create(@FCreateError);
    MText.LoadTable(TableFile);
    WriteLn('Table loaded!');
    If OptFile <> '' Then
    begin
      MText.LoadOptimDataFromFile(OptFile);
      WriteLn('Optimize data loaded!');
    end;
    MText.LoadTextFromFile(TextFile, OptFile <> '');
    WriteLn('Text loaded!');
    MText.NEData := MText.TableElement['?'];
    GetMem(Buf, 1024 * 1024);
    For n := 0 To MText.Count - 1 do
    begin
      WriteLn(Format('[%d/%d] %s',[n + 1, MText.Count, MText.Items[n].Name]));
      Size := BuildText(MText, Buf, n);
      AssignFile(F, MsgDir + MText.Items[n].Name);
      Rewrite(F, 1);
      BlockWrite(F, Buf^, Size);
      CloseFile(F);
    end;
    FreeMem(Buf);   
    MText.Free;
    WriteLn('Done!');
  end else
  If (ParamStr(1) = '-e') and (ParamCount >= 4) Then
  begin
    MText := TGameTextSet.Create(@FCreateError);
    MText.LoadTable(TableFile);
    If FindFirst(MsgDir + '*_' + SLangID + '.mes', faAnyFile XOR faDirectory, SR) <> 0 Then Exit;
    repeat
      WriteLn(SR.Name);
      MText.AddItem(SR.Name);
      AssignFile(F, MsgDir + SR.Name);
      Reset(F,1);
      Size := FileSize(F);
      GetMem(Buf, Size);
      BlockRead(F, Buf^, Size);
      CloseFile(F);
      ExtractText(MText, Buf, Size);
      FreeMem(Buf);
      //break;
    until FindNext(SR) <> 0;
    If OptFile <> '' Then
    begin
      WriteLn('Optimizing...');
      MText.OptimizeText(@OptimizeProgress);
      MText.SaveOptimDataToFile(OptFile);
    end;
    MText.SaveTextToFile(TextFile);
    MText.Free;
    WriteLn('Done!');
  end else
  begin
    WriteLn('Usage:');
    WriteLn('  TextExtract <key> <dir> <table> <text> [optimize_data]');
    WriteLn('');
    WriteLn('Keys:');
    WriteLn('  -e         - Extract text');
    WriteLn('  -b         - Build text files');
    WriteLn('');
    WriteLn('Dir          - directory with *.msg files');
    WriteLn('Table        - coding table with advanced features:');
    WriteLn('  - Unicode supported ;)');
    WriteLn('  - Directives:');
    WriteLn('    .format         - use cpp formatting string (\n, \t, etc)');
    WriteLn('    .normal         - use standard text format (default)');
    WriteLn('    .include <name> - include table file');
    WriteLn('  - Stop data must be defines as <data>!=<text>, for example - 02!=\0');
    WriteLn('Text - text file');
    WriteLn('Optimize data - if defined, the text will be optimized');
    WriteLn('                (All the duplicate strings will be removed)');
  end;
end.
