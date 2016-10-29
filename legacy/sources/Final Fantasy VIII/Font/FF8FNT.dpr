program SERFontEditor;

uses
  Forms,
  main in 'main.pas' {MainForm},
  FontProporties in 'FontProporties.pas' {PropForm},
  FF8_compression in '..\FF8_compression.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Final Fantasy VIII Font Editor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPropForm, PropForm);
  //Application.CreateForm(TSEFORM, SEFORM);
  Application.Run;
end.
