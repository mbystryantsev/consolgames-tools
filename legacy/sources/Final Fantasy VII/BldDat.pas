unit BldDat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, FF7_Common, StdCtrls, Buttons;

type
  TBDForm = class(TForm)
    Progress: TProgressBar;
    Panel: TPanel;
    bCancel: TBitBtn;
    procedure bCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BDForm: TBDForm;

implementation

{$R *.dfm}

procedure TBDForm.bCancelClick(Sender: TObject);
begin
  CancelPressed:=True;
end;

end.
