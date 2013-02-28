program FontEditor;

uses
  Forms,
  Windows,
  main in 'main.pas' {MainForm},
  FontProporties in 'FontProporties.pas' {PropForm},
  CharProperties in 'CharProperties.pas' {CharPropForm};

{$R *.res}

//function AttachConsole(dwProcessId: DWORD):BOOL;
//stdcall; external 'kernel32.dll' name 'AttachConsole';

begin
  //GetWindowThreadProcessId(wnd, dwProcessID);
  Application.Initialize;
  Application.Title := 'Silent Hill 0rigins Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPropForm, PropForm);
  Application.CreateForm(TCharPropForm, CharPropForm);
  //Application.CreateForm(TSEFORM, SEFORM);
  Application.Run;
end.
