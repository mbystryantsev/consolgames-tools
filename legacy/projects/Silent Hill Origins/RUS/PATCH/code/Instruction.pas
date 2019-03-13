unit Instruction;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Errors;

type
  TInstructionForm = class(TForm)
    Memo: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InstructionForm: TInstructionForm;

implementation

{$R *.dfm}

procedure TInstructionForm.FormCreate(Sender: TObject);
var Stream: TCustomMemoryStream;
begin
  Stream := TMemoryStream.Create;
  Try
    Stream := TResourceStream.Create(HInstance, 'INSTRUCTION', RT_RCDATA);
  except
    CreateError('Не могу загрузить инструкцию!');
  end;
  Memo.Lines.LoadFromStream(Stream);
  Stream.Free;
end;

end.
