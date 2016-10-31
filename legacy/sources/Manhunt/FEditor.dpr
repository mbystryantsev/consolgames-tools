program FEditor;

uses
  Forms,
  Font in 'Font.pas' {Form1},
  PSPRAW in 'PSPRAW.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
