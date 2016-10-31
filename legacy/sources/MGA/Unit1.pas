unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, MGS, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    List: TListBox;
    Button4: TButton;
    Button5: TButton;
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

Procedure Progr(S: String);
begin
  Form1.Caption:=S;
  Application.ProcessMessages;
end;

procedure TForm1.Button1Click(Sender: TObject);
var F,WF: File; Buf: Pointer; Size: Integer;
begin
  AssignFile(F,'MGSA\stage\init\_zar');
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  Size:=ZARDecompress(Buf,FileSize(F));
  AssignFile(WF,'MGSA\stage\init\_zar.dar');
  Rewrite(WF,1);
  BlockWrite(WF, Buf^, Size);
  CloseFile(F);
  CloseFile(WF);
  FreeMem(Buf);


end;

procedure TForm1.Button2Click(Sender: TObject);
var F,WF: File; Buf: Pointer; Size, FSize: Integer;
begin
  AssignFile(F,'MGSA\stage\prologue\Новая папка\_zar.dar');
  Reset(F,1);
  FSize:=FileSize(F);
  GetMem(Buf,FSize);
  BlockRead(F, Buf^, FSize);
  Size:=ZARCompress(Buf,FSize);
  AssignFile(WF,'MGSA\stage\prologue\Новая папка\_zar');
  Rewrite(WF,1);
  BlockWrite(WF, FSize,4);
  Seek(WF,4);
  BlockWrite(WF, Buf^, Size);
  CloseFile(F);
  CloseFile(WF);
  FreeMem(Buf);
end;

procedure TForm1.Button3Click(Sender: TObject);
var F,WF: File; Buf,P: Pointer; Size: Integer; Text: TMGATextArray;
Dar: TDar; n: Integer;
begin
  AssignFile(F,'MGSA\stage\init\_zar');
  Reset(F,1);
  GetMem(Buf,FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  Size:=ZARDecompress(Buf,FileSize(F));
  //AssignFile(WF,'MGSA\stage\init\_zar.dar');
  //Rewrite(WF,1);
  //BlockWrite(WF, Buf^, Size);
  CloseFile(F);
  //CloseFile(WF);
  //FreeMem(Buf);


  Dar:=AssignDar(Buf);
  For n:=0 To Length(Dar)-1 do List.Items.Add(Dar[n].FileName);
  Size:=GetDarFile(P,Dar,'localfont.fcx');
  If Size<0 Then Exit;
  ExtractText(P,Text,'init\');
  For n:=0 To Length(Text[0].Text)-1 do List.Items.Add(Text[0].Text[n].S); 
  {AssignFile(WF,'MGSA\stage\init\test.xxx');
  Rewrite(WF,1);
  BlockWrite(WF, P^, Size);
  CloseFile(WF);}
end;

procedure TForm1.Button4Click(Sender: TObject);
var Text: TMGATextArray;
begin
  ExtractAllText(Text, 'MGSA\stage\',Progr);
  SaveText(Text,'MGSA\stage\Test.txt');
  SaveList(Text,'MGSA\stage\Test.lst');
end;

procedure TForm1.Button5Click(Sender: TObject);
var Text: TMGATextArray;
begin
  LoadText(Text,'MGSA\stage\Test.lst','MGSA\stage\Test.txt', Progr);
  SaveList(Text, 'MGSA\stage\SaveTest.lst');
  SaveText(Text, 'MGSA\stage\SaveTest.txt');
end;

end.
