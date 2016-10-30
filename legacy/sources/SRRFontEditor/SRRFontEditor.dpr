program SRRFontEditor;

uses
  Forms,
  main in 'main.pas' {MainForm},
  SEF in 'SEF.pas' {SEFORM},
  GbaUnit in '..\GbaUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'The Simpsons Road Rage Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSEFORM, SEFORM);
  Application.Run;
end.
