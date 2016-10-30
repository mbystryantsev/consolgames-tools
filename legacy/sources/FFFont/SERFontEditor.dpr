program SERFontEditor;

uses
  Forms,
  main in 'main.pas' {MainForm},
  FontProporties in 'FontProporties.pas' {PropForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Square Enix Remakes Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPropForm, PropForm);
  //Application.CreateForm(TSEFORM, SEFORM);
  Application.Run;
end.
