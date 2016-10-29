program MarioFontEditor;

uses
  Forms,
  SysUtils, Windows,
  main in 'main.pas' {MainForm};

{$R *.res}

var
  ConsoleHandle, n: Cardinal;

begin
  // MarioFontEditor -i Fonts Rom
  If (ParamStr(1) = '-i') and (ParamCount = 3) Then
  begin
    If not FileExists(ParamStr(3)) Then Exit;
    If not LoadFont(ParamStr(2)) Then Exit;
    //ConsoleHandle :=  GetConsoleWindow();
    //ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    //If (ConsoleHandle = INVALID_HANDLE_VALUE)  or (ConsoleHandle = 0)  Then
    //begin
    //  AllocConsole();
    //  ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    //end;
    //WriteConsole(ConsoleHandle, PChar('Inserting font... '), Length('Inserting font... '), n, nil);
    AllocConsole();
    Write('Inserting fonts...');
    LoadFontFromRom(ParamStr(3), True);
    WriteLn(' done!');
    //WriteConsole(ConsoleHandle, PChar('done!'#10), Length('done!'#10), n, nil);
    Exit;
  end;
  Application.Initialize;
  Application.Title := 'Mario & Luidgy Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
