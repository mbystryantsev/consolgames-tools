program TextEditor;

uses
  Forms,
  FF_TextEditor in 'FF_TextEditor.pas' {MainForm},
  TableText in 'TableText.pas',
  FFHighlighter in 'FFHighlighter.pas',
  Errors in 'Errors.pas' {ErrorForm},
  ItemProporties in 'ItemProporties.pas' {ItemPropForm},
  StringProperties in 'StringProperties.pas' {StrPropForm},
  TextSearch in 'TextSearch.pas' {FindForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TErrorForm, ErrorForm);
  Application.CreateForm(TItemPropForm, ItemPropForm);
  Application.CreateForm(TStrPropForm, StrPropForm);
  Application.CreateForm(TFindForm, FindForm);
  Application.Run;
end.
