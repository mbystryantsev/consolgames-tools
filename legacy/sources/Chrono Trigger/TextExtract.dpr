program TextExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, TntClasses,
  TableText in '..\FFText\TableText.pas';

Type
  DWord = LongWord;
  TMsgCount = Array[0..2] of Byte;
  TChronoMsg = Packed Record
    Sign: Array[0..7] of Char;
    LangCount: Byte;
    Count:     TMsgCount;
    Size: Integer;
  end;
  TWordArray = Array[Word] of DWord;
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

Procedure ExtractText(Text: TGameTextSet; Buf: Pointer; LangID: Integer = 1);
var Header: ^TChronoMsg; n: Integer; Ptrs: PWordArray; Count: Integer;
begin
  Header := Buf;
  Ptrs := Pointer(DWord(Buf) + SizeOf(TChronoMsg));

  If LangID >= Header^.LangCount Then
    FCreateError('Lang ID is too big!', etWarning);

  n := LangID;
  Count := Integer(Addr(Header^.Count)^) and $FFFFFF;
  While n < Header^.LangCount * Count do
  begin
    Text.AddString(Pointer(Ptrs^[n] + DWord(Buf)), 0, [$80..$FF]);
    Inc(n,Header^.LangCount);
  end;
end;

Function BuildText(Text: TGameTextSet; Buf: Pointer; ID: Integer): Integer;
var Header: ^TChronoMsg; n: Integer; Ptrs: PWordArray; Count: Integer;
    P: PByte;
begin
  Header := Buf;
  Ptrs := Pointer(DWord(Buf) + SizeOf(TChronoMsg));
  P := @Ptrs^[0];
  Inc(P, Text.Items[ID].Count * 4 * 4);

  Integer(Addr(Header^.Count)^) := Text.Items[ID].Count;
  Header^.Sign := #0#0#0#0'TEXT';
  Header^.LangCount := 4;

  For n := 0 To Text.Items[ID].Count - 1 do
  begin
    Ptrs^[n * 4] := DWord(P) - DWord(Buf);
    Ptrs^[n * 4 + 2] := Ptrs^[n * 4];
    Text.ExportString(P, '', True);
    Ptrs^[n * 4 + 1] := DWord(P) - DWord(Buf);
    Ptrs^[n * 4 + 3] := Ptrs^[n * 4 + 1];
    Text.ExportString(P, Text.Strings(ID,n), True);
  end;
  Header^.Size := DWord(P) - DWord(Buf);
  Result := Header.Size;
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

var MText, DText: TGameTextSet; SR: TSearchRec; Buf: Pointer; n,Size: Integer; F: File;
    List: TTntStringList; S: WideString; B: Byte; L, CL, DL, LangID, Code: Integer; P: PByte;
    A: Array[Byte] of Byte; C: PWideChar;
    MsgDir, TableFile, TextFile, OptFile, SLangID: String;
//const
  //MsgDir       = 'msg_original\big\';
  //ChMsgDir     = 'rom_data\data\msg\big\';
  //TableFile    = 'big.tbl';
  //RusTableFile = 'big_rus.tbl';
  //OutputFile   = 'big.txt';
  //DataFile     = 'big_data.txt';
begin
//      0       1   2    3     4    5
// TextExtract key dir table text [opt]
// -b rom_data\data\msg\big\ big.tbl big.txt big.idx
// -e msg_original\small\ tables\small.tbl small.txt small.idx

  MsgDir    := ParamStr(2);
  TableFile := ParamStr(3);
  TextFile  := ParamStr(4);
  OptFile   := ParamStr(5);
  SLangID   := ParamStr(6);

  If (SLangID = '') and IsInteger(OptFile) Then
  begin
    SLangID := OptFile;
    OptFile := '';
  end;

  If (MsgDir <> '') and (MsgDir[Length(MsgDir)] <> '\') Then
    MsgDir := MsgDir + '\';

  WriteLn('Chrono Trigger text extractor/paster by HoRRoR <horror.cg@gmail.com>');
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
    If SLangID <> '' Then
    begin
      Val(SLangID, LangID, Code);
      If Code <> 0 Then
      begin
        FCreateError('Invalid Language ID!');
        Exit;
      end;
    end else 
      LangID := 1;


    MText := TGameTextSet.Create(@FCreateError);
    MText.LoadTable(TableFile);
    If FindFirst(MsgDir + '*.msg', faAnyFile XOR faDirectory, SR) <> 0 Then Exit;
    repeat
      WriteLn(SR.Name);
      MText.AddItem(SR.Name);
      AssignFile(F, MsgDir + SR.Name);
      Reset(F,1);
      Size := FileSize(F);
      GetMem(Buf, Size);
      BlockRead(F, Buf^, Size);
      CloseFile(F);
      ExtractText(MText, Buf, LangID);
      FreeMem(Buf);
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
    WriteLn('  TextExtract <key> <dir> <table> <text> [optimize_data] [Lang_ID]');
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
    WriteLn('Lang ID - language ID (default 1)');
  end;
end.
