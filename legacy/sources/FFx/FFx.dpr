program FFx;

uses
  Forms,
  FFView in 'FFView.pas' {Form1},
  bmpfnt in 'BMPFnt.pas',
  MyClasses in 'MyClasses.pas',
  TextUnit in 'TextUnit.pas',
  DrawUnit in 'DrawUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FFx';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
