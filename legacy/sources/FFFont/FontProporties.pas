unit FontProporties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TPropForm = class(TForm)
    GroupBox1: TGroupBox;
    eHeight: TSpinEdit;
    GroupBox2: TGroupBox;
    eBitCount: TSpinEdit;
    Label1: TLabel;
    GroupBox3: TGroupBox;
    eCount: TSpinEdit;
    Label2: TLabel;
    bOK: TButton;
    bCancel: TButton;
    procedure eBitCountChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bOKClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bCancelClick(Sender: TObject);
  private
    FLastBitCount: Integer;
    FResult: Boolean;
  public
    Function Show(Height, BitCount: PByte; CharCount: PWord): Boolean;
  end;

var
  PropForm: TPropForm;

implementation

{$R *.dfm}

var H, BPP: PByte; CC: PWord;

procedure TPropForm.eBitCountChange(Sender: TObject);
begin
  Case eBitCount.Value of
    0:     eBitCount.Value := 1;
    3:     If FLastBitCount <= 2 Then
             eBitCount.Value := 4
           else
             eBitCount.Value := 2;
    5,6,7: If FLastBitCount <= 4 Then
             eBitCount.Value := 8
           else
             eBitCount.Value := 4;
  end;
  FLastBitCount := eBitCount.Value;
end;

Function TPropForm.Show(Height, BitCount: PByte; CharCount: PWord): Boolean;
begin
  FResult := False;
  H   := Height;
  BPP := BitCount;
  CC  := CharCount;
  eHeight.Value   := H^;
  eBitCount.Value := BPP^;
  eCount.Value    := CC^;
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
  H^   := eHeight.Value;
  BPP^ := eBitCount.Value;
  CC^  := eCount.Value;
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
