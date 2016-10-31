unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    file1: TEdit;
    Button2: TButton;
    adress: TEdit;
    file2: TEdit;
    TFile1: TEdit;
    TFile2: TEdit;
    TFile3: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

type
TStrSpyro = Record
  len: word;
  col: word;
  str: String;
end;

procedure TForm1.Button1Click(Sender: TObject);
var F: File; F2: TextFile;
Text: Array of TStrSpyro;
Col: Array of Word; len: Word;
Buffer: Pointer; Count,n,m,siz,fin,cnt: integer;
PtrW: ^word; //len, col: array of word;
pos, tpos: ^byte; PtrI: ^integer;
S: string;
begin

AssignFile(F, TFile1.text);
Reset(F,1);
GetMem(Buffer,FileSize(F));
BlockRead(F, Buffer^, FileSize(F));
CloseFile(F);
PtrI:=addr(buffer^); inc(PtrI,StrToInt(adress.Text) div 4);
Count:=PtrI^;
pos:=addr(buffer^); inc(pos,StrToInt(adress.Text));
inc(pos,4);
cnt:=0;
SetLength(Col,Count);
For n:=0 to Count-1 do
begin
PtrW:=addr(Pos^);
len:=PtrW^;
Inc(PtrW);
col[n]:=PtrW^;
fin:=(len and not $3) + $8;
inc(pos,fin);
end;
///-----///
AssignFile(F2, TFile3.Text);
Reset(F2);
AssignFile(F, TFile2.Text);
Reset(F,1);
BlockRead(F, Buffer^, FileSize(F));
//CloseFile(F);
pos:=addr(buffer^); inc(pos,StrToInt(adress.Text)+4);
While not eof(F2) do
begin
  readln(F2,S);
  PtrW:=Addr(pos^);
  PtrW^:=Length(S); inc(PtrW);
  PtrW^:=col[cnt];
  inc(pos,4);
  tpos:=addr(pos^);
  For n:=1 to length(S) do
  begin
    tpos^:=byte(S[n]);
    inc(tpos);
  end;
  for n:=0 to 7 do
  begin
    tpos^:=0;
    inc(tpos);
  end;
  fin:=(length(S) and not $3) + $8-4;
  inc(pos,fin);
  inc(cnt);
end;
CloseFile(F2);
///----///
//AssignFile(F,TFile2.Text);
Rewrite(F,1);
BlockWrite(F,Buffer^,16777216);
FreeMem(Buffer);
CloseFile(F);
end;

procedure TForm1.Button2Click(Sender: TObject);
var F: File; F2: TextFile;
Text: Array of TStrSpyro;
Buffer: Pointer; Count,n,m,siz,fin: integer;
PtrW: ^word; //len, col: array of word;
pos, tpos: ^byte; PtrI: ^integer;
begin

AssignFile(F, File1.text);
Reset(F,1);
GetMem(Buffer,FileSize(F));
BlockRead(F, Buffer^, FileSize(F));
PtrI:=addr(buffer^); inc(PtrI,StrToInt(adress.Text) div 4);
Count:=PtrI^;
pos:=addr(buffer^); inc(pos,StrToInt(adress.Text));
inc(pos,4);
SetLength(Text,Count);
//SetLength(Text.col,Count);
For n:=0 to Count-1 do
begin
PtrW:=addr(Pos^);
Text[n].len:=PtrW^;
Inc(PtrW);
Text[n].col:=PtrW^;
fin:=(Text[n].len and not $3) + $8;
tpos:=addr(pos^);
inc(tpos,4);
Text[n].str:='';
  For m:=0 to Text[n].len-1 do
  begin
    Text[n].str:=Text[n].str+chr(tpos^);
    inc(tpos);
  end;
inc(pos,fin);
//ShowMessage(Format('%d/%d:'+#13#10+'%s-%s: "%s"',
//[n+1,count,IntToHex(Text[n].len,4),IntToHex(Text[n].col,4),Text[n].str]));
end;
FreeMem(Buffer);
CloseFile(F);
AssignFile(F2, file2.text);
Rewrite(F2);
for n:=0 to Count-1 do
begin
  writeln(F2,Text[n].str);
end;
CloseFile(F2);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
OpenDialog1.Title:='Я опен диалого!';
OpenDialog1.Filter:='РОМы ГамеБойа (*.гба)|*.gba|Усё файло|*|';
If OpenDialog1.Execute then
begin
  tfile1.Text:=OpenDialog1.FileName;
end;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
OpenDialog1.Title:='Я опен диалого!';
OpenDialog1.Filter:='РОМы ГамеБойа (*.гба)|*.gba|Усё файло|*|';
If OpenDialog1.Execute then
begin
  tfile1.Text:=OpenDialog1.FileName;
end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
OpenDialog1.Title:='Я опен диалого!';
OpenDialog1.Filter:='Тексто файло (*.хз)|*.txt|Усё файло|*|';
If OpenDialog1.Execute then
begin
  tfile1.Text:=OpenDialog1.FileName;
end;
end;

end.
