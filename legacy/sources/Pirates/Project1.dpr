program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  FF7_Common in '..\FF7\FF7_Common.pas',
  FF7_Compression in '..\FF7\FF7_Compression.pas',
  FF7_Text in '..\FF7\FF7_Text.pas',
  FF7_DAT in '..\FF7\FF7_Dat.pas',
  FF7_Field in '..\FF7\FF7_Field.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
