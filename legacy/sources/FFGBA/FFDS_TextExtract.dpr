program FFDS_TextExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows, GBAUnit,
  TableText in '..\FFText\TableText.pas';

Type
  DWord = LongWord;
  TTextHeader = Packed Record
    Sign:   Array[0..3] of Char;
    tagNull, tagOne: Word;
    Count: DWord;
    Unk:  Dword;
  end;
  TMsgRec = Packed Record
    ID:    DWord;
    tag01: Word;
    tagCC: Word;
    Offset: DWord;
  end;

  TArcHeader = Packed Record    
    Sign:   Array[0..3] of Char;
    Count:  Integer;
  end;
  TFileRec = Packed Record
    Offset: DWord;
    Size:   DWord;
    Name:   Array[0..31] of Char;
  end;



var
  BlockName: String;
  BlockIndex: Integer;

Procedure FCreateError(S: String; Level: TErrorType = etError);
const cLevelStr: Array[TErrorType] of String = ('***LOG: ','***HINT: ','***WARNING: ','***ERROR: ');
begin
  CharToOEM(PChar(S), @S[1]);
  WriteLn(cLevelStr[Level], S, ' [', BlockName, ', ', BlockIndex , ']');
end;

Procedure ExtractText(buf: Pointer; Text: TGameTextSet; Name: String);
var Header: ^TTextHeader; Rec: ^TMsgRec; n, ItemIndex: Integer;
begin
  BlockName := Name;
  Header := Buf;
  Rec := Pointer(DWord(Buf) + SizeOf(TTextHeader));
  Text.AddItem(Name, IntToHex(Rec^.ID, 8));
  ItemIndex := Text.Count - 1;

  Text.Items[ItemIndex].SetCount(Header^.Count);
  For n := 0 To Header^.Count - 1 do
  begin
    BlockIndex := n;
    Text.Items[ItemIndex].Items[n].Strr := WideFormat('[%6.6d]' + #10, [Rec^.ID]);
    Text.ExtractString(Pointer(DWord(Buf) + Rec^.Offset), Text.Items[ItemIndex].Items[n].Strr, 0, [0..255]);
    Inc(Rec);
  end;
end;

var
  Key, InFile, TableName, OutFile: String;
  PtrStart, Position, Code, n: Integer; Header: ^TArcHeader; Rec: ^TFileRec;
  Buf, tBuf, Ptr: Pointer; F: File; Text: TGameTextSet;
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

    If DWord(Buf^) = $4D415353 Then
    begin
      GetMem(tBuf, 1024*256);
      Header := Buf;
      Rec := Pointer(DWord(Buf) + SizeOf(TArcHeader));
      For n := 0 To Header^.Count - 1 do
      begin
        DWord(Ptr) := DWord(Buf) + Rec^.Offset + Header^.Count * SizeOf(TFileRec) + SizeOf(TArcHeader);
        If ExtractFileExt(Rec^.Name) = '.lz' Then
        begin
          Lz77Decompress(Ptr^, tBuf^);
          Ptr := tBuf;
          ExtractText(Ptr, Text, ChangeFileExt(Rec^.Name, ''));
        end else
          ExtractText(Ptr, Text, Rec^.Name);
        Inc(Rec);
      end;

      FreeMem(tBuf);
    end else
      ExtractText(Buf, Text, ExtractFileName(InFile));

    Text.SaveTextToFile(OutFile);
    FreeMem(Buf);
    Text.Free;
    WriteLn('Done!');
  end else
  If Key = '-b' Then
  begin
  {
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
  }
  end else
  begin
  end;
end.
