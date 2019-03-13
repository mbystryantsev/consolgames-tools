program SHTDX;

uses
  Forms,
  TDXViewer in 'TDXViewer.pas' {Form1},
  {FontGim in 'FontGim.pas',}
  DIB_classic in 'DIB_classic.pas',
  PSPRAW in 'PSPRAW.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'TXD Viewer';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
