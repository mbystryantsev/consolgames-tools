program RisenFont;

uses
  Forms,
  main in 'main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Risen Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
