program TextViewer;

uses
  Forms,
  TextView in 'TextView.pas' {MainForm},
  TableText in '..\..\FFText\TableText.pas',
  TextUnit in 'TextUnit.pas',
  ViewForm in 'ViewForm.pas' {FormView},
  FontUnit in 'FontUnit.pas',
  ViewUnit in 'ViewUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'MarioViewer';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFormView, FormView);
  Application.Run;
end.
