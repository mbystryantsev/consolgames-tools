program OpenViewer;

uses
  Forms,
  OpenView in 'OpenView.pas' {Form1},
  FFT in '..\FFT\FFT.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
