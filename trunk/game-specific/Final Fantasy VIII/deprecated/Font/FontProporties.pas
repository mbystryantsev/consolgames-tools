unit FontProporties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TPropForm = class(TForm)
    GroupBox3: TGroupBox;
    eCount: TSpinEdit;
    bOK: TButton;
    bCancel: TButton;
    eCompressed: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bCancelClick(Sender: TObject);
  private
    FLastBitCount: Integer;
    FResult: Boolean;
  public
    Function Show(Count: PInteger; Compressed: PBoolean): Boolean;
  end;

var
  PropForm: TPropForm;

implementation

{$R *.dfm}

var FCount: PInteger; FCompressed: PBoolean;

Function TPropForm.Show(Count: PInteger; Compressed: PBoolean): Boolean;
begin

  FResult := False;
  eCount.Value    := Count^;
  eCompressed.Checked := Compressed^;
  FCount := Count;
  FCompressed := Compressed;
  ShowModal;
  Result := FResult;
end;

procedure TPropForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  Caption := IntToHex(Key, 4);
  Case Key of
    $1B:  Close;
    $0D:  PropForm.bOKClick(nil); 
  end;
end;

procedure TPropForm.bOKClick(Sender: TObject);
begin
  FCompressed^ := eCompressed.Checked;
  FCount^  := eCount.Value;
  FResult := True;
  Close;
end;

procedure TPropForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then Key := #0;
end;

procedure TPropForm.bCancelClick(Sender: TObject);
begin
  Close;
end;

end.
