program AW2FontEditor;

uses
  Forms,
  main in 'main.pas' {MainForm},
  SEF in 'SEF.pas' {SEFORM};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Adwance Wars 2 Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSEFORM, SEFORM);
  Application.Run;
end.
