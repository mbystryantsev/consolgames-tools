unit Readme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Errors;

type
  TReadmeForm = class(TForm)
    Memo: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReadmeForm: TReadmeForm;

implementation

{$R *.dfm}

procedure TReadmeForm.FormCreate(Sender: TObject);
var Stream: TCustomMemoryStream;
begin
  Stream := TMemoryStream.Create;
  Try
    Stream := TResourceStream.Create(HInstance, 'README', RT_RCDATA);
  except
    CreateError('Не могу загрузить Readme.txt!');
  end;
  Memo.Lines.LoadFromStream(Stream);
  Stream.Free; 
end;

end.
