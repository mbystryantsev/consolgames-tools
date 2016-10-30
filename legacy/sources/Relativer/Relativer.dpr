program Relativer;

uses
  Forms,
  Relative in 'Relative.pas' {Form1},
  SR in 'SR.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Relativer by HoRRoR';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
