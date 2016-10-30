program RomHaxxor;

uses
  Forms,
  RomHxr in 'RomHxr.pas' {MainForm},
  Errors in '..\DataPaster\img\Errors.pas' {ErrorForm},
  ValEdit in 'ValEdit.pas' {ValForm},
  HaxList in 'HaxList.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TValForm, ValForm);
  Application.Run;
end.
