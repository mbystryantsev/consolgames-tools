program MsgList_ff;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes;

var F: TextFile;
Var List: TStringList; S: String;
begin
  GetDir(0,S);
  If FileExists(ParamStr(1)) then
  begin
    If FileExists('List.lst') then
    begin
      List := TStringList.Create;
      List.LoadFromFile(S+'\'+'List.lst');
      List.Add(ParamStr(1));
      List.SaveToFile(S+'\'+'List.lst');
      List.Free;
    end else
    begin
      Assign(F, S+'\'+'List.lst');
      Rewrite(F);
      WriteLn(F, ParamStr(1));
      CloseFile(F);
    end;

  end;
  { TODO -oUser -cConsole Main : Insert code here }
end.
 