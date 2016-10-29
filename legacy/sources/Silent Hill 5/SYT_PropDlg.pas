unit SYT_PropDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TPropForm = class(TForm)
    RadioPlatform: TRadioGroup;
    btnOK: TButton;
    btnCancel: TButton;
    RadioTexType: TRadioGroup;
    EditName: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FPlatform:  ^Integer;
    FTexType:   ^Integer;
    FTexName:   ^String;
    FSetted:    Boolean;
  public
    Function ShowPropSelect(var Plat, TexType: Integer; var TexName: String): Boolean;
  end;

var
  PropForm: TPropForm;

implementation

{$R *.dfm}

procedure TPropForm.FormCreate(Sender: TObject);
begin
  RadioPlatform.Buttons[2].Enabled := False;
end;

Function TPropForm.ShowPropSelect(var Plat, TexType: Integer; var TexName: String): Boolean;
begin
  FSetted := False;
  FPlatform := @Plat;
  FTexType  := @TexType;
  FTexName  := @TexName;
  
  EditName.Text := TexName;
  If Plat in    [0..1] Then
    RadioPlatform.ItemIndex := Plat
  else
    RadioPlatform.ItemIndex := 0;


  {If TexType in [0..3] Then
    RadioTexType.ItemIndex  := TexType
  else
    RadioTexType.ItemIndex  := 0;}
  RadioTexType.ItemIndex  := 0;
  Case TexType of
    0: RadioTexType.ItemIndex  := 0;
    1: RadioTexType.ItemIndex  := 1;
    3: RadioTexType.ItemIndex  := 2;
    5: RadioTexType.ItemIndex  := 3;
  end;

  ShowModal;
  Result := FSetted;
end;

procedure TPropForm.btnOKClick(Sender: TObject);
const cTexTypes: Array[0..3] of Integer = (0,1,3,5);
begin
  FTexType^  := cTexTypes[RadioTexType.ItemIndex];
  FPlatform^ := RadioPlatform.ItemIndex;
  FTexName^  := EditName.Text;
  FSetted    := True;
  Close;
end;

procedure TPropForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TPropForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
    13: btnOKClick(nil);
    27: Close;
  end;
end;

end.
