unit DAT_TEST;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FF7_Common, FF7_DAT, FF7_Compression, FF7_Text, FF7_Field,
  FF7_Window, FF7_Image, StrUtils, DIB;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    SList: TListBox;
    Button10: TButton;
    Button11: TButton;
    Memo: TMemo;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    edGetBack: TEdit;
    Button17: TButton;
    edPos: TEdit;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    edLBAOffset: TEdit;
    edLBAFile: TEdit;
    Button23: TButton;
    edLBACount: TEdit;
    OpenDialog1: TOpenDialog;
    edLBAStep: TEdit;
    Button24: TButton;
    Button25: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure SListClick(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button23Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
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
var Buf: Pointer; DAT: TDAT; Size: Integer;
begin
  Size:=LoadDat('_FF7\_LZ\4SBWY_1.DAT', Buf);
  SaveFile('_FF7\_LZ\4SBWY_1.DAT.Unpacked',Buf,Size);
  DAT:=AssignDat(Buf, Size);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ShowMessage(IntToHex(LZ_CryptBack(1, $1C),4));
  ShowMessage(IntToHex(LZ_GetBack($09, $00, $1C),4));
end;

procedure TForm1.Button3Click(Sender: TObject);
var Table: TTableArray; Size: Integer; Msg: TMsg; F: File; Buf: Pointer; Dat: TDat;
begin
  LoadTable('_FF7\Table_En.tbl',Table);
  Size:=LoadDat('_FF7\_LZ\7MIN1.DAT', Buf);
  DAT:=AssignDat(Buf, Size);
  LoadText(Dat.TextPtr.Pos, Table, Msg);
end;

Procedure P(N: Integer; S: String);
begin
  Form1.Caption:=Format('%d - %s',[n,s]);
end;

procedure TForm1.Button4Click(Sender: TObject);
var Text: TText; Table: TTableArray; Buf: Pointer; Size: Integer;
begin
  LoadTable('_FF7\Table_En.tbl',Table);
  //Size:=ExtractAllText('_FF7\FIELD\',Text, Table, Buf, P);
  //OptimizeText(Text, P);
  SaveText('_FF7\_LZ\Project\FF7.txt', Text);
  SaveOpt('_FF7\_LZ\Project\FF7.idx', Text);
  SaveFile('_FF7\_LZ\Project\FF7.fsc',Buf,Size);
end;

procedure TForm1.Button5Click(Sender: TObject);
var Buf, WBuf: Pointer; DAT: TDAT; Size: Integer;
begin
  GetMem(Buf, $10000);
  GetMem(WBuf, $10000);
  Size:=LoadDat('_FF7\_LZ\ELM.DAT',Buf);
  Dat:=AssignDat(Buf,Size);
  Size:=BuildDat(DAT,WBuf);
  SaveFile('_FF7\_LZ\Test\!!!',Buf,Size);
end;

procedure TForm1.Button6Click(Sender: TObject);
var Table: TTableArray; Buf: Pointer; Size: Integer;
begin
  LoadTable('_FF7\Table_En.tbl',Table);
  GetMem(Buf,$1000);
  Size:=PasteText('Wow!'+#13#10+'It"s worked!!!~'+#13#10+'Wonderful!',Table,Buf);
  SaveFile('_FF7\_LZ\Test\Str',Buf,Size);
end;

procedure TForm1.Button7Click(Sender: TObject);
var Text: TText; Table: TTableArray; Buf, WBuf: Pointer; Size: Integer;
Dat: TDAT; Msg: TMsg;
begin
  {LoadTable('_FF7\Table_En.tbl',Table);
  Size:=LoadDat('_FF7\_LZ\7MIN1.DAT', Buf);
  DAT:=AssignDat(Buf, Size);
  SaveFile('_FF7\_LZ\Test\TextOr',Dat.TextPtr.Pos,Dat.TextPtr.Size);
  LoadText(Dat.TextPtr.Pos, Table, Msg);
  GetMem(WBuf, $10000);
  Size:=InsertText(Msg,WBuf,Table);
  SaveFile('_FF7\_LZ\Test\Text',WBuf,Size); }
end;

procedure TForm1.Button8Click(Sender: TObject);
var Buf: Pointer; Size: Integer; F: File;
begin
  Size:=LoadDat('_FF7\_LZ\BLIN66_1.DAT', Buf);
  SaveFile('_FF7\_LZ\W\BLIN66_1.DAT.Unpacked',Buf,Size);
end;

var Script: TFieldDec;
procedure TForm1.Button9Click(Sender: TObject);
var Buf: Pointer; DAT: TFieldRec; Size: Integer;
n: Integer; Msg: ^TAskMsg;
begin
  Dat:=TFieldRec.Create;
  Dat.LoadFromFile('_FF7\FIELD\MDS7PB_1.DAT');
  FieldDecompile(Dat.pScript,Dat.sScript,Script);

//  Size:=LoadDat('_FF7\_LZ\4SBWY_1.DAT', Buf);
  //SaveFile('_FF7\_LZ\MD1STIN.DAT.Unpacked',Buf,Size);
//  DAT:=AssignDat(Buf, Size);
  //FieldDecompile(Dat.IdxPtr.Pos, Dat.IdxPtr.Size, Script);
  For n:=0 To Length(Script)-1 do
  begin
    SList.Items.Add(Format('%s %s',[IntToHex(Script[n].Code,2),FieldON[Script[n].Code]]));
  end;
  Dat.Free;
end;

var M: TMsg;
procedure TForm1.SListClick(Sender: TObject);
var OM: ^TOMessage; Win: ^TWin;
begin
  Form1.Caption:=IntToHex(Script[SList.ItemIndex].Beg,4);
  If Script[SList.ItemIndex].Code=$40 Then
  begin
    OM:=Addr(Script[SList.ItemIndex].Pos^);
    Memo.Text:=M.S[OM^.D].Text;
  end else
  If Script[SList.ItemIndex].Code=$50 Then
  begin
    Win:=Addr(Script[SList.ItemIndex].Pos^);
    Form1.Caption:=Format('%s [N: %d; X: %d; Y:%d; W: %d; H: %d]',
    [Form1.Caption, Win^.N, Win.X, Win.Y, Win.W, Win.H]);
  end;
  Application.ProcessMessages;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  ShowMessage(GetPart('[@Part1,13',',',1));
end;

procedure TForm1.Button11Click(Sender: TObject);
var Text: TText;
begin
  OpenOpt('_FF7\_LZ\FF7.idx',Text);
  OpenText('_FF7\_LZ\FF7.txt',Text);
  //SaveOpt('_FF7\_LZ\Test\FF7.idx',Text);
  SaveText('_FF7\_LZ\Test\FF7.txt',Text);
end;

procedure TForm1.Button12Click(Sender: TObject);
var Table: TTableArray; Size: Integer; F: File;
Buf: Pointer; Dat: TDat; n: Integer;
begin
  LoadTable('_FF7\Table_En.tbl',Table);
  Size:=LoadDat('_FF7\_LZ\MD1STIN.DAT', Buf);
  DAT:=AssignDat(Buf, Size);
  LoadText(Dat.TextPtr.Pos, Table, M);
  FieldDecompile(Dat.IdxPtr.Pos, Dat.IdxPtr.Size, Script);
  For n:=0 To High(Script) do
  begin
    SList.Items.Add(Format('%s %s',[IntToHex(Script[n].Code,2),FieldON[Script[n].Code]])); 
  end;
end;

procedure TForm1.Button13Click(Sender: TObject);
var Buf: Pointer; Field: TLField; n: Integer;
begin
  LoadField('_FF7\_LZ\FF7.fsc', Buf,Field);
  //n:=FindField(Field,'MD1STIN.DAT');
  //SaveFile('_FF7\_LZ\Test\Field.fld',Field[n].Pos, Field[n].Size);
  FreeMem(Buf);
end;

procedure TForm1.Button14Click(Sender: TObject);
var WBuf,Buf: Pointer; Size,USize: Integer;
begin
  //GetMem(WBuf,$10000);
  GetMem(WBuf,10000);
  Size:=LoadFile('noname.gz',Buf);
  Size:=GZip_Decompress(Buf,WBuf,$BD4);
  SaveFile('SSSSS.sss',WBuf,Size);
  FreeMem(Buf);
end;

procedure TForm1.Button15Click(Sender: TObject);
var WBuf,Buf: Pointer; Size,USize: Integer;
begin
  //GetMem(WBuf,$10000);
  Size:=LoadFile('Font.tim',Buf);
  Size:=GZip_Compress(Buf,WBuf,Size);
  SaveFile('Font.gz',Buf,Size);
  FreeMem(Buf);
end;

procedure TForm1.Button16Click(Sender: TObject);
var Size: Integer; Buf,WBuf: Pointer;
begin
  Size:=LoadFile('_FF7\_LZ\MD1STIN.DAT.Unpacked', Buf);
  Size:=LZ_Compress(Buf,WBuf,Size);
  SaveFile('_FF7\_LZ\LZ_TEST_MD1STIN',WBuf,Size);
  FreeMem(Buf); FreeMem(WBuf);
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
  ShowMessage(IntToStr(LZ_GetBackW(HexToInt(edGetBack.Text),HexToInt(edPos.Text))));
end;

procedure TForm1.Button18Click(Sender: TObject);
var Zip: TBinFile;
begin
  Zip:=TBinFile.Create;
  Zip.LoadFromFile('_FF7\INIT\WINDOW.BIN');
  Zip.ReplaceFile(1,'_FF7\_LZ\Test\Font.bmp');
  Zip.ExtractFile(1,'_FF7\_LZ\Test\Zip.bmp');
  Zip.SaveToFile('_FF7\_LZ\Test\Zip.BIN');
  Zip.Free;
end;

procedure TForm1.Button19Click(Sender: TObject);
var Buf,WBuf: Pointer; Zip: TBinFile; Table: TTableArray; Text: TText;
begin
  SetLength(Text,1);
  LoadTable('_FF7\_LZ\Project\Table.tbl',Table);
  Zip:=TBinFile.Create;
  Zip.LoadFromFile('_FF7\INIT\KERNEL.BIN');
  ExtractKernelText(Zip,Table,Text);
  OptimizeText(Text);
  SaveText('_FF7\_LZ\Test\KERNEL.txt',Text);
  SaveOpt('_FF7\_LZ\Test\KERNEL.idx',Text);
  Zip.Free;
end;

procedure TForm1.Button20Click(Sender: TObject);
var Files: TImageFiles; Buf,WBuf,P: Pointer; Size: Integer;
S: String;
begin
  S:='_FF7\TestImg\'+edLBAFile.Text;
  If S[Length(S)]='/' Then
  begin
    S:=LeftStr(S,Length(S)-1);
    Size:=LoadFile(S,Buf);
    GetMem(WBuf,$10000);
    P:=Pointer(Integer(Buf)+8);
    Size:=GZip_Decompress(P,WBuf,Size-8);
    FreeMem(Buf);
  end else
    Size:=LoadFile(S,WBuf);
  LoadImageFiles('_FF7\TestImg\FileList.txt',Files);
  P:=Pointer(Integer(WBuf)+HexToInt(edLBAOffset.Text));
  Memo.Text:=GetLBAFileList(P,StrToInt(edLBACount.Text),Files,StrToInt(edLBAStep.Text));
  FreeMem(WBuf);

  {GetMem(WBuf,$10000);
  Size:=LoadFile('_FF7\TestImg\WORLD\WORLD.BIN',Buf);
  P:=Pointer(Integer(Buf)+8);
  GZip_Decompress(P,WBuf,Size-8);
  LoadImageFiles('_FF7\TestImg\FileList.txt',Files);
  P:=WBuf; Inc(Integer(P),$000273E4);
  Memo.Text:=GetLBAFileList(P,41,Files);
  FreeMem(Buf); FreeMem(WBuf);}
end;

procedure TForm1.Button21Click(Sender: TObject);
var Field: TFieldRec;
begin
  Field:=TFieldRec.Create;
  Field.LoadFromFile('_FF7\FIELD\ANFRST_2.DAT');
  Field.SaveToFile('_FF7\_LZ\ANFRST_2.DAT.U',False);
end;

procedure TForm1.Button22Click(Sender: TObject);
var Field: TFieldRec;
begin
  Field:=TFieldRec.Create;
  Field.LoadFromFile('_FF7\_LZ\Build\MD1STIN.DAT.or');
  Field.SaveToFile('_FF7\_LZ\Build\B\MD1STIN.BUILDED',False);
  Field.Free;
end;

procedure TForm1.Button23Click(Sender: TObject);
var S,S1: String;
begin
  If OpenDialog1.Execute Then
  begin
    S1:=GetFileParentDir(OpenDialog1.FileName);
    S:=ExtractFileName(OpenDialog1.FileName);
    If (S1<>'') and (FindImageFolder(S1)>=0) Then S:=S1+'\'+S;
    edLBAFile.Text:=S;
  end;
end;

procedure TForm1.Button25Click(Sender: TObject);
var Buf, WBuf: Pointer; Size: Integer; Pic: TDIB;
n: Integer; B: ^Byte;
begin
  Size:=LoadFile('_FF7\MOVIE\OVER.LZS',WBuf);
  Size:=LZ_Decompress(WBuf,Buf);
  FreeMem(WBuf);
  Pic:=TDIB.Create;
  Pic.PixelFormat:=MakeDibPixelFormat(5, 5, 5);
  Pic.BitCount:=16;
  Pic.Width:=576;
  Pic.Height:=416;
  B:=Buf;
  For n:=Pic.Height-1 downto 0 do
  begin
    Move(B^,Pic.ScanLine[n]^,Pic.WidthBytes);
    Inc(B,Pic.WidthBytes);
  end;
  Pic.SaveToFile('_FF7\MOVIE\OVER.BMP');
  Pic.Free;
  FreeMem(Buf);
end;

end.
