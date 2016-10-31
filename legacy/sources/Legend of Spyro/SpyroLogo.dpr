program SpyroLogo;

uses
  Forms,
  Spyro_Logo in 'Spyro_Logo.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
