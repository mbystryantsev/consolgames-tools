unit TextOpt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, FFT;

type

TRead=Packed Record
  Read: Boolean;
  RMsg, RDlg: Word;
end;
TReadArray = Array of TRead;

TMsg = Packed Record
  Count: Word;
  Name: String;
  R: TReadArray;
  Text: Array of String;
end;

TMsgArray = Array of TMsg;

  TForm1 = class(TForm)
    ListMsg: TListBox;
    ListDlg: TListBox;
    Memo: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    Procedure LoadText(Sender: TObject; S: String; var mMsg: TMsgArray);
    Procedure LoadOptText(Sender: TObject; S: String; var mMsg: TMsgArray);
    procedure ListMsgClick(Sender: TObject);
    procedure ListDlgClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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

var Msg: TMsgArray;

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

Procedure SaveOptTxt(var mMsg: TMsgArray; const S: String);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(mMsg)-1 do
  begin
    List.Add('['+mMsg[n].Name+']');
    List.Add('');
    For m:=0 To Length(mMsg[n].R)-1 do
    begin
      If not mMsg[n].R[m].Read then
      begin
        List.Add(mMsg[n].Text[m]);
        List.Add('');
      end;
    end;
  end;
  List.SaveToFile(S);
end;


Procedure SaveOpt(var mMsg: TMsgArray; const S: String);
var List: TStringList; n,m: Integer;
begin
  List:=TStringList.Create;
  For n:=0 To Length(mMsg)-1 do
  begin
    List.Add('['+mMsg[n].Name+']');
    For m:=0 To Length(mMsg[n].R)-1 do
    begin
      If mMsg[n].R[m].Read=False Then List.Add('Read')
      else List.Add(IntToHex(mMsg[n].R[m].RMsg,4)+' '+IntToHex(mMsg[n].R[m].RDlg,4));
    end;
    List.Add('');
  end;
  List.SaveToFile(S);
  List.Free;
end;

Procedure OptTxt(var mMsg: TMsgArray);
var n,m,l,r: Integer;
Label Brk;
begin
  For n:=0 To Length(mMsg)-1 do
  begin
    Form1.Caption:=IntToStr(n+1)+'/'+IntToStr(Length(mMsg))+' -';
    SetLength(mMsg[n].R, Length(mMsg[n].Text));
    For m:=0 To Length(mMsg[n].Text)-1 do
    begin
      For l:=0 To n do
      For r:=0 To Length(mMsg[l].Text)-1 do
      begin
        If (l=n) and (r>=m) Then Break;
        If mMsg[n].Text[m]=mMsg[l].Text[r] Then
        begin
          mMsg[n].R[m].Read:=True;
          mMsg[n].R[m].RMsg:=l;
          mMsg[n].R[m].RDlg:=r;
          GoTo Brk;
        end;
      end;
      Brk:
    end;
    Form1.Caption:=IntToStr(n+1)+'/'+IntToStr(Length(mMsg))+' +';
  end;

end;



Procedure LoadFid(S: String; var mMsg: TMsgArray);
var n,m: Integer; List: TStringList; Flag: Boolean; //Str: String;
begin
  List:=TStringList.Create;
  List.LoadFromFile(S);
  For n:=0 To List.Count-1 do
  begin
    If (LeftStr(List.Strings[n],1)='[') and (RightStr(List.Strings[n],1)=']') then
    begin
      Flag:=False;
      SetLength(mMsg, Length(mMsg)+1);
      mMsg[Length(mMsg)-1].Name:=MidStr(List.Strings[n],2,Length(List.Strings[n])-2);
      //ListMsg.Items.Add(mMsg[Length(mMsg)-1].Name);
    end else
    begin
      If List.Strings[n]<>'' Then
      begin
        SetLength(mMsg[Length(mMsg)-1].R,Length(mMsg[Length(mMsg)-1].R)+1);
        If List.Strings[n]<>'Read' Then
        begin
          mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].Read:=True;
          mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].RMsg :=
          HexToInt(LeftStr(List.Strings[n],4));
          mMsg[Length(mMsg)-1].R[Length(mMsg[Length(mMsg)-1].R)-1].RDlg :=
          HexToInt(RightStr(List.Strings[n],4));;
        end;
      end;
    end;
  end;
  List.Free;
  For n:=0 To Length(mMsg)-1 do
  begin
    SetLength(mMsg[n].Text,Length(mMsg[n].R));
  end;
end;

Procedure TForm1.LoadOptText(Sender: TObject; S: String; var mMsg: TMsgArray);
var n,m,l,r: Integer; List: TStringList; Flag: Boolean; Str: String;
begin
  List:=TStringList.Create;
  List.LoadFromFile(S);
  m:=-1;
  l:=m;
  For n:=0 To List.Count-1 do
  begin
    If (LeftStr(List.Strings[n],1)='[') and (RightStr(List.Strings[n],1)=']') then
    begin
      Flag:=False;
      //SetLength(mMsg, Length(mMsg)+1);
      Inc(m);
      mMsg[m].Name:=MidStr(List.Strings[n],2,Length(List.Strings[n])-2);
      ListMsg.Items.Add(mMsg[Length(mMsg)-1].Name);
    end else
    begin
      If not Flag and {(RightStr(List.Strings[n],1)<>'\')}(List.Strings[n]<>'') Then begin
        Flag:=True;
        For r:=l+1 to Length(Msg[m].R)-1 do
        begin
          If Msg[m].R[r].Read Then
          begin
            l:=r;
            Break;
          end;
        end;
        //inc(l);
        //SetLength(mMsg[Length(mMsg)-1].Text,Length(mMsg[Length(mMsg)-1].Text)+1);
      end;
      If Flag Then
      begin
        If mMsg[m].Text[l]<>'' Then
        Str:=#13#10 Else Str:='';
        mMsg[m].Text[l]:=
        mMsg[m].Text[l]+Str+List.Strings[n];
      end;
      If (Flag=True) and (RightStr(List.Strings[n],1)='\'{List.Strings[n]=''}) then Flag:=False;
    end;
  end;
  List.Free;
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
      mMsg[Length(mMsg)-1].Name:=MidStr(List.Strings[n],2,Length(List.Strings[n])-2);
      ListMsg.Items.Add(mMsg[Length(mMsg)-1].Name);
    end else
    begin
      If not Flag and {(RightStr(List.Strings[n],1)<>'\')}(List.Strings[n]<>'') Then begin
        Flag:=True;
        SetLength(mMsg[Length(mMsg)-1].Text,Length(mMsg[Length(mMsg)-1].Text)+1);
      end;
      If Flag Then
      begin
        If mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]<>'' Then
        Str:=#13#10 Else Str:='';
        mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]:=
        mMsg[Length(mMsg)-1].Text[Length(mMsg[Length(mMsg)-1].Text)-1]+Str+List.Strings[n];
      end;
      If (Flag=True) and (RightStr(List.Strings[n],1)='\'{List.Strings[n]=''}) then Flag:=False;
    end;
  end;
  List.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  LoadText(Sender, 'FFT\TEXT\FFTTest.txt', Msg);
end;

procedure TForm1.ListMsgClick(Sender: TObject);
var n: Integer;
begin
  ListDlg.Clear;
  For n:=0 To Length(Msg[ListMsg.ItemIndex].Text)-1 do
  begin
    ListDlg.Items.Add(Msg[ListMsg.ItemIndex].Text[n]);
  end;
end;

procedure TForm1.ListDlgClick(Sender: TObject);
begin
  Memo.Text:=Msg[ListMsg.ItemIndex].Text[ListDlg.ItemIndex];
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  OptTxt(Msg);
  SaveOpt(Msg,'FFT\TEXT\FFTTest.fid');
  SaveOptTxT(Msg,'FFT\TEXT\FFTTest.opt.txt');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  LoadFid('FFT\TEXT\FFTTest.fid', Msg);
  LoadOptText(Sender, 'FFT\TEXT\FFTTest.opt.txt', Msg);
end;

end.
