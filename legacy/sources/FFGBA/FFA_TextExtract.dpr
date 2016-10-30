program FFA_TextExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows,
  TableText in '..\FFText\TableText.pas';

Type
  DWord = LongWord;
  TTextHeader = Packed Record
    Sigh:   Array[0..7] of Char;
    Lng:    Byte;
    CountL: Word;
    CountH: Byte;
    Size:   DWord;
  end;


var
  Key, InFile, TableName, OutFile: String;
  PtrStart, Position, Code, n: Integer; Header: ^TTextHeader;
  Buf: Pointer; F: File; Ptr: ^DWord; P: PByte; Text: TGameTextSet;

Procedure FCreateError(S: String; Level: TErrorType = etError);
const cLevelStr: Array[TErrorType] of String = ('***LOG: ','***HINT: ','***WARNING: ','***ERROR: ');
begin
  CharToOEM(PChar(S), @S[1]);
  WriteLn(cLevelStr[Level], S, ' [', n , ']');
end;

begin
  // <key> <InFile> <OutFile> <Table> [Position]
  //-e "2275 - Final Fantasy IV Advance (UA).gba" FF4.txt Tables\Table_Eng.tbl $2E3670
  //-b FF4.txt FF4.msg Tables\Table_Eng.tbl

  WriteLn('Final Fantasy Advance Text Extractor/Builder by HoRRoR');
  WriteLn('http://consolgames.ru/ :: horror.cg@gmail.com');

  Key := ParamStr(1);
  InFile := ParamStr(2);   
  OutFile := ParamStr(3);
  TableName := ParamStr(4);
  Val(ParamStr(5), Position, Code);
  If Code <> 0 Then
    Position := 0;

  If Key = '-e' Then
  begin
    WriteLn('Extracting...');
    Text := TGameTextSet.Create(@FCreateError);
    Text.LoadTable(TableName);
    Assign(F, InFile);
    Reset(F,1);
    GetMem(Buf, FileSize(F));
    BlockRead(F, Buf^, FileSize(F));
    CloseFile(F);

    Header := Pointer(DWord(Buf) + Position);
    Pointer(Ptr) := Header;
    Inc(Ptr, 4);
    Text.AddItem('Main');
    For n := 0 To Header^.CountL - 1 do
    begin
      Text.AddString(Pointer(DWord(Header) + Ptr^));
      Inc(Ptr);
    end;
    Text.SaveTextToFile(OutFile);
    FreeMem(Buf);
    Text.Free;
    WriteLn('Done!');
  end else
  If Key = '-b' Then
  begin       
    WriteLn('Building...'); 
    Text := TGameTextSet.Create(@FCreateError);
    Text.LoadTable(TableName);
    Text.LoadTextFromFile(InFile); 
    GetMem(Buf, 1024*1024);
    FillChar(Buf^, 1024*1024, 0);
    Header := Buf;
    Header^.Sigh := #0#0#0#0'TEXT';
    Header^.Lng := 1;
    Header^.CountL := Word(Text.Items[0].Count and $FFFF);
    Header^.CountH := Byte(Text.Items[0].Count SHR 16);   
    Pointer(Ptr) := Header;
    Inc(Ptr, 4);
    Pointer(P) := Ptr;
    Inc(P, Text.Items[0].Count * 4);
    For n := 0 To Text.Items[0].Count - 1 do
    begin
      Ptr^ := DWord(P) - DWord(Buf);
      Inc(Ptr);
      Text.ExportString(P, Text.Items[0].Strings[n], True);
    end;
    Header^.Size := DWord(P) - DWord(Buf);
    AssignFile(F, OutFile);
    Rewrite(F, 1);
    BlockWrite(F, Buf^, Header^.Size);
    CloseFile(F);
    Text.Free;
    WriteLn('Done!');
  end else
  begin
  end;
end.
