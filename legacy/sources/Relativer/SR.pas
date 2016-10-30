unit SR;

interface

uses Windows;

Type
  TRFind = Array of Byte;

var
  pCancel: Boolean = False;

Function RFind(Buf: Pointer; S: TRFind; Pos,Size,Step: Integer): Integer;
implementation

Function RemoveStars(S: String): String;
begin
  Result:=S;
  If (S[1]<>'*') and (S[Length(S)]<>'*') Then Exit;
end;

Function RFind(Buf: Pointer; S: TRFind; Pos,Size,Step: Integer): Integer;
var n,m,st: Integer; Flags: Array of Boolean;
Min,Bs: Byte; B: ^Byte; Yes: Boolean;
begin
  Yes:=False;
  Min:=High(Byte);
  SetLength(Flags,Length(S));
  FillChar(Flags[0],Length(S),0);
  For n:=0 To High(S) do
  begin
    If Min>S[n] Then Min:=S[n];
    If S[n]=Byte('*') Then Flags[n]:=True;
  end;
  For n:=0 To High(S) do Dec(S[n],Min);
  If Step<=0 Then Step:=Length(S);

  //--
  For m:=0 To ((Size-Length(S)) div Step) do
  begin
    B:=Pointer(DWord(Buf)+Pos+(m*Step));
    For n:=0 To High(S) do
    begin
      If n=0 Then st:=B^-S[0] else
      begin
        If not Flags[n] and (B^-S[n]<>St) Then Break;
        If n=High(S) Then
        begin
          Yes:=True;
          Result:=Pos+(m*Step);
          break;
        end;
      end;
      Inc(B);
    end;
    If Yes Then Break;
  end;
  //--
  If not Yes Then Result:=-1;
end;

end.
