program PTest;

uses
  Forms,
  Test in 'Test.pas' {Form1},
  LNBPass in 'LNBPass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
