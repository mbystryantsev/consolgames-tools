program SH2FontEditor;

uses
  Forms,
  main in 'main.pas' {MainForm},
  FontProporties in 'FontProporties.pas' {PropForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Silent Hill 2 Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPropForm, PropForm);
  //Application.CreateForm(TSEFORM, SEFORM);
  Application.Run;
end.
