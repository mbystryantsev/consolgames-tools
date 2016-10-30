unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, XPMan, ComCtrls;

type
  TForm1 = class(TForm)
    File1: TEdit;
    File2: TEdit;
    File3: TEdit;
    File4: TEdit;
    Button1: TButton;
    Memo: TMemo;
    List1: TListBox;
    List2: TListBox;
    XPManifest1: TXPManifest;
    GroupBox1: TGroupBox;
    Button2: TButton;
    AdrText: TEdit;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Label1: TLabel;
    PBar: TProgressBar;
    ODialog: TOpenDialog;
    SDialog: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure List2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2,Unit3;

{$R *.dfm}

Type
  TFlag = Record
    PrintLn: Boolean;
    Pos    : String;
    FlagLn : Boolean;
  end;

Type
  TBlock = Record
    Line   : Array of TStringList;
    R      : Array of TFlag;
    Count  : Integer;
    Adress : String;
    Flag   : Boolean;
    Print  : Boolean;
  end;






  {Type
  TOptBlock = Record
    Line   : Array of TStringList;
    Count  : Integer;
    Adress : String;
    Flag   : Boolean;
  end;}

Var Block: Array of TBlock;
Opt, Opt2: Boolean; OptID, OptID2: Integer;
{OptBlock: Array of TOptBlock;}

procedure TForm1.Button1Click(Sender: TObject);
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

Button1.Enabled:=False;
While not EoF(F1) do
begin
  Readln(F1,S);
  If (Length(S)>=2) and (S[1]+S[2]='//') then
  begin
  end else
  If LeftStr(S,2) = '@@' then
  begin
    Inc(BNum);
    SetLength(Block, BNum+1);
    Block[BNum].Count:=0;
    Block[BNum].Adress:=MidStr(S,3,17);
    //Block[BNum].Line[Block[BNum].Count] := TStringList.Create;
  end else
  begin
    If BNum>=0 then
    begin
      If S<>'' then
      begin
        If RFlag=False then
        begin
          Inc(Block[BNum].Count);
          SetLength(Block[BNum].Line, Block[BNum].Count);
          Block[BNum].Line[Block[BNum].Count-1]:=TStringList.Create;
          RFlag:=True;
        end;
        Block[BNum].Line[Block[BNum].Count-1].Add(S);
        If S[Length(S)]='\' then
        begin
          RFlag:=False;
        end;
      end else if (S='') and (RFlag=True) then
      begin
        Block[BNum].Line[Block[BNum].Count-1].Add(S);
      //begin
      end;
    //begin
    end;
  end;
end;
CloseFile(F1);
Button2.Enabled:=True;
For n:=0 to Length(Block)-1 do
begin
  List1.Items.Add(IntToStr(n+1)+' - '+Block[n].Line[0].Strings[0]);
end;
List1.ItemIndex:=0;
List1Click(Sender);

end;//!!

procedure TForm1.List1Click(Sender: TObject);
var n, cnt: integer;
begin
cnt:=0;
//GroupBox1.Caption:='Испытательный полигон ['+IntToStr(List1.ItemIndex)+'/'+IntToStr(List1.Items.Count)+']:';
GroupBox1.Caption:=format('Испытательный полигон [%d/%d]-[%d/%d]:',
[List1.ItemIndex+1,List1.Items.Count,List2.ItemIndex+1,List2.Items.Count]);
List2.Clear;
If Opt=False then
begin
  optID:=List1.ItemIndex;
end else
begin
  For n:=0 to Length(Block)-1 do
  begin
    if Block[n].Print=True then inc(cnt);
    if (cnt-1)=List1.ItemIndex then
    begin
      optID:=n;
      break;
    end;
  end;
end;
AdrText.Text:=Block[optID].Adress;

If opt2=False then
begin
  For n:=0 to Block[optID].Count-1 do
  begin
    List2.Items.Add(IntToStr(n+1)+' - '+Block[optID].Line[n].Strings[0]);
  end;
end else
  For n:=0 to Block[optID].Count-1 do
  begin
    If Block[OptID].R[n].PrintLn=True then
    begin
      List2.Items.Add(IntToStr(n+1)+' - '+Block[optID].Line[n].Strings[0]);
    end;
  end;
begin
end;

List2.ItemIndex:=0;
List2Click(Sender);

end;//!!

procedure TForm1.List2Click(Sender: TObject);
var n, cnt: integer;
begin

GroupBox1.Caption:=format('Испытательный полигон [%d/%d]-[%d/%d]:',
[List1.ItemIndex+1,List1.Items.Count,List2.ItemIndex+1,List2.Items.Count]);
Memo.Text:='';
cnt:=0;
//ShowMessage(IntToStr(Block[List1.ItemIndex].Line[List2.ItemIndex].Count));
If list2.ItemIndex>=0 then
begin
If opt2=False then
begin
  OptID2:=List2.ItemIndex;
end else
begin
  For n:=0 To Length(Block[optID].Line)-1 do
  begin
    If Block[optID].R[n].PrintLn=True then inc(cnt);
    If (cnt-1)=List2.ItemIndex then
    begin
      optID2:=n;
      Break;
    end;
  end;
end;

For n:=0 to Block[optID].Line[OptID2].Count-1 do
begin
  Memo.Lines.add(Block[optID].Line[OptID2].Strings[n]);
end;
end;
end;//!!

procedure TForm1.FormCreate(Sender: TObject);
begin
Memo.Text:='';
end;

procedure TForm1.Button2Click(Sender: TObject);
var n,l,d,m: integer; Flag: boolean;
begin
PBar.Min:=0;
PBar.Max:=Length(Block)-1;
Button2.Enabled:=False;
for n:=0 to length(Block)-1 do
begin
  PBar.Position:=n;
  if Block[n].Flag=false then
  begin
    Block[n].Flag:=True;
    Block[n].Print:=True;
    for l:=n+1 to length(Block)-1 do
    begin
      if Block[l].Flag=false then
      begin
        if length(Block[n].Line)=length(Block[l].Line) then
        begin
          flag:=True;
          for d:=0 to length(Block[n].Line)-1 do
          begin
            if Block[n].Line[d].Count=Block[l].Line[d].Count then
            begin
              for m:=0 to Block[n].Line[d].Count-1 do
              begin
                if Block[n].Line[d].Strings[m]<>Block[l].Line[d].Strings[m] then
                begin
                  Flag:=False;
                  break;
                end;
              end;
            end else
            begin
              Flag:=False;
            end;
            If Flag=False then break;
          end;
          if flag=true then
          begin
            Block[n].Adress:=Block[n].Adress+' '+Block[l].Adress;
            Block[l].Flag:=True;
            Block[l].Print:=False;
          end;
        end;
      end;
    end;
  end;
end;
Button3.Enabled:=True;
opt:=True;
List1.Clear;
List2.Clear;
Memo.Clear;
PBar.Position:=0;

For n:=0 to Length(Block)-1 do
begin
  if Block[n].Print=True then
  List1.Items.Add(IntToStr(n+1)+' - '+Block[n].Line[0].Strings[0]);
end;
List1.ItemIndex:=0;
List1Click(Sender);

end; //!!!

procedure TForm1.Button3Click(Sender: TObject);
var n,l,d,m,k,count,count2: integer; Flag: Boolean;
begin
Button3.Enabled:=False;
Count:=0;
For n:=0 To Length(Block)-1 do
begin
  SetLength(Block[n].R, Length(Block[n].Line));
end;

For n:=0 to length(Block)-1 do
begin
  PBar.Position:=n;
  {Label1.Caption:=IntToStr(n);
  Label1.Refresh;}
  if Block[n].Print=True then
  begin
    inc(Count);
    For l:=0 to length(Block[n].Line)-1 do
    begin

      If Block[n].R[l].FlagLn=False then
      begin
        Block[n].R[l].FlagLn:=True;
        Block[n].R[l].PrintLn:=True;
        //Count2:=0;
        //Flag:=True;
        For d:=n+1 to Length(Block)-1 do
        begin
          For m:=0 To Length(Block[d].Line)-1 do
          begin
            If Block[d].R[m].FlagLn=False then
            begin
              Flag:=True;
              If Block[n].Line[l].Count=Block[d].Line[m].Count then
              begin
                For k:=0 to Block[n].Line[l].Count-1 do
                begin
                  If Block[n].Line[l].Strings[k]<>Block[d].Line[m].Strings[k] then
                  begin
                    Flag:=False;
                    Break;
                  end else
                  begin
                  end;
                end;
              end else
              begin
                Flag:=False;
              end;
              If Flag=True then
              begin
                Block[d].R[m].PrintLn:=False;
                Block[d].R[m].FlagLn:=True;
                Block[d].R[m].Pos:=IntToHex(Count,4)+' '+IntToHex(l,4);
              end else
              begin
              end;
            end;
          end;
        end;
      end;


    end;
  end;
end;
Button4.Enabled:=True;
opt2:=True;
//List1.Clear;
//List2.Clear;
//Memo.Clear;
List1.ItemIndex:=0;
List1Click(Sender);
PBar.Position:=0;
end;//!!

procedure TForm1.Button4Click(Sender: TObject);
var n,l,d,cnt: Integer;
FT, FA, FI: TextFile;
begin
cnt:=0;
//---Сохранение текста---
AssignFile(FT, File2.Text);
Rewrite(FT);
For n:=0 to Length(Block)-1 do
begin
  If Block[n].Print=True then
  begin
    inc(cnt);
    WriteLn(FT, Format('@@%s - %d/%d (%d)',
    [LeftStr(Block[n].Adress,17), n, Length(Block), cnt ]));
    WriteLn(FT,'');
    For l:=0 To Length(Block[n].Line)-1 Do
    begin
      If Block[n].R[l].PrintLn=True then
      begin
        For d:=0 to Block[n].Line[l].Count-1 do
        begin
          WriteLn(FT, Block[n].Line[l].Strings[d]);
        end;
        WriteLn(FT,'');
      end;
    end;
  end;
end;
CloseFile(FT);

//Сохранение адресов блоков
AssignFile(FA, File3.Text);
Rewrite(FA);
For n:=0 to Length(Block)-1 do
begin
  If Block[n].Print=True then
  begin
    WriteLn(FA, Block[n].Adress);
  end;
end;
CloseFile(FA);

//Сохранение индексов диалогов
AssignFile(FI, File4.Text);
Rewrite(FI);
For n:=0 to Length(Block)-1 do
begin
  If Block[n].Print=True then
  begin
    WriteLn(FI, Format('@@%s - %d/%d (%d)',
    [LeftStr(Block[n].Adress,17), n, Length(Block), cnt ]));
    For l:=0 to Length(Block[n].Line)-1 do
    begin
      If Block[n].R[l].PrintLn=True then
      begin
        WriteLn(FI, 'Read');
      end else
      begin
        WriteLn(FI, Block[n].R[l].Pos);
      end;
    end;
    WriteLn(FI, '');
  end;
end;
CloseFile(FI);

end; //!!!

procedure TForm1.Button5Click(Sender: TObject);
begin
ODialog.Title:='Открытие скрипта FFT';
ODialog.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
If ODialog.Execute then
begin
  File1.Text:=ODialog.FileName;
end;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
SDialog.Title:='Сохранение оптимизированного скрипта FFT';
SDialog.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
If SDialog.Execute then
begin
  File2.Text:=SDialog.FileName;
end;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
SDialog.Title:='Сохранение адресов оптимизированного скрипта FFT';
SDialog.Filter:='Файлы адресов (*.adr)|*.adr|Все файлы (*.*)|*';
If SDialog.Execute then
begin
  File3.Text:=SDialog.FileName;
end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin 
SDialog.Title:='Сохранение индексов оптимизированного скрипта FFT';
SDialog.Filter:='Файлы индексов (*.fid)|*.fid|Все файлы (*.*)|*';
If SDialog.Execute then
begin
  File4.Text:=SDialog.FileName;
end;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var n,l: integer;
begin
For n:=0 to length(Block)-1 do
begin
  For l:=0 to length(Block[n].Line)-1 do
  begin
    if assigned(Block[n].Line[l]) then Block[n].Line[l].Free;
  end;
end;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
Form2.Show;
end;

end.
