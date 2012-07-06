program FF8MIM;

uses
  Forms,
  FF8MIM_Main in 'FF8MIM_Main.pas' {MainForm},
  FF8_Mim in 'FF8_Mim.pas',
  FF8_compression in '..\FF8_compression.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FF8MIM';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
