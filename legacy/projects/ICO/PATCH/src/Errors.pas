unit Errors;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TErrorForm = class(TForm)
    Memo: TMemo;
  private
    { Private declarations }
  public
    Procedure AddString(S: String; ShowForm: Boolean = True);
  end;

var
  ErrorForm: TErrorForm;

Procedure CreateError(S: String);
implementation

{$R *.dfm}

Procedure CreateError(S: String);
begin
  ErrorForm.AddString(Format('[Error] %s',[S]));
end;

Procedure TErrorForm.AddString(S: String; ShowForm: Boolean = True);
begin
  Memo.Lines.Add(S);
  If ShowForm Then Show;
end;

end.
