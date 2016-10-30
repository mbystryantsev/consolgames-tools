program DATTEST;

uses
  Forms,
  DAT_TEST in 'DAT_TEST.pas' {Form1},
  FF7_DAT in 'FF7_DAT.pas',
  FF7_Compression in 'FF7_Compression.pas',
  FF7_Field in 'FF7_Field.pas',
  FF7_Window in 'FF7_Window.pas',
  ToCEditor in 'ToCEditor.pas' {ToCForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TToCForm, ToCForm);
  Application.Run;
end.
