program SH2TexEditor;

uses
  Forms,
  SysUtils,
  TexEditor in 'TexEditor.pas' {MainForm},
  SH2_TEX in 'SH2_TEX.pas',
  TIM2 in '..\..\Sources\TIM2.pas',
  PS2Textures in '..\..\Sources\PS2Textures.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  If (ParamStr(1) <> '') and FileExists(ParamStr(1)) Then
    MainForm.OpenTex(ParamStr(1)); 
  Application.Run;
end.
