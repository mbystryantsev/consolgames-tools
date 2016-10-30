program FontEditor_ff;

uses
  Forms,
  FontEditor in 'FontEditor.pas' {Form1},
  FontBmp in 'FontBmp.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
