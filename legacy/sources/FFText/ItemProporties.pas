unit ItemProporties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TntStdCtrls;

type
  TItemPropForm = class(TForm)
    gbName: TGroupBox;
    eName: TEdit;
    gbCaption: TGroupBox;
    eCaption: TTntEdit;
    gbFlags: TGroupBox;
    eHide: TCheckBox;
    eChecked: TCheckBox;
    bOK: TButton;
    bCancel: TButton;
    gbUserData: TGroupBox;
    eUserData: TTntEdit;
    procedure bCancelClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    Procedure GetProps;
  end;

var
  ItemPropForm: TItemPropForm;

implementation

{$R *.dfm}

uses FF_TextEditor;

{ TItemPropForm }

procedure TItemPropForm.GetProps;
begin
  With Current.Item do
  begin
    eName.Text       := Name;
    eCaption.Text    := Caption;
    eChecked.Checked := Checked;
    eHide.Checked    := Hidden;
    eUserData.Text   := UserData;
  end;
  ShowModal;
end;

procedure TItemPropForm.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TItemPropForm.bOKClick(Sender: TObject);
begin
  With Current.Item do
  begin
    Name      := eName.Text;
    Caption   := eCaption.Text;
    Checked   := eChecked.Checked;
    Hidden    := eHide.Checked;
    UserData  := eUserData.Text;
  end;
  Close;
end;

procedure TItemPropForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    27: Close;
    13: bOKClick(nil);
  end;
end;

procedure TItemPropForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key in [#27, #13] Then Key := #0;
end;

end.
