program Project2;

{$APPTYPE CONSOLE}

uses
  SysUtils, StrUtils;

Var HexError: Boolean;
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

var Table: Array[0..255] of String[1];
F, F2: TextFile; S, S2: String; n: integer; B, B1: ^byte; Bt: Byte; MS: String[1];
begin
  AssignFile(F, 'TABLE.TBL');
  Reset(F);
  While not EOF(F) do
  begin
    ReadLn(F,S);
    B:=Addr(Bt);
    B1:=Addr(MS[1]);
    MS:='A';
    If (Length(S)=4) and (S[3]='=') then
    begin
      Bt:=HexToInt(S[1]+S[2]);
      B1^:=B^;
      Table[byte(S[4])]:=MS;
    end else
    If (Length(S)=6) and (S[5]='=') Then
    begin
      Bt:=HexToInt(S[1]+S[2]);
      B1^:=B^;
      Table[byte(S[4])]:=MS;
    end;
  end;
  CloseFile(F);
  AssignFile(F, 'STR_RUS.TXT');
  AssignFile(F2, 'STR_EN.TXT');
  Reset(F);
  Rewrite(F2);
  While not EOF(F) do
  begin
    ReadLn(F,S);
    S2:='';
    For n:=1 to length(S) do
    begin
      If Table[Byte(S[n])]='' then S2:=S2+S[n] else S2:=S2+Table[Byte(S[n])];
    end;
    WriteLn(F2,S2);
  end;
  CloseFile(F);
  CloseFile(F2);
  { TODO -oUser -cConsole Main : Insert code here }
end.
