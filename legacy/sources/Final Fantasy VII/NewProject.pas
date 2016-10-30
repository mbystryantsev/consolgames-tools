unit NewProject;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TNewProjectForm = class(TForm)
    StaticText1: TStaticText;
    ComboBox1: TComboBox;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Edit1: TEdit;
    Edit2: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewProjectForm: TNewProjectForm;

implementation

{$R *.dfm}

end.
