program RawTextConv;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  TableText in '..\FFText\TableText.pas';

var Text: TGameTextSet; F: File; Buf, P: PByte;
  Action: String;
  InFile: String;
  OutFile: String;
  TableFile: String;
  Size, n:     Integer;
begin

  WriteLn('RawTextConv by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');

  If ParamCount = 4 Then
  begin
    Action    := ParamStr(1);
    InFile    := ParamStr(2);
    OutFile   := ParamStr(3);
    TableFile := ParamStr(4);
  end;

  If Action = '-e' Then
  begin
    WriteLn('Extracting...');
    Text := TGameTextSet.Create;
    Text.LoadTable(TableFile);
    Text.AddItem(ExtractFileName(InFile));
    AssignFile(F, InFile);
    Reset(F, 1);
    Size := FileSize(F);
    GetMem(Buf, Size);
    P := Buf;
    BlockRead(F, Buf^, Size);
    CloseFile(F);
    While (LongWord(P) - LongWord(Buf)) < Size do
      Inc(P, Text.AddString(P, Size - (LongWord(P) - LongWord(Buf))));
    FreeMem(Buf);
    Text.SaveTextToFile(OutFile); 
    Text.Free;
    WriteLn('Done!');
  end else
  If Action = '-b' Then
  begin         
    WriteLn('Building...');       
    Text := TGameTextSet.Create;
    Text.LoadTable(TableFile);
    Text.LoadTextFromFile(InFile);
    GetMem(Buf, 1024*1024);
    P := Buf;
    For n := 0 To Text.Items[0].Count - 1 do
      Text.ExportString(P, Text.Items[0].Items[n].Strr, True);
    Size := LongWord(P) - LongWord(Buf);
    AssignFile(F, OutFile);
    Rewrite(F, 1);
    BlockWrite(F, Buf^, Size);
    CloseFile(F);
    FreeMem(Buf);
    Text.Free;                
    WriteLn('Done!');
  end else
  begin
    WriteLn('Usage: <key> <InFile> <OutFile> <TableFile>');
    WriteLn('Keys:');
    WriteLn(' -e: Extract text');
    WriteLn(' -b: Build file from text');
  end;
  { TODO -oUser -cConsole Main : Insert code here }
end.
