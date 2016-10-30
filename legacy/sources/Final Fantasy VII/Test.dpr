program Test;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Compression in 'Compression.pas',
  FF7_Text in 'FF7_Text.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
