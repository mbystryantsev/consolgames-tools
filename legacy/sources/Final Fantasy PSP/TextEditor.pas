unit TextEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, StdActns, Menus, StdCtrls, ToolWin, ComCtrls, ExtCtrls,
  PSPRAW, XPMan, ImgList, DIB, StrUtils, BMPFnt,Packer, DXDraws;


Type
TTable = Packed Record
  Value: Word;
  Text: String;
end;

Type
  TBAHeader = Record
  Name: Array[0..21] of byte;
  Data: Word;
  Offset: DWord;
  Size: DWord;
  FullSize: DWord;
end;
{Type
  TAHeader = Record
  FileCount: DWord;
  Size: DWord;
  Blank1: DWord;
  Blank2: DWord;
end;}
THeader = Record
  Name: Array[0..21] of byte;
  Data: Word;
  Offset: DWord;
  Size: DWord;
  FullSize: DWord;
  Comp: Boolean;
end;

TAHeader = Record
  FileCount: DWord;
  Size: DWord;
  Blank1: DWord;
  Blank2: DWord;
end;


TMsgSign = Array[0..7] of Char;
TTableArray = Array of TTable;

TPath = Record
  pProgram: String;
  pFiles: String;
  pOrFiles: String;
end;

TASymbol = Packed Record
  Code,X,Y,Z: Word;
End;

TMsgBin = Packed Record
  Sign: Array[0..7] of Char;
  Count: DWord;
  Size: DWord;
  Ptr: Array of DWord;
end;

{TMsgBinPtr = Packed Record
  Sig}

TSymbol = Packed Record
  X,Y,W: Word;
end;


TSymbolArray = Array of TSymbol;



TLine =Record
  Line: Array of String;
end;


TFont = Packed Record
  Height: Word;
  Count: Word;
  Image: TDIB;
  Shadow: TDIB;
  Symbol: TSymbolArray;//Array of TSymbol;
  CBytes: Array[0..136] of Word;
end;


TMsg = Packed Record
  Count: Word;
  Name: String;
  Com: String;
  Pic: TDIB;
  Font: TFont;
  Table: TTableArray;
  Chars: Array of TASymbol;
  Text: Array of String;
end;


TMsgArray = Array of TMsg;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    mFile: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    FileSave: TAction;
    ListMsg: TListBox;
    ListDlg: TListBox;
    mText: TMemo;
    ListTbl: TListBox;
    ListFnt: TListBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ImgTbl: TImage;
    Status: TStatusBar;
    mOText: TMemo;
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
    Button2: TButton;
    XPManifest1: TXPManifest;
    ToolButton3: TToolButton;
    ImageList: TImageList;
    FileOpen: TAction;
    FileOpenDlg: TOpenDialog;
    ToolButton4: TToolButton;
    FileSaveAs: TAction;
    Exit: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    mEdit: TMenuItem;
    mPaste: TMenuItem;
    mPasteAll: TMenuItem;
    EditPaste: TAction;
    EditPasteAll: TAction;
    ToolButton7: TToolButton;
    GroupBox1: TGroupBox;
    cShowAll: TCheckBox;
    Img: TImage;
    cHideUsed: TCheckBox;
    WriteText: TAction;
    ToolButton8: TToolButton;
    EditPasteGroup: TAction;
    N1: TMenuItem;
    mView: TMenuItem;
    mMini: TMenuItem;
    mTextView: TMenuItem;
    mOptions: TMenuItem;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ShowProgress: TAction;
    cNotReplase: TCheckBox;
    DX: TDXDraw;
    Button3: TButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    EditRebuild: TAction;
    procedure FileOpenExecute(Sender: TObject);
    Procedure LoadText(Sender: TObject; S: String; var mMsg: TMsgArray);
    Procedure LoadEngText(Sender: TObject; S: String; var mMsg: TMsgArray);
    procedure WriteTextExecute(Sender: TObject);
    procedure ListDlgClick(Sender: TObject);
    procedure ListFntClick(Sender: TObject);
    procedure ListTblClick(Sender: TObject);
    procedure FileSaveExecute(Sender: TObject);
    procedure mTextChange(Sender: TObject);
    procedure EditPasteExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShowProgressExecute(Sender: TObject);
    procedure EditPasteAllExecute(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
Procedure ReplaceArc(Const pArc, pFile, pName: String);
implementation

{$R *.dfm}

Function GetName(Bytes: Array of byte): String;
var n: integer;
begin
  Result:='';
  For n:=0 to Length(Bytes)-1 do
  begin
    If Bytes[n]=0 then begin Exit; end else Result:=Result+Char(Bytes[n]);
  end;
end;

Procedure Round(var a: DWord);
begin
  Inc(a,15);
  a:=(a div 16) * 16;
end;

var Msg, OMsg: TMsgArray; OpenedFile: String; ChFlag: Boolean;
//BigFont, SmallFont: TFont;
MainFont: Array[0..1] of TFont;
var pArc: String = 'FF1PSP\ff1psp.dpk';
Pal: Array[0..15] of DWord = (0, $101010, $202020, $303030, $404040, $505050,
$606060, $707070, $808080, $909090, $A0A0A0, $B0B0B0, $C0C0C0, $D0D0D0, $E0E0E0,
$F0F0F0);
Path: TPath;
// = 'FF1PSP\Tools','FF1PSP\ff1psp'];
var Blank: Array[0..3] of DWord = (0,0,0,0); 
Procedure Build(DFile, AFile: String);
var Count, S: Dword; Compressed: Boolean; B: ^Byte;
Buf: Pointer; AHead: TAHeader; Head: Array of THeader;
n: Integer; F, FW: File; Ex: String; Size: DWord; CtSt: DWord;
BL: Integer;
begin
  //If ParamStr(1)='' then Exit;
  AssignFile(F, DFile);
  Reset(F,1);
  {BlockRead(F,S, 4);
    If S<>$36317057 then
    begin
      CloseFile(F);
      Exit;
    end;}

    Seek(F,8);
    BlockRead(F, AHead.FileCount, 4);
    Seek(F,12);
    BlockRead(F, S, 4);
    {If S=$36317057 then Compressed:=True else} Compressed:=False;
    {If Compressed=True then ex:='PCK' Else} ex:='NPK';
    AHead.Size:=16+AHead.FileCount*36;
    //Round(AHead.Size);
    SetLength(Head, AHead.FileCount);

    For n:=0 to AHead.FileCount-1 do
    begin
      Seek(F, n*32+16);
      BlockRead(F, Head[n], 24);
      Seek(F, n*32+16+28);
      BlockRead(F, CTst, 4);
      Head[n].Comp:=False;
      If CTst=$36317057 then Head[n].Comp:=True;
    end;
    CloseFile(F);
    n:=0;
    {If ParamStr(2)='' Then} AssignFile(FW, AFile{LeftStr(ParamStr(1), Length(ParamStr(1))-4)+ex});
    //else AssignFile(FW, ParamStr(2));
    Rewrite(FW,1);
    For n:=0 to AHead.FileCount-1 do
    begin
      //WriteLn(GetName(Head[n].Name));
      Round(AHead.Size);
      AssignFile(F, ExtractFilePath(DFile){+'\'}+GetName(Head[n].Name));
      //ShowMessage(ExtractFilePath(DFile)+GetName(Head[n].Name));
      Reset(F,1);
      Head[n].Size:=FileSize(F);

      If Head[n].Comp=True then
      begin
        Seek(F,4);
        BlockRead(F,Head[n].FullSize,4);
      end else
      begin
        Head[n].FullSize:=Head[n].Size;
      end;
      Head[n].Offset:=AHead.Size;
      Inc(AHead.Size, Head[n].Size);
      Seek(FW, 16 + (n*36));
      BlockWrite(FW, Head[n], 36);
      Seek(FW, Head[n].Offset);
      GetMem(Buf, Head[n].Size);
      Seek(F,0);
      BlockRead(F, Buf^, Head[n].Size);
      BlockWrite(FW, Buf^, Head[n].Size);
      FreeMem(Buf);
      CloseFile(F);
    end;
    Size:=FileSize(FW);
    Round(Size);
    If Size<>FileSize(FW) then
    begin
      Seek(FW, FileSize(FW));
      BL:=Size-FileSize(FW);
      BlockWrite(FW, Blank, BL);
    end;
    Seek(FW,0);
    AHead.Size:=Size;
    BlockWrite(FW, AHead, 16);
    If Compressed=True then
    begin
      Reset(FW,1);
      GetMem(Buf, AHead.Size + $1000);
      B:=Addr(Buf^);
      Inc(B, $1000);
      BlockRead(FW, B^, AHead.Size);
      Size:=Pack(Buf, AHead.Size, $7FF);
      Rewrite(FW,1);
      Seek(FW, 0);
      BlockWrite(FW, Buf^, Size);
      FreeMem(Buf);
    end;
    Close(FW);
end;

Function GetPart(S: String; C: Char; Num: Integer): String;
var n,m: Integer;
begin
  m:=1;
  Result:='';
  For n:=1 to Length(S) do
  begin
    If (Num=m) and (S[n]=C) Then Inc(m);
    If Num=m then
    Result:=Result+S[n];
    If (Num<>m) and (S[n]=C) Then Inc(m);
  end;
end;


Procedure Clear;
var n: Integer;
Begin
  For n:=0 To Length(Msg)-1 do
  begin
    If Assigned(Msg[n].Pic) Then Msg[n].Pic.Free;
    SetLength(Msg[n].Text,0);
    //SetLength(Msg[n].Font,0);
    If Assigned(Msg[n].Font.Image) Then Msg[n].Font.Image.Free;
    SetLength(Msg[n].Table,0);
    SetLength(Msg[n].Chars,0);
  end;
  SetLength(Msg,0);
end;

Function GetParam(S: String; Num: Integer): String;
var n,m: Integer;
begin
  m:=1;
  Result:='';
  For n:=2 to Length(S)-1 do
  begin
    If (Num=m) and (S[n]=',') Then Inc(m);
    If Num=m then
    Result:=Result+S[n];
    If (Num<>m) and (S[n]=',') Then Inc(m);
  end;
end;

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char; HexError: Boolean;
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

Procedure WriteTable(Table: TTableArray);
var n: Integer;
begin
  Form1.ListTbl.Clear;
  For n:=0 To Length(Table)-1 do
  begin
    Form1.ListTbl.Items.Add(IntToHex(Table[n].Value,(Table[n].Value div 256+1)*2)+'='+Table[n].Text);
  end;
end;

Procedure WriteCodes(Symbol: TSymbolArray);
var n: Integer;
begin
  Form1.ListFnt.Clear;
  For n:=0 To Length(Symbol)-1 do
  begin
    Form1.ListFnt.Items.Add(IntToHex(n,2*(n div 256+1)));
  end;
end;
var PicChar: TDIB;
Procedure DrawCode(Pic: TDIB; Img: TImage; Symbol: TSymbol; H: Integer);
begin
  If Symbol.W=0 then
  begin
    Img.Height:=0;
    Img.Width:=0;
    Exit;
  end;
  If not Assigned(PicChar) Then
  begin
    PicChar:=TDIB.Create;
    PicChar.BitCount:=4;
    PicChar.PixelFormat:= MakeDibPixelFormat(8, 8, 8);
    SetPallete(PicChar, Pal);
  End;
  PicChar.Height:=H*4;
  PicChar.Width:=Symbol.W*4;
  Img.Height:=H*4;
  Img.Width:=Symbol.W*4;
  PicChar.Canvas.CopyRect(Bounds(0,0,PicChar.Width,PicChar.Height),
  Pic.Canvas,Bounds(Symbol.X, Symbol.Y, Symbol.W, H));
  Img.Picture.Graphic:=PicChar;
end;

Procedure LoadTable(S: String; var Table: TTableArray);
var F: File; List: TStringList; n: Integer; SR: TSearchRec;
begin
  SetLength(Table,0);
  List:=TStringList.Create;
  FindFirst(ExtractFilePath(S)+'\'+'*.TBL', 71, SR);
  List.LoadFromFile(ExtractFilePath(S)+'\'+SR.Name);
  FindClose(SR);
  For n:=0 to List.Count-1 do
  begin
    If ((Length(List.Strings[n])=4) or (Length(List.Strings[n])=7)) and
    (MidStr(List.Strings[n],3,1)='=') then
    begin
      SetLength(Table, Length(Table)+1);
      Table[Length(Table)-1].Value :=
      HexToInt(LeftStr(List.Strings[n], Pos('=',List.Strings[n])-1));
      Table[Length(Table)-1].Text:=RightStr(List.Strings[n],
      Length(List.Strings[n])-Pos('=',List.Strings[n]));
      //WriteLn(IntToHex(Table[Length(Table)-1].Value, (Table[Length(Table)-1].Value
      //div 256+1)*2)+'='+Table[Length(Table)-1].Text);
    end;
  end;
end;



Procedure LoadFont(S: String; var mMsg: TMsgArray);
var F: File; SR: TSearchRec;
begin
  FindFirst(ExtractFilePath(S)+'\'+'*.FIF', 71, SR);
  AssignFile(F, ExtractFilePath(S)+'\'+SR.Name);
  Reset(F,1);
  BlockRead(F, mMsg[Length(mMsg)-1].Font, 4);
  Seek(F, 6);
  BlockRead(F, mMsg[Length(mMsg)-1].Font.CBytes, 137*2);
  SetLength(mMsg[Length(mMsg)-1].Font.Symbol, mMsg[Length(mMsg)-1].Font.Count);
  Seek(F, $118);
  BlockRead(F, mMsg[Length(mMsg)-1].Font.Symbol[0],mMsg[Length(mMsg)-1].Font.Count*6);
  Seek(F,0);
  CloseFile(F);
  LoadGimFont(ExtractFilePath(S)+'\'+LeftStr(SR.Name, Length(SR.Name)-3)+'GIM', mMsg[Length(mMsg)-1].Font.Image, Pal);
  FindClose(SR);
end;

Procedure LoadBMPFont(S: String; var Font: TFont);
var F: File;
begin
  AssignFile(F, S);
  Reset(F,1);
  BlockRead(F, Font, 4);
  Seek(F, 6);
  BlockRead(F, Font.CBytes, 137*2);
  SetLength(Font.Symbol, Font.Count);
  Seek(F, $118);
  BlockRead(F, Font.Symbol[0],Font.Count*6);
  Seek(F,0);
  CloseFile(F);
  If not Assigned(Font.Image) Then Font.Image:=TDIB.Create;
  Font.Image.LoadFromFile(LeftStr(S,Length(S)-3)+'BMP');
  If not Assigned(Font.Shadow) Then Font.Shadow:=TDIB.Create;
  Font.Shadow.LoadFromFile(LeftStr(S,Length(S)-4)+'_s.BMP');
end;

Procedure TForm1.LoadText(Sender: TObject; S: String; var mMsg: TMsgArray);
var n: Integer; List: TStringList; Flag: Boolean; Str: String;
begin

  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 To List.Count-1 do
  begin
    If (LeftStr(List.Strings[n],1)='[') and (RightStr(List.Strings[n],1)=']') then
    begin
      Flag:=False;
      SetLength(mMsg, Length(mMsg)+1);
      mMsg[Length(mMsg)-1].Name:=GetParam(List.Strings[n], 1);
      mMsg[Length(mMsg)-1].Count:=StrToInt(GetParam(List.Strings[n], 2));
      mMsg[Length(mMsg)-1].Com:=GetParam(List.Strings[n], 3);
      //ShowMessage(IntToStr(mMsg[Length(mMsg)-1].Count));
      LoadFont({ParamStr(0)}'FF1PSP\ff1psp_or'+'\'+mMsg[Length(mMsg)-1].Name, mMsg);  //\\\\!!!!!

      LoadTable({ParamStr(0)}'FF1PSP\ff1psp_or'+'\'+mMsg[Length(mMsg)-1].Name,
      mMsg[Length(mMsg)-1].Table);
      //ShowMessage(mMsg[Length(mMsg)-1].Name);
      ListMsg.Items.Add(mMsg[Length(mMsg)-1].Name);
      //ListMsg.Add(mMsg[Length(mMsg)-1].Name);
    end else
    begin
      If not Flag and (List.Strings[n]<>'') Then begin
        Flag:=True;
        SetLength(mMsg[Length(mMsg)-1].Text,Length(mMsg[Length(mMsg)-1].Text)+1);
      end;
      //If Length(mMsg[Length(mMsg)-1].Text)>0 then ShowMessage(mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]);
      If (Flag=True) and (List.Strings[n]='') then Flag:=False;
      If Flag Then
      begin
        If mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]<>'' Then
        Str:=#13#10 Else Str:='';
        mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]:=
        mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]+Str+List.Strings[n];
      end;
      {With mMsg[Length(mMsg)-1] do
      begin
        If (Length(Text)>0) and (Text[Length(Text)-1]<>'') then
        begin
          //If RightStr(mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1],1)='/' then Flag:=False;
          If mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]='' then Flag:=False;
        end;
      end;}
    end;


  end;
  //ListMsg.ItemIndex:=0;
  //WriteTextExecute(Sender);
  List.Free;
end;


Procedure TForm1.LoadEngText(Sender: TObject; S: String; var mMsg: TMsgArray);
var n: Integer; List: TStringList; Flag: Boolean; Str: String;
begin
  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 To List.Count-1 do
  begin
    If (LeftStr(List.Strings[n],1)='[') and (RightStr(List.Strings[n],1)=']') then
    begin
      Flag:=False;
      SetLength(mMsg, Length(mMsg)+1);
      mMsg[Length(mMsg)-1].Name:=GetParam(List.Strings[n], 1);
      mMsg[Length(mMsg)-1].Count:=StrToInt(GetParam(List.Strings[n], 2));
    end else
    begin
      If not Flag and (List.Strings[n]<>'') Then begin
        Flag:=True;
        SetLength(mMsg[Length(mMsg)-1].Text,Length(mMsg[Length(mMsg)-1].Text)+1);
      end;
      If (Flag=True) and (List.Strings[n]='') then Flag:=False;
      If Flag Then
      begin
        If mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]<>'' Then
        Str:=#13#10 Else Str:='';
        mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]:=
        mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]+Str+List.Strings[n];
      end;
      {With mMsg[Length(mMsg)-1] do
      begin
        If (Length(Text)>0) and (Text[Length(Text)-1]<>'') then
        begin
          If RightStr(mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1],1)='/' then Flag:=False;
        end;
      end;}
    end;
  end;
  List.Free;
end;


var BitmapFont: TBMPFont;
procedure TForm1.FileOpenExecute(Sender: TObject);
var n: Integer; PicChar: TDIB;
begin
  //ShowMessage('!');
  If FileOpenDlg.Execute and FileExists(FileOpenDlg.FileName) Then
  begin
    Clear;
    LoadText(Sender, FileOpenDlg.FileName, Msg);
    LoadEngText(Sender, 'FF1PSP\ff1psp\FF1_ENG.txt', OMsg);
    ListMsg.ItemIndex:=0;
    WriteTextExecute(Sender);
    OpenedFile:=FileOpenDlg.FileName;
    LoadBMPFont('FF1PSP\Tools\BigFont.FIF', MainFont[0]);
    LoadBMPFont('FF1PSP\Tools\SmallFont.FIF', MainFont[1]);
      //BitmapFont: TBMPFont;
      BitmapFont := TBMPFont.Create;
  BitmapFont.Transparent := True;
  BitmapFont.TransparentColor := 0;

  If not Assigned(PicChar) Then
  begin
    PicChar:=TDIB.Create;
    PicChar.BitCount:=4;
    PicChar.PixelFormat:= MakeDibPixelFormat(8, 8, 8);
    SetPallete(PicChar, Pal);
  End;
  PicChar.Height:=MainFont[0].Height;
  PicChar.Width:=MainFont[0].Symbol[n].W;
  //Img.Height:=H;
  //Img.Width:=Symbol.W;
  PicChar.Canvas.CopyRect(Bounds(0,0,PicChar.Width,PicChar.Height),
  MainFont[0].Image.Canvas,Bounds(MainFont[0].Symbol[n].X,MainFont[0].Symbol[n].Y, MainFont[0].Symbol[n].W, MainFont[0].Height));
  //Img.Picture.Graphic:=PicChar;
  For n:=0 To 255 do
  begin
    //MainFont[0].Image
    BitmapFont.AddFromDIBRect(PicChar,
    Bounds(0,0,PicChar.Width,PicChar.Height),
    PicChar.Width, PicChar.Height, CharToWideChar(Char(n)));
  end;
  {BitmapFont.AddFromDIBRect(DIB, Bounds, W, H, CharToWideChar);
  BitmapFont.CanvasDrawText(DXDraw1.Surface.Canvas,Text,X,Y);
  DXDraw1.Surface.Canvas.Release;
  DXDraw1.Flip;}
  end;
end;

procedure TForm1.WriteTextExecute(Sender: TObject);
var n: Integer;
begin
ChFlag:=True;
  Status.Panels.Items[0].Text:=ListMsg.Items.Strings[ListMsg.ItemIndex];
  Status.Panels.Items[1].Text:=Format('%d/%d',
  [ListMsg.ItemIndex+1, ListMsg.Count]);
  If cShowAll.Checked Then
  begin
    For n:=0 to Length(Msg[ListMsg.ItemIndex].Text)-1 do
    begin
      mText.Text:=mText.Text+Msg[ListMsg.ItemIndex].Text[n];
      mText.Lines.Add(''); 
    end;
  end else
  begin
    ListDlg.Clear;
    For n:=0 To Length(Msg[ListMsg.ItemIndex].Text)-1 do
    begin
      ListDlg.Items.Add(Msg[ListMsg.ItemIndex].Text[n]);
    end;
    ListDlg.ItemIndex:=0;
    ListDlgClick(Sender);
  end;
  WriteTable(Msg[ListMsg.ItemIndex].Table);
  WriteCodes(Msg[ListMsg.ItemIndex].Font.Symbol);
  ListTbl.ItemIndex:=0;
  ListFnt.ItemIndex:=0;
  ListTblClick(Sender);
  ListFntClick(Sender);
ChFlag:=False;
end;

procedure TForm1.ListDlgClick(Sender: TObject);
begin

  Status.Panels.Items[2].Text:=Format('%d/%d',
  [ListDlg.ItemIndex+1, ListDlg.Count]);
  If Not cShowAll.Checked then
  begin
    mText.Text:=Msg[ListMsg.ItemIndex].Text[ListDlg.ItemIndex];
    mOText.Text:=OMsg[ListMsg.ItemIndex].Text[ListDlg.ItemIndex];
  end;

end;

procedure TForm1.ListFntClick(Sender: TObject);
begin
  DrawCode(Msg[ListMsg.ItemIndex].Font.Image,Img,Msg[ListMsg.ItemIndex].Font.Symbol[ListFnt.ItemIndex],
  Msg[ListMsg.ItemIndex].Font.Height);
end;

procedure TForm1.ListTblClick(Sender: TObject);
begin
  If Msg[ListMsg.ItemIndex].Table[ListTbl.ItemIndex].Value<=ListFnt.Count-1 then
  DrawCode(Msg[ListMsg.ItemIndex].Font.Image, ImgTbl,
  Msg[ListMsg.ItemIndex].Font.Symbol[Msg[ListMsg.ItemIndex].Table[ListTbl.ItemIndex].Value],
  Msg[ListMsg.ItemIndex].Font.Height);
end;

Procedure SaveMsg(S: String);
var n,m: Integer; MsgList: TStringList; Str: String;
begin
  MsgList:=TStringList.Create;
  For n:=0 to Length(Msg)-1 do
  begin
    //ShowMessage(IntToStr(Msg[n].Count));
    If Msg[n].Com<>'' then Str:=','+Msg[n].Com else Str:='';
    MsgList.Add(Format('[%s,%d%s]',[Msg[n].Name,Msg[n].Count,Str]));
    MsgList.Add('');
    For m:=0 to Length(Msg[n].Text)-1 do
    begin
      MsgList.Add(Msg[n].Text[m]);
      MsgList.Add('');
    end;
  end;
  MsgList.SaveToFile(S);
  MsgList.Free;
end;


procedure TForm1.FileSaveExecute(Sender: TObject);
begin
 SaveMsg(OpenedFile);
end;

procedure TForm1.mTextChange(Sender: TObject);
begin
  If ChFlag=False then
  begin
    Msg[ListMsg.ItemIndex].Text[ListDlg.ItemIndex]:=mText.Text;
    ListDlg.Items.Strings[ListDlg.ItemIndex]:=mText.Text;
  end;
end;

Procedure SaveTable(S: String; Table: TTableArray);
var List: TStringList; n: Integer;
begin
  List:=TStringList.Create;
  For n:=0 to Length(Table)-1 do
  begin
    List.Add(IntToHex(Table[n].Value,(Table[n].Value div 256+1)*2)+'='+Table[n].Text);
  end;
  List.SaveToFile(S); 
  List.Free;
end;

Procedure GenerateTable();
Begin
end;

Procedure SaveFont(Font: TFont; S: String; Pic: TDIB);
var F: File; Buf: Pointer; Null: Word; B: ^Byte; Size: Integer; CBytes: Array[0..136] of Word;
begin
  Null:=0;
  AssignFile(F, S);
  Reset(F,1);
  Seek(F,6);
  BlockRead(F, CBytes, 137*2);
  Rewrite(F,1);
  BlockWrite(F,Font,4);
  Seek(F,4);
  BlockWrite(F,Null,2);
  Seek(F,6);
  BlockWrite(F, {Font.}CBytes, 137*2);
  Seek(F,$118);
  BlockWrite(F, Font.Symbol[0], Length(Font.Symbol)*6);
  CloseFile(F);
  AssignFile(F, 'FF1PSP\Tools\Font.gim');
  Reset(F,1);
  Size:=FileSize(F);
  GetMem(Buf,Size);
  BlockRead(F, Buf^, Size);
  CloseFile(F);
  AssignFile(F, LeftStr(S,Length(S)-3)+'GIM');
  Rewrite(F,1);
  B:=Addr(Buf^);
  Inc(B, $80);
  DIBToRAW(Pic, Addr(B^));
  BlockWrite(F, Buf^, Size);
  CloseFile(F);
  FreeMem(Buf);
end;

Procedure GenerateFont(Table: Array of TTable; var Font: TFont; {FIFFile: String;} var pic: TDIB; const FontID: Byte);
var Wd: Array of Word; n,m: Integer; {Pic: TDIB;} cX,cY: Word; //FontID: Byte;
begin
  //FontID:=0;
  SetLength(Wd,1);
  SetLength(Font.Symbol,Length(Table)+1);
  Font.Height:=MainFont[FontID].Height;
  Font.Count:=Length(Table)+1;
  For n:=0 To Length(Table)-1 do
  begin
    For m:=0 To Length(Wd)-1 do
    begin
      If 512-Wd[m]>=MainFont[FontID].Symbol[Byte(Table[n].Text[1])].W then
      begin
        Font.Symbol[n+1].X:=Wd[m];
        Font.Symbol[n+1].Y:=(m)*Font.Height;
        Font.Symbol[n+1].W:=MainFont[FontID].Symbol[Byte(Table[n].Text[1])].W;
        Inc(Wd[Length(Wd)-1],MainFont[FontID].Symbol[Byte(Table[n].Text[1])].W);
      end else
      If m=Length(Wd)-1 then begin
        SetLength(Wd, Length(Wd)+1);
        Inc(Wd[Length(Wd)-1],MainFont[FontID].Symbol[Byte(Table[n].Text[1])].W);
        Font.Symbol[n+1].X:=0;
        Font.Symbol[n+1].Y:=(m+1)*Font.Height;
        Font.Symbol[n+1].W:=MainFont[FontID].Symbol[Byte(Table[n].Text[1])].W;
        Break;
      end;
    end;
  end;
  Font.CBytes[31]:=0;
  Font.CBytes[$64]:=1;
  Font.Image:=TDib.Create;
  Font.Shadow:=TDIB.Create;
  Font.Image.Height:=168;
  Font.Shadow.Height:=168;
  Font.Image.Width:=512;
  Font.Shadow.Width:=512;
  {Font.Shadow.BitCount:=4;
  Font.Image.BitCount:=4;
  SetPallete(Font.Image,Pal);
  SetPallete(Font.Shadow,Pal);}
  For n:=1 To Length(Table) do
  begin
    With Font.Symbol[n] do
    begin
      cY:=Byte(Table[n-1].Text[1]);
      cY:=(cY div 16)*32;
      cX:=Byte(Table[n-1].Text[1]);
      cX:=cX*32-((cX div 16)*16)*32;
      Font.Image.Canvas.CopyRect(Bounds(X,Y,W, Font.Height), MainFont[FontID].Image.Canvas,
      Bounds(cX, cY,W,Font.Height));
      Font.Shadow.Canvas.CopyRect(Bounds(X,Y,W, Font.Height), MainFont[FontID].Shadow.Canvas,
      Bounds(cX, cY,W,Font.Height));
    end;
  end;
  //Font.Image.SaveToFile('FTest.bmp');
  Pic:=TDIB.Create;
  {Pic.Height:=168*2;
  Pic.Width:=512;
  Pic.BitCount:=4;
  SetPallete(Pic, Pal);}
  {If FontID=0 then }Pic.LoadFromFile('FF1PSP\Tools\BigFont_f.bmp');// else Pic.LoadFromFile('FF1PSP\Tools\SmallFont_f.bmp');
  Pic.Canvas.CopyRect(Bounds(0,0,512,198),Font.Image.Canvas, Bounds(0,0,512,198));
  Pic.Canvas.CopyRect(Bounds(0,198,512,198),Font.Shadow.Canvas, Bounds(0,0,512,198));
  //Pic.SaveToFile('PicTest.bmp');
  //SaveFont(Font, FIFFont{'Fnt.FIF'}, Pic);
end;

procedure GenerateMsg(var Buf: Pointer; var Size: Integer; var mTable: TTableArray; const Num: Integer);
var CBNum, n,m,l,p: Integer; List: TStringList; {Buf: Pointer;} B: ^Byte; W: ^Word;
Pos: Integer; MsgBin: TMsgBin; S: String; {mTable: Array of TTable;}
CBytes: Array[0..136] of Word; CB: Word; C: Char; TblFlag: Boolean; V, VL: Word;
cLine, cScreen, cStop: Word; F: File; Font: TFont; MB: ^TMsgBin; DW: ^DWord; MS: ^TMsgSign;
begin
  cStop:=0;
  CBNum:=4;
  For n:=0 to 136 do
  begin
    CBytes[n]:=$FFFF;
  end;
  //GetMem(Buf, $10000);
  List:=TStringList.Create;
  MsgBin.Sign:=#0#0#0#0+'TEXT';
  With Msg[{Form1.ListMsg.ItemIndex}Num] do
  begin
    For n:=0 To Length(Text)-1 do
    begin
      List.Text:=Text[n];
      For m:=0 To List.Count-1 do
      begin
        S:=List.Strings[m];
        p:=1;
        While p<=Length(S) do
        begin
          If (S[p]='<') or (S[p]='{') then
          begin
            Inc(p,4);
            If (Length(S)-p>=7) and (S[p]='<') and (S[p+5]='>') then Inc(p,2);
          end else
          begin
            TblFlag:=False;
            C:=S[p];
            //ShowMessage(IntToStr(Length(mTable)-1));
            For l:=0 To Length(mTable)-1 do
            begin
              If (C='/') or (C='^') or (C='~') Then
              begin
                TblFlag:=True;
                Inc(p);
                Break;
              end;
              If {((Length(S)-p+1)>=Length(mTable[l].Text)) and
              (Mid(S, p,Length(mTable[l].Text)=mTable[l].Text)}
              mTable[l].Text=C then
              Begin
                TblFlag:=True;
                V:=l;
                Inc(p{, Length(mTable[l].Text)});
                Break;
              end;
            end;
            If not TblFlag Then
            begin
              Inc(p);
              SetLength(mTable, Length(mTable)+1);
              mTable[Length(mTable)-1].Value:=Length(mTable);
              mTable[Length(mTable)-1].Text:=C;
            end;
          end;
        end;
      end;
    end;
    cLine:=Length(mTable)+2;
    cScreen:=cLine+2;
    MsgBin.Count:=(Length(Text) SHL 8)+1;
    SetLength(MsgBin.Ptr,MsgBin.Count SHR 8);
    Pos:=16+(MsgBin.Count SHR 8)*4;
    B:=Addr(Buf^);
    Inc(B,Pos);
    W:=Addr(B^);
    For n:=0 To Length(Text)-1 do
    begin
    Form1.Status.Panels.Items[3].Text:=Format('[%d/%d]',[n+1,Length(Text)]);
    Form1.Status.Refresh;
      //
      If n>0 then
      begin
        B^:=0;
        Inc(B);
        Inc(Pos);
        W:=Addr(B^);
      end;
      //
      MsgBin.Ptr[n]:=Pos;
      List.Text:=Text[n];
      For m:=0 To List.Count-1 do
      begin
        If m>0 Then
        begin
          B^:=cLine;
          Inc(B);
          Inc(Pos);
          W:=Addr(B^);
        end;
        p:=1;
        S:=List.Strings[m];
        While p<=Length(S) do
        begin
          If S[p]='<' Then
          begin
            CB:=HexToInt(MidStr(S,P+1,2));
            {If CBytes[CB]=$FFFF then
            begin
              CBytes[CB]:=CBNum;
              Inc(CBNum);
            end;}
            {If Length(Table)+2+CBytes[CB]>255 Then
            begin
              W^:=Length(Table)+2+CBytes[CB];
              Inc(B); Inc(Pos);
            end else}
              B^:=Length(mTable)+1+CB{2+CBytes[CB]};
            Inc(Pos);
            Inc(B);
            W:=Addr(B^);
            Inc(p,4);
          end else
          If S[p]='{' Then
          begin
            B^:=HexToInt(MidStr(S,P+1,2));
            Inc(p,4);
            Inc(B);
            W:=Addr(B^);
            Inc(Pos);  
          end else
          If (S[p]='/') or (S[p]='^') or (S[p]='~') then
          begin
            If S[p]='~' Then B^:=cScreen else if S[p]='/' then
            B^:=cStop else B^:=cLine;
            Inc(B); Inc(Pos); Inc(p); W:=Addr(B^);
          end else
          begin
            C:=S[p];
            For l:=0 To Length(mTable)-1 do
            begin
              If mTable[l].Text=C then
              Begin
                B^:=l+1;
                Inc(p);
                Inc(B);
                W:=Addr(B^);
                Inc(Pos);
                Break;
              end;
            end;
          end;
        end;      
      end;
    end;
    B^:=0;
    Inc(B);
    Inc(Pos);
    W:=Addr(B^);
  end;
  MsgBin.Size:=Pos;
  MS:=Addr(Buf^);
  MS^:=#0#0#0#0+'TEXT';
  DW:=Addr(Buf^);
  Inc(DW,2);
  DW^:=MsgBin.Count;
  Inc(DW);
  DW^:=MsgBin.Size;
  Inc(DW);
  For n:= 0 to Length(MsgBin.Ptr)-1 do
  begin
    DW^:=MsgBin.ptr[n];
    Inc(DW);
  end;

  {MB:=Addr(Buf^);
  MB^:=MsgBin;}
  Size:=Pos;
  {AssignFile(F, 'Test.Msg');
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F, Buf^, Pos);
  Seek(F,0);
  BlockWrite(F, MsgBin, 16);
  Seek(F,16);
  BlockWrite(F, MsgBin.Ptr[0], (MsgBin.Count SHR 8)*4);
  CloseFile(F);}
  List.Free;
  {FreeMem(Buf);
  SaveTable('Test.TBL', mTable);
  For n:=0 To 136 do
  begin
      Font.CBytes[n]:=CBytes[n];
  end;

  GenerateFont(mTable, Font, 'GimTest.GIM');}
end;

procedure TForm1.EditPasteExecute(Sender: TObject);
var Table: TTableArray; Buf: Pointer; Size: Integer; F: File;
Font: TFont; Pic: TDIB; SR: TSearchRec; pDir{, pArc}, ANM: String; Sign: Array[0..7] Of Char;
FontID: Byte;
begin
  GetMem(Buf, $10000);
  GenerateMsg(Buf, Size, Table, ListMsg.ItemIndex);
  SaveTable('Test.TBL', Table);
  pDir:=ExtractFilePath(Path.pFiles+'\'+ListMsg.Items.Strings[ListMsg.ItemIndex]);
  AssignFile(F, Path.pFiles+'\'+ListMsg.Items.Strings[ListMsg.ItemIndex]);
  Rewrite(F,1);
  Seek(F,0);
  BlockWrite(F, Buf^, Size);
  CloseFile(F);
  FindFirst(pDir+'\*.FIF', faAnyFile, SR);
  If Msg[ListMsg.ItemIndex].Font.Height=$12 Then FontID:=0 Else FontID:=1;
  GenerateFont(Table, Font, {'GimTest.FIF',} Pic, FontID);
  SaveFont(Font, pDir+'\'+SR.Name, Pic);
  FindClose(SR);
  FindFirst(pDir+'\*.DATA', faAnyFile, SR);
  AssignFile(F, pDir+'\'+SR.Name);
  Reset(F,1);
  Seek(F,0);
  BlockRead(F,Sign,8);
  If Sign<>'FFPSPDT2' Then FindNext(SR);
  FindClose(SR);
  ANM:=pDir+GetPart(ListMsg.Items.Strings[ListMsg.ItemIndex],'\',1)+'.PCK';
  Build(pDir+'\'+SR.Name, ANM);
  ReplaceArc(pArc, ANM, ExtractFileName(ANM));
  FreeMem(Buf);
  Pic.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
Path.pProgram:='FF1PSP\Tools';
Path.pFiles:='FF1PSP\ff1psp';
Path.pOrFiles:='FF1PSP\ff1psp_or';
end;
{
  BitmapFont: TBMPFont;
  BitmapFont := TBMPFont.Create;
  BitmapFont.Transparent := True;
  BitmapFont.TransparentColor := 0;
  BitmapFont.AddFromDIBRect(DIB, Bounds, W, H, CharToWideChar);
  BitmapFont.CanvasDrawText(DXDraw1.Surface.Canvas,Text,X,Y);
  DXDraw1.Surface.Canvas.Release;
  DXDraw1.Flip;
}

Procedure ReplaceArc(Const pArc, pFile, pName: String);
var
varList: TextFile;    NM: String;
F, FW: File; {FT: TextFile;} Buf, Buffer: pointer;
Header: Array of TBAHeader; AHeader: TAHeader;
H: ^TBAHeader; n: Integer; S: DWord; FSize, Size: DWord;
UnpBuf: Pointer;
begin
  //If ParamStr(1)='' then Exit;
  AssignFile(F, pArc);
  Reset(F,1);

  Seek(F,0);
  BlockRead(F,AHeader, 16);
  FSize:=FileSize(F);
  If AHeader.Size<>FSize then
  begin
    CloseFile(F);
    //FreeMem(Buffer);
    Exit;
  end;
  SetLength(Header,AHeader.FileCount);
  GetMem(Buffer,AHeader.FileCount*$24);
  Seek(F, $10);
  BlockRead(F, Buffer^, AHeader.FileCount*$24);
  H:=Addr(Buffer^);
  For n:=0 to AHeader.FileCount-1 do
  begin
    Header[n]:=H^;
    inc(H);
  end;

  If pName<>'' then begin NM:= pName; end else NM:=ExtractFileName(pFile);
  For n:=0 to AHeader.FileCount-1 do
  begin
    //WriteLn(GetName(Header[n].Name)+'  '+NM);
    //ShowMessage(GetName(Header[n].Name)+' '+NM );
    If GetName(Header[n].Name)=NM then
    begin
      AssignFile(FW, pFile);
      Reset(FW,1);
      Size:=Header[n].Size;
      Round(Size);
      If FileSize(FW)>Size then
      begin
        Seek(F, FileSize(F));
        Header[n].Offset:=FileSize(F);
      end else
      begin
        Seek(F, Header[n].Offset);
      end;
      Header[n].Size:=FileSize(FW);
      Header[n].FullSize:=FileSize(FW);
      GetMem(Buf, FileSize(FW));
      BlockRead(FW, Buf^, FileSize(FW));
      BlockWrite(F, Buf^, FileSize(FW));
      FreeMem(Buf);
      Seek(F, n*$24+16);
      BlockWrite(F, Header[n], $24);
      break;
    end;
  end;
  //FreeMem(Buffer);
  AHeader.Size:=FileSize(F);
  CloseFile(FW);
  Seek(F,0);
  BlockWrite(F, AHeader, 16);
  CloseFile(F);

end;


Function GetChanges(const n: Integer): Integer;
var m: Integer;
begin
  Result:=0;
  For m:=0 to Length(Msg[n].Text)-1 do
  begin
    If Msg[n].Text[m]<>OMsg[n].Text[m] then Inc(Result);
  end;
end;

procedure TForm1.ShowProgressExecute(Sender: TObject);
var n, cDlg, cMesg, cAll: Integer;
begin
  cDlg:=0; cMesg:=0; cAll:=0;
  For n:=0 to Length(Msg)-1 do
  begin
    Inc(cDlg,GetChanges(n));
    Inc(cAll, Msg[n].Count);
    If GetChanges(n)<>0 then inc(cMesg);
  end;
  ShowMessage(Format('[%d/%d]'+#13#10+'%d/%d'+#13#10+'%d%%',
  [cDlg,cAll,cMesg,Length(Msg),(cDlg*100) div cAll]));
end;

procedure TForm1.EditPasteAllExecute(Sender: TObject);
var Table: TTableArray; Buf: Pointer; Size: Integer; F: File;
Font: TFont; Pic: TDIB; SR: TSearchRec; pDir{, pArc}, ANM: String; Sign: Array[0..7] Of Char;
Chck, Cmpl: Array of Boolean; n,m: Integer; Nam: String; NamesList: TStringList;
FontID: Byte;
begin
  GetMem(Buf, $10000);
  SetLength(Cmpl, Length(Msg));
  NamesList:=TStringList.Create;
  For n:=0 to Length(Msg)-1 do
  begin
    Status.Panels.Items[4].Text:=Format('[%d/%d]',[n+1, Length(Msg)]);
    
    //If not Chck[n] Then
    //begin
      //Chck[n]:=True;
      If {(Msg[n].Font.Height=$12) and} (Cmpl[n]=False) and (GetChanges(n)>0) {and (n=3)} then
      begin
        //GetMem(Buf, $10000);
        Nam:=GetPart(Msg[n].Name, '\', 1);
        NamesList.Add({ExtractFilePath(Msg[n].Name)} GetPart(Msg[n].Name, '\', 1) +'.PCK');
        For m:=0 To Length(Msg)-1 Do
        begin
          If (Cmpl[m]=False) and (GetPart(Msg[m].Name, '\', 1)=Nam) then
          begin
            GenerateMsg(Buf, Size, Table, m);
            AssignFile(F, Path.pFiles+'\'+{ListMsg.Items.Strings[n]} Msg[m].Name);
            Rewrite(F,1);
            Seek(F,0);
            BlockWrite(F, Buf^, Size);
            CloseFile(F);
            Cmpl[m]:=True;
          end;
        end;
        //SaveTable('Test.TBL', Table);
        pDir:=ExtractFilePath(Path.pFiles+'\'+{ListMsg.Items.Strings[n]}Msg[n].Name);
        FindFirst(pDir+'\*.FIF', faAnyFile, SR);
        If Msg[n].Font.Height=$12 Then FontID:=0 Else FontID:=1;
        GenerateFont(Table, Font, {'GimTest.FIF',} Pic, FontID);
        SaveFont(Font, pDir+'\'+SR.Name, Pic);
        FindClose(SR);
        FindFirst(pDir+'\*.DATA', faAnyFile, SR);
        AssignFile(F, pDir+'\'+SR.Name);
        Reset(F,1);
        Seek(F,0);
        BlockRead(F,Sign,8);
        If Sign<>'FFPSPDT2' Then FindNext(SR);
        FindClose(SR);
        ANM:=pDir+GetPart(Msg[n].Name,'\',1)+'.PCK';
        Build(pDir+'\'+SR.Name, ANM);
        If Not cNotReplase.Checked Then
        begin
          ReplaceArc(pArc, ANM, ExtractFileName(ANM));
        end;
        //FreeMem(Buf);
        Pic.Free;
        SetLength(Table,0);
      end;
    //end;
  end;
  //NamesList.SaveToFile('NamesList.txt'); 
  NamesList.Free;
  FreeMem(Buf);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  BitmapFont.CanvasDrawText(DX.Surface.Canvas,'Test',0,0);
  DX.Surface.Canvas.Release;
  DX.Flip;
end;

end.
