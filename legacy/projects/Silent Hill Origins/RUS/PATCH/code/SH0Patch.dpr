program SH0Patch;

uses
  Forms,
  SH0_Patch in 'SH0_Patch.pas' {MainForm},
  Errors in 'Errors.pas' {ErrorForm},
  IPS_Patch in 'IPS_Patch.pas',
  SH0_ARC in 'SH0_ARC.pas',
  Readme in 'Readme.pas' {ReadmeForm},
  Instruction in 'Instruction.pas' {InstructionForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SHO Patch';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TReadmeForm, ReadmeForm);
  Application.CreateForm(TInstructionForm, InstructionForm);
  Application.Run;
end.
