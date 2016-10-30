unit SEF;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, HexUnit, Dialogs;

type
  TSEFORM = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel: TBevel;
    StartEdit: TLabeledEdit;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    Function GetNumber: Integer;
  public
    Function Execute: Boolean;
    Function NewExecute(Capt, NC: String; Number: Integer): Boolean;
    property ResultNumber: Integer read GetNumber;
  end;

var
  SEFORM: TSEFORM;
  OkPressed: Boolean;

resourcestring
 SMUIntegerError = 'Неверное числовое значение.';

implementation

{$R *.dfm}

Function TSEFORM.Execute: Boolean;
begin
 ShowModal;
 Result := ModalResult = mrOk;
end;

Function TSEFORM.NewExecute(Capt, NC: String; Number: Integer): Boolean;
begin
 Caption := Capt;
 StartEdit.EditLabel.Caption := NC;
 StartEdit.Text := 'h' + IntToHex(Number, 1);
 ShowModal;
 Result := ModalResult = mrOk;
end;

procedure TSEFORM.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose := False;
 If OkPressed then
 begin
  OkPressed := False;
  If not UnsCheckOut(StartEdit.Text) then
   ShowMessage(SMUIntegerError) Else CanClose := True;
 end Else CanClose := True;
end;

procedure TSEFORM.OKBtnClick(Sender: TObject);
begin
 OkPressed := True;
end;

procedure TSEFORM.FormShow(Sender: TObject);
begin
 OkPressed := False;
 StartEdit.SetFocus;
end;

Function TSEFORM.GetNumber: Integer;
begin
 Result := GetLDW(StartEdit.Text);
end;

end.
