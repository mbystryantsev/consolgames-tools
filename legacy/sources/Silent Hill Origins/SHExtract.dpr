program SHExtract;

{$APPTYPE CONSOLE}

uses
  SysUtils, SH0_ARC;

Procedure CreateError(S: String);
begin
  WriteLn(Format('***ERROR: %s',[S]));
end;

Procedure Progress(Cur, Max: Integer; S: String);
begin
  WriteLn(Format('[%d/%d] %s', [Cur + 1, Max, S]));
end;

var n: Integer;
  S, InFile, OutDir, ListFile: String;
  ListOnly: Boolean = False;
begin
  WriteLn('Silen Hill Origins ARC extractor v2.0 by HoRRoR <ho-rr-or@mail.ru>');
  WriteLn('http://consolgames.ru/');

  If ParamCount < 2 then
  begin
    WriteLn('Usage: [Keys] <InFile> <OutDir> [ListFile]');
    WriteLn('Keys:');
    WriteLn(' -l: List only without file extracting');
    Exit;
  end;
  For n := 1 To ParamCount do
  begin
    S := ParamStr(n);
    If S[1] <> '-' Then break;
    Case S[2] of
      'l', 'L': ListOnly := True;
    end;
  end;
  InFile := ParamStr(n);
  OutDir := ParamStr(n + 1);
  ListFile := ParamStr(n + 2);

  WriteLn('Extracting...');
  ARC_Extract(InFile, OutDir, ListFile, ListOnly, @Progress, @CreateError);
  WriteLn('Done!')

end.
