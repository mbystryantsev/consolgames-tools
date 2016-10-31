program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {X};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TX, X);
  Application.Run;
end.
