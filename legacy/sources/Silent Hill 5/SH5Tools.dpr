program SH5Tools;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  SH5Compression in 'SH5Compression.pas',
  SH5PAK in 'SH5PAK.pas',
  PakArc in 'PakArc.pas' {PakForm},
  SH5Common in 'SH5Common.pas',
  SH5_Syt in 'SH5_Syt.pas',
  SytViewer in 'SytViewer.pas' {SytForm},
  SH5_SYTGFX in 'SH5_SYTGFX.pas',
  ImFrame in 'ImFrame.pas' {ImageFrame: TFrame},
  Windows,
  SYT_PropDlg in 'SYT_PropDlg.pas' {PropForm},
  Errors in 'Errors.pas' {ErrorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPakForm, PakForm);
  Application.CreateForm(TSytForm, SytForm);
  Application.CreateForm(TPropForm, PropForm);
  Application.CreateForm(TErrorForm, ErrorForm);
  If ParamStr(1)='-debug' Then
  begin
    SytForm.Button1.Visible := True;
    PakForm.Button1.Visible := True;
    PakForm.Button2.Visible := True;  
    SytForm.Show;
    PakForm.Show;
  end;
  Application.Run;
end.
