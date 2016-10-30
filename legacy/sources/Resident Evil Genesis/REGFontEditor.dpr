program REGFontEditor;

uses
  Forms,
  main in 'main.pas' {MainForm},
  SEF in 'SEF.pas' {SEFORM};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Resident Evil Genesis Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSEFORM, SEFORM);
  Application.Run;
end.
