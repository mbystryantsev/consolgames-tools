unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, ValEdit, FF7_Common, DIB, ActnList,
  ExtDlgs;

type
  TForm1 = class(TForm)
    Img: TImage;
    VList: TValueListEditor;
    List: TListBox;
    Button1: TButton;
    SList: TListBox;
    VSList: TValueListEditor;
    LoadPallete: TButton;
    OD: TOpenDialog;
    SP: TSavePictureDialog;
    ActionList1: TActionList;
    ASPicture: TAction;
    Memo: TMemo;
    Action1: TAction;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure ListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SListClick(Sender: TObject);
    procedure LoadPalleteClick(Sender: TObject);
    procedure ASPictureExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

const
  SCount = $AC;
  LChars: Array[0..32] of Byte = (49,50,78,79,80,81,82,83,85,86,87,88,89,90,91,92,93,94,95,96,97,98,
  99,100,101,145,146,147,148,149,150,168,170);
  Chars: Array[0..32] of Byte = (116,117,118,119,120,121,122,123,125,126,127,
  128,129,130,131,132,133,134,135,136,137,138,139,140,141,152,153,155,154,157,
  158,169,171);
Type
  THeader = Packed Record
    Count:    Integer;
    Size:	    DWord;
    W,H:     DWord;
    TegFFFF:  DWord;
    Ptr:	    DWord;
    Teg2:	     Array[0..1] of DWord;
  end;
  TSymbol = Packed Record
    Size: DWord;
    X:	  Integer;
    Y:	  Integer;
    W,H:  Integer;
    Unk:  DWord;
    Ptr:  DWord;
  end;

var
  Head: Array[0..SCount-1] of THeader;
  Symb: Array of TSymbol;
  Buf: Pointer;
  Pic: TDIB;

implementation

{$R *.dfm}


         Type
TByteArray = Array[0..3] of Byte;
Function ToMot(X: Integer; SZ: Byte): Integer;
var B,B1: TByteArray; n: Integer;
begin
  B:=TByteArray(X);
  For n:=0 To Sz-1 do
  begin
    B1[n]:=B[Sz-n-1];
  end;
  Result:=Integer(B1);
end;

procedure Fill(Var P: TDib);
var n: Integer;
begin
  For n:=0 To P.Height-1 do
  begin
    FillChar(P.ScanLine[n]^,P.WidthBytes,0);
  end;
end;

Procedure DrawSprite(X,Y,W,H: Integer; P: Pointer; ToRaw: Boolean = False);
var n,m,l,r: Integer; B: ^Byte;
begin
  For m:=0 To (H div 8)-1 do
  begin
    For n:=0 To (W div 8)-1 do
    begin
      B:=P;
      Inc(DWord(P),64);
      For l:=Y+8*m to Y+8*m+7 do
      begin
        If ToRaw Then Move(Pointer(DWord(Pic.ScanLine[l{+m*8}])+X+n*8)^,B^,8)
        else Move(B^,Pointer(DWord(Pic.ScanLine[l{+m*8}])+X+n*8)^,8);
        Inc(B,8);
      end;
    end;
  end;
end;

Procedure LoadSymb;
var n: Integer;
begin
  Fill(Pic);
  For n:=0 To High(Symb) do
  begin
    With Symb[n] do DrawSprite(X,Y,W,H,Pointer(DWord(Buf)+Ptr-$08000000));
  end;
  //Form1.Img.Canvas.Draw(0,0,Pic);
  //Form1.Img.Picture.Graphic:=Pic;
end;

procedure TForm1.ListClick(Sender: TObject);
var n,m: Integer;
begin
  n:=List.ItemIndex;
  VList.Strings[0]:=Format('Count=%.8x',[Head[n].Count]);
  VList.Strings[1]:=Format('Size=%.8x',[Head[n].Size]);
  VList.Strings[2]:=Format('W=%d',[Head[n].W]);
  VList.Strings[3]:=Format('H=%d',[Head[n].H]);
  VList.Strings[4]:=Format('TegFFFF=%.8x',[Head[n].TegFFFF]);
  VList.Strings[5]:=Format('Pointer=%.8x',[Head[n].Ptr]);
  VList.Strings[6]:=Format('Teg1=%.8x',[Head[n].Teg2[0]]);
  VList.Strings[7]:=Format('Teg2=%.8x',[Head[n].Teg2[1]]);
  SetLength(Symb,Head[n].Count);
  Move(Pointer(DWord(Buf)+(Head[n].Ptr-$08000000))^,Symb[0],Head[n].Count*$1C);
  SList.Clear;
  For m:=0 To Head[n].Count-1 do
  begin
    With Symb[m] do SList.Items.Add(Format('%d:%d; %dx%d',
    [X,Y,W,H]));
  end;
  LoadSymb;
  SList.ItemIndex:=0;
  SListClick(Sender);
end;

procedure TForm1.Button1Click(Sender: TObject);
var n: Integer; var WBuf: Pointer; C: ^DWord;
begin
  LoadFile('Pirates\Pirates of the Caribbean.gba',Buf);
  Move(Pointer(DWord(Buf)+$156C70)^,Head,SCount*$20);
  For n:=0 To SCount-1 do
  begin
    List.Items.Add(Format('%.6x',[$156C70+n*$20]));
  end;
  List.ItemIndex:=0;
  ListClick(Sender);
    LoadFile('Pirates\Font.act',WBuf);
    C:=WBuf;
    For n:=0 To 255 do
    begin
      DWord(Pic.ColorTable[n]):=ToMot(C^,3) and $FFFFFF;
      Inc(DWord(C),3);
    end;
    Pic.UpdatePalette;
end;

var tn: Byte;
procedure TForm1.SListClick(Sender: TObject);
var n: Integer;
begin
  n:=SList.ItemIndex;
  VSList.Strings[0]:=Format('Size=%.8x',[Symb[n].Size]);
  VSList.Strings[1]:=Format('X=%d',[Symb[n].X]);
  VSList.Strings[2]:=Format('Y=%d',[Symb[n].Y]);
  VSList.Strings[3]:=Format('W=%d',[Symb[n].W]);
  VSList.Strings[4]:=Format('H=%d',[Symb[n].H]);
  VSList.Strings[5]:=Format('Unk2=%.8x',[Symb[n].Unk]);
  VSList.Strings[6]:=Format('Pointer=%.8x',[Symb[n].Ptr]);
  LoadSymb;
  Img.Canvas.Brush.Style:=bsClear;
  Img.Canvas.Pen.Color:=clRed;
  Form1.Img.Canvas.Draw(0,0,Pic);
  With Symb[n] do
  begin
    Img.Canvas.MoveTo(0,0); 
    Img.Canvas.LineTo(X,Y);
    Img.Canvas.Rectangle(X,Y,X+W,Y+H);
  end;
end;




procedure TForm1.LoadPalleteClick(Sender: TObject);
var WBuf: Pointer; n: Integer; C: ^DWord;
begin
  If OD.Execute Then
  begin
    LoadFile(OD.FileName,WBuf);
    C:=WBuf;
    For n:=0 To 255 do
    begin
      DWord(Pic.ColorTable[n]):=ToMot(C^,3) and $FFFFFF;
      Inc(DWord(C),3);
    end;
    Pic.UpdatePalette;
  end;
end;

procedure TForm1.ASPictureExecute(Sender: TObject);
var P: TDIB; n: Integer;
begin
  If SP.Execute Then
  begin
    P:=TDIB.Create;
    P.BitCount:=8;
    With Head[List.ItemIndex] do
    begin
      P.Width:=W;
      P.Height:=H;
      For n:=0 To 255 do
      begin
        P.ColorTable[n]:=Pic.ColorTable[n];
      end;
      P.UpdatePalette;
      P.Canvas.CopyRect(Bounds(0,0,W,H),Pic.Canvas,Bounds(0,0,W,H));
    end;
    P.SaveToFile(SP.FileName+'.bmp');
    P.Free;
  end;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  If UpCase(Key)='A' Then Memo.Text:=Format('%s%d,',[Memo.Text,List.ItemIndex]);
end;

procedure TForm1.Button2Click(Sender: TObject);
var P: TDIB; X,Y,n,m: Integer;
begin
  P:=TDIB.Create;
  P.BitCount:=8;
  P.Width:=16*16;
  P.Height:=8*16;
  For n:=0 To 255 do P.ColorTable[n]:=Pic.ColorTable[n];
  P.UpdatePalette;
  Fill(P);
    For n:=0 to 32 do
    begin
      List.ItemIndex:=Chars[n];
      ListClick(Sender);
      Y:=16*(n div 16);
      X:=(n-(n div 16)*16)*16;
      P.Canvas.CopyRect(Bounds(X,Y,16,16),Pic.Canvas,Bounds(0,0,16,16));
    end;
    For n:=64 to 96 do
    begin
      List.ItemIndex:=LChars[n-64];
      ListClick(Sender);
      Y:=16*(n div 16);
      X:=(n-(n div 16)*16)*16;
      P.Canvas.CopyRect(Bounds(X,Y,16,16),Pic.Canvas,Bounds(0,0,16,16));
    end;
  P.SaveToFile('Pirates\Font\Font.bmp');
  P.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var P: TDIB; X,Y,n,m: Integer;
begin
  P:=TDIB.Create;
  P.LoadFromFile('Pirates\Font\Font_Rus.bmp');
    For n:=0 to 32 do
    begin
      List.ItemIndex:=Chars[n];
      ListClick(Sender);
      Y:=16*(n div 16);
      X:=(n-(n div 16)*16)*16;
      Pic.Canvas.CopyRect(Bounds(0,0,16,16),P.Canvas,Bounds(X,Y,16,16));
      Img.Canvas.CopyRect(Bounds(0,0,16,16),P.Canvas,Bounds(X,Y,16,16));
      Application.ProcessMessages;
      DrawSprite(0,0,16,16,Pointer(DWord(Buf)+(Symb[0].Ptr-$08000000)),True);
    end;
    For n:=64 to 96 do
    begin
      List.ItemIndex:=LChars[n-64];
      ListClick(Sender);
      Y:=16*(n div 16);
      X:=(n-(n div 16)*16)*16;
      Pic.Canvas.CopyRect(Bounds(0,0,16,16),P.Canvas,Bounds(X,Y,16,16));
      DrawSprite(0,0,16,16,Pointer(DWord(Buf)+(Symb[0].Ptr-$08000000)),True);
    end;
  P.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  SaveFile('Pirates\Pirates of the Caribbean.gba',Buf,8388608);
end;

Initialization
  Pic:=TDIB.Create;
  Pic.BitCount:=8;
  Pic.Width:=240;
  Pic.Height:=160;
  For tn:=0 To 255 do
  begin
    DWord(Pic.ColorTable[tn]):=tn+(tn shl 8)+(tn shl 16);
  end;
  Pic.UpdatePalette;
  //Form1.Memo.Clear;
Finalization
  Pic.Free;
end.
