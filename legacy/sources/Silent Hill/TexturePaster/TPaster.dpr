program TPaster;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes;


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

var F,TF: File; List: TStringList; n,Pos,Size: Integer;
S,Name: String; Buf: Pointer; NF: Boolean; Val,Len: Integer; Flag: Boolean;
begin
  List:=TStringList.Create;
  List.LoadFromFile('list.txt');
  NF:=False;
  AssignFile(F, List.Strings[0]);
  Reset(F,1);
  For n:=1 To List.Count-1 do
  begin
    If (Length(List.Strings[n])>9) and (List.Strings[n][1]<>'/') Then
    begin
      S:=List.Strings[n];
      If S[9]='>' Then Flag:=True else Flag:=False;
      S[9]:=' ';
      Pos:=HexToInt(GetPart(S,' ',1));
      If Flag Then
      begin
        S:=GetPart(S,' ',2);
        Len:=Length(S) div 2;
        If Len in [1,2,4] Then
        begin
          Val:=HexToInt(S);
          Seek(F,Pos);
          BlockWrite(F,Val,Len);
        end;
      end else
      begin
        Name:=GetPart(S,' ',2);
        If not FileExists(Name) Then
        begin
          WriteLn('File '+Name+' not found!');
          NF:=True;
        end else
        begin
          AssignFile(TF,Name);
          Reset(TF,1);
          Size:=FileSize(TF);
          GetMem(Buf, Size);
          BlockRead(TF, Buf^, Size);
          CloseFile(TF);
          Seek(F, Pos);
          BlockWrite(F, Buf^, Size);
          FreeMem(Buf);
        end;
      end;
    end;
  end;
  If NF Then ReadLn;
end.
