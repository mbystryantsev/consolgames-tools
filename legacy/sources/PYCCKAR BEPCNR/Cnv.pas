unit Cnv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var List, NewList: TStringList; n,m, Count: Integer; Flag: Boolean; S, L, R: String;
begin
  List := TStringList.Create;
  NewList := TStringList.Create;
  List.LoadFromFile('eng_base.txt');
  Count := 0;

  For n := 0 To List.Count - 1 do
  begin
    S := List.Strings[n];
    If S = '##' Then break;
    If S = '' Then Continue;
    L := '';
    R := '';
    Flag := False;
    For m := 1 To Length(S) do
    If Flag Then R := R + S[m] else
    if S[m] <> ' ' Then L := L + S[m] else
    Flag := True;
    For m := 1 To Length(L) do
      If L[m] = '_' Then L[m] := ' ';
    For m := 1 To Length(R) do
      If R[m] = '_' Then R[m] := ' ';
    If Length(L) < 5 Then Continue;
    NewList.Add(Format('    (Eng: ''%s'';'#9'Rus: ''%s''),', [L, R]));
    Inc(Count);
  end;

  S := NewList.Text;
  S[Length(S) - 2] := ' ';
  S := S + ');';
  Memo1.Text := Format('  Standard: Array[0..%d] of TStandard = (', [Count - 1]);
  Memo1.Lines.Add(S);
  Memo1.Lines.SaveToFile('dic.inc'); 
  NewList.Free;
  List.Free;
end;

end.
