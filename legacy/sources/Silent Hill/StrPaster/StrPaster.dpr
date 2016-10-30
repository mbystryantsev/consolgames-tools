program StrPaster;

uses
  Forms,
  StrP in 'StrP.pas' {Form1},
  STR in '..\STR.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
