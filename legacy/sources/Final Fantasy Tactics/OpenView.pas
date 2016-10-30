unit OpenView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, FFT, DIB, StdCtrls, XPMan, ComCtrls, ActnList, Menus,
  ExtDlgs;

type
  TForm1 = class(TForm)
    Img: TImage;
    PalList: TListBox;
    List: TListBox;
    ActionList1: TActionList;
    Status: TStatusBar;
    XPManifest1: TXPManifest;
    MainMenu: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    OpenAction: TAction;
    ExitAction: TAction;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    CopyToBmpAction: TAction;
    AboutAction: TAction;
    OpenPic: TOpenPictureDialog;
    OpenBlock: TOpenPictureDialog;
    SavePicture: TSavePictureDialog;
    OpenDialog: TOpenDialog;
    PasteFormBmpAction: TAction;
    BlockImport: TAction;
    procedure FormCreate(Sender: TObject);
    procedure PalListClick(Sender: TObject);
    procedure ExitActionExecute(Sender: TObject);
    procedure AboutActionExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    Procedure DrawFile(Sender: TObject; const S: String);
    procedure ListClick(Sender: TObject);
    procedure CopyToBmpActionExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

//var Pic: TDIB; Pal: TPal;
Var Head: Array of TOpenImage;

Procedure Clear;
var n: Integer;
begin
  For n:=0 To Length(Head)-1 do
  begin
    If Assigned(Head[n].Pic) Then Head[n].Pic.Free;
  end;
  SetLength(Head,0);
end;

Procedure TForm1.DrawFile(Sender: TObject; const S: String);
var F: File; n,i,pos, Size: Integer; Buf: Pointer;
begin
  AssignFile(F, S);
  Reset(F,1);
  GetMem(Buf, $80000);
  i:=-1;
  Pos:=0;
//
  While Pos<FileSize(F) do
  begin
    Inc(i);
    SetLength(Head, I+1);
    Seek(F,Pos);
    List.Items.Add(IntToHex(Pos,8));
    BlockRead(F, Head[i].HeadSize,4); Inc(Pos,4);
    Seek(F,Pos);
    BlockRead(F, Head[i].Head, Head[i].HeadSize);
    Inc(Pos, Head[i].HeadSize);
    SetLength(Head[i].Pal, Head[i].Head.PalCount);
    For n:=0 To Head[i].Head.PalCount-1 do
    begin
      SetLength(Head[i].Pal[n].Pal, Head[i].Head.ColorCount);
    end;
    For n:=0 To Head[i].Head.PalCount-1 do
    begin
      Seek(F, Pos);
      BlockRead(F, Head[i].Pal[n].Pal[0], Head[i].Head.ColorCount*2);
      Inc(Pos,Head[i].Head.ColorCount*2);
    end;
    //Inc(Pos,Head[i].Head.ColorCount*Head[i].Head.PalCount*2);
    Seek(F, Pos);
    BlockRead(F, Head[i].DataSize, 4);
    Inc(Pos,4);
    Seek(F,Pos);
    BlockRead(F, Head[i].Footer, Head[i].Head.FootSize);
    Inc(Pos, Head[i].Head.FootSize);
    Seek(F,Pos);
    Pos:=RoundBy(Pos,16);
    BlockRead(F, Buf^, Head[i].DataSize-Head[i].Head.FootSize);
    Inc(Pos,Head[i].DataSize-Head[i].Head.FootSize);
    Head[i].Pic:=TDIB.Create;
    Head[i].Pic.BitCount:=GetBpp(Head[i].Head.ColorCount);
    Head[i].Pic.PixelFormat:=MakeDIBPixelFormat(8,8,8);
    Head[i].Pic.Height:=Head[i].Footer.Height;
    If Head[i].Pic.BitCount=4 Then Head[i].Pic.Width:=Head[i].Footer.LineSize*GetBpp(Head[i].Head.ColorCount)
    else Head[i].Pic.Width:=Head[i].Footer.LineSize*2;
    RawToDib(Head[i].Pic, Buf);
    Pos:=RoundBy(Pos, $800);
  end;
  //
  CloseFile(F);
  List.ItemIndex:=0;
  ListClick(Sender);

end;

procedure TForm1.FormCreate(Sender: TObject);
var  Buf: Pointer; F: File;
n: Integer;
begin
  {Pic:=TDIB.Create;
  Pic.PixelFormat:=MakeDibPixelFormat(8,8,8);
  SetLength(Pal,16*16);
  For n:=0 to 15 do
  begin
    PalList.Items.Add(IntToStr(n));
  end;
  AssignFile(F, 'FFT\TEXT\OPNTEX.BIN');
  Reset(F,1);
  GetMem(Buf, $40*$100);
  Seek(F, $220);
  BlockRead(F, Buf^, $80*$100);
  Seek(F,$14);
  BlockRead(F, Pal[0], 32*16);
  Pic.BitCount:=4;
  Pic.Width:=$100;
  Pic.Height:=$100;
  RawToDib(Pic, Buf);
  SetPal(Pic, Pal);
  Img.Picture.Graphic:=Pic;
  Img.Height:=Pic.Height;
  Img.Width:=Pic.Width;}
end;

procedure TForm1.PalListClick(Sender: TObject);
var n: Integer; Pl: TPal;
begin
  SetPal(Head[List.ItemIndex].Pic, Head[List.ItemIndex].Pal[PalList.ItemIndex].Pal);
  Img.Picture.Graphic:= Head[List.ItemIndex].Pic;
  Img.Height := Head[List.ItemIndex].Pic.Height;
  Img.Width := Head[List.ItemIndex].Pic.Width;
  Status.Panels.Items[4].Text:=Format('Pallete: %d/%d',
  [PalList.ItemIndex+1, PalList.Count]);
end;

procedure TForm1.ExitActionExecute(Sender: TObject);
begin
  Close;
end;

procedure TForm1.AboutActionExecute(Sender: TObject);
begin
  MessageDlg(
  'FFT OPNTEX.BIN Viewer v0.1a by HoRRoR <ho-rr-or@mail.ru>'+#13#10+
  'FFT Translation Project <http://consolgames.jino-net.ru/>'
  ,mtInformation,[mbOk],0);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  List.Height:=Form1.Height-87;
  PalList.Height:=Form1.Height-87;
end;

procedure TForm1.OpenActionExecute(Sender: TObject);
var F: File; Buf: Pointer; Size: Integer;
begin
  If OpenDialog.Execute And (FileExists(OpenDialog.FileName)) then
  begin
    //AssignFile(F, OpenDialog.FileName);
    //Reset(F,1);
    //Size:=FileSize(F);
    //GetMem(Buf, Size);
    //BlockRead(F, Buf^, Size);
    //CloseFile(F);
    Clear;
    DrawFile(Sender, OpenDialog.FileName);
  end;
end;

procedure TForm1.ListClick(Sender: TObject);
var n: Integer;
begin
  PalList.Clear;
  For n:=0 To Head[List.ItemIndex].Head.PalCount-1 do
  begin
    PalList.Items.Add('Pallete '+IntToStr(n));
  end;
  PalList.ItemIndex:=0;
  PalListClick(Sender);

  Status.Panels.Items[0].Text:=Format('Image: [%d/%d]',
  [List.ItemIndex+1, List.Count]);
  Status.Panels.Items[1].Text:=Format('Bit Count: %d',
  [Head[List.ItemIndex].Pic.BitCount]);
  Status.Panels.Items[2].Text:=Format('Width: %d',
  [Head[List.ItemIndex].Pic.Width]);
  Status.Panels.Items[3].Text:=Format('Height: %d',
  [Head[List.ItemIndex].Pic.Height]);
  Status.Panels.Items[5].Text:=Format('Color Count: %d',
  [Head[List.ItemIndex].Head.ColorCount]);
end;

procedure TForm1.CopyToBmpActionExecute(Sender: TObject);
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
