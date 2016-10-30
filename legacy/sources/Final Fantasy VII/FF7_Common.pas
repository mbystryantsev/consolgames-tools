unit FF7_Common;

interface
uses ZlibEx, SysUtils, DIB, FF7_Compression, Windows, StrUtils, Errors;

Type
  TTable = Packed Record
    Text: String;
    Value: Word;
    D: Boolean;
  end;
  TTableArray = Array of TTable;

  TMessage = Packed Record
    Text: String;
    Retry: Boolean;
    RName: String;
    RID:  Word;
  end;

  TMsg = Packed Record
    Name: String;
    S: Array of TMessage;
  end;
  TText = Array of TMsg;

  TFName = Array[0..23] of Char;
  TFScript = Packed Record
    Name: TFName;
    Pos:  DWord;
    Size: DWord;
  end;

  TLoadedField = Packed Record
    Name: String;
    Pos:  Pointer;
    Size: Integer;
  end;

  TLField = Array of TLoadedField;

  TZipHeader = Packed Record
    ASize: Word;
    FSize: Integer;
  end;
  TListFile = Record
    P: Pointer;
    Size: Integer;
  end;
  TListFileArray = Array of TListFile;

  TFileList = Class
    Private
    Public
      Files: TListFileArray;
      Procedure Load(Name: String; ID: Integer);
      Procedure Save(Name: String; ID: Integer);
      Procedure AddFromBuf(P: Pointer; Size: Integer);
  end;


    TSetPath = Record
    FieldIn,FieldOut,Table,FontTim,FontDat,
    Project, Text, OrText, Opt, Scripts: String;
  end;
  TSettings = Record
    Path: TSetPath;
    Opened: Boolean;
    Alpha: Byte;
    HideRetry: Boolean;
    FieldSize: Integer;
    ViewOrText: Boolean;
    DatBuilding: Boolean;
  end;
    TSettingNames = Record
    Path: TSetPath;
    Alpha: String;
    HideRetry: String;
  end;
  TBoolArr = Array of Boolean;
  TErrorType = (etNone, etError, etWarning, etHint);
  TFFMode    = (ffNone, ff7, ff8, ffT);

const
  SettingNames: TSettingNames = (Path:
   (FieldIn: 'FieldIn'; FieldOut: 'FieldOut'; Table: 'Table'; FontTim: 'FontTim';
    FontDat: 'FontDat'; Project: 'ProjectName'; Text: 'Text'; OrText: 'OrText';
    Opt: 'Opt'; Scripts: 'Scripts');
    Alpha: 'Alpha'; HideRetry: 'HideRetry');
    Type TChars = Set of Char;


var
  Settings: TSettings;
  BBuf: Pointer;
  FBuf: Pointer;
  DBuf: Pointer;
  TBuf: Pointer;
  CancelPressed: Boolean = False;
  level: Word = $FFF;
  LZNull: Boolean = False;
  ffMode: TFFMode = ff7;

Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
Function  LoadFile(Name: String; var Pos: Pointer): Integer;
Function  ZLibDecompress(Buf: Pointer): Integer;
Procedure DibToRaw(var Pic: TDIB; Buf: Pointer);
Procedure RawToDib(var Pic: TDIB; Buf: Pointer);
Function  GetPart(S: String; C: Char; Num: Integer): String;
Function  GetPart2(S: String; C: Char; Num: Integer): String;
Function  HexToInt(S: String): Integer;
Procedure ResizeMem(var Buf: Pointer; OldSize,NewSize: Integer);
Function  RoundBy(Value, R: Integer): Integer;
Function  GetFileParentDir(S: String): String;
Procedure GetTextNM(var n,m: Integer; Text: TText);
Procedure CreateDib(var Pic: TDIB; W,H: Integer);
Procedure PicToDib(Buf: Pointer; Pic: TDib);
Procedure BGR2RGB(Buf: Pointer; Size: Integer);
Procedure DibToPic(Buf: Pointer; Pic: TDib);
Function  AdvGetPart(S: String; Chars: TChars; Num: Integer; b: Integer=0; e: Integer=0): String;
Function  PartCount(S: String; Chars: TChars): Integer;
Function  RemS(S: String): String;
Function  GetVal(S: String): Integer;
Procedure CreateError(S: String; Error: TErrorType = etError);
implementation

uses
  FF7_Text;

Procedure CreateError(S: String; Error: TErrorType = etError);
const cET: Array[TErrorType] of String = ('','[Error] ','[Warning] ','[Hint] ');
begin
  ErrorForm.AddString(Format('%s%s',[cET[Error],S]));
end;

Function AdvGetPart(S: String; Chars: TChars; Num: Integer; b: Integer=0; e: Integer=0): String;
var n: Integer;
begin
  Result:='';
  If n=0 Then b:=1; If e=0 Then e:=Length(S);
  For n:=b to e do
  begin 
    If S[n] in Chars Then Dec(Num);
    If Num<=0 Then Exit else If (Num=1) and not (S[n] in Chars) Then Result:=Result+S[n];
  end;
end;

Function RemS(S: String): String;
var b,e,Len: Integer;
const Chars: TChars = [#9,' '];
begin
  Len:=Length(S);
  Result:=''; If S='' Then Exit;
  For b:=1 To Len do If not (S[b] in Chars) Then Break;
  For e:=Len DownTo b do If not (S[e] in Chars) Then Break;
  If (b>Len) or (e<=0) or (e<b) Then Exit;
  Result:=MidStr(S,b,e-b+1);
end;

Function PartCount(S: String; Chars: TChars): Integer;
var n: Integer;
begin
  If S='' Then Result:=0 else Result:=1;
  For n:=1 To Length(S) do If S[n] in Chars Then Inc(Result);
end;

Procedure CreateDib(var Pic: TDIB; W,H: Integer);
begin
  Pic:=TDIB.Create;
  Pic.PixelFormat:=MakeDibPixelFormat(5, 5, 5);
  Pic.BitCount:=16;
  Pic.Width:=W;
  Pic.Height:=H;
end;

Procedure BGR2RGB(Buf: Pointer; Size: Integer);
var n: Integer; W: ^Word;
begin
  W:=Buf;
  For n:=0 To Size-1 do
  begin
    W^:=((W^ SHR 10) and $3E) or ((W^ SHL 10) AND $F800) or (W^ AND $7C0);
    Inc(W);
  end;
end;

Procedure PicToDib(Buf: Pointer; Pic: TDib);
var n: Integer; B: ^Byte;
begin
  BGR2RGB(Buf,Pic.Width*Pic.Height);
  B:=Buf;
  For n:=0 to Pic.Height-1 do
  begin
    Move(B^,Pic.ScanLine[n]^,Pic.WidthBytes);
    Inc(B,Pic.WidthBytes);
  end;
end;

Procedure DibToPic(Buf: Pointer; Pic: TDib);
var n: Integer; B: ^Byte;
begin
  B:=Buf;
  For n:=0 to Pic.Height-1 do
  begin
    Move(Pic.ScanLine[n]^,B^,Pic.WidthBytes);
    Inc(B,Pic.WidthBytes);
  end;
  BGR2RGB(Buf,Pic.Width*Pic.Height);
end;

Procedure GetTextNM(var n,m: Integer; Text: TText);
var l: Integer;
begin
  If MText[n].S[m].Retry Then
  begin
    l:=MText[n].S[m].RID;
    n:=FindMessage(MText[n].S[m].RName, Text);
    m:=l;
  end;
end;

Function GetFileParentDir(S: String): String;
var n: Integer; Flag: Boolean;
begin
  Result:='';  Flag:=False;
  For n:=Length(S) downto 1 do
  begin
    If Flag Then
    begin
      If S[n]='\' Then break;
      Result:=S[n]+Result;
    end
    else if S[n]='\' Then Flag:=True;
  end;
end;

Procedure TFileList.Save(Name: String; ID: Integer);
begin
  If (ID>0) and (ID<=High(Files)) Then SaveFile(Name,Files[ID].P, Files[ID].Size);
end;

Procedure TFileList.Load(Name: String; ID: Integer);
begin
  If (ID>0) and (ID<=High(Files)) Then LoadFile(Name,Files[ID].P);
end;

Procedure TFileList.AddFromBuf(P: Pointer; Size: Integer);
begin
  SetLength(Files, Length(Files)+1);
  Files[High(Files)].P:=P;
  Files[High(Files)].Size:=Size;
end;

Procedure ResizeMem(var Buf: Pointer; OldSize,NewSize: Integer);
var WBuf: Pointer;
begin
  GetMem(WBuf,OldSize);
  Move(Buf^,WBuf^,OldSize);
  ReallocMem(Buf,NewSize);
  If OldSize>NewSize Then OldSize:=NewSize;
  Move(WBuf^,Buf^,OldSize);
  FreeMem(WBuf);
end;


Function ZLibDecompress(Buf: Pointer): Integer;
var OutSize: Integer; WBuf: Pointer; FileSize: ^Integer; W,Size: ^Word;
begin
  FileSize:=Buf; Inc(Integer(FileSize),2);
  Size:=Buf; W:=Buf; Inc(W,7); W^:=$9C78;
  Result:=FileSize^;
  GetMem(WBuf,FileSize^);
  //SaveFile('_FF7\_LZ\Test\1.pk',Pointer(Integer(Buf)+14),Size^-8);
  ZDecompress(Pointer(Integer(Buf)+14), Size^-8, WBuf, OutSize{, FileSize^});
  FreeMem(Buf);
  Buf:=WBuf;
end;

Function ZLibCompress(var Buf: Pointer; Size: Integer): Integer;
var WBuf,B: Pointer;
begin
  GetMem(WBuf, Size);;
  ZCompress(Buf, Size, WBuf, Result);
  FreeMem(Buf);
  Buf:=WBuf;
  //Inc(Result,4);
end;


Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
end;
Procedure SaveFile(Name: String; Pos: Pointer; Size: Integer);
var F: File;
begin
  FileMode := fmOpenWrite;
  AssignFile(F,Name);
  Rewrite(F,1);
  BlockWrite(F, Pos^, Size);
  CloseFile(F);
  FileMode := fmOpenReadWrite;
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

Procedure RawToDib(var Pic: TDIB; Buf: Pointer);
var B, WB: ^Byte; n,m: Integer;
begin
  B:=Addr(Buf^);
  For m:=0 To Pic.Height-1 do
  begin
    WB:=Addr(Pic.ScanLine[m]^);
    If Pic.BitCount=4 then
    begin
      For n:=0 To (Pic.Width div 2)-1 do
      begin
        WB^:=((B^ SHR 4) AND $0F) + ((B^ SHL 4) AND $F0);
        Inc(B); Inc(WB);
      end;
    end else
    begin
      For n:=0 To (Pic.Width div 2)-1 do
      begin
        WB^:=B^; Inc(WB); Inc(B);
      end;
    end;
  end;
end;

Procedure DibToRaw(var Pic: TDIB; Buf: Pointer);
var B, WB: ^Byte; n,m: Integer;
begin
  WB:=Addr(Buf^);
  For m:=0 To Pic.Height-1 do
  begin
    B:=Addr(Pic.ScanLine[m]^);
    If Pic.BitCount=4 then
    begin
      For n:=0 To (Pic.WidthBytes div 2)-1 do
      begin
        WB^:=((B^ SHR 4) AND $0F) + ((B^ SHL 4) AND $F0);
        Inc(B); Inc(WB);
      end;
    end else
    begin
      For n:=0 To (Pic.WidthBytes div 2)-1 do
      begin
        WB^:=B^;
        Inc(B); Inc(WB);
      end;
    end;
  end;
end;

Function HexToInt(S: String): Integer;
Var
 I, LS, J: Integer; PS: ^Char; H: Char;
begin
 Result := 0;
 LS := Length(S);
 If (LS <= 0) or (LS > 8) then Exit;
 PS := Addr(S[1]);
 I := LS - 1;
 J := 0;
 While I >= 0 do
 begin
  H := UpCase(PS^);
  If H in ['0'..'9'] then J := Byte(H) - 48 Else
  If H in ['A'..'F'] then J := Byte(H) - 55 Else
  begin
   Result := 0;
   Exit;
  end;
  Inc(Result, J shl (I shl 2));
  Inc(PS);
  Dec(I);
 end;
end;

Function GetPart(S: String; C: Char; Num: Integer): String;
var n,m: Integer;
begin
  m:=1;
  Result:='';
  For n:=3 to Length(S)-1 do
  begin
    If (Num=m) and (S[n]=C) Then Inc(m);
    If Num=m then
    Result:=Result+S[n];
    If (Num<>m) and (S[n]=C) Then Inc(m);
  end;
end;

Function GetPart2(S: String; C: Char; Num: Integer): String;
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

Function GetVal(S: String): Integer;
begin
  If S='' Then
  begin
    Result:=0;
    Exit;
  end;
  If S[1]='$' Then Result:=HexToInt(AdvGetPart(S,['$'],2))
  else Result:=StrToInt(S);
end;

end.
 