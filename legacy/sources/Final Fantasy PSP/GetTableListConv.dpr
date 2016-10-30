program GetTableListConv;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes;

Var List: TStringList; n: Integer;
begin
 List := TStringList.Create;
 List.LoadFromFile('GetTable.lst');
 For n:=0 to List.Count-1 do
 begin
  List.Strings[n]:=List.Strings[n]+'\'+List.Strings[n]+'.FIF';
 end;
 List.SaveToFile('GetTable.lst');
 List.Free;
  { TODO -oUser -cConsole Main : Insert code here }
end.
 