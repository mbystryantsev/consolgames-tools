program TextEditor_FF;

uses
  Forms,
  TextEditor in 'TextEditor.pas' {Form1},
  TextView in 'TextView.pas' {Form2},
  FFTextView in 'FFTextView.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
