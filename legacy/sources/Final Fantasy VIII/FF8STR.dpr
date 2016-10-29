program FF8STR;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FF8_Str in 'FF8_Str.pas';

Function Progress(Cur, Max: Integer; S: String): Boolean;
begin
  If Cur = -1 Then
    WriteLn('*** ' + S)
  else
    Write(Format('Converting... %d%%'#13, [((Cur + 1) * 100) div Max]));
    //Write(Format(#13'[%d/%d] %s', [Cur+1, Max, S]));
end;

begin
  If ParamCount = 1 Then
    SMN2STR(ParamStr(1), ChangeFileExt(ParamStr(1), '.str'), @Progress)
  else
    SMN2STR(ParamStr(1), ParamStr(2), @Progress);
  WriteLn('Done!');
  { TODO -oUser -cConsole Main : Insert code here }
end.
