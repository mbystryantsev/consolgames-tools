unit ValEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, HaxList, StdCtrls, ExtCtrls, Errors;

type
  TValForm = class(TForm)
    eBigEndian: TCheckBox;
    eType: TRadioGroup;
    GroupBoxValue: TGroupBox;
    eValue: TEdit;
    GroupBoxNewValue: TGroupBox;
    eNewValue: TEdit;
    GroupBoxOffset: TGroupBox;
    eOffset: TEdit;
    bOK: TButton;
    bCancel: TButton;
    GroupBoxName: TGroupBox;
    eName: TEdit;
    procedure eOffsetKeyPress(Sender: TObject; var Key: Char);
    procedure bCancelClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure eTypeClick(Sender: TObject);
  private
    FValue: ^THaxValue;
    FResult: Boolean;
  public
    function EditValDialog(var Value: THaxValue; T: TValueType; Name{, ValText}: String; MaxType: TValueType = vtDWord): Boolean;
  end;

var
  ValForm: TValForm;

implementation

{$R *.dfm}

{ TValForm }

function TValForm.EditValDialog(var Value: THaxValue; T: TValueType; Name{, ValText}: String; MaxType: TValueType = vtDWord): Boolean;
var n: Integer;
begin
  FValue := @Value;
  eName.Text   := Name;

  eOffset.Text := IntToHex(Value.Offset, 8);
  Case Value.ValStat of
    vsOK:            eValue.Text := IntToHex(Value.Source, cTypeLen[Value.ValType]*2);
    vsInvalidOffset: eValue.Text := '-';
    vsUnknown:       eValue.Text := '?';
  end;
  //eValue.Text := ValText;

  eNewValue.Text := IntToHex(Value.Value, 8);
  eBigEndian.Checked := Value.BigEndian;

  For n := 0 To Integer(MaxType) do
    eType.Buttons[n].Enabled := True;
  For n := Integer(MaxType) + 1 To 2 do
    eType.Buttons[n].Enabled := False;
  eType.ItemIndex := Integer(T);

  ShowModal;
  Result := FResult;
end;

procedure TValForm.eOffsetKeyPress(Sender: TObject; var Key: Char);
begin
  If not (Key in [#0..#$1F, '0'..'9', 'a'..'f', 'A'..'F']) Then Key := #0;
end;

procedure TValForm.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TValForm.bOKClick(Sender: TObject);
var V,O,Code: DWord;
begin
  Val('$'+eNewValue.Text, V, Code);
  If Code <> 0 Then CreateError('Str->Int conv. error!');
  Val('$'+eOffset.Text, O, Code);
  If Code <> 0 Then CreateError('Str->Int conv. error!');


  FValue^.Name      := eName.Text;
  FValue^.ValType   := TValueType(eType.ItemIndex);
  Case FValue^.ValType of
    vtByte:  FValue^.Value := V and $FF;
    vtWord:  FValue^.Value := V and $FFFF;
    vtDWord: FValue^.Value := V;
  end;
  FValue^.BigEndian := eBigEndian.Checked;
  FValue^.Offset    := O;
  FResult := True;
  Close;
  //FList.Add(eName.Text, V, TValueType(eType.ItemIndex), eBigEndian.Checked);
end;

procedure TValForm.FormActivate(Sender: TObject);
begin
  eName.SetFocus;
  eName.SelectAll;
end;

procedure TValForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Case Key of
    #$1B: bCancelClick(bCancel);
    #$0D: bOKClick(bOK);
  end;
  If Key in [#$1B, #13] Then Key := #0;
end;

procedure TValForm.eTypeClick(Sender: TObject);
begin
  //eNewValue.MaxLength := cTypeLen[TValueType(eType.ItemIndex)];
end;

end.
