program MGAExtractText;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  MGS in 'MGS.pas';

Procedure Progr(S: String);
begin
  WriteLn(S);
end;

var Text: TMGATextArray;
begin
  If ParamCount<3 Then Exit;
  ExtractAllText(Text,ParamStr(1),Progr);
  SaveText(Text,ParamStr(2));
  SaveList(Text,ParamStr(3));
  WriteLn('Complete!');
  { TODO -oUser -cConsole Main : Insert code here }
end.
