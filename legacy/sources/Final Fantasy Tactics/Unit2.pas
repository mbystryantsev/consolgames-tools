unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, ComCtrls, FFT;

type
  TForm2 = class(TForm)
    File1: TEdit;
    File2: TEdit;
    File3: TEdit;
    File4: TEdit;
    File5: TEdit;
    Button1: TButton;
    GroupBox1: TGroupBox;
    Memo: TMemo;
    List1: TListBox;
    List2: TListBox;
    List3: TListBox;
    PBar: TProgressBar;
    Button2: TButton;
    Button3: TButton;
    List4: TListBox;
    List5: TListBox;
    List6: TListBox;
    Memo2: TMemo;
    CheckBox: TCheckBox;
    Dadr: TEdit;
    Badr: TEdit;
    List7: TListBox;
    Button4: TButton;
    Button5: TButton;
    ODialog: TOpenDialog;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    cIgnoreErrors: TCheckBox;
    cCompress: TCheckBox;
    cBigOnly: TCheckBox;
    cClearLog: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure List1Click(Sender: TObject);
    procedure List2Click(Sender: TObject);
    procedure List4Click(Sender: TObject);
    procedure List5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cIgnoreErrorsClick(Sender: TObject);
    procedure cCompressClick(Sender: TObject);
    //procedure FormCreate(Sender: TObject);
    //procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  HexError: Boolean;

Function HexToInt(S: String): Integer;

implementation

{$R *.dfm}
uses Unit1, Unit3;
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
  TPAdr = Record
    Flag  : Boolean;
    Block : Integer;
    Dialog: Integer;
  end;

Type
  TAdrA = Record
    A : Array of TPAdr;
  end;

{Type
  TTable = Record
    S: String;
    V: Array of Integer;
  end;}

Type
  TPasteBuf = Record
    Buffer : Pointer;
    Pos    : ^Byte;
    Size   : Integer;
  end;

Type
  TPasteBlock = Record
    Line   : Array of TStringList;
    Count  : Integer;
    Adress : Array of Integer;
    R      : Array of TPasteBuf;
  end;


var B: Array of TPasteBlock;
optID, optID2: Integer;
MBuffer: Pointer; MPos: ^Byte;
FBuffer: Pointer; FPos: ^Byte;
IDx: Array of TAdrA;
//Table: Array of TTable;
Table: TTableArray;

procedure TForm2.Button1Click(Sender: TObject);
var F1, F2, F3, F4: TextFile;
BNum, n,m, IDb, IDd,c: Integer;
S, S2: String;
RFlag: Boolean;
begin
If not FileExists(file1.Text) then
begin
  beep;
  ShowMessage('Файла "'+file1.Text+'" не существует!');
  Exit;
end;
If not FileExists(file2.Text) then
begin
  beep;
  ShowMessage('Файла "'+file2.Text+'" не существует!');
  Exit;
end;
If not FileExists(file3.Text) then
begin
  beep;
  ShowMessage('Файла "'+file3.Text+'" не существует!');
  Exit;
end;
If not FileExists(file4.Text) then
begin
  beep;
  ShowMessage('Файла "'+file4.Text+'" не существует!');
  Exit;
end;
Button1.Enabled:=False;
AssignFile(F1, File1.Text);
Reset(F1);
AssignFile(F2, File2.Text);
Reset(F2);
BNum:=-1;
RFlag:=False;

While not EoF(F1) do
begin
  Readln(F1,S);
  If (Length(S)>=2) and (S[1]+S[2]='//') then
  begin
  end else
  If LeftStr(S,2) = '@@' then
  begin
    Inc(BNum);
    SetLength(B, BNum+1);
    B[BNum].Count:=0;
    //Загрузка адресов
    ReadLn(F2,S2);
    SetLength(B[BNum].Adress, 0);
    For m:=0 to ((Length(S2)+1) div 18)-1 do
    begin
      SetLength(B[BNum].Adress, Length(B[BNum].Adress)+1);
      B[BNum].Adress[Length(B[BNum].Adress)-1]:=HexToInt(MidStr(S2,(m*18)+1,8));
      //:=MidStr(S,3,17);
    end;
    //---
  end else
  begin
    If BNum>=0 then
      If S<>'' then
      begin
        If RFlag=False then
        begin
          Inc(B[BNum].Count);
          SetLength(B[BNum].Line, B[BNum].Count);
          B[BNum].Line[B[BNum].Count-1]:=TStringList.Create;
          RFlag:=True;
        end;
        B[BNum].Line[B[BNum].Count-1].Add(S);
        If S[Length(S)]='\' then
        begin
          RFlag:=False;
        end;
      end else if (S='') and (RFlag=True) then
        B[BNum].Line[B[BNum].Count-1].Add(S);
      begin
      end;
    begin
    end;
  end;
end;
CloseFile(F1);
CloseFile(F2);
//Button2.Enabled:=True;

m:=-1;
IDd:=-1;
IDb:=-1;
SetLength(IDX, Length(B));
AssignFile(F3, File3.Text);
Reset(F3);
While not eof(F3) do
begin
  ReadLn(F3,S);
  If S='' then
  begin
  end else if (Length(S)>=2) and (S[1]+S[2]='@@') then
  begin
    m:=-1;
    Inc(IDb);
    IDd:=-1;
  end else if S='Read' then
  begin
    Inc(IDd);
    SetLength(IDx[IDb].A, IDd+1);
    Inc(m);
    IDx[IDb].A[IDd].Flag:=True;
    IDx[IDb].A[IDd].Block:=IDb;
    IDx[IDb].A[IDd].Dialog:=m;
  end else
  begin 
    Inc(IDd);
    SetLength(IDx[IDb].A, IDd+1);
    IDx[IDb].A[IDd].Block:=HexToInt(LeftStr(S,4))-1;
    c:=-1;
    For n:=0 to HexToInt(RightStr(S,4)) do
    begin
      If IDx[IDx[IDb].A[IDd].Block].A[n].Flag=True then inc(c);
    end;
    IDx[IDb].A[IDd].Dialog:=c;
  end;
end;
CloseFile(F3);

{AssignFile(F4, File4.Text);
Reset(F4);
While not eof(F4) do
begin
  ReadLn(F4,S);
  If (pos('=',S)>0) and ((pos('=',S)-1) / 2 = (pos('=',S)-1) div 2 )then
  begin
    SetLength(Table, Length(Table)+1);
    SetLength(Table[Length(Table)-1].V, ((pos('=',S)-1) div 2));
    For n:=0 to ((pos('=',S)-1) div 2)-1 do
    begin
      Table[Length(Table)-1].V[n]:=HexToInt(MidStr(S,(n*2)+1,2));
    end;
    S2:=RightStr(S, Length(S)-pos('=',S));
    Table[Length(Table)-1].S:=S2;
  end;
end;
SetLength(Table, Length(Table)+1);
SetLength(Table[Length(Table)-1].V,1);
Table[Length(Table)-1].V[0]:=$fe;
Table[Length(Table)-1].S:='\';
SetLength(Table, Length(Table)+1);
SetLength(Table[Length(Table)-1].V,1);
Table[Length(Table)-1].V[0]:=$f8;
Table[Length(Table)-1].S:='^';
CloseFile(F4);}
LoadTable(File4.Text, Table);

For n:=0 To length(IDx)-1 do
begin
  List4.Items.Add(IntToStr(n));
end;

For n:=0 to Length(B)-1 do
begin
  If Assigned(B[n].Line) Then
  begin
    List1.Items.Add(IntToStr(n+1)+' - '+B[n].Line[0].Strings[0]);
  end else
  begin
    List1.Items.Add(IntToStr(n+1)+' - <Пусто>');
  end;
end;

{For n:=0 To Length(Table)-1 do
begin
  S:='';
  For m:=0 to Length(Table[n].V)-1 do
  begin
    S:=S+IntToHex(Table[n].V[m],2);
  end;
  List6.Items.add(S+'='+Table[n].S);
end;}
For n:=0 To Length(Table)-1 do
begin
  S:='';
  If Table[n].Value>255 Then
    S:=S+IntToHex(((Table[n].Value SHL 8)+(Table[n].Value SHR 8)) and $FFFF, 4)
  else
    S:=S+IntToHex(Table[n].Value, 2);
  List6.Items.add(S+'='+Table[n].Text);
end;


List1.ItemIndex:=0;
List1Click(Sender);
List4.ItemIndex:=0;
List4Click(Sender);
Button2.Enabled:=True;
end;

procedure TForm2.List1Click(Sender: TObject);
var n, cnt: integer;
begin
cnt:=0;
//GroupBox1.Caption:='Испытательный полигон ['+IntToStr(List1.ItemIndex)+'/'+IntToStr(List1.Items.Count)+']:';
GroupBox1.Caption:=format('Испытательный полигон [%d/%d]-[%d/%d]:',
[List1.ItemIndex+1,List1.Items.Count,List2.ItemIndex+1,List2.Items.Count]);
List2.Clear;
{If Opt=False then
begin}
  optID:=List1.ItemIndex;
{end else
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
end;}
//AdrText.Text:=Block[optID].Adress;

{If opt2=False then
begin}
  For n:=0 to B[optID].Count-1 do
  begin
    List2.Items.Add(IntToStr(n+1)+' - '+B[optID].Line[n].Strings[0]);
  end;
{end else
  For n:=0 to Block[optID].Count-1 do
  begin
    If Block[OptID].R[n].PrintLn=True then
    begin
      List2.Items.Add(IntToStr(n+1)+' - '+Block[optID].Line[n].Strings[0]);
    end;
  end;
begin
end;}
List3.Clear;
For n:=0 To Length(B[optID].Adress)-1 do
begin
  List3.Items.Add(IntToHex(B[optID].Adress[n],8)); 
end;

List2.ItemIndex:=0;
List2Click(Sender);
end;

procedure TForm2.List2Click(Sender: TObject);

var n, cnt: integer;
begin
GroupBox1.Caption:=format('Испытательный полигон [%d/%d]-[%d/%d]:',
[List1.ItemIndex+1,List1.Items.Count,List2.ItemIndex+1,List2.Items.Count]);
Memo.Text:='';
cnt:=0;
//ShowMessage(IntToStr(Block[List1.ItemIndex].Line[List2.ItemIndex].Count));
If list2.ItemIndex>=0 then
begin
{If opt2=False then
begin}
  OptID2:=List2.ItemIndex;
{end else
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
end;}

For n:=0 to B[optID].Line[OptID2].Count-1 do
begin
  Memo.Lines.add(B[optID].Line[OptID2].Strings[n]);
end;
end;
end;

procedure TForm2.List4Click(Sender: TObject);
var n: integer; s: string;
begin
List5.Clear;
For n:=0 To Length(IDx[List4.ItemIndex].A)-1 do
begin
  List5.Items.Add(Format('%d - %d-%d [%s] "%s"',
  [n,IDx[List4.ItemIndex].A[n].Block,IDx[List4.ItemIndex].A[n].Dialog,BoolToStr(IDx[List4.ItemIndex].A[n].Flag, True),
  B[IDx[List4.ItemIndex].A[n].Block].Line[IDx[List4.ItemIndex].A[n].Dialog].Strings[0]]));
end;
List5.ItemIndex:=0;
List5Click(Sender);
end;//!!!
procedure TForm2.List5Click(Sender: TObject);
var n:integer;
begin
Memo2.Clear;
CheckBox.Checked:=IDx[List4.ItemIndex].A[List5.ItemIndex].Flag;
BAdr.Text:=IntToStr(IDx[List4.ItemIndex].A[List5.ItemIndex].Block);
DAdr.Text:=IntToStr(IDx[List4.ItemIndex].A[List5.ItemIndex].Dialog);
For n:=0 to B[IDx[List4.ItemIndex].A[List5.ItemIndex].Block].Line[IDx[List4.ItemIndex].A[List5.ItemIndex].Dialog].Count-1 do
begin
Memo2.Lines.Add(B[IDx[List4.ItemIndex].A[List5.ItemIndex].Block].Line[IDx[List4.ItemIndex].A[List5.ItemIndex].Dialog].Strings[n]);
end;

end;//!!!


procedure TForm2.Button2Click(Sender: TObject);
var n,m,z,l,r,ps,sz, size: integer; cFlag: Boolean;
NPos: ^byte; F: File;
S: String;
begin

Button2.Enabled:=False;
PBar.Min:=0;
PBar.Max:=Length(B)-1;
GetMem(MBuffer, $10000);
for n:=0 to Length(B)-1 do
begin
PBar.Position:=n;
//PBar.Refresh;
  SetLength(B[n].R,Length(B[n].Line));
  for l:=0 to Length(B[n].R)-1 do
  begin
    {sz:=0;
    size:=0;
    MPos:=Addr(MBuffer^);
    cFlag:=False;
    for z:=0 to B[n].Line[l].Count-1 do
    begin
      S:=B[n].Line[l].Strings[z];
      ps:=1;
      sz:=Length(B[n].Line[l].Strings[z]);
      If cFlag=True then
      begin
        MPos^:=$f8;
        inc(size);
        inc(MPos);
      end;
      cFlag:=True;
      while ps<=sz do
      begin
        If ((sz-ps)+1>=5) and (MidStr(S,ps,2)='[#') and (MidStr(S,ps+4,1)=']') then
        begin
          MPos^:=HexToInt(MidStr(S,ps+2,2));
          inc(ps,5);
          inc(size);
          inc(MPos);
        end else
        begin
          for m:=0 to Length(Table)-1 do
          begin
            If ((sz-ps)+1>=Length(Table[m].S)) and (MidStr(S,ps,Length(Table[m].S))=Table[m].S) then
            begin
              for r:=0 to length(Table[m].V)-1 do
              begin
                MPos^:=Table[m].V[r];
                inc(size);
                inc(MPos);
              end;
              inc(ps,Length(Table[m].S));
              break;
            end else if length(Table)-1=m then
            begin
              inc(ps);
              //inc(size);
              //inc(MPos);
            end;
          end;
        end;
      end;

    end;
    B[n].R[l].Size:=Size; }
    //
    B[n].R[l].Size:=PasteText(B[n].Line[l].Text, Table, MBuffer);
    GetMem(B[n].R[l].Buffer, B[n].R[l].Size);
    NPos:=Addr(B[n].R[l].Buffer^);
    MPos:=Addr(MBuffer^);
    For m:=0 to B[n].R[l].Size-1 do
    begin
      NPos^:=MPos^;
      Inc(NPos);
      Inc(MPos);
    end;
    //CopyMem(MBuffer, B[n].R[l].Buffer, B[n].R[l].Size);

    {If cCompress.Checked Then
    begin
      B[n].R[l].Size:=
      Compress(B[n].R[l].Buffer, B[n].R[l].Size);
    end;}
  end;
end;
PBar.Position:=0;
FreeMem(MBuffer);
{AssignFile(F, 'F.f');
Rewrite(F,1);
BlockWrite(F,B[0].R[0].Buffer^,B[0].R[0].Size);
CloseFile(F);}
Button3.Enabled:=True;
end;//!!!

procedure TForm2.Button3Click(Sender: TObject);
var F: File; FBuf, Buf: Pointer; n,m,BigSize,FSize, Size,Pos: Integer;
BB: ^Byte; DW: ^DWord; fCompr: Boolean; StopDWord: DWord;
begin
  If cClearLog.Checked Then List7.Clear;
  StopDWord:=$F2F2F2F2;
  AssignFile(F,File5.Text);
  Reset(F,1);
  FSize:=FileSize(F);
  Seek(F,0);
  GetMem(Buf, $20000);
  GetMem(FBuf,FileSize(F));
  BlockRead(F,FBuf^,FileSize(F));

  for n:=0 to length(B)-1 do
  begin
    PBar.Position:=n;
    Size:=0;
    BB:=Addr(Buf^);
    for m:=0 to length(IDx[n].A)-1 do
    begin
      CopyMem(B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Buffer, Pointer(BB),
      B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Size);
      Inc(Size, B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Size);
      Inc(BB,B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Size);
    end;
    fCompr:=False;
    For m:=0 To Length(B[n].Adress)-1 do
    begin
      BB:=Addr(FBuf^);
      Inc(BB,B[n].Adress[m]);
      DW:=Addr(BB^);
      BigSize:=0;
      Pos:=B[n].Adress[m];
      While (DW^<>StopDWord) and (Pos < FSize) do
      begin
        Inc(BigSize); Inc(BB); DW:=Addr(BB^); Inc(Pos);
      end;
      fCompr:=False;
      If cCompress.Checked Then
      begin
        If (not fCompr) and (cBigOnly.Checked and (Size>BigSize)) or (not cBigOnly.Checked) then
        begin
          Size:=Compress(Buf, Size);
          fCompr:=True;
        end;
      end;

      BB:=Addr(FBuf^);
      Inc(BB,B[n].Adress[m]-1);
      If (Size<=BigSize) or cIgnoreErrors.Checked then
      begin
        CopyMem(Buf, Pointer(BB), Size);
      end else
      begin
        List7.Items.Add(format
('[%s] Ошибка! Не хватает места. Блок [%d], адрес #[%d/%d], ф.адрес[%s], не хватает %d байт. Сжатие: %s',
        [TimeToStr(GetTime),n+1,m+1,length(B[n].Adress),IntToHEx(B[n].Adress[m],8),Size-BigSize,fBoolToStr(fCompr)]));
      end;
    end;
  end;
  Seek(F,0);
  BlockWrite(F, FBuf^, FSize);
  PBar.Position:=0;
  FreeMem(Buf);
  FreeMem(FBuf);
  CloseFile(F);
end;


{procedure TForm2.Button3Click(Sender: TObject);
var F: File; n,m,l,r,BSize,FSize,ed,SizeFile:integer;
IPos: Array[0..3] of ^Byte; BPos: ^Byte; flg: Boolean; BB: ^Byte;
Buf: Pointer; ComprFlag: Boolean;
begin
cCompress.Enabled:=False;
cIgnoreErrors.Enabled:=False;
Button3.Enabled:=False;
AssignFile(F,File5.Text);
Reset(F,1);
Seek(F,0);
GetMem(Buf, $20000);
GetMem(FBuffer,FileSize(F));
//ShowMessage(IntToHex(FileSize(F),8));
//ShowMessage(IntToHex(SizeOf(FBuffer),8));
SizeFile:=FileSize(F);
BlockRead(F,FBuffer^,FileSize(F));
FPos:=Addr(FBuffer^);
CloseFile(F);

for n:=0 to length(B)-1 do
begin
  BSize:=0;
  FSize:=0;
  PBar.Position:=n;
  BB:=Addr(Buf^);
  for m:=0 to length(IDx[n].A)-1 do
  begin
    If cCompress.Checked Then
    begin
      CopyMem(B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Buffer, Pointer(BB),
      B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Size);
      Inc(BB, B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Size);
    end;
    inc(BSize,B[IDx[n].A[m].Block].R[IDx[n].A[m].Dialog].Size);
  end;
  for m:=0 to length(B[n].Adress)-1 do
  begin
    For r:=0 to 3 do
    begin
      IPos[r]:=Addr(FBuffer^);
      Inc(IPos[r],B[n].Adress[m]+r);
    end;
    //FPos:=Addr(FBuffer^);
    //Inc(FPos,B[n].Adress[m]);
    FSize:=0;

    While ((IPos[0]^<>$f2) and (IPos[1]^<>$f2) and (IPos[2]^<>$f2) and (IPos[3]^<>$f2))  and (FSize < BSize) do
    begin
      For r:=0 to 3 do
      begin
        Inc(IPos[r]);
      end;
      Inc(FSize);
    end;
    If cCompress.Checked Then
    begin
      ComprFlag:=True;
      If cBigOnly.Checked then
      begin
        If FSize>=BSize then BSize:=Compress(Buf, BSize) else ComprFlag:=False;
      end else
        BSize:=Compress(Buf, BSize);
    end;
    If (FSize>=BSize) or cIgnoreErrors.Checked then
    begin
        FPos:=Addr(FBuffer^);
        Inc(FPos,B[n].Adress[m]);
        //ShowMessage(IntToHex(Integer(FPos),8));
        Inc(FPos,-1);
        //ShowMessage(IntToHex(Integer(FPos),8));
      for l:=0 to length(IDx[n].A)-1 do
      begin
        BPos:=Addr(B[IDx[n].A[l].Block].R[IDx[n].A[l].Dialog].Buffer^);
        //Inc(BPos);

        ///


        ///
        If cCompress.Checked Then
        begin
          If not ComprFlag then
          begin
            for r:=0 To B[IDx[n].A[l].Block].R[IDx[n].A[l].Dialog].Size-1 do
            begin
              FPos^:=BPos^;
              Inc(FPos);
              Inc(BPos);
            end;
          end else
          begin
            CopyMem(Buf, Pointer(FPos), BSize);
            Inc(FPos, BSize);
            Inc(BPos, BSize);
            break;
          end;
        end;
      flg:=False;
      end;
    end else
    begin
      List7.Items.Add(format('Ошибка! Не хватает места. Блок [%d], адрес #[%d/%d], ф.адрес[%s], не хватает %d байт',
      [n+1,m+1,length(B[n].Adress),IntToHEx(B[n].Adress[m],8),BSize-FSize]));
    end;
  end;
end;
AssignFile(F, file5.Text);
Rewrite(F,1);
BlockWrite(F,FBuffer^,SizeFile);
CloseFile(F);
PBar.Position:=0;
FreeMem(FBuffer);
FreeMem(Buf);
end;//!!!    }

procedure TForm2.Button5Click(Sender: TObject);
begin
ODialog.Title:='Открытие оптимизированного скрипта FFT';
ODialog.Filter:='Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
If ODialog.Execute then
begin
  File1.Text:=ODialog.FileName;
end;
end;

procedure TForm2.Button6Click(Sender: TObject);
begin
ODialog.Title:='Открытие файла адресов';
ODialog.Filter:='Файлы адресов (*.adr)|*.adr|Все файлы (*.*)|*';
If ODialog.Execute then
begin
  File2.Text:=ODialog.FileName;
end;
end;

procedure TForm2.Button7Click(Sender: TObject);
begin
ODialog.Title:='Открытие файла индексов';
ODialog.Filter:='Файлы индексов (*.fid)|*.fid|Все файлы (*.*)|*';
If ODialog.Execute then
begin
  File3.Text:=ODialog.FileName;
end;
end;

procedure TForm2.Button8Click(Sender: TObject);
begin
ODialog.Title:='Открытие таблицы';
ODialog.Filter:='Файлы таблиц (*.tbl)|*.tbl|Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*';
If ODialog.Execute then
begin
  File4.Text:=ODialog.FileName;
end;
end;

procedure TForm2.Button9Click(Sender: TObject);
begin
ODialog.Title:='Открытие файла диалогов FFT';
ODialog.Filter:='TEST.EVT|TEST.EVT|Файлы evt (*.evt)|*.evt|Все файлы (*.*)|*';
If ODialog.Execute then
begin
  File5.Text:=ODialog.FileName;
end;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
form1.Show;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
var n,m: integer;
begin
for n:=0 to length(B)-1 do
begin
  for m:=0 to Length(B[n].R)-1 do
  begin
    If assigned(B[n].R[m].Buffer) then FreeMem(B[n].R[m].Buffer);
  end;
end;
end;//!!!

procedure TForm2.cIgnoreErrorsClick(Sender: TObject);
var s: boolean;
begin
  //ShowMessage(BoolToStr(cIgnoreErrors.Checked));
  //S:=cIgnoreErrors.Checked;
  //cIgnoreErrors.Checked:=S;
end;

procedure TForm2.cCompressClick(Sender: TObject);
begin
  If cCompress.Checked Then cBigOnly.Enabled:=True
  else cBigOnly.Enabled:=False;
end;

end.
