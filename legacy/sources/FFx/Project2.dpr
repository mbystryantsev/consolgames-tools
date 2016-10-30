program Project2;

uses
  Forms,
  FFView in 'FFView.pas' {Form1},
  bmpfnt in '..\..\C\BMPFnt.pas',
  MyClasses in '..\..\C\MyClasses.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FFx';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
