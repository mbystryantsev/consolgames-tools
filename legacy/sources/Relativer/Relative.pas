unit Relative;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SR, Grids, ValEdit, ComCtrls, XPMan;

type
  TForm1 = class(TForm)
    OpenDialog: TOpenDialog;
    Button2: TButton;
    Values: TValueListEditor;
    Button3: TButton;
    Results: TMemo;
    Progress: TProgressBar;
    Button4: TButton;
    Status: TStatusBar;
    XPManifest1: TXPManifest;
    ClearLogB: TButton;
    procedure ClearLogBClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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

Function RoundBy(Value, R: Integer): Integer;
begin
 Result := Value;
 If Result mod R > 0 then Result := (Result div R) * R + R;
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

procedure TForm1.ClearLogBClick(Sender: TObject);
//var Buf: Pointer; Size: Integer; S: TRFind;
begin
  Results.Clear;
 { SetLength(S,4);
  S[0]:=Byte('g'); S[1]:=Byte('*'); S[2]:=Byte('o'); S[3]:=Byte('u');
  Size:=LoadFile('_SHADOW\Test',Buf);
  ShowMessage(Format('%.8x',[RFind(Buf,S,0,Size,1)])); }
end;

procedure TForm1.Button2Click(Sender: TObject);
var FilePath,Str: String; Step,BSize,n: Integer; S: TRFind;
F: File; Buf: Pointer; sSize,Size,tSize,hPos: DWord; Pos, fSize, fPos, nSize: Int64;
Stream: TFileStream;
begin


  pCancel   :=  False;

  FilePath  :=  Values.Values['FilePath'];
  Str       :=  Values.Values['String'];
  hPos       :=  HexToInt(Values.Values['Position']);  Pos:=hPos;
  Size      :=  StrToInt(Values.Values['Size']);
  Step      :=  StrToInt(Values.Values['Step']);
  BSize     :=  1024*1024*StrToInt(Values.Values['BlockSize']);

  //FileMode:=fmOpenRead;
  //AssignFile(F,FilePath);
  //Reset(F,1);
  If not FileExists(FilePath) Then
  begin
    ShowMessage('File not exists!');
    Exit;
  end;
  Try
    Stream:=TFileStream.Create(FilePath,fmOpenRead);
  except
    ShowMessage('Cannot open file!');
    Stream.Free;
    Exit;
  end;

  sSize:=Length(Str)-1;

  If Step<=0 Then Step:=Length(Str);

  SetLength(S,Length(Str));
  For n:=1 To Length(Str) do
    S[n-1]:=Byte(Str[n]);

  GetMem(Buf,BSize+sSize);

  If Size<=0 Then Size:=Stream.Size-Pos; //FileSize(F);

  Stream.Seek(hPos,soBeginning);
  //Seek(F,hPos);
  nSize:=Size;
  tSize:=RoundBy(Size,BSize);

  Progress.Min:=0;
  Progress.Max:=(tSize div BSize)-1;

  For n:=0 To (tSize div BSize)-1 do
  begin
    If pCancel Then Break;
    Progress.Position:=n;
    Status.Panels[0].Text:=Format('%.8x/%.8x',[Pos+n*BSize,Stream.Size{Size}]);
    Application.ProcessMessages;
    If nSize<BSize Then fSize:=nSize+sSize else fSize:=BSize+sSize;
    Dec(nSize,BSize);
    //Seek(F,Pos+n*BSize);
    //BlockRead(F,Buf^,fSize);
    Stream.Seek(Pos+n*BSize,soBeginning);
    Stream.ReadBuffer(Buf^,fSize);

    fPos:=0;
    While fPos<>-1 do
    begin
      fPos:=RFind(Buf,S,fPos,fSize-fPos{+Length(Str)-1},Step);
      If fPos<>-1 Then
      begin
        Results.Lines.Add(Format('%.8x',[n*BSize+fPos+Pos]));
        Inc(fPos,Step);
      end;
    end;
  end;

  FreeMem(Buf);
  //CloseFile(F);
  Stream.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  pCancel:=True;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  If not OpenDialog.Execute Then Exit;
  Values.Values['FilePath']:=OpenDialog.FileName;
end;

end.
