unit CharProperties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, main;




type
  TCharPropForm = class(TForm)
    GroupBox1: TGroupBox;
    eCode: TEdit;
    bSelect: TButton;
    bOK: TButton;
    bCancel: TButton;
    procedure eCodeKeyPress(Sender: TObject; var Key: Char);
    procedure bSelectClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FResult: Boolean;
  public
    Function Show(var CharHeader: TCharRecord): Boolean;
  end;

var
  CharPropForm: TCharPropForm;

implementation

{$R *.dfm}

procedure TCharPropForm.eCodeKeyPress(Sender: TObject; var Key: Char);
begin
  If not (Key in ['0'..'9', 'A'..'F', 'a'..'f']) Then Key := #0;
end;

procedure TCharPropForm.bSelectClick(Sender: TObject);
var Key: Word; W: WideChar; Code: Integer; WS: WideString; S: String;
begin
  Val('$' + eCode.Text, Word(W), Code);
  S := InputBox('Input char...', '', W);
  If S = '' Then
    eCode.Text := '0000'
  else
  begin
    WS := S;
    eCode.Text := IntToHex(Word(WS[1]), 4);
  end;

end;

function TCharPropForm.Show(var CharHeader: TCharRecord): Boolean;
var Code: Integer;
begin
  FResult := False;
  eCode.Text := IntToHex(Word(CharHeader.Code), 4);
  ShowModal();
  Result := FResult;
  If Result Then
  begin
    Val('$' + eCode.Text, Word(CharHeader.Code), Code);
  end;
end;

procedure TCharPropForm.bCancelClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TCharPropForm.bOKClick(Sender: TObject);
begin
  FResult := True;
  Self.Close;
end;

procedure TCharPropForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    $1B:  Close;
    $0D:  bOKClick(nil);
    Byte('S'): bSelectClick(nil);
  end;
end;

procedure TCharPropForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 Then Key := #0;
end;

end.
