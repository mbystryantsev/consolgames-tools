unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FF7_Compression, FF7_;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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
var Buf, WBuf: Pointer; F: File; Size: DWord;
begin
  //ShowMessage(IntToHex(GetBack($FB, $F0, $11),3));
  AssignFile(F, '_FF7\_LZ\ELM.DAT');
  Reset(F,1);
  GetMem(Buf, FileSize(F));
  BlockRead(F, Buf^, FileSize(F));
  Size:=LZ_Decompress(Buf, WBuf);
  AssignFile(F, '_FF7\_LZ\ELM.TEST');
  Rewrite(F,1);
  BlockWrite(F, WBuf^, Size);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ShowMessage(IntToHex(LZ_GetBack($03, $00, $19),3));
  //ShowMessage(IntToHex(LZ_GetBack($03, $00, $11),3));
end;

end.
