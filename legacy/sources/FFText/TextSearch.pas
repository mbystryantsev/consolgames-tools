unit TextSearch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TntStdCtrls, FF_TextEditor, TableText;

type
  TFindForm = class(TForm)
    eCurOnly: TCheckBox;
    eHidden: TCheckBox;
    eInstances: TCheckBox;
    eWholeWords: TCheckBox;
    eMatchCase: TCheckBox;
    eWrapAround: TCheckBox;
    eExtended: TCheckBox;
    bFind: TButton;
    bClose: TButton;
    GroupBox1: TGroupBox;
    eText: TTntEdit;
    GroupBox2: TGroupBox;
    eUp: TRadioButton;
    eDown: TRadioButton;
    eBeginEnd: TCheckBox;
    eOriginal: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bFindClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    Procedure FindText(var Str: WideString; out Options: TSearchOptions; out Pressed: Boolean);
  end;

var
  FindForm: TFindForm;
  FOptions: ^TSearchOptions;
  FSearchText: PWideString;
  FPressed: PBoolean;

implementation

{$R *.dfm}


procedure TFindForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    27: Close;
    13: bFindClick(nil);
  end;
end;

procedure TFindForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key in [#27, #13] Then Key := #0;
end;

procedure TFindForm.bFindClick(Sender: TObject);
begin
  If eText.Text = '' Then Exit;
  With FOptions^ do
  begin
    If soExtended Then           
      FSearchText^ := CppToString(eText.Text)
    else
      FSearchText^ := eText.Text;
    soOnlyCurItem     := eCurOnly.Checked;
    soFindInHidden    := eHidden.Checked;
    soFindInInstances := eInstances.Checked;
    soInOriginal      := eOriginal.Checked;
    soWholeWords      := eWholeWords.Checked;
    soMatchCase       := eMatchCase.Checked;
    soWrapAround      := eWrapAround.Checked;
    soExtended        := eExtended.Checked;
    soDirectionDown   := eDown.Checked;
    soBeginEnd        := eBeginEnd.Checked;
  end;
  FPressed^ := True;
  Close;
end;

Procedure TFindForm.FindText(var Str: WideString; out Options: TSearchOptions; out Pressed: Boolean);
begin
  FOptions := @Options;
  FSearchText := @Str;
  Pressed := False;
  FPressed := @Pressed;
  ShowModal;
end;

procedure TFindForm.FormShow(Sender: TObject);
begin
  eText.SetFocus;
  eText.SelectAll;
end;

procedure TFindForm.bCloseClick(Sender: TObject);
begin
  Close;
end;

end.
