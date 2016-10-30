program PSPRawView;

uses
  Forms,
  PSPRawViewer in 'PSPRawViewer.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
