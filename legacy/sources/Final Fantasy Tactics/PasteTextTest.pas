unit PasteTextTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FFT;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
var Buf: Pointer; Size: Integer; Text: String; Table: TTableArray; F: File;
begin

  GetMem(Buf, $4000);
  Text:='Проверка блин'+#13#10+
  '{0}Bla{0}  )( bla bla\'+#13#10+#13#13+'dsss()\';
  LoadTable('FFT\FFTTable.tbl', Table);
  Size:=PasteText(Text, Table, Buf);
  AssignFile(F, 'Test.bin');
  Rewrite(F,1);
  BlockWrite(F, Buf^, Size);
  FreeMem(Buf);
  CloseFile(F);

  ShowMessage(IntToStr(Size));
end;

procedure TForm1.Button2Click(Sender: TObject);
var Buf: Pointer; Size: Integer; Text: String; Table: TTableArray; F: File;
begin
  GetMem(Buf, $4000);
  Text:='Проверка блин... ,блин...'+#13#10+
  '{0}Bla{0}  )( bla bla\'+#13#10+#13#13+'dsss()\';
  LoadTable('FFT\FFTTable.tbl', Table);
  Size:=Compress(Buf, PasteText(Text, Table, Buf));

  AssignFile(F, 'Test.bin');
  Rewrite(F,1);
  BlockWrite(F, Buf^, Size);
  FreeMem(Buf);
  CloseFile(F);

  ShowMessage(IntToStr(Size));
end;

end.
