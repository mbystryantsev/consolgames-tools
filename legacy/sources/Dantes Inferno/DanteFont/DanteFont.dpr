program DanteFont;

uses
  Forms,
  main in 'main.pas' {MainForm},
  FontUnit in 'FontUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Dante''s Inferno Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
