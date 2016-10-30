unit PSPRawViewer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FFT, StdCtrls, ExtCtrls, XPMan, ComCtrls, ActnList, Menus, DIB,
  ExtDlgs;

type

  THead = Packed Record
    Pal: TPallete;
    Pic: TDIB;
  end;

  TForm1 = class(TForm)
    List: TListBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Edit1: TMenuItem;
    About1: TMenuItem;
    ActionList1: TActionList;
    StatusBar1: TStatusBar;
    XPManifest1: TXPManifest;
    OpenDialog: TOpenDialog;
    Img: TImage;
    OpenAction: TAction;
    Open1: TMenuItem;
    ScanDirectory1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    CopytoBitmap1: TMenuItem;
    PastefromBitmap1: TMenuItem;
    Options1: TMenuItem;
    Replacepallete1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    SaveAction: TAction;
    SaveAsAction: TAction;
    ScanAction: TAction;
    AboutAction: TAction;
    PasteFromBitmapAction: TAction;
    CopyToBitmapAction: TAction;
    SavePicture: TSavePictureDialog;
    procedure OpenActionExecute(Sender: TObject);
    procedure ListClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Exit1Click(Sender: TObject);
    procedure CopyToBitmapActionExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
var Head: Array of THead; MBuf: Pointer;

Procedure Clear;
var n: Integer;
begin
  For n:=0 To Length(Head)-1 do
  begin
    If Assigned(Head[n].Pic) Then Head[n].Pic.Free;
  end;
  If Assigned(MBuf) Then FreeMem(MBuf);
  SetLength(Head,0);
end;

Procedure DrawPic(Buf: Pointer; Count: Integer; Sender: TObject);
var P: ^TPallete; WBuf: Pointer; {Pal: Pallete;}
i,n,m: Integer; B, WB: ^Byte;
begin
  GetMem(WBuf, $20400);
  B:=Addr(Buf^);
  I:=0;
  For n:=0 To Count-1 do
  begin
    SetLength(Head, I+1);
    P:=Addr(B^);
    Head[i].Pal:=P^;
    Head[i].Pic:=TDIB.Create;
    Head[i].Pic.PixelFormat:=MakeDIBPixelFormat(8,8,8);
    Head[i].Pic.Width:=64*8;
    Head[i].Pic.Height:=32*8;
    Head[i].Pic.BitCount:=8;
    Inc(B, $400);
    WB:=Addr(WBuf^);
    For m:=0 To $203FF do
    begin
      WB^:=B^;
      Inc(WB); Inc(B);  
    end;
    RawToDib(Head[i].Pic, WBuf);
    SetPallete(Head[i].Pic, Head[i].Pal);
    Form1.List.Items.Add(IntToHex(n*$20800,8));
    Inc(i);
  end;
  Form1.List.ItemIndex:=0;
  Form1.ListClick(Sender);
end;

procedure TForm1.OpenActionExecute(Sender: TObject);
var F: File;  Cnt: Integer;
begin

  If OpenDialog.Execute and FileExists(OpenDialog.FileName) Then
  begin
    AssignFile(F, OpenDialog.FileName);
    Reset(F,1);
    Cnt:=FileSize(F) div $20800;
    If Cnt*$20800<>FileSize(F) Then
    begin
      ShowMessage('Not graphic file!');
      Exit;
    end;
    Clear;
    List.Clear;
    GetMem(MBuf, FileSize(F));
    BlockRead(F, MBuf^, FileSize(F));
    CloseFile(F);
    DrawPic(MBuf, Cnt, Sender);
  end;
end;

procedure TForm1.ListClick(Sender: TObject);
begin
  Img.Picture.Graphic:=Head[List.ItemIndex].Pic;
  Img.Height:=Head[List.ItemIndex].Pic.Height;
  Img.Width:=Head[List.ItemIndex].Pic.Width;
end;



procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Clear;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.CopyToBitmapActionExecute(Sender: TObject);
begin
  If SavePicture.Execute And
  DirectoryExists(ExtractFilePath(SavePicture.FileName)) then
  begin
    //SetPallete(Head[List.ItemIndex].Pic, Head[List.ItemIndex].Pal);
    //Head[List.ItemIndex].Pic.SaveToFile(SavePicture.FileName);
    Img.Picture.Graphic.SaveToFile(SavePicture.FileName);
  end;
end;

end.
