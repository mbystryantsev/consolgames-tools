program ExtraPaster;

{$APPTYPE CONSOLE}

uses
  SysUtils, System,
  EPaster in 'EPaster.pas';


var
  Paster: TExtraPaster; P: Pointer;
begin
  If not FileExists(ParamStr(1)) Then Exit;
  Paster := TExtraPaster.Create;
  //Paster.Execute('addspace 2E3670-323B64, 6DD8D0-7FFFFF');
  Paster.LoadScript(ParamStr(1));
  WriteLn('Inserting data...');
  If Paster.Run <> S_OK Then
    WriteLn('***Error in line ', Paster.ErrorLine, '! ', Paster.ErrorString)
  else
    WriteLn('Done!');
  Paster.Free;
end.
