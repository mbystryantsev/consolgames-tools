unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils;

type
  TForm3 = class(TForm)
    List2: TListBox;
    //Memo1: TMemo;
    List1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    file2: TEdit;
    Button5: TButton;
    Button6: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton2: TRadioButton;
    chAll: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Button7: TButton;
    Button8: TButton;
    AdrText: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    OFile: TEdit;
    ODialog1: TOpenDialog;
    SDialog1: TSaveDialog;
    file1: TEdit;
    procedure Button2Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure List2Click(Sender: TObject);
    procedure chAllClick(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure AdrTextChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}
uses Unit1, Unit2;
Type
  TBlock = Record
    Line   : Array of TStringList;
    //R      : Array of TFlag;
    Count  : Integer;
    Adress : String;
    //Flag   : Boolean;
    //Print  : Boolean;
  end;

var Bl: Array of TBlock;
rFlag: Boolean;

procedure TForm3.Button2Click(Sender: TObject);
var F1: TextFile;
BNum, n: Integer;
S: String;
RFlag: Boolean;
begin
If not FileExists(file1.Text) then
begin
  beep;
  ShowMessage('Файла "'+file1.Text+'" не существует!');
  Exit;
end;
Button1.Enabled:=false;
AssignFile(F1, File1.Text); //Исходный текст
{AssignFile(F2, File2.Text); //Оптимизированный текст
AssignFile(F3, File3.Text); //Блоки
AssignFile(F4, File4.Text); //Диалоги  }
Reset(F1);
{Rewrite(F2);
Rewrite(F3);
Rewrite(F4);}
BNum:=-1;
RFlag:=False;

Button2.Enabled:=False;
File1.Enabled:=False;
Label1.Enabled:=false;
While not EoF(F1) do
begin
  Readln(F1,S);
  If (Length(S)>=2) and (S[1]+S[2]='//') then
  begin
  end else
  If LeftStr(S,2) = '@@' then
  begin
    Inc(BNum);
    SetLength(Bl, BNum+1);
    Bl[BNum].Count:=0;
    //Bl[BNum].Adress:=MidStr(S,3,17);
    Bl[BNum].Adress:=RightStr(S,length(S)-2);
    //Bl[BNum].Line[Bl[BNum].Count] := TStringList.Create;
  end else
  begin
    If BNum>=0 then
    begin
      If S<>'' then
      begin
        If RFlag=False then
        begin
          Inc(Bl[BNum].Count);
          SetLength(Bl[BNum].Line, Bl[BNum].Count);
          Bl[BNum].Line[Bl[BNum].Count-1]:=TStringList.Create;
          RFlag:=True;
        end;
        Bl[BNum].Line[Bl[BNum].Count-1].Add(S);
        If S[Length(S)]='\' then
        begin
          RFlag:=False;
        end;
      end else if (S='') and (RFlag=True) then
        Bl[BNum].Line[Bl[BNum].Count-1].Add(S);
      //begin
      //end;
    end;
  end;
end;

OFile.Text:=File1.Text;
CloseFile(F1);
List1.Enabled:=true;
AdrText.Enabled:=True;
Memo1.Enabled:=True;
Button3.Enabled:=True;
Button4.Enabled:=True;
chAll.Enabled:=true;
RadioButton2.Enabled:=True;
For n:=0 to Length(Bl)-1 do
begin
  if length(Bl[n].Line) >0 then
  begin
    List1.Items.Add(Format('%d - %s',[n+1,Bl[n].Line[0].Strings[0]]));
  end else
  begin
    List1.Items.Add(Format('%d - %s',[n+1,'<Пусто>']));
  end;
end;
List1.ItemIndex:=0;
List1Click(Sender);
end;

procedure TForm3.Memo1Change(Sender: TObject);

var F1, F2, F3, F4: TextFile;
n,id: Integer;
S: String;
RdFlag: Boolean;
begin
if rFlag= true then
begin
  Button3.Font.Size:=10;
  Button3.Font.Style:=[fsBold];
end;

id:=List1.ItemIndex;
if (rFlag=True) and (chAll.checked=True) then
begin

  for n:=0 to length(Bl[id].Line)-1 do
  begin
    Bl[id].Line[n].Free;
  end;

  Bl[id].Count:=0;
  RdFlag:=False;
  For n:=0 to Memo1.Lines.Count-1 do
  begin
    S:=Memo1.Lines.Strings[n];
    If (RdFlag=False) and (length(S)>0) then
    begin
      Inc(Bl[id].Count);
      SetLength(Bl[id].Line, Bl[id].Count);
      Bl[id].Line[Bl[id].Count-1]:=TStringList.Create;
      RdFlag:=True;
    end;
    if RdFlag=True then
    begin
      Bl[id].Line[Bl[id].Count-1].Add(S);
      If (Length(S)>0) and (S[Length(S)]='\') then
      begin
        RdFlag:=False;
      end;
    end;
  end;

  List2.Clear;
  For n:=0 to Length(Bl[id].Line)-1 do
  begin
    if length(Bl[n].Line) >0 then
    begin
      List2.Items.Add(Format('%d - %s',[n+1,Bl[id].Line[n].Strings[0]]));
    end else
    begin
      //List1.Items.Add(Format('%d - %s',[n+1,'<Пусто>']));
    end;
  end;
end else if rFlag=True then
begin
  Bl[id].Line[List2.ItemIndex].Clear;
  for n:=0 to memo1.Lines.Count-1 do
  begin
    Bl[id].Line[List2.ItemIndex].Add(Memo1.Lines.Strings[n]);
  end;
end;
end;//!!!

procedure TForm3.Button7Click(Sender: TObject);
begin
form1.Show;
end;

procedure TForm3.Button8Click(Sender: TObject);
begin
form2.Show;
end;

procedure TForm3.List1Click(Sender: TObject);
var n,m,id: integer; S: TStringList;
begin
GroupBox1.Caption:=Format('Текст [%d/%d] - [%d/%d]:',
[List1.ItemIndex+1,List1.Items.Count,List2.ItemIndex+1,List2.Items.Count]);
S:=TStringList.Create;
id:=list1.ItemIndex;
AdrText.Text :=Bl[id].Adress;
List2.Clear;
For n:=0 to Length(Bl[id].Line)-1 do
begin
  if length(Bl[n].Line) >0 then
  begin
    List2.Items.Add(Format('%d - %s',[n+1,Bl[id].Line[n].Strings[0]]));
  end else
  begin
    //List1.Items.Add(Format('%d - %s',[n+1,'<Пусто>']));
  end;
end;

if chAll.Checked=True then
begin
  rFlag:=False;
  id:=list1.ItemIndex;
  Memo1.Clear;
  For n:=0 to Length(Bl[id].Line)-1 do
  begin
    for m:=0 to Bl[id].Line[n].Count-1 do
    begin
      S.Add(Bl[id].line[n].Strings[m]);
    end;
    S.Add('');
  end;
  Memo1.Text:=S.Text;
end;
  rFlag:=True;
  S.Free;
end;//!!

procedure TForm3.List2Click(Sender: TObject);
var n,m,id: integer;
begin
GroupBox1.Caption:=Format('Текст [%d/%d] - [%d/%d]:',
[List1.ItemIndex+1,List1.Items.Count,List2.ItemIndex+1,List2.Items.Count]);
rFlag:=False;
id:=list1.ItemIndex;
if length(Bl[id].Line)>0 then
begin
  Memo1.Clear;
  for m:=0 to Bl[id].Line[List2.ItemIndex].Count-1 do
  begin
    Memo1.Lines.Add(Bl[id].line[List2.ItemIndex].Strings[m]);
  end;
end else
begin
  memo1.Clear;
end;
rFlag:=True;
end;//!!!

procedure TForm3.chAllClick(Sender: TObject);
begin
list2.Enabled:=false;
list1Click(Sender);
end;

procedure TForm3.RadioButton2Click(Sender: TObject);
begin
rFlag:=False;
list2.Enabled:=true;
if length(Bl[list1.ItemIndex].line)>0 then list2.ItemIndex:=0;
List2Click(Sender);
rFlag:=true;
end;

procedure TForm3.Button5Click(Sender: TObject);
var F: TextFile; S: String; TS: TStringList;
begin
If not FileExists(file2.Text) then
begin
  beep;
  ShowMessage('Файла "'+file2.Text+'" не существует!');
  Exit;
end;
TS:=TStringList.Create;
memo2.Clear;
AssignFile(F,file2.Text);
Reset(F);
while not eof(F) do
begin
  ReadLn(F,S);
  TS.Add(S);
end;
memo2.Text:=TS.text;
CloseFile(F);
TS.Free;
end;//!!!

procedure TForm3.AdrTextChange(Sender: TObject);
begin
Bl[List1.ItemIndex].Adress:=AdrText.Text;
end;

procedure TForm3.Button3Click(Sender: TObject);
var F: TextFile; n,m,l: integer;
begin
  AssignFile(F,OFile.Text);
  Rewrite(F);
  For n:=0 To length(Bl)-1 do
  begin
    WriteLn(F, '@@'+Bl[n].Adress);
    WriteLn(F, '');
    for m:=0 to length(Bl[n].Line)-1 do
    begin
      for l:=0 to Bl[n].Line[m].Count-1 do
      begin
        WriteLn(F, Bl[n].Line[m].Strings[l]);
      end;
      WriteLn(F, '');
    end;
  end;
  Button3.Font.Size:=8;
  Button3.Font.Style:=[];
  CloseFile(F);
end;

procedure TForm3.Button4Click(Sender: TObject);
begin
SDialog1.Title:='Сохранение скрипта FFT';
SDialog1.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
If SDialog1.Execute=True then
begin
  If SDialog1.FileName<>'' then
  begin
    OFile.Text:=SDialog1.FileName;
    Button3Click(Sender);
  end;
end;
end;//!!!

procedure TForm3.Button1Click(Sender: TObject);
begin
ODialog1.Title:='Открытие скрипта FFT';
ODialog1.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
If ODialog1.Execute=True then
begin
  if ODialog1.FileName <> '' then file1.Text:=ODialog1.FileName;
end;

end;//!!!
procedure TForm3.Button6Click(Sender: TObject);
begin
ODialog1.Title:='Открытие текстового файла';
ODialog1.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
If ODialog1.Execute=True then
begin
  if ODialog1.FileName <> '' then file2.Text:=ODialog1.FileName;
end;

end;//!!!

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
var n,m: integer;
begin
for n:=0 to length(Bl)-1 do
  for m:=0 to length(Bl[n].Line)-1 do
  begin
    If assigned(Bl[n].Line[m]) then Bl[n].Line[m].Free;
  end;
end;

procedure TForm3.FormActivate(Sender: TObject);
var n: Integer; Fl: Boolean;
begin
  //FFT\TEXT\WLDMES.OPT.TXT
  //FFT\TEXT\WLDMES.FID
  //FFT\FFTTable.tbl
  //FFT\TEXT\WLDMES.BIN


  //FFT\Out.opt.txt FFT\Out.opt.fid FFT\FFTTable.tbl FFT\TEST.EVT FFT\Out.opt.adr

  //FFT\Out.opt.txt
  //FFT\Out.opt.fid
  //FFT\FFTTable.tbl
  //FFT\TEST.EVT
  //FFT\Out.opt.adr

    If ParamCount>3 Then
    begin
      Fl:=True;
      Form2.Show;
      Form3.Close;
      //Form3.Hide;
      Form2.File1.Text:=ParamStr(1);
      Form2.File2.Text:=ParamStr(5);
      Form2.File3.Text:=ParamStr(2);
      Form2.File4.Text:=ParamStr(3);
      Form2.File5.Text:=ParamStr(4);
      Form2.cCompress.Checked:=False;
      Form2.cClearLog.Checked:=False;
      Form2.cBigOnly.Checked:=False;
      Form2.cIgnoreErrors.Checked:=False;
      For n:=6 to ParamCount do
      begin
          If ParamStr(n)='-c' Then Form2.cCompress.Checked:=True;
          If ParamStr(n)='-l' Then Form2.cClearLog.Checked:=True;
          If ParamStr(n)='-b' Then Form2.cBigOnly.Checked:=True;
          If ParamStr(n)='-i' Then Form2.cIgnoreErrors.Checked:=True;
          If ParamStr(n)='-DontClose' Then Fl:=False;
      end;
    Form2.Button1Click(Sender);
    Form2.Button2Click(Sender);
    Form2.Button3Click(Sender);
    //WriteLn('Completed!');
    If Fl Then Close;
    end;

end;


end.
