program PakTool;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  G3PakDef,
  PakUnit in 'PakUnit.pas';

Procedure PrintUsage();
begin
  WriteLn('Risen PakTool by HoRRoR');
  WriteLn('Usage: paktool.exe -e [keys] <PakFile> <OutDir>');
  WriteLn('       paktool.exe -b [keys] <InDir> <OutFile>');
  WriteLn('Keys:  -c - use compression');

end;

var
  n: Integer; S: String;
  Compression: Boolean = False;

begin
  For n := 2 To ParamCount do
  begin
    S := ParamStr(n);
    If S[1] = '-' Then
    begin
      Case S[2] of
        'c': Compression := True;
      end;
    end else
      Break;
  end;

  //Build('test', 'test.pak', True);
  //Exit;

  If ParamStr(1) = '-e' Then
  begin
  //Extract('strings-PC.pak', 'test');
    Extract(ParamStr(n), ParamStr(n + 1));
    WriteLn('Done!');
  end else
  If ParamStr(1) = '-b' Then
  begin
    Build(ParamStr(n), ParamStr(n + 1), Compression);
    WriteLn('Done!');
  end else
    PrintUsage;
  { TODO -oUser -cConsole Main : Insert code here }
end.
