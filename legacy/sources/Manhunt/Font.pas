unit Font;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,DIB, StdCtrls, PSPRAW, ExtCtrls, ActnList, ExtDlgs;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Img: TImage;
    Button2: TButton;
    Button3: TButton;
    chBGR: TCheckBox;
    PalImg: TImage;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    edGoTo: TEdit;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    OpenDialog1: TOpenDialog;
    edGT: TEdit;
    Button14: TButton;
    edW: TEdit;
    edH: TEdit;
    Label1: TLabel;
    ActionList1: TActionList;
    ANextPal: TAction;
    APrevPal: TAction;
    chAlpha: TCheckBox;
    SavePictureDialog1: TSavePictureDialog;
    Button15: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure chBGRClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure ANextPalExecute(Sender: TObject);
    procedure APrevPalExecute(Sender: TObject);
    procedure Button15Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Pic: TDIB;
  PalPic: TDIB;   
Type TPl = Array[0..255] of DWord;
var Buf: Pointer; Pal: ^TPl;
Size: Integer;

implementation

{$R *.dfm}
var HexError: Boolean;
Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char;
begin
 HexError := True;
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 HexError := False;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   HexError := True;
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;

Type
TByteArray = Array[0..3] of Byte;
Function ToMot(X: DWord; SZ: Byte): DWord;
var B,B1: TByteArray; n: Integer;
begin
  B:=TByteArray(X);
  For n:=0 To Sz-1 do
  begin
    B1[n]:=B[Sz-n-1];
  end;
  Result:=Integer(B1);
  
end;

Function LoadFile(Name: String; var Pos: Pointer): Integer;
var F: File;
begin
  FileMode := fmOpenRead;
  Result:=-1;
  If not FileExists(Name) Then Exit;
  AssignFile(F,Name);
  Reset(F,1);
  Result:=FileSize(F);
  GetMem(Pos, Result);
  BlockRead(F, Pos^, Result);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
end;

Procedure ProcessPal;
var n,m: Integer; DW,WDW: ^DWord;
begin
  If Form1.chAlpha.Checked Then
  begin
    For n:=0 To 255 do
    begin
      If Form1.chBGR.Checked Then
      begin
        Pic.ColorTable[n].rgbRed:=Pal^[n] and $FF;
        Pic.ColorTable[n].rgbGreen:=Pal^[n] and $FF;
        Pic.ColorTable[n].rgbBlue:=Pal^[n] and $FF;
      end else
      begin
        Pic.ColorTable[n].rgbRed:=(Pal^[n] SHR 24) and $FF;
        Pic.ColorTable[n].rgbGreen:=(Pal^[n] SHR 24) and $FF;
        Pic.ColorTable[n].rgbBlue:=(Pal^[n] SHR 24) and $FF;
      end;
    end;
  end else
  begin
    If Form1.chBGR.Checked Then SetPallete(Pic,Pal^) else SetPal(Pic,Pal^);
  end;
  Form1.Img.Picture.Graphic:=Pic;
  Form1.Text:=Format('%.8x',[DWord(Pal)-DWord(Buf)]);
  DW:=Addr(Pal^);
  For m:=0 To 31 do
  begin
    If Form1.chBGR.Checked Then
    begin
      WDW:=PalPic.ScanLine[m];
      For n:=0 To 15 do
      begin
        WDW^:=ToMot(DW^,4);
        Inc(WDW); Inc(DW);
      end;
    end else
    begin
      Move(DW^,PalPic.ScanLine[m]^,64);
      Inc(DW,16);
    end;
  end;
  Form1.PalImg.Canvas.CopyRect(Bounds(0,0,128,256),PalPic.Canvas,Bounds(0,0,16,32));

  Form1.PalImg.Canvas.Pen.Color:=clRed;
  Form1.PalImg.Canvas.MoveTo(128,128);
  Form1.PalImg.Canvas.LineTo(0,128);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  If not (OpenDialog1.Execute or FileExists(OpenDialog1.FileName))Then Exit;
  Size:=LoadFile( OpenDialog1.FileName {'GLOBAL.TXD.u'},Buf);
  RawToDib(Pic,Pointer(DWord(Buf)+{ $1F590 } $F590));
  Pal:=Buf; Inc(DWord(Pal), $1470   { $6E30});
  ProcessPal;
  Button2.Enabled:=True;
  Button3.Enabled:=True;
  Button4.Enabled:=True;
  Button5.Enabled:=True;
  Button6.Enabled:=True;
  Button7.Enabled:=True;
  Button8.Enabled:=True;
  Button9.Enabled:=True;
  Button10.Enabled:=True;
  Button11.Enabled:=True;
  Button12.Enabled:=True;
  Button13.Enabled:=True;
  Button14.Enabled:=True;
  Button15.Enabled:=True;
  chBGR.Enabled:=True;
  chAlpha.Enabled:=True;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin      
  If $100+DWord(Pal)-DWord(Buf)>Size Then Exit;
  Inc(DWord(Pal),$100);
  ProcessPal;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  If DWord(Pal)-$100<DWord(Buf) Then Exit;
  Dec(DWord(Pal),$100);
  ProcessPal;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  If DWord(Pal)-$4<DWord(Buf) Then Exit;
  Dec(DWord(Pal),$4);
  ProcessPal;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  If $4+DWord(Pal)-DWord(Buf)>Size Then Exit;
  Inc(DWord(Pal),$4);
  ProcessPal;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  If $1+DWord(Pal)-DWord(Buf)>Size Then Exit;
  Inc(DWord(Pal),1);
  ProcessPal;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin 
  If DWord(Pal)-$1<DWord(Buf) Then Exit;
  Dec(DWord(Pal),$1);
  ProcessPal;
end;

procedure TForm1.chBGRClick(Sender: TObject);
begin
  ProcessPal;
end;

procedure TForm1.Button10Click(Sender: TObject);
var n: DWord;
begin
  n:=HexToInt(edGoTo.Text);
  If not HexError and (n<=Size) and (n>=0) Then
  begin
    Pal:=Pointer(DWord(Buf)+n);
    ProcessPal;
  end;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin   
  Pic.Height:=256;
  Pic.Width:=256;
  RawToDib(Pic,Pointer(DWord(Buf)+{ $1F590 } $F590));
  ProcessPal;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin 
  Pic.Height:=256;
  Pic.Width:=256;
  RawToDib(Pic,Pointer(DWord(Buf)+ $1F590));
  ProcessPal;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  Pic.Height:=256;
  Pic.Width:=256;
  RawToDib(Pic,Pointer(DWord(Buf)+ $2F590));
  ProcessPal;
end;

procedure TForm1.Button14Click(Sender: TObject);
var n: DWord;
begin
  n:=HexToInt(edGT.Text);
  If not HexError and (n<=Size) and (n>=0) Then
  begin
    Pic.Height:=StrToInt(edH.Text);
    Pic.Width:=StrToInt(edW.Text);
    RawToDib(Pic,Pointer(DWord(Buf)+n));
    ProcessPal;
  end;
end;

procedure TForm1.ANextPalExecute(Sender: TObject);
begin
  If $400+DWord(Pal)-DWord(Buf)>Size Then Exit;
  Inc(Pal);
  ProcessPal;
end;

procedure TForm1.APrevPalExecute(Sender: TObject);
begin
  If DWord(Pal)-$400<DWord(Buf) Then Exit;
  Dec(Pal);
  ProcessPal;
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  If SavePictureDialog1.Execute Then Pic.SaveToFile(SavePictureDialog1.FileName); 
end;

Initialization
  PalPic:=TDIB.Create;
  PalPic.BitCount:=32;
  PalPic.Width:=16;
  PalPic.Height:=32;
  Pic:=TDIB.Create;
  Pic.BitCount:=8;
  Pic.Height:=32*8;
  Pic.Width:=32*8;
Finalization
  Pic.Free;
  PalPic.Free;
end.
