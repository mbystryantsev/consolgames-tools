program PassGen;

uses
  Forms,
  PGen in 'PGen.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'LNBPassGen';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
