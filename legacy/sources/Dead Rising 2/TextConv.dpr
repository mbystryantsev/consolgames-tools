program TextConv;

{$APPTYPE CONSOLE}

uses
  SysUtils, Windows,
  TableText in '..\..\FFText\TableText.pas';

Type
  TLongWordArray = Array[Word] of LongWord;
  PLongWordArray = ^TLongWordArray;

Procedure Extract(Data: Pointer; Text: TGameText);
var IDs, Ptrs: PLongWordArray; Count, i: Integer; P: PChar;
  //astrbuf: Array[0..4095] of Char;
  wstrbuf: Array[0..4095] of WideChar;
begin
  Count := Integer(Data^);
  IDs := Pointer(LongWord(Data) + 4);
  Ptrs := Pointer(LongWord(Data) + 4 + 4 * Count);
  Text.SetCount(Count);
  For i := 0 To Count - 1 do
  begin
    P := PChar(LongWord(Data) + Ptrs^[i]);
    MultiByteToWideChar(CP_UTF8, 0, PChar(P), -1, @wstrbuf, Length(wstrbuf));
    Text.Items[i].Strr := '[' + IntToHex(IDs[i], 8) + ']'#10 + WideString(wstrbuf);
  end;

  //Len := MultiByteToWideChar(CP_UTF8, 0, PChar(P), Len, @wstrbuf, Length(wstrbuf));
end;

Function Build(Text: TGameText; Data: Pointer): Integer;   
var IDs, Ptrs: PLongWordArray; i, Len: Integer; P: PChar;
  //astrbuf: Array[0..4095] of WideChar;
  IdStr: WideString; Code: Integer;
begin
  SetLength(IdStr, 9);
  Integer(Data^) := Text.Count;
  IDs := Pointer(LongWord(Data) + 4);
  Ptrs := Pointer(LongWord(Data) + 4 + 4 * Text.Count);
  IdStr[1] := '$';
  P := PChar(LongWord(Ptrs) + 4 * Text.Count);
  For i := 0 To Text.Count - 1 do
  begin
    Move(Text.Items[i].Strr[2], IdStr[2], 16);
    Val(IdStr, IDs^[i], Code);
    If Code <> 0 Then WriteLn('Error converting id to int at item ', i);
    Ptrs^[i] := LongWord(P) - LongWord(Data);
    Len := WideCharToMultiByte(CP_UTF8, 0, @Text.Items[i].Strr[12], Length(Text.Items[i].Strr[12]) - 12, P, 4096, nil, nil);
    Inc(P, Len);
  end;
  Result := LongWord(P) - LongWord(Data);
end;

Procedure PringUsage();
begin
  WriteLn('TextConv for Dead Rising 2 by HoRRoR');
  WriteLn('http://consolgames.ru/');
  WriteLn('Usage:');
  WriteLn('  -e <BcsFile> <TextFile>');
  WriteLn('  -b <TextFile> <BcsFile>');
end;

var BinFile, TextFile: String; Text: TGameTextSet; Size: Integer;
F: File; Data: Pointer;
begin

  If ParamCount < 3 Then
  begin
    PringUsage();
    Exit;
  end;

  If ParamStr(1) = '-e' Then
  begin
    BinFile := ParamStr(2);
    TextFile := ParamStr(3);

    AssignFile(F, BinFile);
    Reset(F, 1);
    GetMem(Data, FileSize(F));
    BlockRead(F, Data^, FileSize(F));
    CloseFile(F);

    Text := TGameTextSet.Create;
    Extract(Data, Text.AddItem('main'));
    Text.SaveTextToFile(TextFile);
    Text.Free;
    FreeMem(Data);
    WriteLn('Done!');
  end else
  If ParamStr(1) = '-b' Then
  begin   
    BinFile := ParamStr(3);
    TextFile := ParamStr(2);


    GetMem(Data, 1024 * 1024 * 2);
    FillChar(Data^, $6BC89, 0);
    Text := TGameTextSet.Create;
    Text.LoadTextFromFile(TextFile);
    Size := Build(Text.Items[0], Data);
    If Size < $6BC89 Then
      Size := $6BC89
    else
      Size := $C0000;
    Text.Free;

    AssignFile(F, BinFile);
    Rewrite(F, 1);
    BlockWrite(F, Data^, Size);
    CloseFile(F);
    FreeMem(Data);
    WriteLn('Done!');
  end else
    PringUsage();
end.
 