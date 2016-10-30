program ICOPatch;

uses
  Forms,
  ICO_Patch in 'ICO_Patch.pas' {MainForm},
  Errors in 'Errors.pas' {ErrorForm},
  IPS_Patch in 'IPS_Patch.pas',
  Readme in 'Readme.pas' {ReadmeForm},
  Instruction in 'Instruction.pas' {InstructionForm},
  ICO_DF in 'ICO_DF.pas',
  Compression in 'Compression.pas',
  ICO_GZip in 'ICO_GZip.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'ICO Patch';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TReadmeForm, ReadmeForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.Run;
end.
