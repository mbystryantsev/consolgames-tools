program Editor;

uses
  Forms,
  FF7_TextEditor in 'FF7_TextEditor.pas' {Form1},
  WinEditor in 'WinEditor.pas' {WForm},
  About in 'About.pas' {AboutForm},
  GZipMen in 'GZipMen.pas' {Form2},
  FF7_Image in 'FF7_Image.pas',
  BldDat in 'BldDat.pas' {Form3},
  BagReport in 'BagReport.pas' {ReportForm},
  ConvImg in 'ConvImg.pas' {ConvForm},
  ToCEditor in 'ToCEditor.pas' {ToCForm},
  FF8 in 'FF8.pas',
  FFT in 'FFT.pas',
  NewProject in 'NewProject.pas' {NewProjectForm},
  Errors in 'Errors.pas' {ErrorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FF7&8 Text Editor';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TWForm, WForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TBinForm, BinForm);
  Application.CreateForm(TBDForm, BDForm);
  Application.CreateForm(TReportForm, ReportForm);
  Application.CreateForm(TConvForm, ConvForm);
  Application.CreateForm(TToCForm, ToCForm);
  Application.CreateForm(TNewProjectForm, NewProjectForm);
  Application.CreateForm(TErrorForm, ErrorForm);
  WForm.Show;
  If ParamStr(1)='-debug' Then
  begin
    WForm.Hide;
    ToCForm.Show;
    Form1.ATOCEditor.Enabled:=True;
  end else Form1.Button2.Hide;
  //AboutForm.Show;
  //AboutForm.CreateParented(Form1.)
  Application.Run;
end.
