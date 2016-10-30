program WIN_TEST;

uses
  Forms,
  WinEditor in 'WinEditor.pas' {Form1},
  FF7_Common in 'FF7_Common.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
