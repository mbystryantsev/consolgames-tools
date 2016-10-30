unit StringProperties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TStrPropForm = class(TForm)
    GroupBox: TGroupBox;
    eRetry: TCheckBox;
    eRName: TEdit;
    LabelName: TLabel;
    eRIndex: TSpinEdit;
    LabelIndex: TLabel;
    bOK: TButton;
    bCancel: TButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bCancelClick(Sender: TObject);
    procedure eRetryClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure SetComboEnable(Enable: Boolean);
  private
    { Private declarations }
  public
    procedure GetProps;
  end;

var
  StrPropForm: TStrPropForm;

implementation

{$R *.dfm}


uses FF_TextEditor;

{ TStrPropForm }

procedure TStrPropForm.GetProps;
begin
  If Current.Item = nil Then
    Exit;
  With Current.Item.Items[Current.SelStr] do
  begin
    eRetry.Checked   := Retry;
    eRName.Text      := RName;
    eRIndex.Value    := RID;
    SetComboEnable(Retry);
  end;
  If eRIndex.Value < 0 Then
    eRIndex.Value := 0;
  If eRName.Text = '' Then
    eRName.Text := Current.Item.Name;
  ShowModal;
end;

procedure TStrPropForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key in [#27, #13] Then Key := #0;
end;

procedure TStrPropForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    27: Close;
    13: bOKClick(nil);
  end;
end;

procedure TStrPropForm.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TStrPropForm.eRetryClick(Sender: TObject);
begin
  SetComboEnable((Sender as TCheckBox).Checked);
end;

procedure TStrPropForm.bOKClick(Sender: TObject);
var Index, n, m: Integer;
begin
  If eRetry.Checked and (eRName.Text = '') Then
  begin
    MessageBox(0, 'Input item name!', 'Error!', MB_ICONERROR or MB_OK);
    Exit;
  end;
  Index := Current.Text.FindItem(eRName.Text);
  If eRetry.Checked and (Index = -1) Then
  begin
    MessageBox(0, PChar(Format('Item "%s" not found!', [eRName.Text])), 'Error!', MB_ICONERROR or MB_OK);
    Exit;
  end;
  If eRetry.Checked and ((eRIndex.Value < 0) or (eRIndex.Value >= Current.Item.Count)) Then
  begin
    MessageBox(0, 'Index out of bounds!', 'Error!', MB_ICONERROR or MB_OK);
    Exit;
  end;
  If (eRIndex.Value = Current.SelStr) and (eRName.Text = Current.Item.Name) Then
  begin
    MessageBox(0, 'Huh? Recursion?', 'Error!', MB_ICONERROR or MB_OK);
    Exit;
  end;
  If Current.Text.Items[Index].Retry[eRIndex.Value] Then
  begin
    With Current.Text.Items[Index].Items[eRIndex.Value] do
    begin
      eRName.Text   := RName;
      eRIndex.Value := RID;
      Index := Current.Text.FindItem(eRName.Text);
      If Index = -1 Then
      begin
        MessageBox(0, 'Relink error :(', 'Error!', MB_ICONERROR or MB_OK);
        Exit;
      end;
    end;
  end;
  With Current.Item.Items[Current.SelStr] do
  begin
    If Retry and not eRetry.Checked Then
      Current.Item.Unlink(Current.SelStr)
    else
    begin
      Retry := True;
      RID   := eRIndex.Value;
      RName := eRName.Text;
      For m := 0 To Current.Text.Count - 1 do
      begin
        For n := 0 To Current.Text.Items[m].Count - 1 do With Current.Text.Items[m] do
        begin
          If Items[n].Retry and (Items[n].RID = Current.SelStr) and (Items[n].RName = Current.Item.Name) Then
          begin
            Items[n].RID   := RID;
            Items[n].RName := RName;
          end;
        end;
      end;
    end;
  end;
  Close;
end;

procedure TStrPropForm.SetComboEnable(Enable: Boolean);
begin
  eRName.Enabled     := Enable;
  eRIndex.Enabled    := Enable;
  LabelName.Enabled  := Enable;
  LabelIndex.Enabled := Enable;
end;

end.
 