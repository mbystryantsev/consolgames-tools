program CMIViewer;

uses
  Forms,
  CMIView in 'CMIView.pas' {Form1},
  CMIUnit in 'CMIUnit.pas',
  PSPRAW in 'PSPRAW.pas',
  CMIOpt,
  PrForm in 'PrForm.pas' {ProgressForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TProgressForm, ProgressForm);
  Application.Run;
end.
