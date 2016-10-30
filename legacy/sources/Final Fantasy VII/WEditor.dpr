program WEditor;

uses
  Forms,
  WinEditor in 'WinEditor.pas' {WForm},
  FF7_Common in 'FF7_Common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TWForm, WForm);
  Application.Run;
end.
